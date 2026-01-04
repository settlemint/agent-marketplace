#!/usr/bin/env bash
# Track TaskOutput completions for Witness monitoring
# Called by PostToolUse hook on TaskOutput tool invocations
# Updates agent status in .claude/branches/{branch}/agents.json

set +e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Read hook input from stdin
INPUT=$(cat)

# Only process if we have input
if [[ -z $INPUT ]]; then
  exit 0
fi

# Extract task ID and output from input
TASK_ID=$(echo "$INPUT" | jq -r '.tool_input.task_id // empty' 2>/dev/null)
TOOL_OUTPUT=$(echo "$INPUT" | jq -r '.tool_output // empty' 2>/dev/null)

if [[ -z $TASK_ID || $TASK_ID == "null" ]]; then
  exit 0
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
  exit 0
fi

# Determine success/failure from output
STATUS="completed"
if echo "$TOOL_OUTPUT" | grep -qi "error\|fail\|exception"; then
  STATUS="failed"
fi

COMPLETE_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Update agent entry
jq --arg id "$TASK_ID" \
  --arg status "$STATUS" \
  --arg time "$COMPLETE_TIME" \
  '(.agents[] | select(.id == $id)) |= . + {
    "status": $status,
    "completed_at": $time
  } |
  if $status == "completed" then .stats.completed += 1
  elif $status == "failed" then .stats.failed += 1
  else . end' "$AGENTS_FILE" >"${AGENTS_FILE}.tmp" && mv "${AGENTS_FILE}.tmp" "$AGENTS_FILE"

echo "WITNESS: Agent $TASK_ID marked as $STATUS"
