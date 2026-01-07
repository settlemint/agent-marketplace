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

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Read stdin to get event info
INPUT=$(cat)
EVENT_TYPE=$(echo "$INPUT" | jq -r '.type // "unknown"' 2>/dev/null)

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
    (.loop.active // false | tostring),
    (.loop.iteration // 0 | tostring),
    (.loop.maxIterations // 10 | tostring),
    .loop.completionPromise // "",
    (.tasks.pending // 0 | tostring),
    (.tasks.p1 // 0 | tostring),
    (.tasks.p2 // 0 | tostring),
    (.tasks.p3 // 0 | tostring),
    .tasks.next // ""
  ] | @tsv
' "$STATE_FILE" 2>/dev/null)

# Parse tab-separated values into variables
IFS=$'\t' read -r COMPACTED_AT PLAN_EXISTS PLAN_FILE PLAN_PREVIEW_ESC PENDING_COUNT TODOS_JSON \
  ACTIVE_WORKFLOW WORKFLOW_ARGS LOOP_ACTIVE LOOP_ITERATION LOOP_MAX LOOP_PROMISE \
  TASKS_PENDING TASKS_P1 TASKS_P2 TASKS_P3 NEXT_TASK <<<"$STATE_DATA"

# Unescape newlines in plan preview
PLAN_PREVIEW=$(echo -e "$PLAN_PREVIEW_ESC")

# Exit if no compaction timestamp (invalid state file)
if [[ -z $COMPACTED_AT ]]; then
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

# Show plan context if exists (include preview to avoid file read)
if [[ $PLAN_EXISTS == "true" && -n $PLAN_PREVIEW ]]; then
  echo "CONTEXT: Active plan at $PLAN_FILE"
  echo "─────────────────────────────────────────"
  echo "$PLAN_PREVIEW"
  echo "─────────────────────────────────────────"
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
  echo "  **Resume with:** Skill(skill: \"crew:build\")"
  echo ""
fi

# Show active loop state if loop is in progress
if [[ $LOOP_ACTIVE == "true" ]]; then
  echo "ACTION REQUIRED: Resume iteration loop (iteration $LOOP_ITERATION of $LOOP_MAX)"
  echo "  Completion promise: <promise>$LOOP_PROMISE</promise>"
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
