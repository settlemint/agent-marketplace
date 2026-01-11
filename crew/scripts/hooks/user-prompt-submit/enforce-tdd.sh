#!/usr/bin/env bash
# Enforce TDD workflow for ANY code-related request
# Broader pattern matching than devtools - catches all implementation scenarios
#
# This fires on UserPromptSubmit to prime the session for TDD before any work.

set +e

# Read user message from stdin
INPUT=$(cat)
USER_MESSAGE=$(echo "$INPUT" | jq -r '.content // ""' 2>/dev/null)

# Skip empty messages
if [[ -z $USER_MESSAGE ]]; then
	exit 0
fi

# Skip very short messages (likely steering)
if [[ ${#USER_MESSAGE} -lt 15 ]]; then
	exit 0
fi

# Convert to lowercase for pattern matching
MSG_LOWER=$(echo "$USER_MESSAGE" | tr '[:upper:]' '[:lower:]')

# Skip questions and explanations (not code requests)
if echo "$MSG_LOWER" | grep -qE '^(what|how|why|where|when|explain|show|describe|list|find|search|read|check)'; then
	exit 0
fi

# Skip slash commands - they have their own workflows
if echo "$USER_MESSAGE" | grep -qE '^/'; then
	exit 0
fi

# Skip purely git/commit/pr operations
if echo "$MSG_LOWER" | grep -qE '^(commit|push|pull|merge|rebase|checkout|branch|pr|git|revert)'; then
	exit 0
fi

# Comprehensive code change patterns - much broader than devtools
CODE_PATTERNS='(implement|add|create|build|make|write|develop|introduce|fix|bug|broken|error|change|update|modify|refactor|improve|enhance|optimize|rewrite|restructure|extend|new|feature|function|class|method|component|endpoint|api|service|handler|controller|model|view|route|hook|util|helper|module|package|library)'

# Check if this looks like a code change request
if ! echo "$MSG_LOWER" | grep -qE "$CODE_PATTERNS"; then
	exit 0
fi

# Skip if message is clearly about reviewing/reading code only
if echo "$MSG_LOWER" | grep -qE '^(review|look at|examine|analyze|audit|inspect|check)' && ! echo "$MSG_LOWER" | grep -qE '(and fix|and change|and update|then)'; then
	exit 0
fi

# Output TDD enforcement guidance
cat <<'EOF'

<tdd-enforcement-required>

## TDD Workflow Required

This appears to involve code changes. **Test-Driven Development (TDD) is mandatory.**

### The Three Laws of TDD

1. **Write NO production code** until a failing test exists
2. **Write ONLY enough test** to demonstrate failure
3. **Write ONLY enough code** to pass the test

### Before ANY Code Change

```javascript
// Load the TDD skill FIRST
Skill({ skill: "devtools:tdd-typescript" })
```

### RED-GREEN-REFACTOR Cycle

| Phase | Action | Verification |
|-------|--------|--------------|
| RED | Write failing test | `bun run test` - must FAIL |
| GREEN | Write minimal code | `bun run test` - must PASS |
| REFACTOR | Improve code | `bun run test` - still PASS |

### Coverage Requirements (Non-Negotiable)

- Line coverage: **80% minimum**
- Branch coverage: **75% minimum**
- Function coverage: **90% minimum**
- Critical paths (auth, payments, permissions): **100%**

### Workflow

1. **Understand** - Read existing code, understand context
2. **Test First** - Write a failing test for the desired behavior
3. **Run Tests** - Confirm the test fails (RED phase)
4. **Implement** - Write minimum code to pass
5. **Run Tests** - Confirm tests pass (GREEN phase)
6. **Refactor** - Clean up while keeping tests green
7. **Verify** - Run full test suite, check coverage

**NO EXCEPTIONS. Tests first, always.**

</tdd-enforcement-required>

EOF
