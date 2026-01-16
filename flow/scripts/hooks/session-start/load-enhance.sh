#!/usr/bin/env bash
# Load the flow:enhance skill at session start
# This provides Rule of Five convergence patterns for all agent types
#
# The skill is a router that directs to appropriate workflows based on context:
# - Explore agent -> workflows/explore.md
# - Plan agent -> workflows/plan.md
# - General-purpose agent -> workflows/general-purpose.md
# - Review tasks -> workflows/review.md
# - Open PR context -> workflows/pr-awareness.md

set +e

# Read event data from stdin
EVENT_DATA=$(cat)

# Skip for subagents - they should load skills via prompt instructions
# Use tr for lowercase conversion (bash 3.2 compatible, avoids ${var,,} syntax)
AGENT_TYPE=$(echo "$EVENT_DATA" | jq -r '.agent_type // "main"' 2>/dev/null || echo "main")
AGENT_TYPE_LOWER=$(echo "$AGENT_TYPE" | tr '[:upper:]' '[:lower:]')
if [[ "$AGENT_TYPE_LOWER" != "main" ]]; then
  exit 0
fi

echo '<skill-load required="true">'
echo 'REQUIRED: Load the enhance skill for Rule of Five convergence patterns.'
echo 'Call this skill NOW, then proceed with the task.'
echo ''
echo 'Skill({ skill: "flow:enhance" })'
echo '</skill-load>'
