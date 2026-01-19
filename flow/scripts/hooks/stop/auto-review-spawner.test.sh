#!/usr/bin/env bash
# Tests for auto-review-spawner.sh hook
# Run: bash flow/scripts/hooks/stop/auto-review-spawner.test.sh

set -e

SCRIPT_DIR=$(dirname "$0")
HOOK="$SCRIPT_DIR/auto-review-spawner.sh"
TEST_DIR=$(mktemp -d)
TRANSCRIPT="$TEST_DIR/transcript.jsonl"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

TESTS_RUN=0
TESTS_PASSED=0

setup() {
  rm -rf "$TEST_DIR"
  mkdir -p "$TEST_DIR"
  export CLAUDE_PROJECT_DIR="$TEST_DIR"
}

# Helper to create transcript with N Edit operations on code files
create_transcript_with_code_edits() {
  local count=$1
  local has_pass=${2:-false}
  local content=""

  for ((i = 1; i <= count; i++)); do
    content="${content}{\"message\":{\"content\":[{\"type\":\"tool_use\",\"name\":\"Edit\",\"input\":{\"file_path\":\"/src/file$i.ts\"}}]}}\n"
  done

  if [[ "$has_pass" == "true" ]]; then
    content="${content}{\"message\":{\"content\":[{\"type\":\"text\",\"text\":\"## Pass 1: Review\\n## Pass 2: Review\\n## Pass 3: Review\"}]}}\n"
  fi

  echo -e "$content" >"$TRANSCRIPT"
}

# Helper to create transcript with test file edits
create_transcript_with_test_edits() {
  local count=$1
  local content=""

  for ((i = 1; i <= count; i++)); do
    content="${content}{\"message\":{\"content\":[{\"type\":\"tool_use\",\"name\":\"Edit\",\"input\":{\"file_path\":\"/src/file$i.test.ts\"}}]}}\n"
  done

  echo -e "$content" >"$TRANSCRIPT"
}

# Run the hook and capture output
run_hook() {
  local agent_type="${1:-main}"
  echo "{\"transcript_path\": \"$TRANSCRIPT\", \"agent_type\": \"$agent_type\"}" | bash "$HOOK" 2>/dev/null || true
}

# Assert hook outputs spawn instructions
assert_spawns_reviewers() {
  local output
  output=$(run_hook)

  if echo "$output" | grep -qiE "pr-review-toolkit|code-reviewer|silent-failure-hunter"; then
    return 0
  else
    echo "Expected hook to output reviewer spawn instructions but got:"
    echo "$output"
    return 1
  fi
}

# Assert hook outputs nothing (no spawn needed)
assert_no_spawn() {
  local agent_type="${1:-main}"
  local output
  output=$(run_hook "$agent_type")

  if [[ -z "$output" ]]; then
    return 0
  else
    echo "Expected no output but got:"
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

test_spawn_on_code_edits_without_review() {
  # 6 code edits without review passes should trigger spawn
  create_transcript_with_code_edits 6
  assert_spawns_reviewers
}

test_no_spawn_under_threshold() {
  # 4 code edits (under threshold of 5) should not trigger
  create_transcript_with_code_edits 4
  assert_no_spawn
}

test_no_spawn_with_review_passes() {
  # 10 code edits but with review passes should not trigger
  create_transcript_with_code_edits 10 true
  assert_no_spawn
}

test_skip_subagents() {
  # Subagents should not trigger spawning
  create_transcript_with_code_edits 10
  assert_no_spawn "general-purpose"
}

test_skip_review_agents() {
  # Review agents should not trigger spawning (anti-loop)
  create_transcript_with_code_edits 10
  assert_no_spawn "pr-review-toolkit:code-reviewer"
}

test_no_transcript_no_spawn() {
  # No transcript - should not spawn
  local output
  output=$(echo '{"transcript_path": "/nonexistent", "agent_type": "main"}' | bash "$HOOK" 2>/dev/null || true)
  [[ -z "$output" ]]
}

test_includes_code_reviewer() {
  create_transcript_with_code_edits 6
  local output
  output=$(run_hook)
  echo "$output" | grep -qi "code-reviewer"
}

test_includes_silent_failure_hunter() {
  create_transcript_with_code_edits 6
  local output
  output=$(run_hook)
  echo "$output" | grep -qi "silent-failure-hunter"
}

test_includes_test_analyzer_when_tests_changed() {
  # Create transcript with both code and test files
  # Need at least 5 code edits to trigger the spawner
  local content=""
  for ((i = 1; i <= 6; i++)); do
    content="${content}{\"message\":{\"content\":[{\"type\":\"tool_use\",\"name\":\"Edit\",\"input\":{\"file_path\":\"/src/file$i.ts\"}}]}}\n"
  done
  for ((i = 1; i <= 3; i++)); do
    content="${content}{\"message\":{\"content\":[{\"type\":\"tool_use\",\"name\":\"Edit\",\"input\":{\"file_path\":\"/src/file$i.test.ts\"}}]}}\n"
  done
  echo -e "$content" >"$TRANSCRIPT"

  local output
  output=$(run_hook)
  echo "$output" | grep -qi "pr-test-analyzer"
}

# --- Run Tests ---

echo "Running auto-review-spawner.sh tests..."
echo ""

run_test "Spawn reviewers on code edits without review" test_spawn_on_code_edits_without_review
run_test "No spawn under threshold (4 edits)" test_no_spawn_under_threshold
run_test "No spawn with review passes documented" test_no_spawn_with_review_passes
run_test "Skip subagents" test_skip_subagents
run_test "Skip review agents (anti-loop)" test_skip_review_agents
run_test "No transcript - no spawn" test_no_transcript_no_spawn
run_test "Output includes code-reviewer" test_includes_code_reviewer
run_test "Output includes silent-failure-hunter" test_includes_silent_failure_hunter
run_test "Output includes pr-test-analyzer when tests changed" test_includes_test_analyzer_when_tests_changed

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
