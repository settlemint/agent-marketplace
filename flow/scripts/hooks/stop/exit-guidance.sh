#!/usr/bin/env bash
# Exit guidance hook - Stop hook (NON-BLOCKING)
# Philosophy: "Teach, don't police" - provide guidance without blocking
#
# Replaces blocking hooks with informational guidance:
# - todo-enforcer.sh → Shows incomplete todos
# - review-enforcer.sh → Reminds about review passes
# - auto-review-spawner.sh → Suggests review agents
#
# This hook NEVER blocks. It provides a checklist for quality exit.

set +e

SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="exit-guidance"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read hook input from stdin
HOOK_INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // ""' 2>/dev/null || echo "")
AGENT_TYPE=$(echo "$HOOK_INPUT" | jq -r '.agent_type // "main"' 2>/dev/null || echo "main")

# Skip for subagents
if [[ "$AGENT_TYPE" != "main" ]]; then
  log_info "event=SKIP" "reason=subagent"
  exit 0
fi

# No transcript - nothing to check
if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
  log_info "event=SKIP" "reason=no_transcript"
  exit 0
fi

# ============================================================================
# Gather session metrics
# ============================================================================

# Count incomplete todos
TODOS_JSON=$(jq -s '
  [.[] | .message.content[]? | select(.type == "tool_use" and .name == "TodoWrite") | .input.todos] |
  last // empty
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "")

PENDING_COUNT=0
IN_PROGRESS_COUNT=0

if [[ -n "$TODOS_JSON" && "$TODOS_JSON" != "null" ]]; then
  read -r PENDING_COUNT IN_PROGRESS_COUNT < <(
    echo "$TODOS_JSON" | jq -r '[
      [.[] | select(.status == "pending")] | length,
      [.[] | select(.status == "in_progress")] | length
    ] | @tsv'
  )
fi

INCOMPLETE_TODOS=$((PENDING_COUNT + IN_PROGRESS_COUNT))

# Count code changes (non-test files)
CODE_CHANGE_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "tool_use" and (.name == "Edit" or .name == "Write")) |
   .input.file_path // "" |
   select(test("\\.(ts|tsx|js|jsx|py|go|rs|sol)$")) |
   select(test("\\.(test|spec)\\.(ts|tsx|js|jsx)$") | not)] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

# Count review passes
PASS_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "text") | .text // ""] |
  join(" ") |
  [match("(?i)(pass\\s*[1-5]|## pass|\\*\\*pass)"; "g")] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

# Ensure numeric values
[[ -z "$CODE_CHANGE_COUNT" || "$CODE_CHANGE_COUNT" == "null" ]] && CODE_CHANGE_COUNT=0
[[ -z "$PASS_COUNT" || "$PASS_COUNT" == "null" ]] && PASS_COUNT=0

log_info "event=EXIT_METRICS" "incomplete_todos=$INCOMPLETE_TODOS" "code_changes=$CODE_CHANGE_COUNT" "passes=$PASS_COUNT"

# ============================================================================
# Build guidance output (only if there's something to report)
# ============================================================================

GUIDANCE_NEEDED=false
GUIDANCE_OUTPUT=""

# Check 1: Incomplete todos
if [[ "$INCOMPLETE_TODOS" -gt 0 ]]; then
  GUIDANCE_NEEDED=true
  TASK_LIST=$(echo "$TODOS_JSON" | jq -r '
    ([.[] | select(.status == "in_progress") | "  → [in progress] \(.content)"] +
     [.[] | select(.status == "pending") | "  - [pending] \(.content)"]) |
    .[0:5] | join("\n")
  ')
  GUIDANCE_OUTPUT+="
□ Incomplete todos ($INCOMPLETE_TODOS):
$TASK_LIST
"
  if [[ "$INCOMPLETE_TODOS" -gt 5 ]]; then
    GUIDANCE_OUTPUT+="  ... and $((INCOMPLETE_TODOS - 5)) more
"
  fi
fi

# Check 2: Code changes without review passes
if [[ "$CODE_CHANGE_COUNT" -gt 0 && "$PASS_COUNT" -lt 3 ]]; then
  GUIDANCE_NEEDED=true
  GUIDANCE_OUTPUT+="
□ Code changes ($CODE_CHANGE_COUNT files) with $PASS_COUNT review passes (recommend 3)
  Consider: Skill({ skill: \"superpowers:verification-before-completion\" })
"
fi

# Check 3: Significant changes without review agents (only if >5 changes)
if [[ "$CODE_CHANGE_COUNT" -ge 5 && "$PASS_COUNT" -lt 3 ]]; then
  GUIDANCE_OUTPUT+="
□ Significant changes may benefit from specialized review:
  - pr-review-toolkit:code-reviewer (bugs, CLAUDE.md compliance)
  - pr-review-toolkit:silent-failure-hunter (error handling gaps)
"
fi

# ============================================================================
# Output guidance (if needed)
# ============================================================================

if [[ "$GUIDANCE_NEEDED" == "true" ]]; then
  cat <<EOF

<exit-checklist>
Before stopping, consider these items:
$GUIDANCE_OUTPUT
For interactive guidance: Skill({ skill: "flow:exit-readiness" })
</exit-checklist>

EOF
  log_info "event=GUIDANCE_SHOWN"
else
  log_info "event=CLEAN_EXIT"
fi

# NEVER block - this is guidance only
exit 0
