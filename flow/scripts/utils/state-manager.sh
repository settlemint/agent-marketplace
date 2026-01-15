#!/usr/bin/env bash
# Flow state management utilities
# Sourced by other scripts

set -euo pipefail

FLOW_DIR=".claude/flow"
STATE_FILE="$FLOW_DIR/state.json"
CONFIG_FILE="$FLOW_DIR/config.json"
HISTORY_DIR="$FLOW_DIR/history"

# Initialize flow directory structure
init_flow() {
  mkdir -p "$FLOW_DIR"
  mkdir -p "$HISTORY_DIR"

  if [[ ! -f "$CONFIG_FILE" ]]; then
    cat >"$CONFIG_FILE" <<EOF
{
  "projectName": "$(basename "$(pwd)")",
  "initialized": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "version": "1.0.0",
  "settings": {
    "autoTrack": true,
    "saveHistory": true,
    "suggestSkills": true
  }
}
EOF
  fi

  if [[ ! -f "$STATE_FILE" ]]; then
    cat >"$STATE_FILE" <<EOF
{
  "currentWorkflow": null,
  "workflows": [],
  "lastActivity": null
}
EOF
  fi
}

# Check if flow is initialized
is_initialized() {
  [[ -f "$STATE_FILE" ]] && [[ -f "$CONFIG_FILE" ]]
}

# Get current workflow
get_current_workflow() {
  if [[ -f "$STATE_FILE" ]]; then
    jq -r '.currentWorkflow // null' "$STATE_FILE"
  else
    echo "null"
  fi
}

# Update state field
update_state() {
  local field="$1"
  local value="$2"

  if [[ -f "$STATE_FILE" ]]; then
    TMP_FILE=$(mktemp)
    jq --arg val "$value" ".$field = \$val" "$STATE_FILE" >"$TMP_FILE" && mv "$TMP_FILE" "$STATE_FILE"
  fi
}

# Add to history
add_to_history() {
  local workflow_id="$1"
  local workflow_data="$2"

  if [[ -d "$HISTORY_DIR" ]]; then
    echo "$workflow_data" >"$HISTORY_DIR/${workflow_id}.json"
  fi
}
