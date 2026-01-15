#!/usr/bin/env bash
# Enhance agents with domain-specific skills based on prompt content
# Triggered on PreToolUse for Task tool
#
# This hook:
# 1. Scans skill files for trigger patterns (cached)
# 2. Matches Task prompt against triggers
# 3. Outputs directives to include matching skills
# 4. Also applies flow enhancement skills for target agents

set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="enhance-agent"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Target agent types for flow enhancement skills
TARGET_AGENTS="explore plan general-purpose"

# Read tool input from stdin
INPUT=$(cat)

# Extract tool_name, subagent_type, and prompt
read -r TOOL_NAME SUBAGENT_TYPE < <(echo "$INPUT" | jq -r '[.tool_name // "", .tool_input.subagent_type // ""] | @tsv' 2>/dev/null)
TASK_PROMPT=$(echo "$INPUT" | jq -r '.tool_input.prompt // ""' 2>/dev/null)

# Only process Task tool
if [[ "$TOOL_NAME" != "Task" ]]; then
	exit 0
fi

# Skip if no subagent_type
if [[ -z "$SUBAGENT_TYPE" ]]; then
	exit 0
fi

# --- Setup paths ---
LIB_DIR="$SCRIPT_DIR/../lib"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")}"

# --- Source shared skill matcher ---
# shellcheck source=../lib/skill-matcher.sh
source "$LIB_DIR/skill-matcher.sh"

# --- Check if this is a target agent for flow enhancement ---
IS_TARGET=false
for agent in $TARGET_AGENTS; do
	if [[ "$SUBAGENT_TYPE" == "$agent" ]]; then
		IS_TARGET=true
		break
	fi
done

# --- Collect skills to inject ---
SKILLS_TO_INJECT=""

# 1. Flow enhancement skill (for target agents)
if [[ "$IS_TARGET" == "true" ]]; then
	SKILL_PATH="$PLUGIN_ROOT/skills/enhance/$SUBAGENT_TYPE/SKILL.md"
	SKILL_NAME="flow:enhance:$SUBAGENT_TYPE"

	if [[ -f "$SKILL_PATH" ]]; then
		SKILLS_TO_INJECT="$SKILL_NAME"
		log_event "ENHANCE" "agent=$SUBAGENT_TYPE" "skill=$SKILL_NAME"
	else
		log_event "SKIP" "agent=$SUBAGENT_TYPE" "skill=$SKILL_NAME" "reason=skill_missing"
	fi
fi

# 2. Review enhancement (detected from prompt keywords)
# Unlike target agents, review tasks don't have a dedicated subagent_type
# We detect review context from prompt content and inject the skill
if [[ -n "$TASK_PROMPT" ]]; then
	REVIEW_PATTERN="(code.*review|review.*(pr|code|changes)|pr.*review|audit|compliance|bug.*detect|find.*(bug|issue)|security.*review|check.*code)"
	PROMPT_LOWER="${TASK_PROMPT,,}"
	if [[ "$PROMPT_LOWER" =~ $REVIEW_PATTERN ]]; then
		REVIEW_SKILL_PATH="$PLUGIN_ROOT/skills/enhance/review/SKILL.md"
		if [[ -f "$REVIEW_SKILL_PATH" ]]; then
			if [[ -n "$SKILLS_TO_INJECT" ]]; then
				SKILLS_TO_INJECT="$SKILLS_TO_INJECT flow:enhance:review"
			else
				SKILLS_TO_INJECT="flow:enhance:review"
			fi
			log_event "ENHANCE" "agent=$SUBAGENT_TYPE" "skill=flow:enhance:review" "reason=prompt_match"
		fi
	fi
fi

# 3. PR awareness (when working on a branch with open PR)
# Check if there's an open PR for the current branch - inject pr-awareness skill
# This provides passive context about unresolved comments during regular work
HAS_PR=$(gh pr view --json number -q '.number' 2>/dev/null || true)
if [[ -n "$HAS_PR" ]]; then
	PR_AWARENESS_SKILL_PATH="$PLUGIN_ROOT/skills/enhance/pr-awareness/SKILL.md"
	if [[ -f "$PR_AWARENESS_SKILL_PATH" ]]; then
		if [[ -n "$SKILLS_TO_INJECT" ]]; then
			SKILLS_TO_INJECT="$SKILLS_TO_INJECT flow:enhance:pr-awareness"
		else
			SKILLS_TO_INJECT="flow:enhance:pr-awareness"
		fi
		log_event "ENHANCE" "agent=$SUBAGENT_TYPE" "skill=flow:enhance:pr-awareness" "reason=pr_detected"
	fi
fi

# 4. Domain skills (matched from triggers in prompt)
if [[ -n "$TASK_PROMPT" ]]; then
	MATCHED_SKILLS=$(match_skills_from_triggers "$TASK_PROMPT" "$LIB_DIR")

	if [[ -n "$MATCHED_SKILLS" ]]; then
		if [[ -n "$SKILLS_TO_INJECT" ]]; then
			SKILLS_TO_INJECT="$SKILLS_TO_INJECT $MATCHED_SKILLS"
		else
			SKILLS_TO_INJECT="$MATCHED_SKILLS"
		fi
	fi
fi

# --- Exit if no skills to inject ---
if [[ -z "$SKILLS_TO_INJECT" ]]; then
	exit 0
fi

# --- Output enhancement directive ---
{
	echo ""
	echo "╔══════════════════════════════════════════════════════════════════╗"
	echo "║ AGENT ENHANCEMENT DIRECTIVE                                      ║"
	echo "╠══════════════════════════════════════════════════════════════════╣"
	printf "║ Agent: %-57s║\n" "$SUBAGENT_TYPE"
	echo "║                                                                  ║"
	echo "║ ACTION: Modify your prompt parameter to prepend:                 ║"
	echo "║                                                                  ║"
	for skill in $SKILLS_TO_INJECT; do
		printf "║   Skill({ skill: \"%s\" })%*s║\n" "$skill" $((37 - ${#skill})) ""
	done
	echo "║                                                                  ║"
	echo "║ This ensures the agent has required domain knowledge.            ║"
	echo "╚══════════════════════════════════════════════════════════════════╝"
	echo ""
}

exit 0
