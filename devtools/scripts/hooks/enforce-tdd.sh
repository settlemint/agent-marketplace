#!/usr/bin/env bash
# Enforce TDD workflow for implementation requests
# Triggered on UserPromptSubmit for implementation-related prompts

is_truthy() {
	case "${1:-}" in
		1|true|yes|on) return 0 ;;
		*) return 1 ;;
	esac
}

QUIET="${CLAUDE_QUIET:-${DEVTOOLS_QUIET:-}}"
TOKEN_SAVER="${CLAUDE_TOKEN_SAVER:-${DEVTOOLS_TOKEN_SAVER:-}}"

# Check if this looks like an implementation request
if echo "$CLAUDE_USER_PROMPT" | grep -qiE "implement|add feature|build feature|create functionality|new feature|develop"; then
	# Optional per-session dedupe
	PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
	BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
	[[ -z $BRANCH ]] && BRANCH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo 'unknown')
	SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
	BRANCH_DIR="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH"
	SESSION_ID="${CLAUDE_SESSION_ID:-$$}"
	MARKER="$BRANCH_DIR/.tdd-prompt-shown-${SESSION_ID}"

	if [[ -f $MARKER ]]; then
		exit 0
	fi

	mkdir -p "$BRANCH_DIR" 2>/dev/null
	touch "$MARKER" 2>/dev/null

	if is_truthy "$QUIET"; then
		exit 0
	fi

	if is_truthy "$TOKEN_SAVER"; then
		cat <<'EOF'
CONTEXT: TDD required. Write failing test first; then minimal code (RED->GREEN->REFACTOR).
Load skill `devtools:tdd-typescript`.
EOF
	else
		cat <<'EOF'
CONTEXT: TDD required.
1) RED: write failing test first (run `bun run test`)
2) GREEN: minimal code to pass
3) REFACTOR: improve code with tests green
Load skill `devtools:tdd-typescript`.
EOF
	fi
fi
