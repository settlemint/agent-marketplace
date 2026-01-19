---
name: exit-readiness
description: Interactive exit checklist before stopping a session. Use when about to stop working or when prompted by exit-guidance hook.
license: MIT
triggers:
  - "ready to stop"
  - "done for now"
  - "exit checklist"
  - "before I stop"
  - "wrapping up"
---

<objective>
Provide an interactive checklist to ensure quality before ending a work session. Philosophy: "Teach, don't police" - guide users through completion steps rather than blocking them.
</objective>

<quick_start>
When ready to stop working, run through this checklist:

1. **Todo Status** - Are all todos complete or intentionally deferred?
2. **Code Review** - Have changes been reviewed (3 passes with evidence)?
3. **Tests** - Do all tests pass? (`bun run test`)
4. **CI** - Does the full CI pipeline pass? (`bun run ci`)
5. **Commits** - Are changes committed with proper messages?
</quick_start>

<checklist>
## Pre-Exit Checklist

### 1. Task Completion
```
□ All todos marked as completed
□ Or: Remaining todos explicitly deferred with reason
□ Or: TodoWrite cleared if tasks are no longer relevant
```

**Check:** Review your todo list. Any `in_progress` or `pending` items?

### 2. Code Quality
```
□ Changes reviewed (minimum 3 passes)
□ Evidence documented (test output, code citations)
□ Or: Verification skill run
```

**If not reviewed:**
```javascript
Skill({ skill: "superpowers:verification-before-completion" })
```

### 3. Test Status
```
□ All tests pass locally
□ No skipped tests (unless pre-existing)
□ Coverage targets met (80% lines, 75% branches)
```

**Check:**
```bash
bun run test
```

### 4. CI Pipeline
```
□ bun run ci passes locally
□ No lint errors
□ No type errors
```

**Check:**
```bash
bun run ci
```

### 5. Git State
```
□ Changes committed with conventional message
□ No uncommitted work (or intentionally staged for next session)
□ Branch pushed (if applicable)
```

**Check:**
```bash
git status
```
</checklist>

<deferred_tasks>
## Handling Incomplete Work

If stopping with incomplete tasks, document clearly:

```markdown
## Session Pause - [Date]

### Completed
- [x] Task 1
- [x] Task 2

### Deferred
- [ ] Task 3 - Reason: [waiting for dependency/next session]
- [ ] Task 4 - Reason: [blocked by X]

### Next Steps
1. [What to do first next session]
2. [Context needed to resume]
```

This ensures seamless handoff to your next session or another agent.
</deferred_tasks>

<skip_conditions>
## When It's OK to Skip

| Condition | Skip Allowed | Notes |
|-----------|--------------|-------|
| Research/exploration only | Yes | No code changes made |
| Documentation updates only | Yes | No production code affected |
| Conversation/discussion only | Yes | No changes to commit |
| Emergency/time constraint | Yes | Document what's incomplete |
| All checks pass | N/A | Checklist complete |
</skip_conditions>

<integration>
**Related skills:**
- `superpowers:verification-before-completion` - Formal verification workflow
- `superpowers:finishing-a-development-branch` - Branch completion options
- `flow:review-checklist` - Detailed review guidance
</integration>

<success_criteria>
1. [ ] Todo list reviewed (complete or deferred)
2. [ ] Code review documented (if changes made)
3. [ ] Tests pass (if code changed)
4. [ ] CI passes (if code changed)
5. [ ] Git state clean or documented
</success_criteria>
