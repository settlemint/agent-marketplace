#!/usr/bin/env bash
# Witness: Nudge a stuck agent
# Increments nudge count and logs the attempt
# Usage: nudge-agent.sh <agent_id>

set -e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
AGENT_ID="${1:-}"

if [[ -z $AGENT_ID ]]; then
  echo "Usage: nudge-agent.sh <agent_id>"
  exit 1
fi

# Get branch info
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
if [[ -z $BRANCH ]]; then
  BRANCH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo 'unknown')
fi
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')

# Agents tracking file
AGENTS_FILE="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH/agents.json"

if [[ ! -f $AGENTS_FILE ]]; then
  echo "ERROR: No agents file found"
  exit 1
fi

# Check if agent exists
AGENT=$(jq -r --arg id "$AGENT_ID" '.agents[] | select(.id == $id)' "$AGENTS_FILE" 2>/dev/null)

if [[ -z $AGENT ]]; then
  echo "ERROR: Agent $AGENT_ID not found"
  exit 1
fi

STATUS=$(echo "$AGENT" | jq -r '.status')

if [[ $STATUS != "running" ]]; then
  echo "Agent $AGENT_ID is not running (status: $STATUS)"
  exit 0
fi

# Increment nudge count
NUDGE_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)

jq --arg id "$AGENT_ID" \
  --arg time "$NUDGE_TIME" \
  '(.agents[] | select(.id == $id)) |= . + {
    "nudge_count": (.nudge_count + 1),
    "last_nudge": $time
  }' "$AGENTS_FILE" >"${AGENTS_FILE}.tmp" && mv "${AGENTS_FILE}.tmp" "$AGENTS_FILE"

NEW_NUDGE_COUNT=$(jq -r --arg id "$AGENT_ID" '.agents[] | select(.id == $id) | .nudge_count' "$AGENTS_FILE")

echo "WITNESS: Nudged agent $AGENT_ID (nudge #$NEW_NUDGE_COUNT)"
echo "  Use TaskOutput to check status or KillShell to terminate"
