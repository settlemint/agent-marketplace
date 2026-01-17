#!/usr/bin/env bash
# Stop hook: Warn if code changes made without documented review passes
# Implements hybrid enforcement: warn during work, block at commit gates
#
# Checks for:
# - Edit/Write tool usage (code change indicator)
# - "Pass 1", "Pass 2", etc. in assistant messages (review pass documentation)
# - Warns if fewer than 3 passes documented for code-change sessions
#
# Does NOT block - just warns. Blocking happens at commit time.

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

# --- Check for code changes (Edit/Write tool usage) ---
CODE_CHANGE_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "tool_use" and (.name == "Edit" or .name == "Write"))] |
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

# --- Determine warning level ---
WARNING_LEVEL="none"
WARNING_MSG=""

if [[ "$PASS_COUNT" == "0" || "$PASS_COUNT" == "null" ]]; then
  WARNING_LEVEL="high"
  WARNING_MSG="Code changes made without documented review passes. Rule of Five requires minimum 3 passes for code changes."
elif [[ "$PASS_COUNT" -lt 3 ]]; then
  WARNING_LEVEL="medium"
  WARNING_MSG="Only $PASS_COUNT review pass(es) documented. Rule of Five recommends minimum 3 passes for code changes."
fi

# --- Output warning if needed ---
if [[ "$WARNING_LEVEL" != "none" ]]; then
  log_warn "event=REVIEW_WARNING" "level=$WARNING_LEVEL" "passes=$PASS_COUNT" "code_changes=$CODE_CHANGE_COUNT"

  echo ""
  echo "<flow-review-warning>"
  echo "Review passes: $PASS_COUNT (minimum 3 recommended)"
  echo "Code changes: $CODE_CHANGE_COUNT file(s) modified"
  echo ""
  echo "$WARNING_MSG"
  echo ""
  echo "Before committing, document your review:"
  echo "  - Pass 1: Standard review (bugs, edge cases)"
  echo "  - Pass 2: Deep review (naming, duplication)"
  echo "  - Pass 3: Architecture review (patterns, YAGNI)"
  echo ""
  echo "Note: Commits will be blocked without documented passes."
  echo "</flow-review-warning>"
else
  log_info "event=REVIEW_OK" "passes=$PASS_COUNT"
fi

exit 0
