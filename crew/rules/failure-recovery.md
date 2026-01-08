---
description: Failure recovery patterns - how to handle errors
globs: "**/*"
alwaysApply: false
---

# Failure Recovery

## When Fixes Fail

1. Fix root causes, not symptoms
2. Re-verify after EVERY fix attempt
3. Never shotgun debug (random changes hoping something works)

## After 3 Consecutive Failures

1. **STOP** all further edits immediately
2. **REVERT** to last known working state (git checkout / undo edits)
3. **DOCUMENT** what was attempted and what failed
4. **CONSULT** with more context (Oracle/Codex MCP or similar)
5. If still cannot resolve → **ASK USER** before proceeding

## Never Do These

- Leave code in broken state
- Continue hoping it'll work
- Delete failing tests to "pass"
- Suppress errors with `@ts-ignore` or `as any`

## Failure Documentation

Log all failures in task work log:

```markdown
## Errors Encountered

- [DATE] TypeError: null check missing → Added validation
- [DATE] API timeout → Retried with backoff
- [DATE] Test failure → Fixed assertion, was checking wrong value
```

This creates learning for:

- Future agents on this task
- Understanding what was tried
- Debugging if similar issues recur

## Bugfix Rule

**Fix minimally. NEVER refactor while fixing.**

A bug fix should:

- Address the specific bug
- Add a test that reproduces the bug
- Not clean up surrounding code
- Not add features

Refactoring is a separate task.
