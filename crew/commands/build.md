---
name: crew:build
description: Execute work plans with iteration loops and progress tracking
argument-hint: "[plan file, specification, or todo file path]"
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/workflow/build-context.sh`

## Input

<work_document>$ARGUMENTS</work_document>

## Native Tools

### TodoWrite - Track Progress (CRITICAL)

```javascript
TodoWrite({
  todos: [
    {content: "Load work document", status: "in_progress", activeForm: "Loading document"},
    {content: "Load task files", status: "pending", activeForm: "Loading tasks"},
    {content: "Set up branch", status: "pending", activeForm: "Setting up branch"},
    {content: "Execute task batch 1", status: "pending", activeForm: "Running batch 1"},
    {content: "Run tests", status: "pending", activeForm: "Running tests"},
    {content: "Run quality checks", status: "pending", activeForm: "Running quality checks"},
    {content: "Create PR", status: "pending", activeForm: "Creating PR"}
  ]
})
```

**Update IMMEDIATELY after each task. Never batch updates.**

### Task - Parallel Agent Batching

**CRITICAL: One task = One agent. Launch many in parallel. Small scope.**

```javascript
// Launch ALL parallel tasks from current batch in SINGLE message
Task({
  subagent_type: "general-purpose",
  prompt: `TASK: T001 - Create project structure
FILE: (project root)
ACCEPTANCE: Directory structure matches plan
CONTEXT: [minimal context]
OUTPUT: Create structure, report completion`,
  description: "T001",
  run_in_background: true
})

Task({
  subagent_type: "general-purpose",
  prompt: `TASK: T002 - Install dependencies
FILE: package.json
ACCEPTANCE: All deps installed
CONTEXT: [minimal context]
OUTPUT: Install, report completion`,
  description: "T002",
  run_in_background: true
})

// Collect ALL results before next batch
TaskOutput({task_id: "t001-id", block: true})
TaskOutput({task_id: "t002-id", block: true})

// Then launch next batch...
```

### AskUserQuestion - Decision Points

```javascript
AskUserQuestion({
  questions: [{
    question: "Batch complete. Continue to next phase?",
    header: "Next",
    options: [
      {label: "Continue (Recommended)", description: "Execute next batch"},
      {label: "Review changes", description: "Show diff first"},
      {label: "Run tests", description: "Validate before continuing"},
      {label: "Stop here", description: "Pause work"}
    ],
    multiSelect: false
  }]
})
```

## Process

### Phase 1: Load Work Document

```javascript
TodoWrite({
  todos: [
    {content: "Load work document", status: "in_progress", activeForm: "Loading document"},
    // ...
  ]
})

// Read the plan
Read({file_path: ".claude/plans/${planSlug}.md"})

// If not found, ask
AskUserQuestion({
  questions: [{
    question: "Which plan should we build?",
    header: "Plan",
    options: [
      // List available plans from Glob
    ],
    multiSelect: false
  }]
})
```

### Phase 2: Load Task Files

**CRITICAL**: Load individual task files from branch state

```javascript
// Get current branch
const branch = Bash({command: "git branch --show-current"})

// List all task files in order
const taskFiles = Glob({pattern: `.claude/branches/${branch}/tasks/*.md`})

// Files are already ordered by filename:
// 001-pending-p1-setup-...
// 002-pending-p1-setup-...
// 010-pending-p1-us1-...

// Read each task file and parse
for (const file of taskFiles) {
  Read({file_path: file})
  // Parse status, priority, story, parallel from frontmatter
}

// Group tasks by:
// 1. Phase (setup, found, us1, us2, polish)
// 2. Parallel capability (parallel: true)
// 3. Status (pending, in_progress, complete)

// Create execution plan:
// Batch 1: All parallel setup tasks
// Batch 2: Sequential foundational tasks
// Batch 3: All parallel US1 tasks
// etc.
```

### Phase 3: Environment Setup

```javascript
// Ensure on feature branch
Bash({command: "git checkout feature/${slug} 2>/dev/null || git checkout -b feature/${slug}"})

// Update progress
TodoWrite({
  todos: [
    {content: "Load work document", status: "completed", activeForm: "Loading document"},
    {content: "Load task files", status: "completed", activeForm: "Loading tasks"},
    {content: "Set up branch", status: "completed", activeForm: "Setting up branch"},
    {content: "Execute batch 1 (setup)", status: "in_progress", activeForm: "Running setup"},
    // ...
  ]
})
```

### Phase 4: Batch Execution Loop

**CRITICAL: Small agents, many in parallel, batch by phase**

```javascript
// For each batch of parallel tasks:

// 1. Identify parallel tasks in current phase
const batch = pendingTasks.filter(t =>
  t.phase === currentPhase &&
  t.parallel === true &&
  t.status === 'pending'
)

// 2. Launch ALL in SINGLE message
for (const task of batch) {
  Task({
    subagent_type: "general-purpose",
    prompt: `TASK: ${task.id} - ${task.title}

FILE: ${task.file_path}

ACCEPTANCE CRITERIA:
${task.acceptanceCriteria}

CONTEXT:
${task.implementationNotes}

INSTRUCTIONS:
1. Read the target file location
2. Implement the change
3. Run relevant tests
4. Report: SUCCESS or FAILURE with details

Keep it focused. One task only.`,
    description: task.id,
    run_in_background: true
  })
}

