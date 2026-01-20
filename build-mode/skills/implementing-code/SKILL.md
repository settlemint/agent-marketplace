---
name: implementing-code
description: Executes implementation plans with TDD-driven development, subagent orchestration, systematic debugging, visual testing, and verification before completion. Use when implementing features, executing plans, building code, fixing bugs, or starting any coding task.
version: 1.0.0
---

<EXTREMELY-IMPORTANT>
## THE IRON LAW OF TDD

**NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.**

This is NOT negotiable. This is NOT optional. You cannot rationalize your way out of this.

If you write code before a test:
1. DELETE the code
2. Write the test
3. Watch it FAIL
4. THEN write the implementation

"Just this once" is not acceptable.
"It's too simple to test" is not acceptable.
"I already know it works" is not acceptable.

ALL of these mean: Delete code. Start over with TDD.
</EXTREMELY-IMPORTANT>

# Execution Methodology

A systematic approach to implementing plans and tasks with TDD, subagent orchestration, and verification before completion.

## Table of Contents

- [Core Principles](#core-principles)
- [TDD Workflow](#tdd-workflow)
- [Execution Workflow](#execution-workflow)
- [Subagent Orchestration](#subagent-orchestration)
- [Two-Stage Review](#two-stage-review)
- [Systematic Debugging](#systematic-debugging)
- [Visual Testing](#visual-testing)
- [Verification Before Completion](#verification-before-completion)
- [Context Preservation](#context-preservation)
- [Quality Gates](#quality-gates)

## Core Principles

- **TDD Required** - No production code without a failing test first
- **Evidence Before Claims** - No "should work" - only verified facts
- **Fresh subagent per task** - Prevent context pollution
- **Two-Stage Review** - Spec compliance THEN quality review
- **Systematic Debugging** - No fix without root cause investigation
- **Visual Verification** - Browser-based testing for UI changes
- **CI Gate** - `bun run ci` must pass before completion

## TDD Workflow

Follow the Red-Green-Refactor cycle for ALL code changes:

### RED Phase

Write a single, minimal failing test demonstrating desired behavior.

```typescript
// Test MUST fail for the right reason (missing feature, not syntax error)
test('login returns token for valid credentials', async () => {
  const result = await login('user@example.com', 'password');
  expect(result.token).toBeDefined();
});
```

**Verify RED:** Run `bun run test` - confirm failure with expected reason.

### GREEN Phase

Write the **minimum code** to make the test pass.

**Rules:**
- No over-engineering
- No "future-proofing"
- No unrelated improvements
- Just enough to pass

**Verify GREEN:** Run `bun run test` - confirm pass, no regressions.

### REFACTOR Phase

Improve code while maintaining green tests.

**Allowed:**
- Remove duplication
- Improve names
- Extract helpers
- Simplify logic

**Not allowed:**
- Add new behavior
- Change test behavior

**Verify:** Tests still pass after every change.

### Critical Rules

| Rule | Consequence |
|------|-------------|
| Code written before tests | Delete it. Start over. |
| Tests pass immediately | Test is invalid. Write harder test. |
| Can't explain why test fails | Don't proceed. Understand first. |

### Legacy Code Strategy

Not all code has tests. When working with legacy:

1. **Before modifying**: Write characterization tests capturing current behavior
2. **Critical paths**: Security, payments, data mutations MUST have tests
3. **Silent failures**: If error handling is untested, add tests
4. **Bug fixes**: Always write regression test first

**Prioritize by risk:**
- P0 (Security/Auth/Payments): Stop. Write tests first.
- P1 (Business logic): Write tests before modifying
- P2 (API endpoints): Add integration tests
- P3+ (Utilities): Opportunistic

See `references/tdd-patterns.md` for detailed patterns including legacy code handling.

## Execution Workflow

### Overview

```
Plan → Task Breakdown → Per-Task Execution → Verification → Complete
```

### Per-Task Execution Loop

```
For each task:
  1. Mark task in_progress (TodoWrite)
  2. Spawn task-implementer agent (fresh context)
  3. Implementer follows TDD, completes self-review
  4. Spawn spec-reviewer (verify requirements)
  5. If spec fails → implementer fixes → re-review
  6. Spawn quality-reviewer (verify quality)
  7. If quality concerns → address P1s → re-review
  8. Spawn silent-failure-hunter (check error handling)
  9. If UI changes → spawn visual-tester
  10. Mark task completed (TodoWrite)
```

### Task Breakdown

If plan doesn't have 2-5 minute tasks, break down first:

**Before (too big):**
```
1. Implement user authentication
```

**After (2-5 min each):**
```
1. [serial] Write failing test for login function
2. [serial] Implement login to pass test
3. [parallel] Write failing test for logout
4. [serial] Implement logout to pass test
5. [serial] Add auth middleware
6. [serial] Wire routes
```

## Subagent Orchestration

### Core Pattern: Fresh subagent per task

Context pollution from previous tasks degrades quality. Each task gets clean context.

```
Task 1 → Implementer₁ → Spec₁ → Quality₁ → ✓
Task 2 → Implementer₂ → Spec₂ → Quality₂ → ✓
Task 3 → Implementer₃ → Spec₃ → Quality₃ → ✓
```

### MANDATORY: Use Build-Mode Agents

**NEVER use "Explore" or "general-purpose" for implementation tasks.** Always use the specialized build-mode agents:

| Task | Agent | subagent_type |
|------|-------|---------------|
| Implementation | task-implementer | `build-mode:task-implementer` |
| Requirements check | spec-reviewer | `build-mode:spec-reviewer` |
| Code quality | code-reviewer | `build-mode:code-reviewer` |
| Quality assessment | quality-reviewer | `build-mode:quality-reviewer` |
| Security audit | security-reviewer | `build-mode:security-reviewer` |
| Error handling | silent-failure-hunter | `build-mode:silent-failure-hunter` |
| UI verification | visual-tester | `build-mode:visual-tester` |
| Final gate | completion-validator | `build-mode:completion-validator` |

### Spawning Implementer

```javascript
Task({
  subagent_type: "build-mode:task-implementer",
  description: "Implement [task name]",
  prompt: `You are a TASK IMPLEMENTER. Follow TDD strictly.

TASK:
${taskDescription}

MANDATORY:
1. Write failing test FIRST
2. Verify test fails for right reason
3. Write minimal code to pass
4. Complete self-review checklist before reporting

SELF-REVIEW CHECKLIST:
- [ ] All requirements addressed
- [ ] No TODO comments left
- [ ] Tests exist for new functionality
- [ ] TDD cycle documented (RED → GREEN → REFACTOR)
- [ ] Evidence captured (test output)

EVIDENCE REQUIRED:
- Test command output showing pass
- Files modified with line numbers`,
  run_in_background: true
})
```

### Tool Boundaries

| Role | Tools Allowed | Tools Denied |
|------|---------------|--------------|
| Implementer | Read, Write, Edit, Bash, Grep, Glob | Task (no sub-subagents) |
| Reviewers | Read, Grep, Glob | Write, Edit, Bash |

### Iterative Context Refinement

When subagents (implementers or reviewers) return results, apply the iterative-retrieval protocol:

1. **Evaluate sufficiency** - Can I proceed confidently with this information?
2. **Identify gaps** - Did they mention things they didn't detail? Ambiguities?
3. **Resume if needed** - Use `Task({ resume: agentId, prompt: "..." })` for follow-up
4. **Max 3 cycles** - Prevent infinite loops

**Example: Reviewer finding needs clarification**
```javascript
// Reviewer says: "Potential race condition in state update"
// But doesn't show the concurrent access patterns

Task({
  resume: reviewerAgentId,
  prompt: `You identified a potential race condition at line 45.

  FOLLOW-UP NEEDED:
  1. What specific concurrent operations could cause this?
  2. Show the code paths that access this state simultaneously
  3. Is there existing synchronization I should know about?

  WHY: Need to understand the race condition to implement correct fix.`
})
```

See `skills/iterative-retrieval/SKILL.md` for the complete protocol.

## Two-Stage Review

### Stage 1: Spec Compliance Review

**Purpose:** Verify implementation matches requirements exactly.

**Key Rule:** DO NOT trust implementer's report. Read actual code.

**3-Pass Review:**

| Pass | Focus | Questions |
|------|-------|-----------|
| Literal | Exact requirements | Does code do exactly what spec says? |
| Intent | Spirit of requirements | Does it solve the actual problem? |
| Edge Cases | Boundary conditions | What happens at limits? |

### Stage 2: Quality Review

**Runs only AFTER spec review passes.**

**3-Pass Review:**

| Pass | Focus | Questions |
|------|-------|-----------|
| Style | Readability | Clear names? Consistent patterns? |
| Patterns | Architecture | Right abstractions? Follows codebase? |
| Maintainability | Future-proofing | Easy to modify? Well-documented? |

**Priority system:**
- P1: Must fix before merge
- P2: Should fix, not blocking
- P3: Nice to have

See `references/verification-patterns.md` for reviewer prompts.

## Systematic Debugging

When encountering bugs or failures, follow the 4-phase methodology:

### Phase 1: Root Cause Investigation

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

1. Read error messages completely
2. Reproduce issue consistently
3. Review recent changes
4. Trace data flow across boundaries
5. Gather evidence through diagnostics

**Apply Iterative Retrieval for Deep Investigation:**

When dispatching agents to investigate bugs, use the iterative-retrieval protocol:

```javascript
// Initial investigation
const bugResult = Task({
  subagent_type: "general-purpose",
  description: "Investigate API failure",
  prompt: `OBJECTIVE: Fix 500 error on /api/users

  QUERIES: What code handles this? What error handling exists?
  WHY: Need root cause before implementing fix.`
})

// If response shows symptom but not cause, follow up
Task({
  resume: bugResult.agentId,
  prompt: `You showed the error occurs but not WHY.

  FOLLOW-UP: What triggers this code path to fail?
  Show me the data flow from request to error.`
})
```

See `skills/iterative-retrieval/SKILL.md` for the complete protocol.

### Phase 2: Pattern Analysis

1. Find working examples in codebase
2. Compare thoroughly against broken code
3. Read reference implementations completely (no skimming)
4. Document every difference

### Phase 3: Hypothesis and Testing

1. Form single, specific hypothesis
2. Test with minimal changes (one variable)
3. Verify before proceeding
4. If fails → new hypothesis, don't layer fixes

### Phase 4: Implementation

1. Write failing test that reproduces bug
2. Implement single fix for root cause
3. If 3+ fix attempts fail → architectural problem

**Red Flags (return to Phase 1):**
- "Just try X and see"
- "I don't fully understand but..."
- "One more fix attempt"
- Proposing solutions before data flow analysis

See `references/debugging-workflow.md` for detailed workflow.

## Visual Testing

For UI changes, verify in actual browser.

### Development Phase (Chrome MCP)

Use Chrome MCP for real-time verification:

```javascript
// Navigate and verify
mcp__claude-in-chrome__navigate({ url: "http://localhost:3000" })
mcp__claude-in-chrome__read_page({ selector: ".component" })

// Take screenshot evidence
mcp__claude-in-chrome__computer({ action: "screenshot" })

// Record interaction flow
mcp__claude-in-chrome__gif_creator({ name: "feature-demo", frames: 10 })

// Run assertions
mcp__claude-in-chrome__javascript_tool({ code: `
  const element = document.querySelector('.button');
  return element?.textContent === 'Submit';
` })
```

### Test Generation Phase (Playwright)

Before completion, generate persistent E2E tests:

```javascript
// Generate Playwright test file
mcp__playwright__create_test({
  name: "user-login",
  steps: [
    { action: "goto", url: "/login" },
    { action: "fill", selector: "#email", value: "test@example.com" },
    { action: "click", selector: "button[type=submit]" },
    { action: "expect", selector: ".dashboard", visible: true }
  ]
})
```

See `references/visual-testing.md` for patterns.

## Verification Before Completion

### The 5-Step Gate Function

Before claiming ANY completion:

1. **Identify** the verification command proving the claim
2. **Run** the complete command fresh (not cached)
3. **Read** full output and exit codes
4. **Verify** output confirms the claim
5. **Only then** make the claim with evidence

**Skipping any step = misrepresentation**

### Evidence Requirements

| Work Type | Required Evidence | Insufficient |
|-----------|-------------------|--------------|
| Tests | Test output showing 0 failures | Previous runs |
| Lint | Lint output showing 0 errors | Assumptions |
| Build | Build exit code 0 | Passing lint alone |
| Bug fix | Original symptom + passing test | Code change only |
| Feature | Demo + tests pass + CI green | "It works" |

### Red Flags (STOP immediately)

- "Should work"
- "Probably"
- "Seems to"
- Committing without fresh verification
- Accepting agent reports as final

## Context Preservation

### After Compaction

When context compacts, essential state is preserved via `progress-preserver` hook:

**Preserved:**
- Original plan/task description
- Completed tasks with evidence
- Current task in progress
- TodoWrite state

**Injected as system message:**
```
## Preserved Build Progress

### Plan
[Original plan]

### Completed
- [x] Task 1: [evidence]
- [x] Task 2: [evidence]

### In Progress
- [ ] Task 3: [current state]
```

## Quality Gates

### CI Gate (Mandatory)

Before ANY completion, `bun run ci` must pass:

```bash
bun run ci
# Typically runs: lint, typecheck, test, build
```

**Hook behavior:** Advisory only; no blocking. Run CI before completion and cite evidence.

### Completion Checklist

- [ ] All tasks marked completed in TodoWrite
- [ ] TDD followed (failing test → pass → refactor)
- [ ] Two-stage review passed (spec + quality)
- [ ] Silent failure hunter found no issues
- [ ] Visual tests pass (if UI changes)
- [ ] `bun run ci` exits 0
- [ ] Evidence documented for each claim

## Additional Resources

### Reference Files

- **`references/tdd-patterns.md`** - Detailed TDD patterns, anti-patterns, recovery
- **`references/debugging-workflow.md`** - 4-phase debugging methodology
- **`references/verification-patterns.md`** - Reviewer prompts, evidence patterns
- **`references/visual-testing.md`** - Chrome MCP + Playwright integration

### Related Skills

- **`skills/iterative-retrieval/SKILL.md`** - Context refinement protocol for subagent results

### Templates

- **`templates/task-checklist.md`** - Self-review checklist for implementers

### Related Plugins

- **plan-mode** - Create plans that build-mode executes
- **pr-review-toolkit** - Additional specialized review agents
