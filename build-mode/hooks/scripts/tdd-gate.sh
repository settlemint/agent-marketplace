#!/usr/bin/env bash
# TDD Gate - Fast file pattern check with contextual reminders (no LLM call)
set -uo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# Check file type and provide appropriate guidance
if [[ "$FILE_PATH" =~ \.(md|json|yaml|yml|toml|html|svg|css|lock)$ ]] || \
   [[ "$FILE_PATH" =~ \.claude/plans/ ]]; then
  # Non-code files - silent approval
  echo '{"decision": "approve"}'
elif [[ "$FILE_PATH" =~ (test|spec)\.(ts|tsx|js|jsx)$ ]] || \
     [[ "$FILE_PATH" =~ _test\.(py|go|rs)$ ]] || \
     [[ "$FILE_PATH" =~ test_.*\.py$ ]]; then
  # Test file - encourage with verification reminder
  cat <<EOFMSG
{
  "decision": "approve",
  "systemMessage": "Good: Writing test first. REQUIRED: Verify this test FAILS before writing implementation code."
}
EOFMSG
else
  # Implementation file - STRONG TDD enforcement
  cat <<EOFMSG
{
  "decision": "approve",
  "systemMessage": "<system-reminder>REQUIRED: TDD COMPLIANCE - This is implementation code. You MUST have written a FAILING test first and watched it fail BEFORE writing this code. If you did not: DELETE this code, write the test, verify RED, then re-implement. No exceptions.</system-reminder>"
}
EOFMSG
fi
