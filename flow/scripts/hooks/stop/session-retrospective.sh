#!/usr/bin/env bash
# Session retrospective - prompts Claude to analyze the session for learnings
# This runs at Stop to capture insights before session ends

set +e

SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="session-retrospective"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read event data
EVENT_DATA=$(cat)

# Skip for subagents
AGENT_TYPE=$(echo "$EVENT_DATA" | jq -r '.agent_type // "main"' 2>/dev/null || echo "main")
if [[ "$AGENT_TYPE" != "main" ]]; then
	exit 0
fi

# Check for hook errors in this session's logs
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOGS_DIR="$PROJECT_DIR/.claude/logs/flow"
LEARNINGS_DIR="$PROJECT_DIR/.claude/flow/learnings"

# Collect any hook errors from today's logs
HOOK_ERRORS=""
if [[ -d "$LOGS_DIR" ]]; then
	TODAY=$(date +%Y-%m-%d)
	HOOK_ERRORS=$(grep -h "level=ERROR" "$LOGS_DIR"/*.log 2>/dev/null | grep "$TODAY" | head -10 || true)
fi

# Collect skill activation data for pattern analysis
SKILL_LOG="$PROJECT_DIR/.claude/flow/skill-activations.jsonl"
SKILL_STATS=""
if [[ -f "$SKILL_LOG" ]]; then
	# Get today's activations
	TODAY=$(date +%Y-%m-%d)
	SKILL_STATS=$(grep "$TODAY" "$SKILL_LOG" 2>/dev/null | jq -s '
    group_by(.skill) |
    map({skill: .[0].skill, count: length, triggers: [.[].trigger_pattern] | unique}) |
    sort_by(-.count)
  ' 2>/dev/null || echo "[]")
fi

# Create learnings directory
mkdir -p "$LEARNINGS_DIR"

# Generate timestamp for learnings file
TIMESTAMP=$(date +%Y-%m-%d-%H%M)
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
SAFE_BRANCH="${BRANCH//\//-}"
LEARNINGS_FILE="$LEARNINGS_DIR/${TIMESTAMP}-${SAFE_BRANCH}.md"

# Output retrospective prompt
cat <<EOF

<flow-session-retrospective>
Before ending this session, please review what happened and capture learnings.

**Review for:**
1. **Tool errors** - Commands that failed, files not found, permission issues
2. **Hook failures** - Any hook errors reported during the session
3. **Inefficient patterns** - Tasks that took multiple attempts when one should suffice
4. **Skill gaps** - Situations where loading a skill earlier would have helped

**Hook errors detected:**
$(if [[ -n "$HOOK_ERRORS" ]]; then echo "$HOOK_ERRORS"; else echo "None detected"; fi)

**Skill activations today:**
$(if [[ -n "$SKILL_STATS" && "$SKILL_STATS" != "[]" ]]; then echo "$SKILL_STATS" | jq -r '.[] | "- \(.skill): \(.count) activations"' 2>/dev/null; else echo "No activations logged"; fi)

**Write findings to:** $LEARNINGS_FILE

**Format:**
\`\`\`markdown
# Session Learnings - $TIMESTAMP

## Errors Encountered
- [error]: [root cause] → [fix needed]

## Inefficient Patterns
- [what happened]: [why it was inefficient] → [how to prevent]

## Skill Improvements
- [skill name]: [what should be added/changed]

## Notes
- Any other observations
\`\`\`

Skip this review if the session was trivial (single question, no errors).
</flow-session-retrospective>
EOF

log_info "event=RETROSPECTIVE_PROMPTED" "learnings_file=$LEARNINGS_FILE"
exit 0
