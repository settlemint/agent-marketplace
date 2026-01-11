#!/usr/bin/env bash
# Enforce task-first workflow for change requests
# Injects guidance when user requests changes without an existing task
#
# Key behaviors:
# - Detects change request keywords (add, implement, fix, etc.)
# - Checks for existing pending tasks in branch directory
# - Skips trivial requests (questions, short messages, steering)
# - Suggests appropriate review agents based on change type

# Hooks must never fail
set +e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Read user message from stdin
INPUT=$(cat)
USER_MESSAGE=$(echo "$INPUT" | jq -r '.content // ""' 2>/dev/null)

# Skip empty messages
if [[ -z $USER_MESSAGE ]]; then
  exit 0
fi

# Skip very short messages (likely steering or acknowledgments)
if [[ ${#USER_MESSAGE} -lt 25 ]]; then
  exit 0
fi

# Convert to lowercase for pattern matching
MSG_LOWER=$(echo "$USER_MESSAGE" | tr '[:upper:]' '[:lower:]')

# Skip questions and explanations (not change requests)
if echo "$MSG_LOWER" | grep -qE '^(what|how|why|where|when|explain|show|describe|tell me|can you explain|could you explain)'; then
  exit 0
fi

# Skip if message looks like steering/feedback (short and directional)
if echo "$MSG_LOWER" | grep -qE '^(yes|no|ok|okay|sure|good|great|thanks|perfect|correct|right|wrong|try|use|do|looks good|lgtm|approved)'; then
  exit 0
fi

# Skip slash commands - they have their own workflows
if echo "$USER_MESSAGE" | grep -qE '^/'; then
  exit 0
fi

# Skip messages that are primarily code or file paths
if echo "$USER_MESSAGE" | grep -qE '^\s*```|^[a-zA-Z0-9_/-]+\.(ts|js|py|sh|md|json|yaml|yml)$'; then
  exit 0
fi

# Detect change request keywords
CHANGE_KEYWORDS='(add|implement|create|build|make|write|develop|introduce|set up|setup)'
FIX_KEYWORDS='(fix|bug|broken|error|issue|problem|wrong|fail|crash|resolve)'
MODIFY_KEYWORDS='(change|update|modify|refactor|improve|enhance|optimize|rewrite|restructure)'
REMOVE_KEYWORDS='(remove|delete|drop|deprecate|clean up|cleanup)'

IS_CHANGE_REQUEST=false
CHANGE_TYPE=""

if echo "$MSG_LOWER" | grep -qE "$CHANGE_KEYWORDS"; then
  IS_CHANGE_REQUEST=true
  CHANGE_TYPE="feature"
elif echo "$MSG_LOWER" | grep -qE "$FIX_KEYWORDS"; then
  IS_CHANGE_REQUEST=true
  CHANGE_TYPE="bugfix"
elif echo "$MSG_LOWER" | grep -qE "$MODIFY_KEYWORDS"; then
  IS_CHANGE_REQUEST=true
  CHANGE_TYPE="modification"
elif echo "$MSG_LOWER" | grep -qE "$REMOVE_KEYWORDS"; then
  IS_CHANGE_REQUEST=true
  CHANGE_TYPE="removal"
fi

# Exit if not a change request
if [[ $IS_CHANGE_REQUEST != true ]]; then
  exit 0
fi

# Get branch info
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
if [[ -z $BRANCH ]]; then
  BRANCH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo 'unknown')
fi
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')

# Check for existing pending tasks
TASKS_DIR="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH/tasks"
PENDING_TASKS=0
if [[ -d $TASKS_DIR ]]; then
  PENDING_TASKS=$(find "$TASKS_DIR" -maxdepth 1 -name '*-pending-*' -type f 2>/dev/null | wc -l | tr -d ' ')
fi

# If there are pending tasks, assume work is already planned
if [[ $PENDING_TASKS -gt 0 ]]; then
  exit 0
fi

# Determine recommended review agents based on change domain
DOMAIN_AGENTS=""

# Detect domain-specific keywords for agent selection
if echo "$MSG_LOWER" | grep -qE '(security|auth|permission|access|token|password|secret|encrypt|sanitize|xss|sql|injection)'; then
  DOMAIN_AGENTS="$DOMAIN_AGENTS security-reviewer"
fi

if echo "$MSG_LOWER" | grep -qE '(performance|speed|fast|slow|optimize|cache|memory|latency|throughput|scale)'; then
  DOMAIN_AGENTS="$DOMAIN_AGENTS performance-reviewer"
fi

if echo "$MSG_LOWER" | grep -qE '(api|endpoint|route|rest|graphql|request|response|schema|contract)'; then
  DOMAIN_AGENTS="$DOMAIN_AGENTS api-interface-analyst"
fi

if echo "$MSG_LOWER" | grep -qE '(ui|ux|component|page|form|button|modal|layout|style|css|tailwind|design)'; then
  DOMAIN_AGENTS="$DOMAIN_AGENTS ux-workflow-analyst"
fi

if echo "$MSG_LOWER" | grep -qE '(data|database|model|schema|migration|table|entity|relation|query|orm|drizzle)'; then
  DOMAIN_AGENTS="$DOMAIN_AGENTS data-model-architect"
fi

if echo "$MSG_LOWER" | grep -qE '(test|spec|coverage|mock|stub|assert|expect|vitest|playwright)'; then
  DOMAIN_AGENTS="$DOMAIN_AGENTS correctness-reviewer"
fi

if echo "$MSG_LOWER" | grep -qE '(error|exception|retry|fallback|timeout|resilient|recover|graceful)'; then
  DOMAIN_AGENTS="$DOMAIN_AGENTS resilience-reviewer"
fi

# Default agents if no specific domain detected
if [[ -z $DOMAIN_AGENTS ]]; then
  DOMAIN_AGENTS="correctness-reviewer elegance-reviewer"
fi

# Trim leading space
DOMAIN_AGENTS="${DOMAIN_AGENTS# }"

# Output condensed task-first guidance
cat <<EOF

<task-first>
**${CHANGE_TYPE^} detected** - No task file exists.
Create task at: \`.claude/branches/${SAFE_BRANCH}/tasks/{order}-pending-{priority}-{slug}.md\`
Or skip for trivial changes (<10 lines). For complex features: \`/crew:plan\`
</task-first>

EOF
