#!/usr/bin/env bash
# Initialize flow state on session start
# Runs on: startup, compact, resume

set -euo pipefail

# Read event data from stdin
EVENT_DATA=$(cat)
EVENT_TYPE=$(echo "$EVENT_DATA" | jq -r '.event // "unknown"')

# Skip for subagents
AGENT_TYPE=$(echo "$EVENT_DATA" | jq -r '.agent_type // "main"')
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
		echo "Flow: Active workflow '$CURRENT_WORKFLOW' ($WORKFLOW_STATUS)"
	fi
fi

exit 0
