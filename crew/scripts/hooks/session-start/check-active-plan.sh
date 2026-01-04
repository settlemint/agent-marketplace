#!/bin/bash
# Check for active plan file on current branch
# Hooks must never fail - use defensive error handling
set +e

branch=$(git -C "$CLAUDE_PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
plan="$CLAUDE_PROJECT_DIR/.claude/plans/${branch}.plan.md"

if [[ -n $branch && -f $plan ]]; then
	echo "ACTIVE PLAN: ${branch}.plan.md exists. Resume work by invoking Skill({skill: \"workflows:work\"})"
fi
