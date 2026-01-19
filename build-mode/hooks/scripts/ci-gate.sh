#!/usr/bin/env bash
# CI gate hook - validates lint and test status after bash commands
# Only triggers on commands that look like they're running tests or lint
set -uo pipefail

# Read input from stdin
INPUT=$(cat)

# Extract the command that was run
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
# Note: tool_result is available but we use exit_code for logic

# Only trigger on test/lint related commands
if [[ ! "$COMMAND" =~ (test|lint|ci|check|build) ]]; then
  # Not a CI-related command, just pass through
  echo '{"continue": true, "suppressOutput": true}'
  exit 0
fi

# Check if the command failed
EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_result_exit_code // 0')

if [[ "$EXIT_CODE" != "0" ]]; then
  # Command failed - provide helpful feedback
  if [[ "$COMMAND" =~ test ]]; then
    cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "## CI Gate: Test Failure Detected

The test command failed. Before proceeding:

1. **Read the error output** - Identify which test(s) failed
2. **Understand the failure** - Is it the expected RED phase or an unexpected regression?
3. **If RED phase** - Proceed with GREEN (write minimal code to pass)
4. **If regression** - Stop and investigate before continuing

Do NOT proceed with more changes until you understand why tests failed."
}
EOF
  elif [[ "$COMMAND" =~ lint ]]; then
    cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "## CI Gate: Lint Failure Detected

Lint errors found. Fix these before proceeding:

1. Read the lint output to identify issues
2. Fix each issue in order
3. Re-run lint to verify clean
4. Continue with implementation only after lint passes

Common fixes:
- Unused imports: Remove them
- Type errors: Add proper types
- Formatting: Run formatter"
}
EOF
  else
    cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "## CI Gate: Command Failed

The command \`$COMMAND\` failed with exit code $EXIT_CODE.

Investigate before proceeding. Check the output for error details."
}
EOF
  fi
else
  # Command succeeded - brief acknowledgment for test/lint
  if [[ "$COMMAND" =~ test ]]; then
    echo '{"continue": true, "suppressOutput": false, "systemMessage": "Tests passed. Proceed with next step."}'
  elif [[ "$COMMAND" =~ lint ]]; then
    echo '{"continue": true, "suppressOutput": false, "systemMessage": "Lint clean. Proceed with next step."}'
  else
    echo '{"continue": true, "suppressOutput": true}'
  fi
fi
