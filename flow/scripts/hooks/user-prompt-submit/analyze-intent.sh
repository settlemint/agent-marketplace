#!/usr/bin/env bash
# Analyze user intent and suggest relevant workflows
# Runs on: UserPromptSubmit

set -euo pipefail

# Read user prompt from stdin
USER_PROMPT=$(cat)
PROMPT_TEXT=$(echo "$USER_PROMPT" | jq -r '.prompt // ""' | tr '[:upper:]' '[:lower:]')

# Skip if no prompt
if [[ -z "$PROMPT_TEXT" ]]; then
	exit 0
fi

# Pattern matching for workflow suggestions
if [[ "$PROMPT_TEXT" =~ (start|begin|create).*(workflow|process|project) ]]; then
	echo "Tip: Use /flow:workflow:start to begin a structured workflow"
elif [[ "$PROMPT_TEXT" =~ (analyze|audit|review).*(code|codebase|project) ]]; then
	echo "Tip: Use /flow:analyze for systematic codebase analysis"
elif [[ "$PROMPT_TEXT" =~ (optimize|improve|refactor) ]]; then
	echo "Tip: Use /flow:suggest for improvement recommendations"
elif [[ "$PROMPT_TEXT" =~ (status|progress|where) ]]; then
	echo "Tip: Use /flow:status to see current workflow status"
fi

exit 0
