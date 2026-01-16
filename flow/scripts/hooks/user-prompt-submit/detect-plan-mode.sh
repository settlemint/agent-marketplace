#!/usr/bin/env bash
# Detect plan mode and inject planning workflow guidance
# Triggered on UserPromptSubmit to provide planning discipline
#
# When plan mode is active, this hook surfaces the plan workflow from
# flow/skills/enhance/workflows/plan.md to ensure 5-pass planning discipline.

set +e

# Read hook input from stdin
INPUT=$(cat)

# Check if plan mode is active by looking at the user message content
# Plan mode system prompt includes "Plan mode is active" or "Plan mode still active"
USER_MESSAGE=$(echo "$INPUT" | jq -r '.user_message // ""' 2>/dev/null)

# Detect plan mode - check for common plan mode indicators
IS_PLAN_MODE=false
if echo "$USER_MESSAGE" | grep -qiE '(plan mode (is|still) active|Plan mode active)'; then
  IS_PLAN_MODE=true
fi

# Also check session context if available
SESSION_CONTEXT=$(echo "$INPUT" | jq -r '.session_context // ""' 2>/dev/null)
if echo "$SESSION_CONTEXT" | grep -qiE 'plan.?mode'; then
  IS_PLAN_MODE=true
fi

# If not in plan mode, exit silently
if [[ "$IS_PLAN_MODE" != "true" ]]; then
  exit 0
fi

# Check if we've already injected plan workflow this session
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo 'unknown')
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
BRANCH_DIR="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH"
SESSION_ID="${CLAUDE_SESSION_ID:-$$}"
PLAN_MARKER="$BRANCH_DIR/.plan-workflow-shown-${SESSION_ID}"

# If already shown this session, skip
if [[ -f "$PLAN_MARKER" ]]; then
  exit 0
fi

# Output plan workflow guidance
cat <<'EOF'
<plan-mode-guidance>
## Planning Discipline

**Load planning skills:**
```javascript
Skill({ skill: "devtools:rule-of-five" })  // 5-pass convergence
Skill({ skill: "devtools:tdd-typescript" }) // TDD for implementation steps
```

**5-Pass Protocol:** Generate → Tactical → Quality → Architecture → Strategic
Converge when <3 changes per pass.

**Plan Format:**
- Each step: `[parallel]` or `[serial]` marker + evidence + TDD requirement
- User stories: As a <user>, I want <goal>, so that <benefit>
- Acceptance criteria: Given <context>, when <action>, then <outcome>
- Template: `flow/skills/enhance/templates/plan-template.md`

**For complex plans (>5 files, architectural decisions):**
```javascript
MCPSearch({ query: "select:mcp__plugin_devtools_codex__codex" });
mcp__plugin_devtools_codex__codex({
  prompt: `Review this plan for: 1) Architecture trade-offs, 2) Security implications, 3) Complexity assessment`
});
```

**Full workflow details:** Read `flow/skills/enhance/workflows/plan.md`
</plan-mode-guidance>
EOF

# Mark as shown for this session
mkdir -p "$BRANCH_DIR" 2>/dev/null
touch "$PLAN_MARKER" 2>/dev/null

exit 0
