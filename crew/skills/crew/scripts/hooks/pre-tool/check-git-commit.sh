#!/bin/bash
# Block direct git commit and require CI check first
# Hooks must never fail - use defensive error handling
set +e

source "$(dirname "$0")/../lib/hook-logger.sh" 2>/dev/null || true

input=$(cat)
result="success"
cmd=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Block direct git commit
if echo "$cmd" | grep -qE '^git commit'; then
	echo 'STOP: Do not run git commit directly. REQUIRED: First run "bun run ci" to verify tests pass. Then invoke Skill({skill: "commit-commands:commit"}) for proper commit message format.'
	result="blocked"
fi

log_hook "PreToolUse" "check-git-commit" "$result" 2>/dev/null || true
