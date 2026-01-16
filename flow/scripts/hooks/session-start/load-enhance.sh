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

echo '<skill-load required="true">'
echo 'REQUIRED: Load the enhance skill for Rule of Five convergence patterns.'
echo 'Call this skill NOW, then proceed with the task.'
echo ''
echo 'Skill({ skill: "flow:enhance" })'
echo '</skill-load>'
