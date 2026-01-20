---
name: implementing-code
description: This skill should be used when the user asks to "implement a feature", "build this", "write code", "execute the plan", or when starting implementation tasks. TDD-driven with agent orchestration.
version: 1.1.0
context: fork
agent: general-purpose
---

# TDD Implementation Workflow

**NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.**

Code before test? Delete it. Start over.

## Mode Selection

**If continuing from a plan:**
- Read the plan file from `~/.claude/plans/`
- Resume from the last completed task
- Follow the established task order

**If new implementation:**
- Create task breakdown with TodoWrite
- Set up progress tracking

---

## For Each Task

### Step 1: TDD Implementation

```javascript
Task({
  subagent_type: "build-mode:task-implementer",
  description: "Implement task with TDD",
  prompt: `Task: [TASK]

Requirements:
[specific requirements]

Follow TDD: RED -> GREEN -> REFACTOR
Complete self-review checklist before reporting.`
})
```

**TDD Cycle:**
1. **RED:** Write failing test → verify fails for right reason
2. **GREEN:** Minimal code to pass → no over-engineering
3. **REFACTOR:** Clean up while green → tests pass after every change

### Step 2: Spec Review

```javascript
Task({
  subagent_type: "build-mode:spec-reviewer",
  description: "Verify spec compliance",
  prompt: `Review implementation for:
- Task: [TASK]
- Files modified: [FILES]

DO NOT trust implementer report. Read actual code.
3-pass review: Literal, Intent, Edge Cases.`
})
```

### Step 3: Quality Review (only if spec passes)

```javascript
Task({
  subagent_type: "build-mode:quality-reviewer",
  description: "Review code quality",
  prompt: `Review code quality for:
- Files: [FILES]

3-pass review: Style, Patterns, Maintainability.
Only report issues with 80%+ confidence.`
})
```

### Step 4: Error Handling

```javascript
Task({
  subagent_type: "build-mode:silent-failure-hunter",
  description: "Check error handling",
  prompt: `Hunt for silent failures in:
- Files: [FILES]

Find: empty catches, silent returns, broad catches.
Priority: P0 must fix, P1 should fix, P2 consider.`
})
```

### Step 5: Visual Test (if UI)

```javascript
Task({
  subagent_type: "build-mode:visual-tester",
  description: "Verify UI visually",
  prompt: `Verify UI implementation:
- Component: [COMPONENT]
- URL: http://localhost:3000/path

Test: layout, styles, interactions, responsiveness.
Capture evidence (screenshots, GIFs).`
})
```

### Step 6: Final Gate

```javascript
Task({
  subagent_type: "build-mode:completion-validator",
  description: "Final verification gate",
  prompt: `Validate completion:
- Task: [TASK]
- Files: [FILES]

Execute 5-step gate: IDENTIFY -> RUN -> READ -> VERIFY -> CLAIM
No approval without evidence.`
})
```

---

## Quality Gates

**Must pass before moving to next task:**
- [ ] Tests pass: `bun run test`
- [ ] Lint clean: `bun run lint`
- [ ] CI gates: `bun run ci` (if available)
- [ ] Spec review: APPROVED
- [ ] Quality review: APPROVED
- [ ] Error handling: No P0 issues

## Systematic Debugging

If tests fail:
1. **Root Cause** - Error msgs, reproduce, trace data flow
2. **Pattern Analysis** - Find working examples, compare
3. **Hypothesis** - Single hypothesis, one variable
4. **Implementation** - Failing test first, then fix

Red flags: "Just try X", "don't understand but...", 3+ fix attempts

## Progress Tracking

After each task:
1. Update TodoWrite with completion status
2. Record evidence in task report
3. Note any issues for follow-up

## Checkpoint Pattern

After completing 2-3 tasks:
1. Run full test suite
2. Run lint check
3. Verify CI passes locally
4. Commit checkpoint with descriptive message

## Verification

**5-Step Gate:** Identify → Run → Read → Verify → Claim with evidence

| Work Type | Required Evidence |
|-----------|-------------------|
| Tests | Output showing 0 failures |
| Bug fix | Symptom + passing test |
| Feature | Tests + CI green |

**CI Gate:** `bun run ci` must pass before completion.
