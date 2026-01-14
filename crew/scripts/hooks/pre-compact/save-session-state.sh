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

# Session Completion Discipline: Check for uncommitted work
# "Work is NOT complete until git commit succeeds"
UNCOMMITTED_FILES=""
UNCOMMITTED_COUNT=0
WIP_TASK_CREATED="false"

# Get uncommitted changes (staged + unstaged + untracked)
if git -C "$PROJECT_DIR" rev-parse --git-dir >/dev/null 2>&1; then
	# Count modified/staged files
	STAGED=$(git -C "$PROJECT_DIR" diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
	UNSTAGED=$(git -C "$PROJECT_DIR" diff --name-only 2>/dev/null | wc -l | tr -d ' ')
	UNTRACKED=$(git -C "$PROJECT_DIR" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
	UNCOMMITTED_COUNT=$((STAGED + UNSTAGED + UNTRACKED))

	if [[ $UNCOMMITTED_COUNT -gt 0 ]]; then
		# Get file list for WIP task (limit to 20 files)
		UNCOMMITTED_FILES=$(git -C "$PROJECT_DIR" status --porcelain 2>/dev/null | head -20 | sed 's/^/  /')

		# Create WIP task for next session
		TASKS_DIR="$BRANCH_DIR/tasks"
		mkdir -p "$TASKS_DIR"

		# Find next available order number (start at 000 for WIP - highest priority)
		WIP_FILE="$TASKS_DIR/000-pending-p1-found-commit-wip-changes.md"

		# Only create if doesn't already exist (avoid duplicates)
		if [[ ! -f $WIP_FILE ]]; then
			cat >"$WIP_FILE" <<EOF
---
status: pending
priority: p1
story: found
parallel: false
---

# T000: Commit uncommitted work from previous session

## Description
Session ended with uncommitted changes. Review and commit or discard.

## Uncommitted Files
\`\`\`
$UNCOMMITTED_FILES
\`\`\`

## Acceptance Criteria
- [ ] Review all uncommitted changes
- [ ] Stage appropriate files with \`git add\`
- [ ] Commit with conventional message OR discard with \`git checkout -- .\`
- [ ] Delete this task file when complete

## Work Log
### $(date -u +%Y-%m-%dT%H:%M:%SZ) - Created
**By:** PreCompact hook
**Status:** Auto-generated due to uncommitted work
EOF
			WIP_TASK_CREATED="true"
		fi
	fi
fi

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
# Use ls -t for cross-platform sorting by modification time
else
	PLAN_FILE=$(find "$PROJECT_DIR/.claude/plans" -maxdepth 1 -name "*.md" -type f 2>/dev/null | xargs ls -t 2>/dev/null | head -1 || echo '')
fi

if [[ -n $PLAN_FILE && -f $PLAN_FILE ]]; then
	PLAN_CONTENT=$(head -100 "$PLAN_FILE" 2>/dev/null || echo "")
	PLAN_EXISTS="true"
fi

# Get active workflow
WORKFLOW_FILE="$BRANCH_DIR/current-workflow.json"
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

# Get handoff info from legacy location
HANDOFF_DIR="$PROJECT_DIR/.claude/handoffs/$SAFE_BRANCH"
HANDOFF_COUNT=0
LAST_HANDOFF=""
if [[ -d $HANDOFF_DIR ]]; then
	HANDOFF_COUNT=$(find "$HANDOFF_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
	LAST_HANDOFF=$(find "$HANDOFF_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | xargs ls -t 2>/dev/null | head -1 || echo "")
fi

# Get routing state (for intelligent request routing)
ROUTING_FILE="$BRANCH_DIR/routing.json"
ROUTING_MODE="idle"
ROUTING_ENTERED=""
ROUTING_CONFIDENCE=""
if [[ -f $ROUTING_FILE ]]; then
	ROUTING_MODE=$(jq -r '.current_mode // "idle"' "$ROUTING_FILE" 2>/dev/null)
	ROUTING_ENTERED=$(jq -r '.entered_at // ""' "$ROUTING_FILE" 2>/dev/null)
	ROUTING_CONFIDENCE=$(jq -r '.confidence // ""' "$ROUTING_FILE" 2>/dev/null)
fi

# Get failure budget state
FAILURE_WORKER=$(jq -r '.failure_budget.worker.current // 0' "$STATE_FILE" 2>/dev/null || echo "0")
FAILURE_CI=$(jq -r '.failure_budget.ci.iterations // 0' "$STATE_FILE" 2>/dev/null || echo "0")
FAILURE_REVIEW=$(jq -r '.failure_budget.review.passes // 0' "$STATE_FILE" 2>/dev/null || echo "0")

# Scan task files in .claude/branches/{branch}/tasks/
# Task naming: {order}-{status}-{priority}-{story}-{slug}.md
TASKS_DIR="$BRANCH_DIR/tasks"
TASKS_PENDING=0
TASKS_P1=0
TASKS_P2=0
TASKS_P3=0
NEXT_TASK=""

if [[ -d $TASKS_DIR ]]; then
	# Count pending tasks by priority from filenames
	while IFS= read -r filename; do
		# Match pattern: ###-pending-p#-*
		if [[ $filename =~ ^[0-9]+-pending-p([123])- ]]; then
			((TASKS_PENDING++)) || true
			priority="${BASH_REMATCH[1]}"
			case $priority in
			1) ((TASKS_P1++)) || true ;;
			2) ((TASKS_P2++)) || true ;;
			3) ((TASKS_P3++)) || true ;;
			esac
			# Track first pending task (lowest order number)
			if [[ -z $NEXT_TASK ]]; then
				NEXT_TASK="$filename"
			fi
		fi
	done < <(find "$TASKS_DIR" -maxdepth 1 -name "*.md" -type f -exec basename {} \; 2>/dev/null | sort)
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
	--argjson handoff_count "$HANDOFF_COUNT" \
	--arg last_handoff "$LAST_HANDOFF" \
	--argjson tasks_pending "$TASKS_PENDING" \
	--argjson tasks_p1 "$TASKS_P1" \
	--argjson tasks_p2 "$TASKS_P2" \
	--argjson tasks_p3 "$TASKS_P3" \
	--arg next_task "$NEXT_TASK" \
	--argjson uncommitted_count "$UNCOMMITTED_COUNT" \
	--arg wip_task_created "$WIP_TASK_CREATED" \
	--arg routing_mode "$ROUTING_MODE" \
	--arg routing_entered "$ROUTING_ENTERED" \
	--arg routing_confidence "$ROUTING_CONFIDENCE" \
	--argjson failure_worker "$FAILURE_WORKER" \
	--argjson failure_ci "$FAILURE_CI" \
	--argjson failure_review "$FAILURE_REVIEW" \
	'{
    branch: $branch,
    session: $session,
    compacted_at: $time,
    routing: {
      current_mode: $routing_mode,
      entered_at: $routing_entered,
      confidence: $routing_confidence
    },
    failure_budget: {
      worker: { current: $failure_worker, max: 5 },
      ci: { iterations: $failure_ci, max: 3 },
      review: { passes: $failure_review }
    },
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
    tasks: {
      pending: $tasks_pending,
      p1: $tasks_p1,
      p2: $tasks_p2,
      p3: $tasks_p3,
      next: $next_task
    },
    uncommitted: {
      count: $uncommitted_count,
      wip_task_created: ($wip_task_created == "true")
    },
    handoff: {
      count: $handoff_count,
      last: $last_handoff
    }
  }' >"$STATE_FILE"

# Output session completion status
echo "COMPACTION: Session state saved to $STATE_FILE"
echo "  - Branch: $BRANCH"
echo "  - Active workflow: ${ACTIVE_WORKFLOW:-none}"
echo "  - Plan exists: $PLAN_EXISTS"
echo "  - Pending todos: $PENDING_COUNT"
echo "  - Pending tasks: $TASKS_PENDING (P1:$TASKS_P1 P2:$TASKS_P2 P3:$TASKS_P3)"

# Session Completion Discipline: Warn about uncommitted work
if [[ $UNCOMMITTED_COUNT -gt 0 ]]; then
	echo ""
	echo "⚠️  SESSION COMPLETION WARNING: $UNCOMMITTED_COUNT uncommitted files"
	echo "    Work is NOT complete until git commit succeeds."
	if [[ $WIP_TASK_CREATED == "true" ]]; then
		echo "    Created WIP task: 000-pending-p1-found-commit-wip-changes.md"
	fi
	echo ""
	echo "    **ACTION REQUIRED:** Use Skill(skill: \"crew:git:commit\") to complete session"
	echo ""
fi
