#!/bin/bash
# Block direct git commit and guide to /crew:git:commit skill
# Uses JSON permissionDecision for clean UX (no red error blocks)
set +e

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Block direct git commit
if echo "$cmd" | grep -qE '^git commit'; then
	cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Use the /crew:git:commit skill for proper conventional commit format.\n\nInvoke: Skill({skill: \"crew:git:commit\"})\n\nThis ensures consistent commit messages and runs pre-commit validation."
  }
}
EOF
	exit 0
fi
