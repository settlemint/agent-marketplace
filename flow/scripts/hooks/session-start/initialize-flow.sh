#!/usr/bin/env bash
# Initialize flow state on session start
# Runs on: startup, compact, resume

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="initialize-flow"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read event data from stdin
EVENT_DATA=$(cat)
EVENT_TYPE=$(echo "$EVENT_DATA" | jq -r '.event // "unknown"' 2>/dev/null || echo "unknown")

# Skip for subagents
AGENT_TYPE=$(echo "$EVENT_DATA" | jq -r '.agent_type // "main"' 2>/dev/null || echo "main")
if [[ "$AGENT_TYPE" != "main" ]]; then
	exit 0
fi

# Check for flow state directory
FLOW_DIR=".claude/flow"
STATE_FILE="$FLOW_DIR/state.json"

if [[ -f "$STATE_FILE" ]]; then
	# Flow is initialized, restore state
	CURRENT_WORKFLOW=$(jq -r '.currentWorkflow.name // "none"' "$STATE_FILE" 2>/dev/null || echo "none")
	WORKFLOW_STATUS=$(jq -r '.currentWorkflow.status // "none"' "$STATE_FILE" 2>/dev/null || echo "none")

	if [[ "$CURRENT_WORKFLOW" != "none" && "$CURRENT_WORKFLOW" != "null" ]]; then
		log_info "event=WORKFLOW_RESTORED" "workflow=$CURRENT_WORKFLOW" "status=$WORKFLOW_STATUS"
		echo "Flow: Active workflow '$CURRENT_WORKFLOW' ($WORKFLOW_STATUS)"
	else
		log_debug "event=NO_ACTIVE_WORKFLOW"
	fi
else
	log_debug "event=NO_STATE_FILE"
fi

exit 0
