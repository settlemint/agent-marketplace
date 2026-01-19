#!/usr/bin/env bash
# Stop hook: BLOCK if code changes made without documented review passes
# Enforces Rule of Five at session end
#
# Checks for:
# - Edit/Write tool usage on code files (code change indicator)
# - "Pass 1", "Pass 2", etc. in assistant messages (review pass documentation)
# - BLOCKS if fewer than 3 passes documented for code-change sessions
#
# Override: Include "[REVIEW-BYPASS]" in message (audited to /tmp/claude-audit/)
# Allow-list: Docs-only changes (no .ts/.tsx/.js/.jsx files) are allowed

set +e

SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="review-enforcer"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read hook input from stdin
HOOK_INPUT=$(cat)

# Parse hook input
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // ""' 2>/dev/null || echo "")
AGENT_TYPE=$(echo "$HOOK_INPUT" | jq -r '.agent_type // "main"' 2>/dev/null || echo "main")

# Skip for subagents - they report to parent
if [[ "$AGENT_TYPE" != "main" ]]; then
  log_info "event=SKIP" "reason=subagent"
  exit 0
fi

# No transcript - nothing to check
if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
  log_info "event=SKIP" "reason=no_transcript"
  exit 0
fi

# --- Check for bypass marker ---
HAS_BYPASS=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "text") | .text // ""] |
  join(" ") |
  test("\\[REVIEW-BYPASS\\]")
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "false")

if [[ "$HAS_BYPASS" == "true" ]]; then
  log_warn "event=REVIEW_BYPASS"
  # Audit bypass
  AUDIT_DIR="/tmp/claude-audit"
  mkdir -p "$AUDIT_DIR" 2>/dev/null || true
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] REVIEW-BYPASS used" >>"$AUDIT_DIR/review-bypass.log" 2>/dev/null || true
  exit 0
fi

# --- Check for code changes (Edit/Write tool usage on CODE files) ---
# Only count changes to code files (.ts, .tsx, .js, .jsx, .py, .go, .rs, .sol)
CODE_CHANGE_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "tool_use" and (.name == "Edit" or .name == "Write")) |
   .input.file_path // "" |
   select(test("\\.(ts|tsx|js|jsx|py|go|rs|sol)$")) |
   select(test("\\.(test|spec)\\.(ts|tsx|js|jsx)$") | not)] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

if [[ "$CODE_CHANGE_COUNT" == "0" || "$CODE_CHANGE_COUNT" == "null" ]]; then
  log_info "event=SKIP" "reason=no_code_changes"
  exit 0
fi

log_info "event=CODE_CHANGES_DETECTED" "count=$CODE_CHANGE_COUNT"

# --- Check for review pass documentation ---
# Look for "Pass 1", "Pass 2", "Pass 3" etc. in assistant messages
# Also check for alternative patterns like "## Pass 1" or "**Pass 1**"
PASS_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "text") | .text // ""] |
  join(" ") |
  [match("(?i)(pass\\s*[1-5]|## pass|\\*\\*pass)"; "g")] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

# Also check for convergence indicators
HAS_CONVERGENCE=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "text") | .text // ""] |
  join(" ") |
  test("(?i)(converg|findings|## review)"; "g")
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "false")

log_info "event=REVIEW_CHECK" "pass_count=$PASS_COUNT" "has_convergence=$HAS_CONVERGENCE"

# --- Determine if blocking needed ---
if [[ "$PASS_COUNT" == "null" ]]; then
  PASS_COUNT=0
fi

# Allow if 3+ passes documented
if [[ "$PASS_COUNT" -ge 3 ]]; then
  log_info "event=REVIEW_OK" "passes=$PASS_COUNT"
  exit 0
fi

# --- BLOCK: insufficient review passes ---
log_warn "event=REVIEW_BLOCK" "passes=$PASS_COUNT" "code_changes=$CODE_CHANGE_COUNT"

REASON="Review enforcer: Code changes require documented review passes.

Code changes: $CODE_CHANGE_COUNT file(s) modified
Review passes: $PASS_COUNT (minimum 3 required)

Rule of Five requires minimum 3 documented review passes for code changes.

Before stopping, document your review:

## Pass 1: Standard Review - EVIDENCE
- Checked: [what you reviewed]
- Findings: [issues found or 'No issues']
- Evidence: [test output, code citations]

## Pass 2: Deep Review - EVIDENCE
- Checked: [naming, duplication, error handling]
- Findings: [issues found or 'No issues']

## Pass 3: Architecture Review - EVIDENCE
- Checked: [patterns, dependencies, YAGNI]
- Findings: [issues found or 'Converged']

Override: Include [REVIEW-BYPASS] in your message (audited to /tmp/claude-audit/)"

jq -n --arg reason "$REASON" '{"decision": "block", "reason": $reason}'
exit 0
