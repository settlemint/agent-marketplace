#!/usr/bin/env bash
# Suggest relevant devtools skills based on command being run
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

# Vitest - suggest vitest skill
if [[ $CMD_LINE =~ vitest|bun\ run\ test|npm\ run\ test|pnpm\ run\ test ]]; then
	SUGGESTION="Tip: Check the vitest skill for testing patterns, mocking, and coverage."
fi

# Playwright - suggest playwright skill
if [[ $CMD_LINE =~ playwright|bun\ run\ e2e|npm\ run\ e2e ]]; then
	SUGGESTION="Tip: Check the playwright skill for Page Object patterns and web-first assertions."
fi

# Drizzle migrations
if [[ $CMD_LINE =~ drizzle|migration|db\ push|db\ pull ]]; then
	SUGGESTION="Tip: Check the drizzle skill for schema patterns and migrations."
fi

# Biome/ESLint
if [[ $CMD_LINE =~ biome|eslint|lint ]]; then
	SUGGESTION="Tip: PostToolUse hook auto-lints modified files. Check troubleshooting skill for common lint issues."
fi

# Helm
if [[ $CMD_LINE =~ helm|kubectl ]]; then
	SUGGESTION="Tip: Check the helm skill for chart patterns and values.yaml conventions."
fi

# Git machete
if [[ $CMD_LINE =~ git\ machete|machete ]]; then
	SUGGESTION="Tip: Check the git-machete skill for stacked PR workflows."
fi

# Output suggestion if we have one
if [[ -n $SUGGESTION ]]; then
	jq -n --arg msg "$SUGGESTION" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "message": $msg
    }
  }'
fi

exit 0
