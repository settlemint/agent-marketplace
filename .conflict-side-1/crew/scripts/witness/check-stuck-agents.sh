#!/usr/bin/env bash
# Witness: Check for stuck agents and report status
# Detects agents running longer than threshold and provides recovery options
# Usage: check-stuck-agents.sh [timeout_minutes]

set -e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TIMEOUT_MINUTES="${1:-5}"
TIMEOUT_SECONDS=$((TIMEOUT_MINUTES * 60))

# Get branch info
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
if [[ -z $BRANCH ]]; then
  BRANCH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo 'unknown')
fi
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')

# Agents tracking file
AGENTS_FILE="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH/agents.json"

if [[ ! -f $AGENTS_FILE ]]; then
  echo "WITNESS: No agents tracked on branch $BRANCH"
  exit 0
fi

CURRENT_EPOCH=$(date +%s)

# Get running agents
RUNNING_AGENTS=$(jq -r '.agents[] | select(.status == "running")' "$AGENTS_FILE" 2>/dev/null)

if [[ -z $RUNNING_AGENTS ]]; then
  STATS=$(jq -r '.stats | "Total: \(.total_spawned), Completed: \(.completed), Failed: \(.failed), Stuck: \(.stuck)"' "$AGENTS_FILE")
  echo "WITNESS: No running agents. Stats: $STATS"
  exit 0
fi

echo "WITNESS: Agent Status Report"
echo "=============================="
echo ""

# Check each running agent
STUCK_COUNT=0
RUNNING_COUNT=0

while IFS= read -r agent; do
  [[ -z $agent ]] && continue

  ID=$(echo "$agent" | jq -r '.id')
  TYPE=$(echo "$agent" | jq -r '.type')
  DESC=$(echo "$agent" | jq -r '.description')
  SPAWNED_EPOCH=$(echo "$agent" | jq -r '.spawned_epoch')
  NUDGE_COUNT=$(echo "$agent" | jq -r '.nudge_count // 0')

  ELAPSED=$((CURRENT_EPOCH - SPAWNED_EPOCH))
  ELAPSED_MINS=$((ELAPSED / 60))
  ELAPSED_SECS=$((ELAPSED % 60))

  if [[ $ELAPSED -gt $TIMEOUT_SECONDS ]]; then
    ((STUCK_COUNT++))
    echo "⚠️  STUCK: $DESC"
    echo "   ID: $ID"
    echo "   Type: $TYPE"
    echo "   Running: ${ELAPSED_MINS}m ${ELAPSED_SECS}s (threshold: ${TIMEOUT_MINUTES}m)"
    echo "   Nudge count: $NUDGE_COUNT"
    echo ""
  else
    ((RUNNING_COUNT++))
    echo "✓  RUNNING: $DESC"
    echo "   ID: $ID"
    echo "   Type: $TYPE"
    echo "   Elapsed: ${ELAPSED_MINS}m ${ELAPSED_SECS}s"
    echo ""
  fi
done < <(echo "$RUNNING_AGENTS" | jq -c '.')

echo "=============================="
echo "Summary: $RUNNING_COUNT active, $STUCK_COUNT stuck"

# Update stuck count in stats
if [[ $STUCK_COUNT -gt 0 ]]; then
  jq --argjson stuck "$STUCK_COUNT" '.stats.stuck = $stuck' "$AGENTS_FILE" >"${AGENTS_FILE}.tmp" && mv "${AGENTS_FILE}.tmp" "$AGENTS_FILE"

  echo ""
  echo "Recovery options:"
  echo "  1. TaskOutput({task_id: \"<id>\", block: true}) - Wait for completion"
  echo "  2. KillShell({shell_id: \"<id>\"}) - Terminate stuck agent"
  echo "  3. Investigate with /tasks command"
fi
