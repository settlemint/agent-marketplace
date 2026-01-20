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
  # Test file - encourage with brief message
  cat <<EOFMSG
{
  "decision": "approve",
  "systemMessage": "Writing test first. Good TDD practice."
}
EOFMSG
else
  # Implementation file - remind about TDD
  cat <<EOFMSG
{
  "decision": "approve",
  "systemMessage": "TDD Reminder: This is implementation code. Ensure you wrote a failing test first and watched it fail before writing this code."
}
EOFMSG
fi
