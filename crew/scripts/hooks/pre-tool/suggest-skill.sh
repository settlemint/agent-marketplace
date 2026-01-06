#!/usr/bin/env bash
# Suggest relevant skills based on command being run
# Non-blocking - provides tips without preventing the action

set +e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Only check Bash tool
[[ $TOOL_NAME != "Bash" ]] && exit 0

# Extract first line of command
CMD_LINE="${COMMAND%%$'\n'*}"

# Suggestion messages based on command patterns
SUGGESTION=""

# Git commit - suggest git skill
if [[ $CMD_LINE =~ ^git\ commit ]]; then
	SUGGESTION="Tip: Use /crew:git:commit for guided commits with context, or check the git skill for conventions."
fi

# Direct test/lint commands - suggest /crew:ci
if [[ $CMD_LINE =~ (npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?(test|lint|format|typecheck)([[:space:]]|$) ]] ||
	[[ $CMD_LINE =~ ^[[:space:]]*(vitest|jest|biome|eslint|prettier|tsc)[[:space:]] ]]; then
	SUGGESTION="Tip: Use /crew:ci to run CI in a background haiku agent (keeps main thread responsive)."
fi

# Git push - remind about CI
if [[ $CMD_LINE =~ ^git\ push ]]; then
	SUGGESTION="Tip: Run /crew:ci before pushing to catch issues early."
fi

# Output suggestion if we have one
if [[ -n $SUGGESTION ]]; then
	# Use jq to properly escape the suggestion for JSON
	jq -n --arg msg "$SUGGESTION" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "message": $msg
    }
  }'
fi

exit 0
