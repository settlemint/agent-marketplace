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

# Skip if this is a subagent running via /crew:ci (prevents recursion)
# The ci.md skill prefixes commands with CREW_CI_SUBAGENT=1
if [[ $COMMAND == *"CREW_CI_SUBAGENT=1"* ]]; then
  exit 0
fi

# Extract just the command portion (before any heredoc or quoted string body)
# This prevents matching tool names in PR bodies, commit messages, etc.
CMD_FIRST_LINE="${COMMAND%%$'\n'*}"

# Fast regex check for CI-related commands (avoids array iteration)
# Only match actual command invocations, not mentions in text
if [[ $CMD_FIRST_LINE =~ (npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?(test|lint|format|typecheck|ci)([[:space:]]|$) ]] ||
  [[ $CMD_FIRST_LINE =~ ^[[:space:]]*(vitest|jest|biome|eslint|prettier|ultracite|tsc)[[:space:]] ]] ||
  [[ $CMD_FIRST_LINE =~ (^|[;\&\|][[:space:]]*)(vitest|jest|biome|eslint|prettier|ultracite|tsc)[[:space:]] ]] ||
  [[ $CMD_FIRST_LINE =~ (bunx|npx|pnpm[[:space:]]exec)[[:space:]]+(vitest|jest|biome|ultracite) ]]; then

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