// 3. Collect ALL results
for (const task of batch) {
  const result = TaskOutput({task_id: task.agentId, block: true})

  // 4. Update task file status
  if (result.success) {
    // Rename: pending → complete
    Bash({
      command: `mv ".claude/branches/${branch}/tasks/${task.oldFilename}" ".claude/branches/${branch}/tasks/${task.newFilename}"`,
      description: `Complete ${task.id}`
    })

    // Update frontmatter
    Edit({
      file_path: `.claude/branches/${branch}/tasks/${task.newFilename}`,
      old_string: "status: pending",
      new_string: "status: complete"
    })
  }
}

// 5. Update TodoWrite
TodoWrite({
  todos: [
    // ... mark batch completed, next batch in_progress
  ]
})

// 6. Run tests after each batch
Bash({command: "bun run test", description: "Run tests"})

// 7. Continue to next batch
```

### Phase 5: Quality Checks

Launch quality agents in **SINGLE message** (each agent = small scope):

```javascript
Task({
  subagent_type: "typescript-reviewer",
  prompt: `TASK: Type review
SCOPE: ${changedFiles.slice(0, 5).join(', ')}  // Limit scope
OUTPUT: P1/P2/P3 findings with file:line
Tools: Glob, Grep, Read (not bash)`,
  description: "TS review",
  run_in_background: true
})

Task({
  subagent_type: "security-sentinel",
  prompt: `TASK: Security audit
SCOPE: ${changedFiles.slice(0, 5).join(', ')}  // Limit scope
OUTPUT: Vulnerabilities with severity
MCP: Codex for threat analysis`,
  description: "Security",
  run_in_background: true
})

// Collect results
const tsResults = TaskOutput({task_id: "ts-id", block: true})
const secResults = TaskOutput({task_id: "sec-id", block: true})
```

### Phase 6: Add Findings as Tasks

If quality issues found, add as new task files:

```javascript
// Find next order number
const existing = Glob({pattern: `.claude/branches/${branch}/tasks/*.md`})
const nextOrder = getNextOrderNumber(existing) // e.g., 050

// Create finding task file
Write({
  file_path: `.claude/branches/${branch}/tasks/${nextOrder}-pending-p1-found-fix-type-error.md`,
  content: `---
status: pending
priority: p1
story: found
parallel: true
file_path: ${finding.file}
depends_on: []
---

# T${nextOrder}: Fix type error in ${finding.file}

## Description
${finding.description}

## Acceptance Criteria
- [ ] Type error resolved
- [ ] Tests pass

## File Path
\`${finding.file}:${finding.line}\`

## Work Log
### ${date} - Created
**By:** /crew:check quality review`
})
```

### Phase 7: Final Validation

```javascript
// Run full CI
Bash({command: "bun run ci", description: "Run CI checks"})

// Verify all tasks complete
const remaining = Glob({pattern: `.claude/branches/${branch}/tasks/*-pending-*.md`})
if (remaining.length > 0) {
  // Report incomplete tasks
}
```

### Phase 8: Ship It

```javascript
AskUserQuestion({
  questions: [{
    question: `All tasks complete. ${taskCount} tasks done. Ready to ship?`,
    header: "Ship",
    options: [
      {label: "Create PR (Recommended)", description: "Commit, push, and open PR"},
      {label: "Commit only", description: "Create commit without PR"},
      {label: "Review diff", description: "Show changes before committing"},
      {label: "More work needed", description: "Continue editing"}
    ],
    multiSelect: false
  }]
})

// If creating PR:
Bash({
  command: `git add . && git commit -m "$(cat <<'EOF'
feat(${scope}): ${description}

${body}

Tasks: .claude/branches/${branch}/tasks/
EOF
)" && git push -u origin ${branch}`,
  description: "Commit and push"
})

Bash({
  command: `gh pr create --title "${title}" --body "$(cat <<'EOF'
## Summary
${summary}

## Test Plan
${testPlan}

## Tasks Completed
See: .claude/branches/${branch}/tasks/
EOF
)"`,
  description: "Create PR"
})
```

## Parallel Batching Strategy

**CRITICAL: Prevent context exhaustion with small agents**

### Rules

1. **One task = One agent** - Never give agent multiple tasks
2. **Small scope** - Each task ~5-10 minutes of work
3. **Batch by phase** - All parallel tasks in phase run together
4. **Collect before next** - Wait for batch completion before next batch
5. **Update immediately** - Mark tasks complete as agents finish

### Batch Order

1. **Setup batch**: All `*-setup-*.md` with `parallel: true`
2. **Foundational batch**: All `*-found-*.md` (may be sequential)
3. **US1 batch**: All `*-us1-*.md` with `parallel: true`
4. **US2 batch**: All `*-us2-*.md` with `parallel: true`
5. **Polish batch**: All `*-polish-*.md`

### Agent Context Template

Keep agent prompts minimal and focused:

```text
TASK: T010 - Create User model
FILE: src/models/user.ts
ACCEPTANCE:
- Field: id, email, passwordHash, createdAt
- Validation: required fields
CONTEXT:
- TypeScript, Prisma ORM
- Pattern: see src/models/profile.ts
OUTPUT:
- Create file
- Run tests
- Report completion
```

## Success Criteria

- [ ] TodoWrite tracks ALL progress (updated after EVERY task)
- [ ] Task files loaded from `.claude/branches/<branch>/tasks/`
- [ ] Tasks executed in batches by phase
- [ ] Each agent handles ONE small task
- [ ] All parallel tasks launched in SINGLE message
- [ ] Task files renamed on completion (pending → complete)
- [ ] Tests run after EACH batch
- [ ] Quality findings added as new task files
- [ ] Native tools used for file operations
- [ ] AskUserQuestion at key decision points
- [ ] PR created with conventional commit
