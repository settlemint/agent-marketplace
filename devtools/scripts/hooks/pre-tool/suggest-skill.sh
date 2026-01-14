#!/usr/bin/env bash
# Suggest relevant devtools skills based on command being run
# Non-blocking - provides tips without preventing the action

set +e

is_truthy() {
	case "${1:-}" in
	1 | true | yes | on) return 0 ;;
	*) return 1 ;;
	esac
}

QUIET="${CLAUDE_QUIET:-${DEVTOOLS_QUIET:-}}"
TOKEN_SAVER="${CLAUDE_TOKEN_SAVER:-${DEVTOOLS_TOKEN_SAVER:-}}"
TIPS_MODE="${DEVTOOLS_TIPS:-}"

# Allow opt-out for tips
if is_truthy "$QUIET" || [[ "$TIPS_MODE" =~ ^(0|off|false)$ ]]; then
	exit 0
fi

INPUT=$(cat)

# Single jq call to extract both fields (performance optimization)
read -r TOOL_NAME COMMAND < <(echo "$INPUT" | jq -r '[.tool_name // "", .tool_input.command // ""] | @tsv' 2>/dev/null)

# Only check Bash tool
[[ $TOOL_NAME != "Bash" ]] && exit 0

# Extract first line of command
CMD_LINE="${COMMAND%%$'\n'*}"

# Suggestion messages based on command patterns
SUGGESTION=""

# Optional dedupe per session (default) to save tokens
MARKER=""
if is_truthy "$TOKEN_SAVER" || [[ "$TIPS_MODE" != "all" ]]; then
	PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
	BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
	[[ -z $BRANCH ]] && BRANCH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo 'unknown')
	SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
	BRANCH_DIR="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH"
	SESSION_ID="${CLAUDE_SESSION_ID:-$$}"
	MARKER="$BRANCH_DIR/.devtools-tips-shown-${SESSION_ID}"
	[[ -f $MARKER ]] && exit 0
fi

# Vitest - suggest vitest skill
if [[ $CMD_LINE =~ vitest|bun\ run\ test|npm\ run\ test|pnpm\ run\ test ]]; then
	SUGGESTION="Tip: check devtools:vitest for test patterns and coverage."
fi

# Playwright - suggest playwright skill
if [[ $CMD_LINE =~ playwright|bun\ run\ e2e|npm\ run\ e2e ]]; then
	SUGGESTION="Tip: check devtools:playwright for E2E patterns."
fi

# Drizzle migrations
if [[ $CMD_LINE =~ drizzle|migration|db\ push|db\ pull ]]; then
	SUGGESTION="Tip: check devtools:drizzle for schema and migrations."
fi

# Biome/ESLint
if [[ $CMD_LINE =~ biome|eslint|lint ]]; then
	SUGGESTION="Tip: auto-lint runs post-edit; see devtools:troubleshooting for lint issues."
fi

# Helm
if [[ $CMD_LINE =~ helm|kubectl ]]; then
	SUGGESTION="Tip: check devtools:helm for chart and values.yaml conventions."
fi

# Next.js - suggest react-best-practices for performance patterns
if [[ $CMD_LINE =~ next\ (build|dev|start)|npm\ run\ (build|dev)|bun\ run\ (build|dev) ]]; then
	SUGGESTION="Tip: check devtools:react-best-practices for React/Next.js performance patterns."
fi

# React component creation - suggest react-best-practices
if [[ $CMD_LINE =~ create.*component|generate.*component ]]; then
	SUGGESTION="Tip: check devtools:react-best-practices for optimal component patterns."
fi

# Output suggestion if we have one
if [[ -n $SUGGESTION ]]; then
	# Mark as shown for this session (token saver)
	if [[ -n $MARKER ]]; then
		mkdir -p "$(dirname "$MARKER")" 2>/dev/null
		touch "$MARKER" 2>/dev/null
	fi
	jq -n --arg msg "$SUGGESTION" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "message": $msg
    }
  }'
fi

exit 0
