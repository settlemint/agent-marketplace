#!/usr/bin/env bash
# Save session state before compaction
# Called by PreCompact hook to preserve work context
# Writes unified state to .claude/branches/{branch}/state.json

# Hooks must never fail - use defensive error handling
set +e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Get branch info (handle detached HEAD where --show-current returns empty)
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
if [[ -z $BRANCH ]]; then
	# Detached HEAD - use short commit hash instead
	BRANCH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo 'unknown')
fi
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')

# Use unified branch-namespaced state location
BRANCH_DIR="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH"
mkdir -p "$BRANCH_DIR"
STATE_FILE="$BRANCH_DIR/state.json"

# Also keep legacy location for backwards compatibility during migration
LEGACY_DIR="$PROJECT_DIR/.claude/state"
mkdir -p "$LEGACY_DIR"

# Get plan file content (first 100 lines)
# Plan files can be stored as:
#   - .claude/plans/${BRANCH}.plan.md (branch-based, with slashes as directories)
#   - .claude/plans/${SAFE_BRANCH}.plan.md (sanitized branch name)
#   - .claude/plans/<feature-slug>.md (feature-based naming from workflows:plan)
# Try multiple patterns to find an active plan
PLAN_FILE=""
PLAN_CONTENT=""
PLAN_EXISTS="false"

# First try: branch-based with slashes preserved (creates subdirectories)
if [[ -f "$PROJECT_DIR/.claude/plans/${BRANCH}.plan.md" ]]; then
	PLAN_FILE="$PROJECT_DIR/.claude/plans/${BRANCH}.plan.md"
# Second try: sanitized branch name (flat structure)
elif [[ -f "$PROJECT_DIR/.claude/plans/${SAFE_BRANCH}.plan.md" ]]; then
	PLAN_FILE="$PROJECT_DIR/.claude/plans/${SAFE_BRANCH}.plan.md"
# Third try: find most recently modified .md file in plans directory
# Use ls -t for macOS compatibility (BSD find lacks -printf)
else
	PLAN_FILE=$(ls -t "$PROJECT_DIR/.claude/plans"/*.md 2>/dev/null | head -1 || echo '')
fi

if [[ -n $PLAN_FILE && -f $PLAN_FILE ]]; then
	PLAN_CONTENT=$(head -100 "$PLAN_FILE" 2>/dev/null || echo "")
	PLAN_EXISTS="true"
fi

# Get active workflow
WORKFLOW_FILE="$STATE_DIR/current-workflow.json"
if [[ -f $WORKFLOW_FILE ]]; then
	ACTIVE_WORKFLOW=$(jq -r '.workflow // empty' "$WORKFLOW_FILE" 2>/dev/null)
	WORKFLOW_ARGS=$(jq -r '.args // empty' "$WORKFLOW_FILE" 2>/dev/null)
else
	ACTIVE_WORKFLOW=""
	WORKFLOW_ARGS=""
fi

# Get pending todos from .claude/todos/ directory
# We create a TodoWrite-compatible JSON array for easy restoration
TODO_DIR="$PROJECT_DIR/.claude/todos"
TODOS_JSON="[]"
PENDING_COUNT=0
COMPLETED_COUNT=0

if [[ -d $TODO_DIR ]]; then
	TODOS_ARRAY="[]"
	while IFS= read -r -d '' file; do
		filename=$(basename "$file")
		# Extract title from todo file (skip YAML frontmatter if present)
		title=$(awk '
        BEGIN { in_frontmatter=0; found=0 }
        /^---$/ && NR==1 { in_frontmatter=1; next }
        /^---$/ && in_frontmatter { in_frontmatter=0; next }
        in_frontmatter { next }
        /^#/ && !found { gsub(/^#+ */, ""); print; found=1; exit }
        !found && NF { print; found=1; exit }
      ' "$file" 2>/dev/null)

		# Determine status based on filename
		if [[ $filename == *complete* ]]; then
			status="completed"
			((COMPLETED_COUNT++)) || true
		else
			status="pending"
			((PENDING_COUNT++)) || true
		fi

		# Add to todos array (TodoWrite format: content, status, activeForm)
		# For activeForm, prefix with "Working on: " to avoid malformed gerunds
		TODOS_ARRAY=$(echo "$TODOS_ARRAY" | jq --arg content "$title" --arg status "$status" --arg activeForm "Working on: $title" \
			'. + [{"content": $content, "status": $status, "activeForm": $activeForm}]' 2>/dev/null || echo "$TODOS_ARRAY")
	done < <(find "$TODO_DIR" -name '*.md' -print0 2>/dev/null)
	TODOS_JSON="$TODOS_ARRAY"
fi

# Get loop state from legacy locations (check both old formats)
LOOP_STATE='{"active":false,"iteration":0,"maxIterations":10}'
OLD_LOOP_FILE="$PROJECT_DIR/.claude/handoffs/$SAFE_BRANCH/loop-state.json"
if [[ -f $OLD_LOOP_FILE ]]; then
	LOOP_STATE=$(cat "$OLD_LOOP_FILE" 2>/dev/null || echo "$LOOP_STATE")
fi

# Get handoff info from legacy location
HANDOFF_DIR="$PROJECT_DIR/.claude/handoffs/$SAFE_BRANCH"
HANDOFF_COUNT=0
LAST_HANDOFF=""
if [[ -d $HANDOFF_DIR ]]; then
	HANDOFF_COUNT=$(find "$HANDOFF_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
	LAST_HANDOFF=$(ls -t "$HANDOFF_DIR"/*.md 2>/dev/null | head -1 || echo "")
fi

# Build the unified state JSON
jq -n \
	--arg branch "$BRANCH" \
	--arg session "${CLAUDE_SESSION_ID:-unknown}" \
	--arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
	--arg plan_exists "$PLAN_EXISTS" \
	--arg plan_file "$PLAN_FILE" \
	--arg plan_content "$PLAN_CONTENT" \
	--argjson todos "$TODOS_JSON" \
	--argjson pending_count "$PENDING_COUNT" \
	--argjson completed_count "$COMPLETED_COUNT" \
	--arg active_workflow "$ACTIVE_WORKFLOW" \
	--arg workflow_args "$WORKFLOW_ARGS" \
	--argjson loop "$LOOP_STATE" \
	--argjson handoff_count "$HANDOFF_COUNT" \
	--arg last_handoff "$LAST_HANDOFF" \
	'{
    branch: $branch,
    session: $session,
    compacted_at: $time,
    workflow: {
      phase: (if $active_workflow != "" then "executing" else "idle" end),
      active: $active_workflow,
      args: $workflow_args
    },
    plan: {
      exists: ($plan_exists == "true"),
      file: $plan_file,
      preview: ($plan_content | split("\n")[0:40] | join("\n"))
    },
    execution: {
      todos: $todos,
      pending_count: $pending_count,
      completed_count: $completed_count
    },
    loop: $loop,
    handoff: {
      count: $handoff_count,
      last: $last_handoff
    }
  }' >"$STATE_FILE"

# Also write to legacy location during migration period
cp "$STATE_FILE" "$LEGACY_DIR/session-${SAFE_BRANCH}.json" 2>/dev/null || true

echo "COMPACTION: Session state saved to $STATE_FILE"
echo "  - Branch: $BRANCH"
echo "  - Active workflow: ${ACTIVE_WORKFLOW:-none}"
echo "  - Plan exists: $PLAN_EXISTS"
echo "  - Pending todos: $PENDING_COUNT"
echo "  - Completed todos: $COMPLETED_COUNT"

