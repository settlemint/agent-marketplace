#!/usr/bin/env bash
# Redirect CI commands to /crew:ci skill automatically
# Uses minimal deny message so Claude auto-invokes the skill

set +e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Only check Bash tool
[[ $TOOL_NAME != "Bash" ]] && exit 0

# Skip if this is a subagent running via /crew:ci (prevents recursion)
if [[ $COMMAND == *"CREW_CI_SUBAGENT=1"* ]]; then
	exit 0
fi

# Extract just the command portion (before any heredoc or quoted string body)
CMD_FIRST_LINE="${COMMAND%%$'\n'*}"

# Fast regex check for CI-related commands
if [[ $CMD_FIRST_LINE =~ (npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?(test|lint|format|typecheck|ci)([[:space:]]|$) ]] ||
	[[ $CMD_FIRST_LINE =~ ^[[:space:]]*(vitest|jest|biome|eslint|prettier|ultracite|tsc)[[:space:]] ]] ||
	[[ $CMD_FIRST_LINE =~ (^|[;\&\|][[:space:]]*)(vitest|jest|biome|eslint|prettier|ultracite|tsc)[[:space:]] ]] ||
	[[ $CMD_FIRST_LINE =~ (bunx|npx|pnpm[[:space:]]exec)[[:space:]]+(vitest|jest|biome|ultracite) ]]; then

	# Directive deny - Claude will auto-invoke /crew:ci
	cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "REDIRECT: Invoke Skill({skill: \"crew:ci\"}) now"
  }
}
EOF
	exit 0
fi

exit 0
