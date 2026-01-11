#!/usr/bin/env bash
# Enforce TDD workflow before ANY code modification
# Triggered on PreToolUse for Edit, MultiEdit, Write operations
#
# This is the universal TDD enforcement point - no code changes without tests.
# OPTIMIZATION: Only outputs once per session (tracks via marker file)

set +e

# Session-level deduplication: only show TDD message once
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Get branch for marker location
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
if [[ -z $BRANCH ]]; then
  BRANCH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo 'unknown')
fi
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
BRANCH_DIR="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH"
TDD_MARKER="$BRANCH_DIR/.tdd-shown-$$"

# If already shown this session, skip
if [[ -f $TDD_MARKER ]]; then
  exit 0
fi

# Read tool input from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)

# Only process file modification tools
if [[ ! "$TOOL_NAME" =~ ^(Edit|MultiEdit|Write)$ ]]; then
  exit 0
fi

# Skip if no file path
if [[ -z $FILE_PATH ]]; then
  exit 0
fi

# Extract filename and extension
FILENAME=$(basename "$FILE_PATH")
EXTENSION="${FILENAME##*.}"

# Check if this is a code file that needs TDD enforcement
IS_TEST_FILE=false

case "$EXTENSION" in
  ts | tsx | js | jsx | py | rb | go | rs | java | kt | swift | c | cpp | cs)
    # Code file - continue to check if test
    ;;
  *)
    # Not a code file - skip TDD enforcement
    exit 0
    ;;
esac

# Check if this is a test file (allow test files without TDD warning)
if echo "$FILE_PATH" | grep -qE '(\.test\.|\.spec\.|_test\.|_spec\.|/tests?/|/__tests__/)'; then
  IS_TEST_FILE=true
fi

# Check if this is a fixture, mock, or test utility
if echo "$FILE_PATH" | grep -qE '(fixtures?/|mocks?/|__mocks__|test-utils|test-helpers|\.mock\.|\.fixture\.)'; then
  IS_TEST_FILE=true
fi

# If it's a test file, allow it - this is the RED phase
if [[ $IS_TEST_FILE == true ]]; then
  exit 0
fi

# For implementation files, enforce TDD (condensed output)
cat <<'EOF'

<tdd-enforcement>
**TDD Required** - Write failing test FIRST, then minimal code to pass.
RED→GREEN→REFACTOR. Coverage: 80% lines, 75% branches, 90% functions.
Load skill: `Skill({ skill: "devtools:tdd-typescript" })`
</tdd-enforcement>

EOF

# Mark as shown for this session (in branch folder)
mkdir -p "$BRANCH_DIR" 2>/dev/null
touch "$TDD_MARKER" 2>/dev/null
