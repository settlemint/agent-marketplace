# Task Implementation Checklist

Complete this checklist BEFORE reporting task completion.

## Pre-Implementation

- [ ] Read task requirements completely
- [ ] Identify files to modify
- [ ] Check for existing tests (backfill if critical path)
- [ ] Understand expected behavior

## TDD Cycle

### RED Phase
- [ ] Test file exists (created if needed)
- [ ] Failing test written for new behavior
- [ ] Test fails for the RIGHT reason (not syntax/import error)
- [ ] Test name describes expected behavior

### GREEN Phase
- [ ] Minimal code written to pass test
- [ ] Test now passes
- [ ] No regressions (other tests still pass)
- [ ] No over-engineering

### REFACTOR Phase
- [ ] Code cleaned up (if needed)
- [ ] Tests still pass after each change
- [ ] No new behavior added

## Code Quality

- [ ] Clear, descriptive names
- [ ] Follows codebase patterns
- [ ] No TODO comments left
- [ ] No placeholder code
- [ ] No magic numbers/strings
- [ ] Error handling appropriate

## Legacy Code (if applicable)

- [ ] Critical paths have tests
- [ ] Characterization tests written for modified functions
- [ ] Error handling gaps addressed
- [ ] No silent failures introduced

## Evidence Capture

- [ ] Test output saved (copy/paste)
- [ ] Files modified listed with line numbers
- [ ] TDD cycle documented (RED → GREEN → REFACTOR)

## Final Verification

- [ ] `bun run test` passes
- [ ] `bun run lint` clean
- [ ] Related tests all pass
- [ ] Feature works as expected

---

## Report Template

```markdown
## Task: [Task Name]

### TDD Cycle
- RED: Wrote failing test for [behavior]
- GREEN: Implemented [minimal solution]
- REFACTOR: [Changes made or "No refactoring needed"]

### Files Modified
- `path/to/file.ts:10-25` - [what changed]
- `path/to/file.test.ts:5-20` - [tests added]

### Test Evidence
```
Test output here
```

### Verification
- [x] Tests pass: X/X
- [x] Lint clean
- [x] Feature verified
```
