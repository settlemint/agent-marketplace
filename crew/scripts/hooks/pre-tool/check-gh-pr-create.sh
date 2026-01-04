#!/bin/bash
# Block direct gh pr create and suggest skill instead
# Hooks must never fail - use defensive error handling
set +e

source "$(dirname "$0")/../lib/hook-logger.sh" 2>/dev/null || true

input=$(cat)
result="success"

if echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null | grep -qE 'gh pr create'; then
	echo 'STOP: Use Skill({skill: "commit-commands:commit-push-pr"}) instead for templated PRs with proper summary and test plan format.'
	result="blocked"
fi

log_hook "PreToolUse" "check-gh-pr-create" "$result" 2>/dev/null || true
