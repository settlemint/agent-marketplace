#!/usr/bin/env bash
# Stop hook: Block exit if there are incomplete todos
# Prevents premature task abandonment by checking TodoWrite state
#
# Based on patterns from jarrodwatts/claude-code-config
# Safety valve: Max 10 consecutive blocks per session to prevent infinite loops

set -euo pipefail

# Config file for block tracking
readonly CONFIG_FILE="${HOME}/.claude/hooks/todo-enforcer.config.json"
readonly DEBUG_LOG="${HOME}/.claude/hooks/todo-enforcer.log"
readonly MAX_CONSECUTIVE_BLOCKS=10

# Logging function
log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${2:-INFO}] $1" >>"$DEBUG_LOG" 2>/dev/null || true
}

die() {
	log "$1" "ERROR"
	exit 0
}

# Require jq
if ! command -v jq &>/dev/null; then
	die "jq is required but not installed"
fi

# Skip if in ralph-loop mode (different completion tracking)
# Check both root location and branch-specific location
[[ -f ".claude/ralph-loop.local.md" ]] && exit 0
BRANCH=$(git branch --show-current 2>/dev/null | tr '/' '-' || echo '')
[[ -n $BRANCH && -f ".claude/branches/$BRANCH/ralph-loop.local.md" ]] && exit 0

# Load or initialize config
load_config() {
	if [[ -f "$CONFIG_FILE" ]]; then
		cat "$CONFIG_FILE" 2>/dev/null || echo '{"enabled":true,"block_count":0}'
	else
		mkdir -p "$(dirname "$CONFIG_FILE")"
		echo '{"enabled":true,"block_count":0}'
	fi
}

save_config() {
	local temp_file="${CONFIG_FILE}.tmp.$$"
	echo "$1" >"$temp_file" 2>/dev/null && mv "$temp_file" "$CONFIG_FILE" 2>/dev/null || true
}

allow_exit() {
	[[ -n "${1:-}" ]] && log "Allowing exit: $1"
	exit 0
}

# Read hook input from stdin
HOOK_INPUT=$(cat)

log "Hook started"

# Load config
CONFIG=$(load_config)

# Check if disabled
if [[ "$(echo "$CONFIG" | jq -r '.enabled // true')" != "true" ]]; then
	allow_exit "Disabled via config"
fi

# Parse hook input
read -r SESSION_ID TRANSCRIPT_PATH STOP_HOOK_ACTIVE < <(
	echo "$HOOK_INPUT" | jq -r '[.session_id // "unknown", .transcript_path // "", .stop_hook_active // false] | @tsv'
)

log "Session: $SESSION_ID | stop_hook_active: $STOP_HOOK_ACTIVE"

# If stop hook is active (we're being called from Stop event), reset block count
if [[ "$STOP_HOOK_ACTIVE" == "true" ]]; then
	if [[ "$(echo "$CONFIG" | jq -r '.last_block_session // ""')" == "$SESSION_ID" ]]; then
		CONFIG=$(echo "$CONFIG" | jq '.block_count = 0')
		save_config "$CONFIG"
	fi
fi

# No transcript - nothing to check
[[ -z "$TRANSCRIPT_PATH" ]] && allow_exit "No transcript path"
[[ ! -f "$TRANSCRIPT_PATH" ]] && allow_exit "Transcript not found"

# Find the last TodoWrite call in the transcript
TODOS_JSON=$(jq -s '
  [.[] | .message.content[]? | select(.type == "tool_use" and .name == "TodoWrite") | .input.todos] |
  last // empty
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "")

# No todos found - allow exit
if [[ -z "$TODOS_JSON" || "$TODOS_JSON" == "null" ]]; then
	CONFIG=$(echo "$CONFIG" | jq '.block_count = 0')
	save_config "$CONFIG"
	allow_exit "No todos found"
fi

# Count incomplete todos
read -r PENDING_COUNT IN_PROGRESS_COUNT < <(
	echo "$TODOS_JSON" | jq -r '[
    [.[] | select(.status == "pending")] | length,
    [.[] | select(.status == "in_progress")] | length
  ] | @tsv'
)

INCOMPLETE_COUNT=$((PENDING_COUNT + IN_PROGRESS_COUNT))

log "Pending: $PENDING_COUNT, In progress: $IN_PROGRESS_COUNT"

# All todos complete - allow exit
if [[ "$INCOMPLETE_COUNT" -eq 0 ]]; then
	CONFIG=$(echo "$CONFIG" | jq '.block_count = 0')
	save_config "$CONFIG"
	allow_exit "All todos completed"
fi

# Track consecutive blocks
read -r BLOCK_COUNT LAST_SESSION < <(
	echo "$CONFIG" | jq -r '[.block_count // 0, .last_block_session // ""] | @tsv'
)

if [[ "$LAST_SESSION" == "$SESSION_ID" ]]; then
	BLOCK_COUNT=$((BLOCK_COUNT + 1))
else
	BLOCK_COUNT=1
fi

# Safety valve - don't block forever
if [[ "$BLOCK_COUNT" -ge "$MAX_CONSECUTIVE_BLOCKS" ]]; then
	log "Safety valve triggered after $MAX_CONSECUTIVE_BLOCKS blocks" "WARN"
	CONFIG=$(echo "$CONFIG" | jq '.block_count = 0')
	save_config "$CONFIG"
	allow_exit "Safety valve triggered"
fi

# Update config with block tracking
CONFIG=$(echo "$CONFIG" | jq --arg sid "$SESSION_ID" --argjson count "$BLOCK_COUNT" \
	'.block_count = $count | .last_block_session = $sid')
save_config "$CONFIG"

log "Blocking (count: $BLOCK_COUNT): $INCOMPLETE_COUNT incomplete"

# Build the task list for display
TASK_LIST=$(echo "$TODOS_JSON" | jq -r '
  ([.[] | select(.status == "in_progress") | "  → [in progress] \(.content)"] +
   [.[] | select(.status == "pending") | "  ○ [pending] \(.content)"]) |
  join("\n")
')

# Output block decision
REASON="You have $INCOMPLETE_COUNT incomplete todo(s):
$TASK_LIST

Complete these tasks before stopping.
Mark each task as 'completed' using TodoWrite when done."

jq -n --arg reason "$REASON" '{"decision": "block", "reason": $reason}'

exit 0
