#!/usr/bin/env bash
# Track active workflow/skill invocations
# Called by UserPromptSubmit hook to remember current workflow

# Hooks must never fail - use defensive error handling
set +e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
STATE_DIR="$PROJECT_DIR/.claude/state"
WORKFLOW_FILE="$STATE_DIR/current-workflow.json"

# Read prompt from stdin
PROMPT=$(cat | jq -r '.prompt // empty' 2>/dev/null)

if [[ -z $PROMPT ]]; then
	exit 0
fi

# Detect skill/workflow invocations
WORKFLOW=""
ARGS=""

# Match explicit skill invocations
if [[ $PROMPT =~ ^[[:space:]]*/([a-zA-Z0-9:_-]+) ]]; then
	WORKFLOW="${BASH_REMATCH[1]}"
	ARGS="${PROMPT#*"$WORKFLOW"}"
	ARGS="${ARGS#"${ARGS%%[![:space:]]*}"}" # trim leading whitespace
elif echo "$PROMPT" | grep -qiE "Skill[[:space:]]*\([[:space:]]*\{[[:space:]]*skill:[[:space:]]*[\"']"; then
	# Extract skill name from Skill({skill: "name"}) or Skill({skill: 'name'})
	# Use POSIX-compatible [[:space:]] and double-quoted string for portable quote matching
	WORKFLOW=$(echo "$PROMPT" | sed -n "s/.*Skill[[:space:]]*([[:space:]]*{[[:space:]]*skill:[[:space:]]*[\"']\([^\"']*\).*/\1/ip" | head -1)
fi

# Only track workflows: prefixed skills
if [[ -n $WORKFLOW && $WORKFLOW == workflows:* ]]; then
	mkdir -p "$STATE_DIR"
	jq -n \
		--arg workflow "$WORKFLOW" \
		--arg args "$ARGS" \
		--arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
		'{workflow: $workflow, args: $args, started_at: $time}' >"$WORKFLOW_FILE"
fi

