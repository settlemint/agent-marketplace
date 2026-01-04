---
name: crew:build
description: Execute work plans with iteration loops and progress tracking
argument-hint: "[plan file, specification, or todo file path]"
---

!`../scripts/workflow/build-context.sh`

## Input

<work_document>$ARGUMENTS</work_document>

## Process

### Phase 1: Load Work Document

1. Read the input document (plan file, todo file, or specification)
2. Parse requirements and acceptance criteria
3. If document not found, use AskUserQuestion to clarify

### Phase 2: Create Progress Tracking

```javascript
TodoWrite([
  {content: "Read and understand work document", status: "completed", activeForm: "Reading document"},
  {content: "Verify branch setup", status: "in_progress", activeForm: "Verifying branch"},
  // Break down implementation from the plan
  {content: "[Task 1 from plan]", status: "pending", activeForm: "Implementing task 1"},
  {content: "Run test suite", status: "pending", activeForm: "Running tests"},
  {content: "Run linting and formatting", status: "pending", activeForm: "Linting code"},
  {content: "Create commit and PR", status: "pending", activeForm: "Creating PR"}
])
```

### Phase 3: Environment Setup

If not on feature branch, create one from plan.

### Phase 4: Choose Execution Mode

| Tasks | Criteria Clear? | Mode |
|-------|-----------------|------|
| 1-3 | No | Direct implementation |
| 1-3 | Yes | Iteration Loop |
| 4+ | No | Agent Orchestration |
| 4+ | Yes | Iteration Loop |

**Priority:** If acceptance criteria are verifiable, use iteration loop.

### Phase 5: Quality Checks

1. Run tests: `bun run test`
2. Run linting: `bun run lint`
3. Format code: `bun run format`

### Phase 6: Ship It

```javascript
AskUserQuestion({
  questions: [{
    question: "All tests pass. Ready to create PR?",
    header: "Ship",
    options: [
      {label: "Create PR (Recommended)", description: "Commit, push, and create pull request"},
      {label: "Commit only", description: "Create commit without PR"},
      {label: "Review changes first", description: "Show me the diff before committing"}
    ],
    multiSelect: false
  }]
})
```

## Success Criteria

- [ ] All plan tasks completed
- [ ] Tests passing
- [ ] PR created (if requested)
