#!/bin/bash
# Block direct gh pr create and guide to /crew:git:pr skill
# Uses JSON permissionDecision for clean UX (no red error blocks)
set +e

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)

if echo "$cmd" | grep -qE 'gh pr create'; then
	cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Use the /crew:git:pr skill for templated PRs with proper summary and test plan.\n\nInvoke: Skill({skill: \"crew:git:pr\"})\n\nThis creates PRs with consistent formatting and handles machete stacks automatically."
  }
}
EOF
	exit 0
fi
