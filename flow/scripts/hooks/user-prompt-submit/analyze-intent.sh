#!/usr/bin/env bash
# Token-efficient prompt enhancement for proactive tool usage
# Injects guidance for AskUserQuestion, TodoWrite, Task parallelization, and skill suggestions
#
# Classification:
# - SKIP: steering, slash commands, questions, short messages
# - TRIVIAL: single low-complexity actions
# - MULTI_STEP: 3+ actions implied
# - COMPLEX: architecture/design/security/ambiguous scope
#
# Skill matching:
# - Scans all skill files for trigger patterns
# - Suggests loading matching skills
#
# Token budget: <150 tokens per injection
# Deduplication: Once per session via marker file

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="analyze-intent"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read input
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null)

# --- Skip conditions (exit early for token efficiency) ---

# Empty prompt
[[ -z "$PROMPT" ]] && exit 0

# Very short messages (steering/acknowledgments)
[[ ${#PROMPT} -lt 20 ]] && exit 0

# Slash commands have their own workflows
[[ "$PROMPT" =~ ^/ ]] && exit 0

# Convert to lowercase for pattern matching
MSG_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

# Question detection - let Claude answer naturally
if [[ "$MSG_LOWER" =~ ^(what|how|why|where|when|which|explain|show|describe|tell[[:space:]]me|can[[:space:]]you[[:space:]]explain|could[[:space:]]you[[:space:]]explain|is[[:space:]]there) ]]; then
	exit 0
fi

# Steering/feedback detection
if [[ "$MSG_LOWER" =~ ^(yes|no|ok|okay|sure|good|great|thanks|perfect|correct|right|wrong|try|use|do|looks[[:space:]]good|lgtm|approved|go|proceed|continue)[[:space:]]*$ ]]; then
	exit 0
fi

# Code blocks or file paths only
if [[ "$PROMPT" =~ ^[[:space:]]*\`\`\` ]] || [[ "$PROMPT" =~ ^[a-zA-Z0-9_/-]+\.(ts|js|py|sh|md|json|yaml|yml)$ ]]; then
	exit 0
fi

# --- Session deduplication (show hint only once per session) ---
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SESSION_ID="${CLAUDE_SESSION_ID:-$$}"
MARKER_DIR="$PROJECT_DIR/.claude/flow/hooks"
MARKER="$MARKER_DIR/.prompt-hint-${SESSION_ID}"

if [[ -f "$MARKER" ]]; then
	exit 0
fi

# --- Setup paths ---
SCRIPT_DIR=$(dirname "$0")
LIB_DIR="$SCRIPT_DIR/../lib"

# --- Source shared skill matcher ---
# shellcheck source=../lib/skill-matcher.sh
source "$LIB_DIR/skill-matcher.sh"

# --- Classification ---
CLASSIFICATION="SKIP"
SUGGESTED_SKILLS=""

# Match skills from triggers (with activation logging for evaluation)
SUGGESTED_SKILLS=$(match_skills_from_triggers "$MSG_LOWER" "$LIB_DIR" "log" "analyze-intent")

# TRIVIAL indicators - no hint needed (but not if skills matched)
TRIVIAL_PATTERN='(typo|comment|rename[[:space:]]|move[[:space:]]|copy[[:space:]]|delete[[:space:]]line|remove[[:space:]]line|add[[:space:]]line|fix[[:space:]]indent|add[[:space:]]comment)'
if [[ -z "$SUGGESTED_SKILLS" ]] && [[ "$MSG_LOWER" =~ $TRIVIAL_PATTERN ]] && [[ ${#PROMPT} -lt 80 ]]; then
	exit 0
fi

# COMPLEX domain detection
COMPLEX_DOMAIN='(architecture|design[[:space:]]|security|auth|permission|performance|scale|refactor|restructure|migrate|integrate|api[[:space:]]design|database[[:space:]]schema|workflow|implement[[:space:]].*system)'
AMBIGUOUS_SCOPE='(something|somehow|properly|correctly|better[[:space:]]way|improve[[:space:]]|optimize[[:space:]]|enhance[[:space:]]|fix[[:space:]]the[[:space:]]issue|address[[:space:]]the|handle[[:space:]]the)'

IS_AMBIGUOUS=false
if [[ "$MSG_LOWER" =~ $AMBIGUOUS_SCOPE ]]; then
	IS_AMBIGUOUS=true
	CLASSIFICATION="COMPLEX"
elif [[ "$MSG_LOWER" =~ $COMPLEX_DOMAIN ]]; then
	CLASSIFICATION="COMPLEX"
fi

# MULTI_STEP detection (if not already COMPLEX)
MULTI_STEP_PATTERN='([[:space:]]and[[:space:]].*[[:space:]]and[[:space:]]|,.*,|then[[:space:]].*then|first[[:space:]].*second|implement.*test|create.*add|build.*test|add.*update)'
if [[ "$CLASSIFICATION" != "COMPLEX" ]]; then
	if [[ "$MSG_LOWER" =~ $MULTI_STEP_PATTERN ]] || [[ ${#PROMPT} -gt 150 ]]; then
		CLASSIFICATION="MULTI_STEP"
	fi
fi

# Skip if still classified as SKIP and no skills suggested
[[ "$CLASSIFICATION" == "SKIP" ]] && [[ -z "$SUGGESTED_SKILLS" ]] && exit 0

# --- Create marker to prevent repeated hints ---
mkdir -p "$MARKER_DIR" 2>/dev/null
touch "$MARKER" 2>/dev/null

# Log the classification result
log_info "event=INTENT_ANALYZED" "classification=$CLASSIFICATION" "skills=$SUGGESTED_SKILLS" "ambiguous=$IS_AMBIGUOUS"

# --- Output skill suggestions first (if any) ---
if [[ -n "$SUGGESTED_SKILLS" ]]; then
	# Count skills
	skill_count=$(echo "$SUGGESTED_SKILLS" | wc -w | tr -d ' ')

	if [[ "$skill_count" -eq 1 ]]; then
		cat <<EOF

<flow-hint>
Skill match detected. Load:
Skill({ skill: "$SUGGESTED_SKILLS" })
</flow-hint>
EOF
	else
		echo ""
		echo "<flow-hint>"
		echo "Skills matched. Load:"
		for skill in $SUGGESTED_SKILLS; do
			echo "Skill({ skill: \"$skill\" })"
		done
		echo "</flow-hint>"
	fi
fi

# --- Output based on classification ---
case "$CLASSIFICATION" in
"MULTI_STEP")
	cat <<'EOF'

<flow-hint>
Multi-step task. Use TodoWrite for visibility:
TodoWrite({ todos: [{ content: "...", status: "in_progress", activeForm: "..." }] })
</flow-hint>
EOF
	;;
"COMPLEX")
	if [[ "$IS_AMBIGUOUS" == true ]]; then
		cat <<'EOF'

<flow-hint>
Ambiguous scope. Use AskUserQuestion FIRST:
AskUserQuestion({ questions: [{ question: "...", options: [...] }] })
Then spawn Task({ run_in_background: true }) for parallel work.
</flow-hint>
EOF
	else
		cat <<'EOF'

<flow-hint>
Complex task. Consider:
1. AskUserQuestion to clarify requirements
2. Task({ run_in_background: true }) for parallel work
3. TodoWrite for progress tracking
</flow-hint>
EOF
	fi
	;;
esac

exit 0
