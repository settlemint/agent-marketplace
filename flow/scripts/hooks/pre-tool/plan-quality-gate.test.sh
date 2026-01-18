#!/usr/bin/env bash
# Tests for plan-quality-gate.sh hook
# Run: bash flow/scripts/hooks/pre-tool/plan-quality-gate.test.sh

set -e

SCRIPT_DIR=$(dirname "$0")
HOOK="$SCRIPT_DIR/plan-quality-gate.sh"
TEST_DIR=$(mktemp -d)
TRANSCRIPT="$TEST_DIR/transcript.jsonl"
PLAN_FILE="$TEST_DIR/plans/test-plan.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

TESTS_RUN=0
TESTS_PASSED=0

setup() {
  rm -rf "$TEST_DIR"
  mkdir -p "$TEST_DIR/plans"
  mkdir -p "$TEST_DIR/.claude/audit"
  export CLAUDE_PROJECT_DIR="$TEST_DIR"
}

# Helper to create transcript with specific tool uses
create_transcript() {
  local content="$1"
  echo "$content" >"$TRANSCRIPT"
}

# Helper to create plan file
create_plan() {
  local content="$1"
  echo "$content" >"$PLAN_FILE"
}

# Run the hook and capture output
run_hook() {
  local tool_name="${1:-ExitPlanMode}"
  echo "{\"tool_name\": \"$tool_name\", \"transcript_path\": \"$TRANSCRIPT\"}" | bash "$HOOK" 2>/dev/null || true
}

# Assert hook blocks with specific reason
assert_blocks() {
  local reason_pattern="$1"
  local output
  output=$(run_hook)

  if echo "$output" | jq -e '.decision == "block"' >/dev/null 2>&1; then
    if echo "$output" | jq -r '.reason' | grep -qiE "$reason_pattern"; then
      return 0
    else
      echo "Expected reason to match '$reason_pattern' but got:"
      echo "$output" | jq -r '.reason'
      return 1
    fi
  else
    echo "Expected hook to block but it didn't. Output:"
    echo "$output"
    return 1
  fi
}

# Assert hook allows (no output or empty)
assert_allows() {
  local output
  output=$(run_hook)

  if [[ -z "$output" ]] || echo "$output" | jq -e '.decision != "block"' >/dev/null 2>&1; then
    return 0
  else
    echo "Expected hook to allow but it blocked. Output:"
    echo "$output"
    return 1
  fi
}

# Test runner
run_test() {
  local name="$1"
  local test_fn="$2"
  TESTS_RUN=$((TESTS_RUN + 1))

  setup

  if $test_fn; then
    echo -e "${GREEN}PASS${NC}: $name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}FAIL${NC}: $name"
  fi
}

# --- Test Cases ---

test_skip_non_exitplanmode() {
  jq -n '{message:{content:[]}}' >"$TRANSCRIPT"
  local output
  output=$(echo '{"tool_name": "Bash", "transcript_path": "'"$TRANSCRIPT"'"}' | bash "$HOOK" 2>/dev/null || true)
  [[ -z "$output" ]]
}

test_block_no_codex() {
  # Transcript with passes but no Codex
  # Use jq to create properly escaped JSON
  jq -n '{message:{content:[{type:"text",text:"## Pass 1\n## Pass 2\n## Pass 3"}]}}' >"$TRANSCRIPT"
  create_plan "## Steps
1. [serial] Do something"
  assert_blocks "Codex"
}

test_block_no_passes() {
  # Transcript with Codex but no passes
  jq -n '{message:{content:[{type:"tool_use",name:"mcp__plugin_devtools_codex__codex"}]}}' >"$TRANSCRIPT"
  create_plan "## Steps
1. [serial] Do something"
  assert_blocks "Rule of Five"
}

test_block_insufficient_passes() {
  # Only 2 passes (need 3)
  jq -n '{message:{content:[{type:"tool_use",name:"mcp__plugin_devtools_codex__codex"},{type:"text",text:"## Pass 1\n## Pass 2"}]}}' >"$TRANSCRIPT"
  create_plan "## Steps
1. [serial] Do something"
  assert_blocks "Rule of Five"
}

test_block_no_tdd() {
  # Has Codex, has passes, but no TDD in plan
  # Include Write operation so hook can find the plan file
  jq -n --arg pf "$PLAN_FILE" '{message:{content:[{type:"tool_use",name:"mcp__plugin_devtools_codex__codex"},{type:"tool_use",name:"Write",input:{file_path:$pf}},{type:"text",text:"## Pass 1\n## Pass 2\n## Pass 3"}]}}' >"$TRANSCRIPT"
  create_plan "## Steps
1. [serial] Implement feature
2. [parallel] Add validation"
  assert_blocks "TDD"
}

test_allow_with_review_subagent() {
  # Review subagent counts as passes
  jq -n '{message:{content:[{type:"tool_use",name:"mcp__plugin_devtools_codex__codex"},{type:"tool_use",name:"Task",input:{prompt:"Apply Rule of Five to this plan"}}]}}' >"$TRANSCRIPT"
  create_plan "## Steps
1. [serial] Implement feature
- TDD: Write failing test first"
  assert_allows
}

test_allow_all_requirements() {
  # Has Codex, 3+ passes, TDD in plan
  jq -n '{message:{content:[{type:"tool_use",name:"mcp__plugin_devtools_codex__codex"},{type:"text",text:"## Pass 1\n## Pass 2\n## Pass 3"}]}}' >"$TRANSCRIPT"
  create_plan "## Steps
1. [serial] Implement feature
- TDD: Write failing test first
- Coverage target: 80%"
  assert_allows
}

test_bypass_marker() {
  # Has bypass marker - should allow even without requirements
  # Include Write operation so hook can find the plan file
  jq -n --arg pf "$PLAN_FILE" '{message:{content:[{type:"tool_use",name:"Write",input:{file_path:$pf}}]}}' >"$TRANSCRIPT"
  create_plan "[PLAN-BYPASS]
## Steps
1. [serial] Quick fix"
  assert_allows

  # Check audit log was created
  [[ -f "$TEST_DIR/.claude/audit/plan-bypass.log" ]]
}

test_no_transcript_allows() {
  # No transcript file - should allow (can't verify)
  local output
  output=$(echo '{"tool_name": "ExitPlanMode", "transcript_path": "/nonexistent"}' | bash "$HOOK" 2>/dev/null || true)
  [[ -z "$output" ]]
}

# --- Run Tests ---

echo "Running plan-quality-gate.sh tests..."
echo ""

run_test "Skip non-ExitPlanMode tools" test_skip_non_exitplanmode
run_test "Block when no Codex invocation" test_block_no_codex
run_test "Block when no Rule of Five passes" test_block_no_passes
run_test "Block when insufficient passes (2 < 3)" test_block_insufficient_passes
run_test "Block when no TDD in plan" test_block_no_tdd
run_test "Allow when Review subagent spawned" test_allow_with_review_subagent
run_test "Allow when all requirements met" test_allow_all_requirements
run_test "Bypass marker allows and logs" test_bypass_marker
run_test "No transcript allows (can't verify)" test_no_transcript_allows

echo ""
echo "================================"
echo "Tests: $TESTS_PASSED/$TESTS_RUN passed"

# Cleanup
rm -rf "$TEST_DIR"

if [[ $TESTS_PASSED -eq $TESTS_RUN ]]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed${NC}"
  exit 1
fi
