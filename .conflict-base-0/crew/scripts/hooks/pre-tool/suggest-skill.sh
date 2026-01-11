#!/usr/bin/env bash
# Suggest relevant skills based on command being run
# Non-blocking - provides tips without preventing the action

set +e

INPUT=$(cat)

# Single jq call to extract both fields (performance optimization)
read -r TOOL_NAME COMMAND < <(echo "$INPUT" | jq -r '[.tool_name // "", .tool_input.command // ""] | @tsv' 2>/dev/null)

# Only check Bash tool
[[ $TOOL_NAME != "Bash" ]] && exit 0

# Extract first line of command
CMD_LINE="${COMMAND%%$'\n'*}"

# Suggestion messages based on command patterns
SUGGESTION=""

# Git commit - suggest git skill
if [[ $CMD_LINE =~ ^git\ commit ]]; then
	SUGGESTION="⚠️ **USE SKILL:** Use Skill(skill: \"crew:git:commit\") for guided commits with conventions."
fi

# Direct test/lint commands - suggest /crew:work:ci
if [[ $CMD_LINE =~ (npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?(test|lint|format|typecheck)([[:space:]]|$) ]] ||
	[[ $CMD_LINE =~ ^[[:space:]]*(vitest|jest|biome|eslint|prettier|tsc)[[:space:]] ]]; then
	SUGGESTION="⚠️ **USE SKILL:** Use Skill(skill: \"crew:work:ci\") to run CI in background (keeps main thread responsive)."
fi

# Git push - remind about CI
if [[ $CMD_LINE =~ ^git\ push ]]; then
	SUGGESTION="⚠️ **BEFORE PUSHING:** Use Skill(skill: \"crew:work:ci\") to catch issues early."
fi

# Sed/grep patterns that look like code refactoring - suggest ast-grep
# Patterns: sed with s/ replacement, for loops with sed/grep, grep -l piped to xargs
if [[ $CMD_LINE =~ sed[[:space:]]+-i?[[:space:]]*[\'\"]?s/ ]] ||
	[[ $CMD_LINE =~ for[[:space:]]+.*in.*\$\(.*grep ]] ||
	[[ $CMD_LINE =~ grep[[:space:]]+-[lr].*\|.*sed ]] ||
	[[ $CMD_LINE =~ grep[[:space:]]+-[lr].*\|.*xargs ]] ||
	[[ $COMMAND =~ import.*from ]] && [[ $CMD_LINE =~ sed ]]; then
	SUGGESTION="⚠️ **USE SKILL:** Consider Skill(skill: \"crew:ast-grep\") for syntax-aware code refactoring. ast-grep understands code structure, ignores strings/comments, and is safer for mass changes."
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
