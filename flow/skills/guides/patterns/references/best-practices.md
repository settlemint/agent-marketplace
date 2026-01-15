# Workflow Best Practices

## Design Principles

### 1. Single Responsibility

Each workflow should accomplish one thing well. If a workflow is trying to do too much, split it.

**Signs of overloaded workflow:**

- More than 10 tasks
- Multiple unrelated outcomes
- Difficult to name succinctly

### 2. Clear Success Criteria

Every task and workflow needs explicit success criteria. "Done" is not a criterion.

**Good criteria:**

- Tests pass with >80% coverage
- Documentation updated in README
- PR approved by 2 reviewers

**Bad criteria:**

- Code looks good
- Everything works
- Done

### 3. Appropriate Granularity

Tasks should be neither too small nor too large.

**Too small:** "Open file" → "Add line" → "Save file"
**Too large:** "Implement authentication system"
**Just right:** "Add login form component with validation"

### 4. Explicit Dependencies

Never assume dependencies are obvious. Document them.

```
Task: Deploy to production
Dependencies:
  - All tests pass (Task 3)
  - Staging verification complete (Task 4)
  - Release notes written (Task 5)
```

## Execution Patterns

### 1. Pre-flight Checks

Always verify prerequisites before starting:

- Required tools installed?
- Permissions in place?
- Dependencies available?

### 2. Checkpoint Reviews

At each checkpoint:

1. Verify all previous tasks truly complete
2. Check quality of outputs
3. Assess if proceeding makes sense
4. Document any issues found

### 3. Progress Tracking

Use consistent tracking:

- Update status immediately when starting a task
- Note blockers as they arise
- Record completion with evidence

### 4. Communication

For team workflows:

- Notify on task start
- Flag blockers immediately
- Announce completions

## Error Handling

### 1. Anticipate Failures

For each task, consider:

- What could go wrong?
- How will we know it failed?
- What's the recovery procedure?

### 2. Graceful Degradation

When failures occur:

1. Stop and assess (don't blindly continue)
2. Document what happened
3. Determine if rollback needed
4. Communicate to stakeholders

### 3. Rollback Procedures

Every workflow should have rollback plans:

- What state to restore to
- Steps to undo changes
- How to verify rollback success

## Continuous Improvement

### 1. Post-workflow Review

After completing workflows, review:

- What went well?
- What could improve?
- Any tasks that should split/merge?
- Timeline accuracy?

### 2. Metrics to Track

- Completion time vs estimate
- Number of blockers encountered
- Checkpoint pass rate
- Rollback frequency

### 3. Template Evolution

Regularly update templates based on learnings:

- Add common tasks discovered
- Remove consistently skipped tasks
- Adjust time estimates
- Improve documentation
