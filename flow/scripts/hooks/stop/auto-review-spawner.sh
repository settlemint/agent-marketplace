#!/usr/bin/env bash
# Stop hook: Auto-spawn reviewer agents when code changes detected without review
# Enforces Rule of Five by spawning pr-review-toolkit agents
#
# Checks for:
# - Edit/Write tool usage on code files
# - Review pass documentation ("## Pass") in messages
# - Spawns reviewers if >5 code edits AND no review passes
#
# Anti-loop protection:
# - Skips if agent_type != "main" (subagents don't trigger)
# - Skips if agent_type contains "review" (review agents don't trigger)
#
# Spawns these agents based on changed file types:
# - pr-review-toolkit:code-reviewer (always)
# - pr-review-toolkit:silent-failure-hunter (always)
# - pr-review-toolkit:pr-test-analyzer (if test files changed)
# - pr-review-toolkit:type-design-analyzer (if type definitions changed)

set +e

SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="auto-review-spawner"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Minimum edits to trigger auto-spawn
MIN_EDITS_FOR_SPAWN=5

# Read hook input from stdin
HOOK_INPUT=$(cat)

# Parse hook input
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // ""' 2>/dev/null || echo "")
AGENT_TYPE=$(echo "$HOOK_INPUT" | jq -r '.agent_type // "main"' 2>/dev/null || echo "main")

# --- Anti-loop protection ---
# Skip for subagents
if [[ "$AGENT_TYPE" != "main" ]]; then
  log_info "event=SKIP" "reason=subagent" "agent_type=$AGENT_TYPE"
  exit 0
fi

# Skip for review agents (prevent recursive spawning)
if [[ "$AGENT_TYPE" == *"review"* ]]; then
  log_info "event=SKIP" "reason=review_agent" "agent_type=$AGENT_TYPE"
  exit 0
fi

# No transcript - nothing to check
if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
  log_info "event=SKIP" "reason=no_transcript"
  exit 0
fi

# --- Count code file edits ---
CODE_EDIT_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "tool_use" and (.name == "Edit" or .name == "Write")) |
   .input.file_path // "" |
   select(test("\\.(ts|tsx|js|jsx|py|go|rs|sol)$")) |
   select(test("\\.(test|spec)\\.(ts|tsx|js|jsx)$") | not) |
   select(test("\\.d\\.ts$") | not)] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

if [[ "$CODE_EDIT_COUNT" == "null" || -z "$CODE_EDIT_COUNT" ]]; then
  CODE_EDIT_COUNT=0
fi

# Under threshold - no spawn needed
if [[ "$CODE_EDIT_COUNT" -lt "$MIN_EDITS_FOR_SPAWN" ]]; then
  log_info "event=SKIP" "reason=under_threshold" "count=$CODE_EDIT_COUNT" "threshold=$MIN_EDITS_FOR_SPAWN"
  exit 0
fi

# --- Check for review pass documentation ---
PASS_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "text") | .text // ""] |
  join(" ") |
  [match("(?i)(## pass|\\*\\*pass\\s*[1-5]|### pass)"; "g")] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

if [[ "$PASS_COUNT" == "null" || -z "$PASS_COUNT" ]]; then
  PASS_COUNT=0
fi

# Has review passes - no spawn needed
if [[ "$PASS_COUNT" -ge 3 ]]; then
  log_info "event=SKIP" "reason=has_review_passes" "passes=$PASS_COUNT"
  exit 0
fi

# --- Check for test files changed ---
TEST_FILE_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "tool_use" and (.name == "Edit" or .name == "Write")) |
   .input.file_path // "" |
   select(test("\\.(test|spec)\\.(ts|tsx|js|jsx)$"))] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

# --- Check for type definition changes ---
TYPE_DEF_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "tool_use" and (.name == "Edit" or .name == "Write")) |
   .input.file_path // "" |
   select(test("\\.d\\.ts$|/types/"))] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

# --- Get list of changed files ---
CHANGED_FILES=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "tool_use" and (.name == "Edit" or .name == "Write")) |
   .input.file_path // ""] |
  unique | join(", ")
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "")

log_info "event=SPAWN_REVIEWERS" "code_edits=$CODE_EDIT_COUNT" "passes=$PASS_COUNT" "test_files=$TEST_FILE_COUNT" "type_defs=$TYPE_DEF_COUNT"

# --- Output spawn instructions ---
cat <<EOF

<auto-review-spawn>
REQUIRED: Code changes detected without documented review passes.

Code edits: $CODE_EDIT_COUNT files
Review passes: $PASS_COUNT (need 3)
Changed files: $CHANGED_FILES

Spawn these reviewer agents to complete Rule of Five:

Task({
  subagent_type: "pr-review-toolkit:code-reviewer",
  description: "Review code changes for CLAUDE.md compliance",
  prompt: "Review these files for bugs, logic errors, and CLAUDE.md violations: $CHANGED_FILES"
})

Task({
  subagent_type: "pr-review-toolkit:silent-failure-hunter",
  description: "Check error handling",
  prompt: "Check these files for silent failures, missing error handling, and logging gaps: $CHANGED_FILES"
})
EOF

# Conditional spawns based on file types
if [[ "$TEST_FILE_COUNT" -gt 0 ]]; then
  cat <<EOF

Task({
  subagent_type: "pr-review-toolkit:pr-test-analyzer",
  description: "Analyze test coverage",
  prompt: "Analyze test coverage and quality for the changed code files"
})
EOF
fi

if [[ "$TYPE_DEF_COUNT" -gt 0 ]]; then
  cat <<EOF

Task({
  subagent_type: "pr-review-toolkit:type-design-analyzer",
  description: "Review type definitions",
  prompt: "Analyze type design for encapsulation and invariant expression"
})
EOF
fi

cat <<EOF

After spawning reviewers, document your review passes:
## Pass 1: Standard Review - EVIDENCE
## Pass 2: Deep Review - EVIDENCE
## Pass 3: Architecture Review - EVIDENCE
</auto-review-spawn>
EOF

exit 0
