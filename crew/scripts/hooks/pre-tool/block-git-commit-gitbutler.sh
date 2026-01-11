#!/usr/bin/env bash
# Block direct git commit when GitButler is active
# Uses permissionDecision: deny to block the tool call

set +e

INPUT=$(cat)

# Extract tool name and command
read -r TOOL_NAME COMMAND < <(echo "$INPUT" | jq -r '[.tool_name // "", .tool_input.command // ""] | @tsv' 2>/dev/null)

# Only check Bash tool
[[ $TOOL_NAME != "Bash" ]] && exit 0

# Extract first line of command
CMD_LINE="${COMMAND%%$'\n'*}"

# Only check git commit commands
if [[ ! $CMD_LINE =~ ^git\ commit ]] && [[ ! $CMD_LINE =~ \&\&[[:space:]]*git\ commit ]]; then
	exit 0
fi

# Check if GitButler is active in current directory
if [[ ! -d ".git/gitbutler" ]]; then
	exit 0
fi

# GitButler is active and we're trying to git commit - BLOCK IT
jq -n '{
  "permissionDecision": "deny",
  "permissionDecisionReason": "⛔ BLOCKED: GitButler is active in this repository.\n\nDirect git commits bypass GitButler virtual branches and corrupt workspace state.\n\nUse one of these instead:\n- MCP tool: mcp__gitbutler__gitbutler_update_branches\n- Skill: crew:git:butler:commit\n\nTo use direct git commits, first disable GitButler in this repository."
}'

exit 0
