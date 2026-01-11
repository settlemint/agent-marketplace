#!/usr/bin/env bash
# Enforce TDD workflow before ANY code modification
# Triggered on PreToolUse for Edit, MultiEdit, Write operations
#
# This is the universal TDD enforcement point - no code changes without tests.

set +e

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

# For implementation files, enforce TDD
cat <<'EOF'

<tdd-enforcement>
## TDD Required: Test First

You are about to modify **implementation code**. TDD discipline requires:

### RED-GREEN-REFACTOR Cycle

1. **RED** - Write a failing test FIRST
   - The test MUST fail before you write implementation
   - Run tests to confirm failure: `bun run test` or `vitest run`

2. **GREEN** - Write minimal code to pass
   - Only enough code to make the test pass
   - No extra functionality

3. **REFACTOR** - Improve while keeping tests green
   - Clean up, optimize, clarify
   - Tests must still pass

### Before This Edit

**Ask yourself:**
- Have I written a failing test for this functionality?
- Did I run the tests and confirm they fail?
- Am I writing the minimum code to pass?

### Load the TDD Skill

```javascript
Skill({ skill: "devtools:tdd-typescript" })
```

**If you haven't written a failing test first, STOP and write the test now.**

Coverage Requirements:
- Line coverage: 80% minimum
- Branch coverage: 75% minimum
- Function coverage: 90% minimum
- Critical paths: 100% mandatory

</tdd-enforcement>

EOF
