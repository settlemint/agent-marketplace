#!/usr/bin/env bash
# Track Task tool agent spawns for Witness monitoring
# Called by PostToolUse hook on Task tool invocations
# Writes agent tracking data to .claude/branches/{branch}/agents.json

set +e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Read hook input from stdin
INPUT=$(cat)

# Only track Task tool calls
if [[ -z $INPUT ]]; then
  exit 0
fi

# Extract agent details from tool input
AGENT_ID=$(echo "$INPUT" | jq -r '.tool_input.task_id // empty' 2>/dev/null)
SUBAGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // "general-purpose"' 2>/dev/null)
DESCRIPTION=$(echo "$INPUT" | jq -r '.tool_input.description // "unnamed"' 2>/dev/null)
RUN_IN_BACKGROUND=$(echo "$INPUT" | jq -r '.tool_input.run_in_background // false' 2>/dev/null)

# Skip if no meaningful data
if [[ -z $DESCRIPTION || $DESCRIPTION == "null" ]]; then
  exit 0
fi

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

# Initialize agents file if doesn't exist
if [[ ! -f $AGENTS_FILE ]]; then
  echo '{"agents":[],"stats":{"total_spawned":0,"completed":0,"failed":0,"stuck":0}}' >"$AGENTS_FILE"
fi

# Generate unique ID if not provided
if [[ -z $AGENT_ID || $AGENT_ID == "null" ]]; then
  AGENT_ID="agent-$(date +%s)-$$"
fi

# Add new agent entry
SPAWN_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
SPAWN_EPOCH=$(date +%s)

jq --arg id "$AGENT_ID" \
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
  }] | .stats.total_spawned += 1' "$AGENTS_FILE" >"${AGENTS_FILE}.tmp" && mv "${AGENTS_FILE}.tmp" "$AGENTS_FILE"

# Output tracking info
echo "WITNESS: Tracking agent spawn"
echo "  ID: $AGENT_ID"
echo "  Type: $SUBAGENT_TYPE"
echo "  Description: $DESCRIPTION"
echo "  Background: $RUN_IN_BACKGROUND"
