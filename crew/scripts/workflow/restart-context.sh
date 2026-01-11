#!/usr/bin/env bash
# Context script for /crew:restart command
# Scans for pending work and provides actionable context

set +e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Get branch info (handle detached HEAD)
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
if [[ -z $BRANCH ]]; then
	BRANCH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo 'unknown')
fi
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')

# State location
BRANCH_DIR="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH"
STATE_FILE="$BRANCH_DIR/state.json"
TASKS_DIR="$BRANCH_DIR/tasks"

echo "## Session State"
echo ""
echo "Branch: \`$BRANCH\`"
echo ""

FOUND_WORK=false

# Check for pending task files
if [[ -d $TASKS_DIR ]]; then
	PENDING_FILES=$(find "$TASKS_DIR" -maxdepth 1 -name "*-pending-*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
	if [[ $PENDING_FILES -gt 0 ]]; then
		FOUND_WORK=true

		# Count by priority
		P1_COUNT=$(find "$TASKS_DIR" -maxdepth 1 -name "*-pending-p1-*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
		P2_COUNT=$(find "$TASKS_DIR" -maxdepth 1 -name "*-pending-p2-*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
		P3_COUNT=$(find "$TASKS_DIR" -maxdepth 1 -name "*-pending-p3-*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

		# Build priority breakdown
		PRIORITY_BREAKDOWN=""
		[[ $P1_COUNT -gt 0 ]] && PRIORITY_BREAKDOWN="${P1_COUNT} P1"
		[[ $P2_COUNT -gt 0 ]] && PRIORITY_BREAKDOWN="${PRIORITY_BREAKDOWN:+$PRIORITY_BREAKDOWN, }${P2_COUNT} P2"
		[[ $P3_COUNT -gt 0 ]] && PRIORITY_BREAKDOWN="${PRIORITY_BREAKDOWN:+$PRIORITY_BREAKDOWN, }${P3_COUNT} P3"

		echo "### Pending Tasks"
		echo ""
		echo "Found **$PENDING_FILES pending tasks** ($PRIORITY_BREAKDOWN)"
		echo ""

		# List first 5 pending tasks
		echo "| Order | Priority | Task |"
		echo "|-------|----------|------|"
		find "$TASKS_DIR" -maxdepth 1 -name "*-pending-*.md" -type f 2>/dev/null | sort | head -5 | while read -r file; do
			basename "$file" | sed 's/\.md$//' | awk -F'-' '{
        order=$1
        priority=$3
        # Join remaining parts as task name
        task=""
        for(i=5;i<=NF;i++) task=task (task?"-":"") $i
        printf "| %s | %s | %s |\n", order, toupper(priority), task
      }'
		done
		echo ""
		echo "**ACTION REQUIRED:** Use Skill(skill: \"crew:work\") to resume"
		echo ""
	fi
fi

# Check for state.json with active workflow or todos
if [[ -f $STATE_FILE ]]; then
	# Check for active workflow
	ACTIVE_WORKFLOW=$(jq -r '.workflow.active // .active_workflow // empty' "$STATE_FILE" 2>/dev/null)
	WORKFLOW_ARGS=$(jq -r '.workflow.args // .workflow_args // empty' "$STATE_FILE" 2>/dev/null)

	if [[ -n $ACTIVE_WORKFLOW ]]; then
		FOUND_WORK=true
		echo "### Active Workflow"
		echo ""
		echo "Workflow: \`$ACTIVE_WORKFLOW\`"
		[[ -n $WORKFLOW_ARGS ]] && echo "Args: \`$WORKFLOW_ARGS\`"
		echo ""
		echo "**Action**: \`Skill({skill: \"$ACTIVE_WORKFLOW\"${WORKFLOW_ARGS:+, args: \"$WORKFLOW_ARGS\"}})\`"
		echo ""
	fi

	# Check for pending todos
	PENDING_COUNT=$(jq -r '.execution.pending_count // .todos.pending_count // 0' "$STATE_FILE" 2>/dev/null)
	TODOS_JSON=$(jq -c '.execution.todos // .todos.items // []' "$STATE_FILE" 2>/dev/null)

	if [[ $PENDING_COUNT -gt 0 && $TODOS_JSON != "[]" ]]; then
		FOUND_WORK=true
		echo "### Saved Todos"
		echo ""
		echo "Found **$PENDING_COUNT pending todos** to restore"
		echo ""
		echo "**Action**: \`TodoWrite($TODOS_JSON)\`"
		echo ""
	fi

	# No loop handling (simplified workflow)
fi

# Check for plan files
PLAN_FILES=$(find "$PROJECT_DIR/.claude/plans" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
if [[ $PLAN_FILES -gt 0 ]]; then
	echo "### Available Plans"
	echo ""
	find "$PROJECT_DIR/.claude/plans" -name "*.md" -type f 2>/dev/null | while read -r file; do
		echo "- \`$(basename "$file")\`"
	done
	echo ""
fi

if [[ $FOUND_WORK == "false" ]]; then
	echo "### No Pending Work"
	echo ""
	echo "No pending tasks, active workflows, or saved state found for branch \`$BRANCH\`."
	echo ""
	echo "To start new work:"
	echo "- Use Skill(skill: \"crew:plan\") - Create a new implementation plan"
	echo "- Use Skill(skill: \"crew:work\", args: \"<plan>\") - Execute an existing plan"
	echo ""
fi
