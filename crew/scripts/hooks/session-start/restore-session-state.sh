#!/usr/bin/env bash
# Restore session state after compaction or resume
# Called by SessionStart hook to provide recovery context
#
# Key design: Output is structured so Claude can immediately act on it
# - Plan preview included directly (no need to read file)
# - Todos in TodoWrite-compatible format
# - Minimal output to avoid context overload
#
# PERFORMANCE: Uses single jq call instead of 15+ separate invocations
# This reduces startup time by ~400ms

# Hooks must never fail - use defensive error handling
set +e

is_truthy() {
	case "${1:-}" in
		1|true|yes|on) return 0 ;;
		*) return 1 ;;
	esac
}

QUIET="${CLAUDE_QUIET:-${CREW_QUIET:-}}"
TOKEN_SAVER="${CLAUDE_TOKEN_SAVER:-${CREW_TOKEN_SAVER:-}}"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Read stdin to get event info (includes agent_type since v2.1.2)
INPUT=$(cat)
EVENT_TYPE=$(echo "$INPUT" | jq -r '.type // "unknown"' 2>/dev/null)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // ""' 2>/dev/null)

# Skip for subagents - they don't need session state restoration
if [[ -n "$AGENT_TYPE" && "$AGENT_TYPE" != "null" ]]; then
	exit 0
fi

# Get branch info (handle detached HEAD)
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
if [[ -z $BRANCH ]]; then
	BRANCH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo 'unknown')
fi
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')

# State location: .claude/branches/{branch}/state.json
BRANCH_DIR="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH"
STATE_FILE="$BRANCH_DIR/state.json"

# On fresh startup, skip - user should run /crew:restart manually
# Hook output on startup is not actionable by Claude
if [[ $EVENT_TYPE == "startup" ]]; then
	exit 0
fi

# For compact/resume events, also restore from state.json
# Exit if file doesn't exist or contains invalid JSON
if [[ ! -f $STATE_FILE ]] || ! jq empty "$STATE_FILE" 2>/dev/null; then
	exit 0
fi

