#!/usr/bin/env bash
# Enforce TDD workflow for implementation requests
# Triggered on UserPromptSubmit for implementation-related prompts

# Check if this looks like an implementation request
if echo "$CLAUDE_USER_PROMPT" | grep -qiE "implement|add feature|build feature|create functionality|new feature|develop"; then
	cat <<'EOF'
CONTEXT: TDD Workflow Required

Before implementing, you MUST follow the RED-GREEN-REFACTOR cycle:

1. **RED** - Write a failing test FIRST (run `bun run test` to confirm failure)
2. **GREEN** - Write minimal code to pass the test
3. **REFACTOR** - Improve code while keeping tests green

Load skill `devtools:tdd-typescript` for detailed workflow guidance.

**NEVER write implementation code without a failing test first.**
EOF
fi
