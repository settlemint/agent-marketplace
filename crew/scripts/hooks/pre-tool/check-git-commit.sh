#!/bin/bash
# Block direct git commit and guide to /crew:git:commit skill
# Uses JSON permissionDecision for clean UX (no red error blocks)
# Allows commits with [skill] marker in message (used by /crew:git:commit skill)
set +e

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Block direct git commit unless it contains [skill] marker
if echo "$cmd" | grep -qE '^git commit' && ! echo "$cmd" | grep -qF '[skill]'; then
	cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "REDIRECT: Invoke Skill({skill: \"crew:git:commit\"}) now"
  }
}
EOF
	exit 0
fi
