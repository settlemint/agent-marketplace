#!/usr/bin/env bash
# Track TaskOutput completions for Witness monitoring
# Called by PostToolUse hook on TaskOutput tool invocations
# Updates agent status in .claude/branches/{branch}/agents.json
#
# PERFORMANCE: Single jq call to extract all fields

set +e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Read hook input from stdin
INPUT=$(cat)

# Only process if we have input
[[ -z $INPUT ]] && exit 0

# PERFORMANCE: Single jq call extracts all fields at once
PARSED=$(echo "$INPUT" | jq -r '[
  .tool_input.task_id // "",
  .tool_output // ""
] | @tsv' 2>/dev/null)

IFS=$'\t' read -r TASK_ID TOOL_OUTPUT <<<"$PARSED"

[[ -z $TASK_ID || $TASK_ID == "null" ]] && exit 0

# Get branch info
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
if [[ -z $BRANCH ]]; then
	BRANCH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo 'unknown')
fi
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')

# Agents tracking file
BRANCH_DIR="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH"
AGENTS_FILE="$BRANCH_DIR/agents.json"

# Exit silently if agents file doesn't exist or directory is missing
if [[ ! -f $AGENTS_FILE ]]; then
	exit 0
fi

# Validate agents.json is valid JSON before processing
if ! jq empty "$AGENTS_FILE" 2>/dev/null; then
	exit 0
fi

# Determine success/failure from output
STATUS="completed"
if echo "$TOOL_OUTPUT" | grep -qi "error\|fail\|exception"; then
	STATUS="failed"
fi

COMPLETE_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Update agent entry (suppress errors to avoid polluting context)
TMP_FILE="${AGENTS_FILE}.tmp"
if jq --arg id "$TASK_ID" \
	--arg status "$STATUS" \
	--arg time "$COMPLETE_TIME" \
	'(.agents[] | select(.id == $id)) |= . + {
    "status": $status,
    "completed_at": $time
  } |
  if $status == "completed" then .stats.completed += 1
  elif $status == "failed" then .stats.failed += 1
  else . end' "$AGENTS_FILE" >"$TMP_FILE" 2>/dev/null && [[ -s $TMP_FILE ]]; then
	mv "$TMP_FILE" "$AGENTS_FILE" 2>/dev/null || rm -f "$TMP_FILE"
else
	rm -f "$TMP_FILE"
fi

# Silent tracking - no output to keep context clean
