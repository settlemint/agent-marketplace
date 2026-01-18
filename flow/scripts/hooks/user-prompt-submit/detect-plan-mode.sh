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

# Output plan workflow guidance - MANDATORY requirements enforced by PreToolUse hook
cat <<'EOF'
<plan-mode-requirements>
## MANDATORY: Plan Mode Compliance (Enforced by PreToolUse hook)

ExitPlanMode will be BLOCKED until you complete all requirements.

### Delegation Pattern (Main Thread = Orchestrator)

**Phase 1: Parallel Research** - Spawn 2-3 Explore agents:
```javascript
Task({ subagent_type: "Explore", prompt: "Research external docs, SDK patterns..." })
Task({ subagent_type: "Explore", prompt: "Analyze codebase architecture, existing patterns..." })
Task({ subagent_type: "Explore", prompt: "Identify test coverage gaps for files we'll touch..." })
```

**Phase 2: Draft Plan** - Main thread synthesizes and drafts

**Phase 3: Review Delegation** - Spawn review agents OR invoke directly:
```javascript
// Option A: Delegate Rule of Five to subagent
Task({ subagent_type: "Plan", prompt: "Apply Rule of Five: 3 passes (tactical, quality, architecture). Return findings with evidence." })

// Option B: Invoke Codex directly (REQUIRED for ALL plans)
MCPSearch({ query: "select:mcp__plugin_devtools_codex__codex" })
mcp__plugin_devtools_codex__codex({
  prompt: "Review this plan for: architecture trade-offs, security implications, complexity"
})
```

**Phase 4: Finalize** - Main thread makes final decisions

### Gate Requirements (checked by plan-quality-gate.sh)

| Requirement | How to Satisfy |
|-------------|----------------|
| Codex Review | Invoke mcp__plugin_devtools_codex__codex (required for ALL plans) |
| Rule of Five | Document 3+ passes OR spawn Review subagent |
| TDD | Plan mentions tests for implementation steps |

### Plan Format
- Each step: `[parallel]` or `[serial]` marker
- Each step: Evidence definition for completion
- Implementation steps: TDD requirement (test file, coverage target)
- Merge walls: Identified and front-loaded

### TDD in Plans (MANDATORY)
Every implementation step MUST include test requirement:
```markdown
3. [serial] Implement user service
   - File: src/services/user.ts
   - TDD: Write failing test in src/services/user.test.ts FIRST
   - Evidence: Test fails -> passes -> coverage >=80%
```

**Emergency bypass:** Add `[PLAN-BYPASS]` to plan file (audited)
**Full workflow:** Read `flow/skills/enhance/workflows/plan.md`
</plan-mode-requirements>
EOF

# Mark as shown for this session
mkdir -p "$BRANCH_DIR" 2>/dev/null
touch "$PLAN_MARKER" 2>/dev/null

exit 0
