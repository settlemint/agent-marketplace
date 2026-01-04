---
name: crew:build
description: Execute work plans with iteration loops and progress tracking
argument-hint: "[plan file, specification, or todo file path]"
aliases:
  - build
---

<objective>

Execute a work plan with continuous progress visibility and autonomous iteration.

</objective>

<input>

<work_document>$ARGUMENTS</work_document>

</input>

<process>

**IMPORTANT:** Execute directly in main thread for native UI access.

## Phase 1: Load Work Document

1. Read the input document (plan file, todo file, or specification)
2. Parse requirements and acceptance criteria
3. If document not found, use AskUserQuestion to clarify

## Phase 2: Create Progress Tracking

```javascript
TodoWrite([
  {content: "Read and understand work document", status: "completed", activeForm: "Reading document"},
  {content: "Verify branch setup", status: "in_progress", activeForm: "Verifying branch"},
  // Break down implementation from the plan:
  {content: "[Task 1 from plan]", status: "pending", activeForm: "Implementing task 1"},
  {content: "[Task 2 from plan]", status: "pending", activeForm: "Implementing task 2"},
  {content: "Write/update tests", status: "pending", activeForm: "Writing tests"},
  {content: "Run test suite", status: "pending", activeForm: "Running tests"},
  {content: "Run linting and formatting", status: "pending", activeForm: "Linting code"},
  {content: "Create commit and PR", status: "pending", activeForm: "Creating PR"}
])
```

## Phase 3: Environment Setup

Check if on feature branch:

```bash
git branch --show-current | grep -qE '^(feat|fix|refactor|chore)/' && echo "On feature branch"
```

If not set up, create branch from plan.

## Phase 4: Choose Execution Mode

| Tasks | Criteria Clear? | Mode | Reason |
|-------|-----------------|------|--------|
| 1-3 | No | Direct | Faster, keep context |
| 1-3 | Yes | Iteration Loop | Iterate until complete |
| 4+ | No | Agent Orchestration | Compaction-resistant |
| 4+ | Yes | Iteration Loop | Iterate until complete |

**Priority:** If acceptance criteria are verifiable, use iteration loop.

### 4a: Agent Orchestration (4+ tasks, unclear criteria)

```javascript
Bash({ command: "mkdir -p .claude/branches/$(git branch --show-current | tr '/' '-')/handoffs" });

// For each task, spawn an implementation agent
Task({
  subagent_type: "general-purpose",
  model: "sonnet",
  prompt: `Implement Task ${N} of ${total}: ${taskDescription}
    Plan file: ${planFile}
    After completing: Create handoff with Skill({skill: "crew:handoff"})`,
});
```

### 4b: Direct Implementation (1-3 tasks)

For each task:
1. Mark as in_progress in TodoWrite
2. Read existing patterns
3. Implement the change
4. Run tests incrementally
5. Mark as completed
6. **MANDATORY:** Create handoff

### 4c: Iteration Loop Mode (verifiable criteria)

```javascript
Skill({
  skill: "crew:loop",
  args: `Implement the plan in ${planFile}.

After EACH iteration:
1. Run CI: bun run ci
2. Check acceptance criteria from plan

When ALL acceptance criteria are met AND CI passes:
<promise>BUILD COMPLETE</promise>

--max-iterations 15 --completion-promise "BUILD COMPLETE"`
})
```

## Phase 5: Quality Checks

1. Run full test suite: `bun run test`
2. Run linting: `bun run lint`
3. Format code: `bun run format`

## Phase 6: Verify Handoffs

```bash
ls .claude/branches/$(git branch --show-current | tr '/' '-')/handoffs/*.md 2>/dev/null || echo "WARNING: No handoffs!"
```

If no handoffs, create them NOW.

## Phase 7: Ship It

```javascript
AskUserQuestion({
  questions: [{
    question: "All tests pass. Ready to create PR?",
    header: "Ship",
    options: [
      {label: "Create PR (Recommended)", description: "Commit, push, and create pull request"},
      {label: "Commit only", description: "Create commit without PR"},
      {label: "Review changes first", description: "Show me the diff before committing"},
      {label: "More work needed", description: "I'll add more tasks"}
    ],
    multiSelect: false
  }]
})
```

## Phase 8: Final Handoff

**ALWAYS create session handoff:**

```javascript
Skill({ skill: "crew:handoff", args: "session Completed: [description]" });
```

</process>

<key_principles>

1. **Keep UI in main thread** - TodoWrite and AskUserQuestion work here, not in agents
2. **Agents for research only** - Use background agents for code review, not decisions
3. **Test continuously** - Don't wait until the end
4. **Ship complete features** - Don't leave things 80% done
5. **ALWAYS create handoffs** - Every task completion MUST have a handoff
6. **Use iteration loop for thorough completion** - When criteria are verifiable

</key_principles>

<stopping_early>

### Cancel Active Loop

```javascript
Skill({ skill: "crew:cancel-loop" })
```

Then create handoff documenting partial progress.

</stopping_early>

<success_criteria>

- [ ] All plan tasks completed
- [ ] Tests passing
- [ ] Handoffs created
- [ ] PR created (if requested)

</success_criteria>
