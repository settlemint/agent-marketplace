#!/usr/bin/env bash
# Track Task tool agent spawns for Witness monitoring
# Called by PostToolUse hook on Task tool invocations
# Writes agent tracking data to .claude/branches/{branch}/agents.json
#
# PERFORMANCE: Single jq call to extract all fields

set +e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Read hook input from stdin
INPUT=$(cat)

# Only track Task tool calls
[[ -z $INPUT ]] && exit 0

# PERFORMANCE: Single jq call extracts all fields at once
PARSED=$(echo "$INPUT" | jq -r '[
  .tool_input.task_id // "",
  .tool_input.subagent_type // "general-purpose",
  .tool_input.description // "",
  (.tool_input.run_in_background // false | tostring)
] | @tsv' 2>/dev/null)

IFS=$'\t' read -r AGENT_ID SUBAGENT_TYPE DESCRIPTION RUN_IN_BACKGROUND <<<"$PARSED"

# Skip if no meaningful data
[[ -z $DESCRIPTION || $DESCRIPTION == "null" ]] && exit 0

# Get branch info
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
if [[ -z $BRANCH ]]; then
  BRANCH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo 'unknown')
fi
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')

# Agents tracking file
BRANCH_DIR="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH"
mkdir -p "$BRANCH_DIR"
AGENTS_FILE="$BRANCH_DIR/agents.json"

# Initialize agents file if doesn't exist or is invalid JSON
if [[ ! -f $AGENTS_FILE ]] || ! jq empty "$AGENTS_FILE" 2>/dev/null; then
  echo '{"agents":[],"stats":{"total_spawned":0,"completed":0,"failed":0,"stuck":0}}' >"$AGENTS_FILE"
fi

# Generate unique ID if not provided
if [[ -z $AGENT_ID || $AGENT_ID == "null" ]]; then
  AGENT_ID="agent-$(date +%s)-$$"
fi

# Add new agent entry
SPAWN_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
SPAWN_EPOCH=$(date +%s)

# Ensure variables have valid JSON values for argjson
[[ -z $SPAWN_EPOCH ]] && SPAWN_EPOCH=0
[[ -z $RUN_IN_BACKGROUND || $RUN_IN_BACKGROUND == "null" ]] && RUN_IN_BACKGROUND="false"

# Add new agent entry (suppress errors to avoid polluting context)
if jq --arg id "$AGENT_ID" \
  --arg type "$SUBAGENT_TYPE" \
  --arg desc "$DESCRIPTION" \
  --arg time "$SPAWN_TIME" \
  --argjson epoch "$SPAWN_EPOCH" \
  --argjson background "$RUN_IN_BACKGROUND" \
  '.agents += [{
    "id": $id,
    "type": $type,
    "description": $desc,
    "spawned_at": $time,
    "spawned_epoch": $epoch,
    "background": $background,
    "status": "running",
    "completed_at": null,
    "result": null,
    "nudge_count": 0
  }] | .stats.total_spawned += 1' "$AGENTS_FILE" >"${AGENTS_FILE}.tmp" 2>/dev/null; then
  mv "${AGENTS_FILE}.tmp" "$AGENTS_FILE"
else
  rm -f "${AGENTS_FILE}.tmp"
fi

# Silent tracking - no output to keep context clean
