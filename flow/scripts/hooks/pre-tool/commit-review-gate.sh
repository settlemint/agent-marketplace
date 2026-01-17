#!/usr/bin/env bash
# PreToolUse hook: Block git commit without documented review passes
# Implements hybrid enforcement: block at commit gates
#
# Checks for:
# - git commit commands
# - Review pass documentation in transcript
# - Blocks if fewer than 3 passes documented for code-change sessions
#
# Bypass: Include "--skip-review" in commit message for emergencies

set +e

SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="commit-review-gate"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read tool input from stdin
TOOL_INPUT=$(cat)
COMMAND=$(echo "$TOOL_INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
TRANSCRIPT_PATH=$(echo "$TOOL_INPUT" | jq -r '.transcript_path // ""' 2>/dev/null || echo "")

# Skip if no command
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Skip if not a git commit command
if [[ "$COMMAND" != *"git commit"* ]]; then
  exit 0
fi

log_info "event=COMMIT_DETECTED" "command_preview=${COMMAND:0:50}..."

# Check for bypass flag in commit message
if [[ "$COMMAND" == *"--skip-review"* ]]; then
  log_warn "event=REVIEW_BYPASS" "reason=skip_review_flag"
  echo "Review check bypassed with --skip-review flag" >&2
  exit 0
fi

# No transcript - allow (can't verify)
if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
  log_warn "event=ALLOW_NO_TRANSCRIPT"
  exit 0
fi

# --- Check for code changes (Edit/Write tool usage) ---
CODE_CHANGE_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "tool_use" and (.name == "Edit" or .name == "Write"))] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

# No code changes in session - allow commit (might be committing external changes)
if [[ "$CODE_CHANGE_COUNT" == "0" || "$CODE_CHANGE_COUNT" == "null" ]]; then
  log_info "event=ALLOW" "reason=no_code_changes_in_session"
  exit 0
fi

# --- Check for review pass documentation ---
PASS_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "text") | .text // ""] |
  join(" ") |
  [match("(?i)(pass\\s*[1-5]|## pass|\\*\\*pass)"; "g")] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

log_info "event=REVIEW_CHECK" "pass_count=$PASS_COUNT" "code_changes=$CODE_CHANGE_COUNT"

# --- Block if insufficient passes ---
MIN_PASSES=3

if [[ "$PASS_COUNT" -lt "$MIN_PASSES" ]]; then
  log_warn "event=COMMIT_BLOCKED" "pass_count=$PASS_COUNT" "required=$MIN_PASSES"

  REASON="Commit blocked: Rule of Five requires documented review passes.

Code changes detected: $CODE_CHANGE_COUNT file(s)
Review passes found: $PASS_COUNT (minimum $MIN_PASSES required)

Before committing, document your review:
  1. Pass 1: Standard review - bugs, edge cases, test coverage
  2. Pass 2: Deep review - naming, duplication, error handling
  3. Pass 3: Architecture review - patterns, dependencies, YAGNI

Example output format:
  ## Pass 1: Standard Review
  - Finding: [issue] - Severity: P2
  - Fix applied: [change]

  ## Pass 2: Deep Review
  - No new findings

  ## Pass 3: Architecture Review
  - Converged: All issues addressed

Emergency bypass: Add '--skip-review' to commit message (use sparingly)"

  jq -n --arg reason "$REASON" '{"decision": "block", "reason": $reason}'
  exit 0
fi

log_info "event=COMMIT_ALLOWED" "pass_count=$PASS_COUNT"
exit 0
