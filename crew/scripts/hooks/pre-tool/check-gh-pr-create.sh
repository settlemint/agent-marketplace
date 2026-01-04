#!/bin/bash
# Block direct gh pr create and suggest skill instead
# Hooks must never fail - use defensive error handling
set +e

input=$(cat)

if echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null | grep -qE 'gh pr create'; then
	echo 'STOP: Use Skill({skill: "commit-commands:commit-push-pr"}) instead for templated PRs with proper summary and test plan format.'
fi