# PERFORMANCE: Single jq call extracts all fields at once
# Output format: tab-separated values, with newlines escaped
STATE_DATA=$(jq -r '
  [
    .compacted_at // "",
    (.plan.exists // false | tostring),
    .plan.file // "",
    (.plan.preview // "" | gsub("\n"; "\\n")),
    (.execution.pending_count // .todos.pending_count // 0 | tostring),
    (.execution.todos // .todos.items // [] | @json),
    .workflow.active // .active_workflow // "",
    .workflow.args // .workflow_args // "",
    (.tasks.pending // 0 | tostring),
    (.tasks.p1 // 0 | tostring),
    (.tasks.p2 // 0 | tostring),
    (.tasks.p3 // 0 | tostring),
    .tasks.next // ""
  ] | @tsv
' "$STATE_FILE" 2>/dev/null)

# Parse tab-separated values into variables
# Note: _ is used for unused PLAN_PREVIEW_ESC (removed for token savings)
IFS=$'\t' read -r COMPACTED_AT PLAN_EXISTS PLAN_FILE _ PENDING_COUNT TODOS_JSON \
	ACTIVE_WORKFLOW WORKFLOW_ARGS TASKS_PENDING TASKS_P1 TASKS_P2 TASKS_P3 NEXT_TASK <<<"$STATE_DATA"

# Exit if no compaction timestamp (invalid state file)
if [[ -z $COMPACTED_AT ]]; then
	exit 0
fi

# Quiet mode: suppress output entirely
if is_truthy "$QUIET"; then
	exit 0
fi

# Token-saver mode: output minimal context
if is_truthy "$TOKEN_SAVER"; then
	echo ""
	echo "CONTEXT: Session state recovered from $EVENT_TYPE (compacted at $COMPACTED_AT)"
	echo ""

	if [[ -n $ACTIVE_WORKFLOW ]]; then
		echo "Resume workflow: Skill({skill: \"$ACTIVE_WORKFLOW\"${WORKFLOW_ARGS:+, args: \"$WORKFLOW_ARGS\"}})"
	fi

	if [[ $PLAN_EXISTS == "true" && -n $PLAN_FILE ]]; then
		echo "Plan: $PLAN_FILE"
	fi

	if [[ $PENDING_COUNT -gt 0 && $TODOS_JSON != "[]" ]]; then
		echo "Todos: $PENDING_COUNT pending (use /crew:restore for details)"
	fi

	if [[ $TASKS_PENDING -gt 0 ]]; then
		PRIORITY_BREAKDOWN=""
		[[ $TASKS_P1 -gt 0 ]] && PRIORITY_BREAKDOWN="${TASKS_P1} P1"
		[[ $TASKS_P2 -gt 0 ]] && PRIORITY_BREAKDOWN="${PRIORITY_BREAKDOWN:+$PRIORITY_BREAKDOWN, }${TASKS_P2} P2"
		[[ $TASKS_P3 -gt 0 ]] && PRIORITY_BREAKDOWN="${PRIORITY_BREAKDOWN:+$PRIORITY_BREAKDOWN, }${TASKS_P3} P3"
		echo "Tasks: $TASKS_PENDING pending ($PRIORITY_BREAKDOWN). Next: $NEXT_TASK"
	fi

	AGENTS_FILE="$BRANCH_DIR/agents.json"
	if [[ -f $AGENTS_FILE ]] && jq empty "$AGENTS_FILE" 2>/dev/null; then
		CURRENT_EPOCH=$(date +%s)
		TIMEOUT_SECONDS=300
		RUNNING_AGENTS=$(jq -r '[.agents[] | select(.status == "running")] | length' "$AGENTS_FILE" 2>/dev/null)
		STUCK_AGENTS=$(jq -r --argjson now "$CURRENT_EPOCH" --argjson timeout "$TIMEOUT_SECONDS" \
			'[.agents[] | select(.status == "running" and ($now - .spawned_epoch) > $timeout)] | length' "$AGENTS_FILE" 2>/dev/null)
		if [[ $RUNNING_AGENTS -gt 0 || $STUCK_AGENTS -gt 0 ]]; then
			echo "Agents: $RUNNING_AGENTS running, $STUCK_AGENTS stuck"
		fi
	fi

	echo ""
	exit 0
fi

# Output structured recovery context
echo ""
echo "CONTEXT: Session state recovered from $EVENT_TYPE (compacted at $COMPACTED_AT)"
echo ""

# Show active workflow first (highest priority)
if [[ -n $ACTIVE_WORKFLOW ]]; then
	echo "ACTION REQUIRED: Resume active workflow"
	echo "  Skill({skill: \"$ACTIVE_WORKFLOW\"${WORKFLOW_ARGS:+, args: \"$WORKFLOW_ARGS\"}})"
	echo ""
fi

# Show plan reference if exists (preview removed to save ~500 tokens)
if [[ $PLAN_EXISTS == "true" && -n $PLAN_FILE ]]; then
	echo "CONTEXT: Active plan at $PLAN_FILE (use Read tool if needed)"
	echo ""
fi

# Show todos in TodoWrite-ready format (TodoWrite takes array directly, not object)
if [[ $PENDING_COUNT -gt 0 && $TODOS_JSON != "[]" ]]; then
	echo "CONTEXT: Restore todos with TodoWrite($TODOS_JSON)"
	echo ""
fi

# Propulsion: Surface pending tasks for autonomous continuation
if [[ $TASKS_PENDING -gt 0 ]]; then
	# Build priority breakdown string
	PRIORITY_BREAKDOWN=""
	[[ $TASKS_P1 -gt 0 ]] && PRIORITY_BREAKDOWN="${TASKS_P1} P1"
	[[ $TASKS_P2 -gt 0 ]] && PRIORITY_BREAKDOWN="${PRIORITY_BREAKDOWN:+$PRIORITY_BREAKDOWN, }${TASKS_P2} P2"
	[[ $TASKS_P3 -gt 0 ]] && PRIORITY_BREAKDOWN="${PRIORITY_BREAKDOWN:+$PRIORITY_BREAKDOWN, }${TASKS_P3} P3"

	echo "ACTION REQUIRED: Found $TASKS_PENDING pending tasks ($PRIORITY_BREAKDOWN)"
	echo "  Next: $NEXT_TASK"
	echo "  **Resume with:** Skill(skill: \"crew:work\")"
	echo ""
fi

# Witness: Check for stuck agents from previous session
AGENTS_FILE="$BRANCH_DIR/agents.json"
if [[ -f $AGENTS_FILE ]] && jq empty "$AGENTS_FILE" 2>/dev/null; then
	CURRENT_EPOCH=$(date +%s)
	TIMEOUT_SECONDS=300 # 5 minutes

	# Count running agents
	RUNNING_AGENTS=$(jq -r '[.agents[] | select(.status == "running")] | length' "$AGENTS_FILE" 2>/dev/null)

	if [[ $RUNNING_AGENTS -gt 0 ]]; then
		echo "WITNESS: $RUNNING_AGENTS agents were running when session ended"

		# Check for stuck agents
		STUCK_AGENTS=$(jq -r --argjson now "$CURRENT_EPOCH" --argjson timeout "$TIMEOUT_SECONDS" \
			'[.agents[] | select(.status == "running" and ($now - .spawned_epoch) > $timeout)] | length' "$AGENTS_FILE" 2>/dev/null)

		if [[ $STUCK_AGENTS -gt 0 ]]; then
			echo "  ⚠️  $STUCK_AGENTS agents exceeded timeout threshold"
			echo ""

			# List stuck agents
			jq -r --argjson now "$CURRENT_EPOCH" --argjson timeout "$TIMEOUT_SECONDS" \
				'.agents[] | select(.status == "running" and ($now - .spawned_epoch) > $timeout) |
        "  - \(.description) (ID: \(.id), running \((($now - .spawned_epoch) / 60 | floor))m)"' "$AGENTS_FILE" 2>/dev/null

			echo ""
			echo "  Recovery options:"
			echo "    TaskOutput({task_id: \"<id>\", block: true}) - Wait for completion"
			echo "    KillShell({shell_id: \"<id>\"}) - Terminate stuck agent"
			echo ""

			# Mark as stuck in the file (suppress errors to avoid polluting context)
			if jq --argjson now "$CURRENT_EPOCH" --argjson timeout "$TIMEOUT_SECONDS" \
				'(.agents[] | select(.status == "running" and ($now - .spawned_epoch) > $timeout)) |= . + {"status": "stuck"}' \
				"$AGENTS_FILE" >"${AGENTS_FILE}.tmp" 2>/dev/null; then
				mv "${AGENTS_FILE}.tmp" "$AGENTS_FILE"
			else
				rm -f "${AGENTS_FILE}.tmp"
			fi
		fi

		# Show agent stats
		STATS=$(jq -r '.stats | "Spawned: \(.total_spawned), Completed: \(.completed), Failed: \(.failed)"' "$AGENTS_FILE" 2>/dev/null)
		echo "  Stats: $STATS"
		echo ""
	fi
fi
