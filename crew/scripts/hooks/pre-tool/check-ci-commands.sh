#!/usr/bin/env bash
# Intercept CI commands (test, lint, format, typecheck) in main thread
# Guide Claude to use /crew:ci background agents instead
#
# PERFORMANCE: Uses JSON permissionDecision instead of exit 2 for cleaner UX
# This avoids ugly red error blocks while still blocking the command

set +e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Only check Bash tool
[[ $TOOL_NAME != "Bash" ]] && exit 0

# Fast regex check for CI-related commands (avoids array iteration)
if [[ $COMMAND =~ (npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?(test|lint|format|typecheck|ci)([[:space:]]|$) ]] ||
	[[ $COMMAND =~ (vitest|jest|biome|eslint|prettier|ultracite|tsc)[[:space:]] ]] ||
	[[ $COMMAND =~ (bunx|npx|pnpm[[:space:]]exec)[[:space:]]+(vitest|jest|biome|ultracite) ]]; then

	# Use JSON response with permissionDecision for clean UX (no red error block)
	cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "CI commands should run in background agents to keep context focused.\n\nInvoke the /crew:ci skill instead:\n  Skill({skill: \"crew:ci\"})\n\nThis runs tests/lint/typecheck in parallel haiku agents with automatic result tracking."
  }
}
EOF
	exit 0
fi

exit 0
