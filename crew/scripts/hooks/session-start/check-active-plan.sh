#!/bin/bash
# Check for active plan file on current branch
# Hooks must never fail - use defensive error handling
set +e

source "$(dirname "$0")/../lib/hook-logger.sh" 2>/dev/null || true

branch=$(git -C "$CLAUDE_PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
plan="$CLAUDE_PROJECT_DIR/.claude/plans/${branch}.plan.md"
result="no-plan"

if [[ -n $branch && -f $plan ]]; then
	echo "ACTIVE PLAN: ${branch}.plan.md exists. Resume work by invoking Skill({skill: \"workflows:work\"})"
	result="plan-found"
fi

log_hook "SessionStart" "check-active-plan" "$result" "$branch" 2>/dev/null || true
