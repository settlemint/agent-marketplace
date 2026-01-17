#!/usr/bin/env bash
# PreToolUse hook: Warn on commits without code explanation
# Implements "never commit code you can't explain" principle
#
# Checks for:
# - git commit commands with significant changes
# - Explanation indicators in transcript
# - Warns (non-blocking) if explanation missing
#
# Based on: https://addyosmani.com/blog/code-review-ai/

set +e

SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="comprehension-gate"
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

log_info "event=COMMIT_DETECTED"

# No transcript - skip check
if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
  log_info "event=SKIP_NO_TRANSCRIPT"
  exit 0
fi

# --- Check for significant code changes ---
# Count unique files modified via Edit/Write tools
FILE_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "tool_use" and (.name == "Edit" or .name == "Write")) |
   .input.file_path // ""] |
  unique | length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

log_info "event=CHANGE_ANALYSIS" "file_count=$FILE_COUNT"

# Only check for significant changes (>=4 files, i.e., more than 3)
SIGNIFICANCE_THRESHOLD=4
if [[ "$FILE_COUNT" -lt "$SIGNIFICANCE_THRESHOLD" ]]; then
  log_info "event=SKIP_SMALL_CHANGE" "file_count=$FILE_COUNT" "threshold=$SIGNIFICANCE_THRESHOLD"
  exit 0
fi

# --- Check for explanation indicators in assistant messages ---
EXPLANATION_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "text") | .text // ""] |
  join(" ") |
  [match("(?i)(because|this (code|approach|implementation|solution)|the reason|in order to|this (handles|fixes|adds|enables|ensures)|this works by|the key (insight|change|idea))"; "g")] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

log_info "event=EXPLANATION_CHECK" "explanation_count=$EXPLANATION_COUNT" "file_count=$FILE_COUNT"

# --- Warn if insufficient explanation for significant changes ---
MIN_EXPLANATIONS=2

if [[ "$EXPLANATION_COUNT" -lt "$MIN_EXPLANATIONS" ]]; then
  log_warn "event=COMPREHENSION_WARNING" "explanation_count=$EXPLANATION_COUNT" "file_count=$FILE_COUNT"

  # Check for session marker to avoid repeated warnings
  if session_marker_exists "comprehension-warned"; then
    log_info "event=SKIP_ALREADY_WARNED"
    exit 0
  fi

  create_session_marker "comprehension-warned"

  # Emit warning message (non-blocking)
  cat <<EOF

<flow-comprehension-notice>
Significant code changes detected ($FILE_COUNT files) with limited explanation.

Article insight: "Never commit code you can't explain."
  — https://addyosmani.com/blog/code-review-ai/

Consider adding a brief explanation of:
- What the code does and why
- Key design decisions
- How to verify it works

This helps reviewers (and future you) understand the changes.
</flow-comprehension-notice>

EOF

  exit 0
fi

log_info "event=COMPREHENSION_OK" "explanation_count=$EXPLANATION_COUNT"
exit 0
