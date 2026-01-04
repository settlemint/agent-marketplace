#!/usr/bin/env bash
# Restore session state after compaction or resume
# Called by SessionStart hook to provide recovery context
#
# Key design: Output is structured so Claude can immediately act on it
# - Plan preview included directly (no need to read file)
# - Todos in TodoWrite-compatible format
# - Minimal output to avoid context overload

# Hooks must never fail - use defensive error handling
set +e

source "$(dirname "$0")/../lib/hook-logger.sh" 2>/dev/null || true

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Read stdin to get event info
INPUT=$(cat)
EVENT_TYPE=$(echo "$INPUT" | jq -r '.type // "unknown"' 2>/dev/null)

# Only restore for compact/resume events, not fresh startup
if [[ $EVENT_TYPE == "startup" ]]; then
	log_hook "SessionStart" "restore-session-state" "skip-startup" "type:$EVENT_TYPE"
	exit 0
fi

# Get branch info (handle detached HEAD)
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
if [[ -z $BRANCH ]]; then
	BRANCH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo 'unknown')
fi
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')

# Try unified location first, then fall back to legacy location
BRANCH_DIR="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH"
UNIFIED_STATE="$BRANCH_DIR/state.json"
LEGACY_STATE="$PROJECT_DIR/.claude/state/session-${SAFE_BRANCH}.json"

if [[ -f $UNIFIED_STATE ]]; then
	STATE_FILE="$UNIFIED_STATE"
elif [[ -f $LEGACY_STATE ]]; then
	STATE_FILE="$LEGACY_STATE"
else
	log_hook "SessionStart" "restore-session-state" "no-state" "branch:$BRANCH,event:$EVENT_TYPE"
	exit 0
fi

# Read state
COMPACTED_AT=$(jq -r '.compacted_at // empty' "$STATE_FILE" 2>/dev/null)
if [[ -z $COMPACTED_AT ]]; then
	exit 0
fi

# Extract state info - support both old and new formats
PLAN_EXISTS=$(jq -r '.plan.exists // false' "$STATE_FILE" 2>/dev/null)
PLAN_FILE=$(jq -r '.plan.file // empty' "$STATE_FILE" 2>/dev/null)
PLAN_PREVIEW=$(jq -r '.plan.preview // empty' "$STATE_FILE" 2>/dev/null)

# Handle both old and new todo formats
PENDING_COUNT=$(jq -r '.execution.pending_count // .todos.pending_count // 0' "$STATE_FILE" 2>/dev/null)
TODOS_JSON=$(jq -c '.execution.todos // .todos.items // []' "$STATE_FILE" 2>/dev/null)

# Handle both old and new workflow formats
ACTIVE_WORKFLOW=$(jq -r '.workflow.active // .active_workflow // empty' "$STATE_FILE" 2>/dev/null)
WORKFLOW_ARGS=$(jq -r '.workflow.args // .workflow_args // empty' "$STATE_FILE" 2>/dev/null)

# Get loop state from unified format
LOOP_ACTIVE=$(jq -r '.loop.active // false' "$STATE_FILE" 2>/dev/null)
LOOP_ITERATION=$(jq -r '.loop.iteration // 0' "$STATE_FILE" 2>/dev/null)
LOOP_MAX=$(jq -r '.loop.maxIterations // 10' "$STATE_FILE" 2>/dev/null)
LOOP_PROMISE=$(jq -r '.loop.completionPromise // empty' "$STATE_FILE" 2>/dev/null)

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

# Show active loop state if loop is in progress
if [[ $LOOP_ACTIVE == "true" ]]; then
	echo "ACTION REQUIRED: Resume iteration loop (iteration $LOOP_ITERATION of $LOOP_MAX)"
	echo "  Completion promise: <promise>$LOOP_PROMISE</promise>"
	echo ""
fi

log_hook "SessionStart" "restore-session-state" "restored" "branch:$BRANCH,event:$EVENT_TYPE,workflow:${ACTIVE_WORKFLOW:-none},todos:$PENDING_COUNT,loop:$LOOP_ACTIVE" 2>/dev/null || true
