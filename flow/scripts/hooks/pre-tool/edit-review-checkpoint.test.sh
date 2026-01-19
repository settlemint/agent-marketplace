#!/usr/bin/env bash
# Tests for edit-review-checkpoint.sh hook
# Run: bash flow/scripts/hooks/pre-tool/edit-review-checkpoint.test.sh

set -e

SCRIPT_DIR=$(dirname "$0")
HOOK="$SCRIPT_DIR/edit-review-checkpoint.sh"
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
  mkdir -p "/tmp/claude-audit"
  export CLAUDE_PROJECT_DIR="$TEST_DIR"
  export CLAUDE_SESSION_ID="test-session-$$"
  # Reset checkpoint threshold to default
  unset CLAUDE_REVIEW_CHECKPOINT
}

# Helper to create transcript with specific tool uses
create_transcript() {
  local content="$1"
  echo "$content" >"$TRANSCRIPT"
}

# Helper to create transcript with N Edit operations
create_transcript_with_edits() {
  local count=$1
  local has_pass=${2:-false}
  local content=""

  for ((i = 1; i <= count; i++)); do
    content="${content}{\"message\":{\"content\":[{\"type\":\"tool_use\",\"name\":\"Edit\",\"input\":{\"file_path\":\"/src/file$i.ts\"}}]}}\n"
  done

  if [[ "$has_pass" == "true" ]]; then
    content="${content}{\"message\":{\"content\":[{\"type\":\"text\",\"text\":\"## Pass 1: Review - EVIDENCE\\n- Checked code\"}]}}\n"
  fi

  echo -e "$content" >"$TRANSCRIPT"
}

# Run the hook and capture output
run_hook() {
  local file_path="${1:-/src/component.ts}"
  echo "{\"tool_name\": \"Edit\", \"tool_input\": {\"file_path\": \"$file_path\"}, \"transcript_path\": \"$TRANSCRIPT\"}" | bash "$HOOK" 2>/dev/null || true
}

# Assert hook blocks with specific reason
assert_blocks() {
  local reason_pattern="$1"
  local file_path="${2:-/src/component.ts}"
  local output
  output=$(run_hook "$file_path")

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
  local file_path="${1:-/src/component.ts}"
  local output
  output=$(run_hook "$file_path")

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

test_allow_under_threshold() {
  # 9 edits should be allowed (threshold is 10)
  create_transcript_with_edits 9
  assert_allows
}

test_block_at_threshold() {
  # 10 edits without pass should block
  create_transcript_with_edits 10
  assert_blocks "review pass"
}

test_allow_with_pass_documented() {
  # 10 edits but pass documented should allow
  create_transcript_with_edits 10 true
  assert_allows
}

test_skip_test_files() {
  # Edits to test files should not count
  create_transcript_with_edits 15
  assert_allows "/src/component.test.ts"
}

test_skip_config_files() {
  # Edits to config files should be allowed
  create_transcript_with_edits 15
  assert_allows "vitest.config.ts"
}

test_skip_markdown_files() {
  # Edits to markdown files should be allowed
  create_transcript_with_edits 15
  assert_allows "README.md"
}

test_custom_threshold() {
  # Custom threshold via env var
  export CLAUDE_REVIEW_CHECKPOINT=5
  create_transcript_with_edits 5
  assert_blocks "review pass"
}

test_skip_checkpoint_bypass() {
  # [SKIP-CHECKPOINT] in recent message allows bypass
  create_transcript_with_edits 10
  # Add bypass marker
  echo '{"message":{"content":[{"type":"text","text":"[SKIP-CHECKPOINT] Emergency fix"}]}}' >>"$TRANSCRIPT"
  assert_allows
}

test_no_transcript_allows() {
  # No transcript file - should allow (can't verify)
  local output
  output=$(echo '{"tool_name": "Edit", "tool_input": {"file_path": "/src/file.ts"}, "transcript_path": "/nonexistent"}' | bash "$HOOK" 2>/dev/null || true)
  [[ -z "$output" ]]
}

test_write_tool_also_counted() {
  # Write tool should also count toward threshold
  local content=""
  for ((i = 1; i <= 10; i++)); do
    content="${content}{\"message\":{\"content\":[{\"type\":\"tool_use\",\"name\":\"Write\",\"input\":{\"file_path\":\"/src/new$i.ts\"}}]}}\n"
  done
  echo -e "$content" >"$TRANSCRIPT"
  assert_blocks "review pass"
}

test_mixed_edit_write() {
  # Mix of Edit and Write should count together
  local content=""
  for ((i = 1; i <= 5; i++)); do
    content="${content}{\"message\":{\"content\":[{\"type\":\"tool_use\",\"name\":\"Edit\",\"input\":{\"file_path\":\"/src/edit$i.ts\"}}]}}\n"
  done
  for ((i = 1; i <= 5; i++)); do
    content="${content}{\"message\":{\"content\":[{\"type\":\"tool_use\",\"name\":\"Write\",\"input\":{\"file_path\":\"/src/write$i.ts\"}}]}}\n"
  done
  echo -e "$content" >"$TRANSCRIPT"
  assert_blocks "review pass"
}

# --- Run Tests ---

echo "Running edit-review-checkpoint.sh tests..."
echo ""

run_test "Allow under threshold (9 edits)" test_allow_under_threshold
run_test "Block at threshold (10 edits)" test_block_at_threshold
run_test "Allow with pass documented" test_allow_with_pass_documented
run_test "Skip test files" test_skip_test_files
run_test "Skip config files" test_skip_config_files
run_test "Skip markdown files" test_skip_markdown_files
run_test "Custom threshold via env var" test_custom_threshold
run_test "Skip checkpoint bypass marker" test_skip_checkpoint_bypass
run_test "No transcript allows (can't verify)" test_no_transcript_allows
run_test "Write tool also counted" test_write_tool_also_counted
run_test "Mixed Edit/Write count together" test_mixed_edit_write

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
