#!/usr/bin/env bash
# Output loop state for prompt-based stop hook evaluation
# This script provides context that the prompt can use to make decisions

set +e

cd "$CLAUDE_PROJECT_DIR" || exit 0

# Get current branch for state file location
BRANCH=$(git branch --show-current 2>/dev/null || echo '')
if [[ -z $BRANCH ]]; then
	BRANCH=$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')
fi
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
STATE_FILE=".claude/branches/$SAFE_BRANCH/state.json"

# Output structured state for the prompt
echo "branch: $SAFE_BRANCH"
echo "state_file: $STATE_FILE"

# Check if state file exists
if [[ ! -f $STATE_FILE ]]; then
	echo "loop_exists: false"
	echo "loop_active: false"
	exit 0
fi

# Validate JSON
if ! jq empty "$STATE_FILE" 2>/dev/null; then
	echo "loop_exists: false"
	echo "loop_active: false"
	echo "error: invalid JSON in state file"
	exit 0
fi

echo "loop_exists: true"

# Extract loop state (single jq call for performance)
LOOP_DATA=$(jq -r '[
  (.loop.active // false | tostring),
  (.loop.iteration // 1 | tostring),
  (.loop.maxIterations // 10 | tostring),
  .loop.completionPromise // "BUILD COMPLETE",
  .loop.prompt // ""
] | @tsv' "$STATE_FILE" 2>/dev/null)

IFS=$'\t' read -r ACTIVE ITERATION MAX_ITERATIONS COMPLETION_PROMISE PROMPT <<<"$LOOP_DATA"

echo "loop_active: $ACTIVE"
echo "iteration: $ITERATION"
echo "max_iterations: $MAX_ITERATIONS"
echo "completion_promise: $COMPLETION_PROMISE"

# Check for pending tasks
TASKS_DIR=".claude/branches/$SAFE_BRANCH/tasks"
if [[ -d $TASKS_DIR ]]; then
	PENDING=$(find "$TASKS_DIR" -maxdepth 1 -name '*-pending-*' -type f 2>/dev/null | wc -l | tr -d ' ')
	COMPLETE=$(find "$TASKS_DIR" -maxdepth 1 -name '*-complete-*' -type f 2>/dev/null | wc -l | tr -d ' ')
	echo "pending_tasks: $PENDING"
	echo "complete_tasks: $COMPLETE"
else
	echo "pending_tasks: 0"
	echo "complete_tasks: 0"
fi

# Output the loop prompt if present
if [[ -n $PROMPT ]]; then
	echo ""
	echo "loop_prompt: |"
	echo "$PROMPT" | sed 's/^/  /'
fi

exit 0
