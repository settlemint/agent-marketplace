---
name: build
description: Execute implementation with TDD, subagent orchestration, and quality gates
argument-hint: [task description or "continue" to resume plan]
---

Execute a feature implementation with TDD-driven development, subagent orchestration, and comprehensive quality gates.

## Current State
- Branch: !`git branch --show-current`
- Status: !`git status --short`
- Tests: !`bun run test --run 2>&1 | tail -5`

## Mode Selection

**If continuing from a plan:**
- Read the plan file from `~/.claude/plans/`
- Resume from the last completed task
- Follow the established task order

**If new implementation:**
- Create task breakdown
- Estimate complexity
- Set up progress tracking

## Execution Workflow

### Phase 1: Task Setup

For each task in the plan (or the provided task):

1. **Check test coverage** for files to modify
   ```bash
   ls path/to/feature.test.ts 2>/dev/null || echo "No tests"
   ```

2. **If critical path lacks tests**, backfill first:
   - P0: Security, auth, payments - MUST have tests
   - P1: Business logic - Test before modifying
   - P2: API endpoints - Add integration tests
   - P3+: Utilities - Opportunistic

### Phase 2: TDD Implementation

Spawn `task-implementer` agent for each task:

```javascript
Task({
  subagent_type: "build-mode:task-implementer",
  description: "Implement task with TDD",
  prompt: `Task: [task description]

Requirements:
[specific requirements]

Follow TDD: RED -> GREEN -> REFACTOR
Complete self-review checklist before reporting.`
})
```

**TDD Cycle:**
1. **RED:** Write failing test first
2. **GREEN:** Minimal code to pass
3. **REFACTOR:** Clean up while green

### Phase 3: Two-Stage Review

After implementation, run reviews IN ORDER:

**Stage 1: Spec Compliance**
```javascript
Task({
  subagent_type: "build-mode:spec-reviewer",
  description: "Verify spec compliance",
  prompt: `Review implementation for:
- Task: [task]
- Files modified: [list]

DO NOT trust implementer report. Read actual code.
3-pass review: Literal, Intent, Edge Cases.`
})
```

**Stage 2: Quality Review** (only if spec passes)
```javascript
Task({
  subagent_type: "build-mode:quality-reviewer",
  description: "Review code quality",
  prompt: `Review code quality for:
- Files: [list]

3-pass review: Style, Patterns, Maintainability.
Only report issues with 80%+ confidence.`
})
```

### Phase 4: Error Handling Verification

Run silent failure detection:

```javascript
Task({
  subagent_type: "build-mode:silent-failure-hunter",
  description: "Check error handling",
  prompt: `Hunt for silent failures in:
- Files: [list]

Find: empty catches, silent returns, broad catches.
Priority: P0 must fix, P1 should fix, P2 consider.`
})
```

### Phase 5: Visual Testing (if UI changes)

If the implementation involves frontend/UI:

```javascript
Task({
  subagent_type: "build-mode:visual-tester",
  description: "Verify UI visually",
  prompt: `Verify UI implementation:
- Component: [component]
- URL: http://localhost:3000/path

Test: layout, styles, interactions, responsiveness.
Capture evidence (screenshots, GIFs).`
})
```

### Phase 6: Final Validation

Before marking complete:

```javascript
Task({
  subagent_type: "build-mode:completion-validator",
  description: "Final verification gate",
  prompt: `Validate completion:
- Task: [task]
- Files: [list]

Execute 5-step gate: IDENTIFY -> RUN -> READ -> VERIFY -> CLAIM
No approval without evidence.`
})
```

### Phase 7: Code Health Check

Apply "leave it better" principle:

- Clean nearby code smells
- Remove dead code found
- Fix console.log statements
- Note but don't fix major refactors

## Quality Gates

**Must pass before moving to next task:**
- [ ] Tests pass: `bun run test`
- [ ] Lint clean: `bun run lint`
- [ ] CI gates: `bun run ci` (if available)
- [ ] Spec review: APPROVED
- [ ] Quality review: APPROVED
- [ ] Error handling: No P0 issues

## Progress Tracking

After each task:
1. Update TodoWrite with completion status
2. Record evidence in task report
3. Note any issues for follow-up

On context compaction, preserve:
- Plan file path
- Current task number
- Completed task evidence
- Pending issues

## Checkpoint Pattern

After completing 2-3 tasks:
1. Run full test suite
2. Run lint check
3. Verify CI passes locally
4. Commit checkpoint with descriptive message

## Debugging Integration

If tests fail during implementation:

1. **Gather evidence** - Don't guess
2. **Root cause first** - No fix without understanding
3. **Hypothesis testing** - Verify before changing
4. **Minimal fix** - Target the bug, not symptoms

## Output

After each task cycle:

```markdown
## Task: [Task Name]

### Implementation
- TDD: RED -> GREEN -> REFACTOR
- Files: [list with line ranges]

### Reviews
- Spec: APPROVED
- Quality: APPROVED (P2: [minor issues noted])
- Error handling: CLEAR

### Evidence
- Tests: 15/15 passing
- Lint: Clean
- CI: Passing

### Status: COMPLETE
```

## Related Commands

- `/fixup` - Fix PR review comments and CI failures
- `/plan` - Create implementation plan (plan-mode plugin)
