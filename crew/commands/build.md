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
    {
      content: "Load work document",
      status: "in_progress",
      activeForm: "Loading document",
    },
    {
      content: "Load task files",
      status: "pending",
      activeForm: "Loading tasks",
    },
    {
      content: "Set up branch",
      status: "pending",
      activeForm: "Setting up branch",
    },
    {
      content: "Execute task batch 1",
      status: "pending",
      activeForm: "Running batch 1",
    },
    { content: "Run tests", status: "pending", activeForm: "Running tests" },
    {
      content: "Run quality checks",
      status: "pending",
      activeForm: "Running quality checks",
    },
    { content: "Create PR", status: "pending", activeForm: "Creating PR" },
  ],
});
```

**Update IMMEDIATELY after each task. Never batch updates.**

### Task - Parallel Agent Batching

**CRITICAL: One task = One agent. Max 6 agents per batch. Small scope.**

```javascript
// Launch parallel tasks from current batch in SINGLE message (max 6)
Task({
  subagent_type: "general-purpose",
  // model: inherits from parent (opus/sonnet)
  prompt: `TASK: T001 - Create project structure
FILE: (project root)
ACCEPTANCE: Directory structure matches plan
CONSTRAINTS:
- Read at most 2-3 files for context
- Do NOT run tests (test-runner handles this)
- Do NOT explore beyond target files
OUTPUT: Create structure, report SUCCESS or FAILURE`,
  description: "T001",
  run_in_background: true,
});

Task({
  subagent_type: "general-purpose",
  // model: inherits from parent
  prompt: `TASK: T002 - Install dependencies
FILE: package.json
ACCEPTANCE: All deps installed
CONSTRAINTS:
- Read at most 2-3 files for context
- Do NOT run tests (test-runner handles this)
OUTPUT: Install, report SUCCESS or FAILURE`,
  description: "T002",
  run_in_background: true,
});

// Collect ALL results before next batch
TaskOutput({ task_id: "t001-id", block: true });
TaskOutput({ task_id: "t002-id", block: true });

// Then launch test-runner agent...
```

### AskUserQuestion - Decision Points

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Batch complete. Continue to next phase?",
      header: "Next",
      options: [
        { label: "Continue (Recommended)", description: "Execute next batch" },
        { label: "Review changes", description: "Show diff first" },
        { label: "Run tests", description: "Validate before continuing" },
        { label: "Stop here", description: "Pause work" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Process

### Phase 1: Load Work Document

```javascript
TodoWrite({
  todos: [
    {
      content: "Load work document",
      status: "in_progress",
      activeForm: "Loading document",
    },
    // ...
  ],
});

// Read the plan
Read({ file_path: ".claude/plans/${planSlug}.md" });

// If not found, ask
AskUserQuestion({
  questions: [
    {
      question: "Which plan should we build?",
      header: "Plan",
      options: [
        // List available plans from Glob
      ],
      multiSelect: false,
    },
  ],
});
```

### Phase 2: Load Task Files

**CRITICAL**: Load individual task files from branch state

```javascript
// Get current branch and slugify it (replace / with -)
const branch = Bash({ command: "git branch --show-current" }).trim();
const slugBranch = branch.replace(/\//g, "-"); // feat/foo → feat-foo

// List all task files in order
const taskFiles = Glob({
  pattern: `.claude/branches/${slugBranch}/tasks/*.md`,
});

// Files are already ordered by filename:
// 001-pending-p1-setup-...
// 002-pending-p1-setup-...
// 010-pending-p1-us1-...

// Read each task file and parse
for (const file of taskFiles) {
  Read({ file_path: file });
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
Bash({
  command:
    "git checkout feature/${slug} 2>/dev/null || git checkout -b feature/${slug}",
});

// Update progress
TodoWrite({
  todos: [
    {
      content: "Load work document",
      status: "completed",
      activeForm: "Loading document",
    },
    {
      content: "Load task files",
      status: "completed",
      activeForm: "Loading tasks",
    },
    {
      content: "Set up branch",
      status: "completed",
      activeForm: "Setting up branch",
    },
    {
      content: "Execute batch 1 (setup)",
      status: "in_progress",
      activeForm: "Running setup",
    },
    // ...
  ],
});
```

### Phase 4: Batch Execution Loop

**CRITICAL: Max 6 agents per batch. Use haiku. Agents do NOT run tests.**

```javascript
// For each batch of parallel tasks:

// 1. Identify parallel tasks in current phase (max 6 per batch)
const allParallel = pendingTasks.filter(
  (t) =>
    t.phase === currentPhase && t.parallel === true && t.status === "pending",
);
const batch = allParallel.slice(0, 6); // Max 6 agents per batch

// 2. Launch batch in SINGLE message (max 6)
for (const task of batch) {
  Task({
    subagent_type: "general-purpose",
    // model: inherits from parent (opus/sonnet)
    prompt: `TASK: ${task.id} - ${task.title}

FILE: ${task.file_path}

ACCEPTANCE CRITERIA:
${task.acceptanceCriteria}

CONTEXT:
${task.implementationNotes}

CONSTRAINTS:
- Read at most 2-3 files for context
- Do NOT run tests (test-runner agent handles this)
- Do NOT explore beyond target files
- Stop immediately after implementing

OUTPUT: Report SUCCESS or FAILURE with brief summary`,
    description: task.id,
    run_in_background: true,
  });
}

// 3. Collect ALL results
for (const task of batch) {
  const result = TaskOutput({ task_id: task.agentId, block: true });

  // 4. Update task file status
  if (result.success) {
    // Rename: pending → complete (use slugBranch, not branch)
    Bash({
      command: `mv ".claude/branches/${slugBranch}/tasks/${task.oldFilename}" ".claude/branches/${slugBranch}/tasks/${task.newFilename}"`,
      description: `Complete ${task.id}`,
    });

    // Update frontmatter
    Edit({
      file_path: `.claude/branches/${slugBranch}/tasks/${task.newFilename}`,
      old_string: "status: pending",
      new_string: "status: complete",
    });
  }
}

// 5. Launch test-runner agent (haiku) to validate batch
Task({
  subagent_type: "general-purpose",
  model: "haiku", // Fast, focused on test output parsing
  prompt: `TASK: Run tests and report failures only

RUN: bun run test (or npm test / pnpm test)

OUTPUT FORMAT:
If all tests pass: "ALL TESTS PASSING"
If failures exist, report ONLY:
- Failed test name
- File:line of failure
- Brief error message (1 line)

Do NOT include:
- Passing tests
- Full stack traces
- Test coverage info
- Timing information

Keep output minimal - only actionable failures.`,
  description: "test-runner",
  run_in_background: false, // Wait for test results
});

// 6. If test failures, create fix tasks or notify
// 7. Update TodoWrite and continue to next batch
```

### Phase 5: Quality Checks

Launch quality agents in **SINGLE message** (each agent = small scope):

```javascript
Task({
  subagent_type: "typescript-reviewer",
  prompt: `TASK: Type review
SCOPE: ${changedFiles.slice(0, 5).join(", ")}  // Limit scope
OUTPUT: P1/P2/P3 findings with file:line
Tools: Glob, Grep, Read (not bash)`,
  description: "TS review",
  run_in_background: true,
});

Task({
  subagent_type: "security-sentinel",
  prompt: `TASK: Security audit
SCOPE: ${changedFiles.slice(0, 5).join(", ")}  // Limit scope
OUTPUT: Vulnerabilities with severity
MCP: Codex for threat analysis`,
  description: "Security",
  run_in_background: true,
});

// Collect results
const tsResults = TaskOutput({ task_id: "ts-id", block: true });
const secResults = TaskOutput({ task_id: "sec-id", block: true });
```

### Phase 6: Add Findings as Tasks

If quality issues found, add as new task files:

```javascript
// Find next order number (use slugBranch)
const existing = Glob({ pattern: `.claude/branches/${slugBranch}/tasks/*.md` });
const nextOrder = getNextOrderNumber(existing); // e.g., 050

// Create finding task file
Write({
  file_path: `.claude/branches/${slugBranch}/tasks/${nextOrder}-pending-p1-found-fix-type-error.md`,
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
**By:** /crew:check quality review`,
});
```

### Phase 7: Final Validation

```javascript
// Run full CI
Bash({ command: "bun run ci", description: "Run CI checks" });

// Verify all tasks complete (use slugBranch)
const remaining = Glob({
  pattern: `.claude/branches/${slugBranch}/tasks/*-pending-*.md`,
});
if (remaining.length > 0) {
  // Report incomplete tasks
}
```

### Phase 8: Ship It

```javascript
AskUserQuestion({
  questions: [
    {
      question: `All tasks complete. ${taskCount} tasks done. Ready to ship?`,
      header: "Ship",
      options: [
        {
          label: "Create PR (Recommended)",
          description: "Commit, push, and open PR",
        },
        { label: "Commit only", description: "Create commit without PR" },
        { label: "Review diff", description: "Show changes before committing" },
        { label: "More work needed", description: "Continue editing" },
      ],
      multiSelect: false,
    },
  ],
});

// If creating PR (note: git branch uses slash, folder uses hyphen)
Bash({
  command: `git add . && git commit -m "$(cat <<'EOF'
feat(${scope}): ${description}

${body}

Tasks: .claude/branches/${slugBranch}/tasks/
EOF
)" && git push -u origin ${branch}`,
  description: "Commit and push",
});

Bash({
  command: `gh pr create --title "${title}" --body "$(cat <<'EOF'
## Summary
${summary}

## Test Plan
${testPlan}

## Tasks Completed
See: .claude/branches/${slugBranch}/tasks/
EOF
)"`,
  description: "Create PR",
});
```

## Parallel Batching Strategy

**CRITICAL: Prevent context exhaustion with small agents**

### Rules

1. **One task = One agent** - Never give agent multiple tasks
2. **Max 6 agents per batch** - More causes context exhaustion
3. **Inherit parent model** - Implementation agents use opus/sonnet
4. **Agents do NOT run tests** - Test-runner agent (haiku) handles this
5. **Limit file reads** - Max 2-3 files per agent
6. **Collect before next** - Wait for batch + test-runner before next batch
7. **Update immediately** - Mark tasks complete as agents finish

### Batch Order

1. **Setup batch**: All `*-setup-*.md` with `parallel: true` (max 6)
2. **Foundational batch**: All `*-found-*.md` (may be sequential)
3. **US1 batch**: All `*-us1-*.md` with `parallel: true` (max 6)
4. **US2 batch**: All `*-us2-*.md` with `parallel: true` (max 6)
5. **Polish batch**: All `*-polish-*.md`

If more than 6 tasks in a phase, split into sub-batches.

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
CONSTRAINTS:
- Read at most 2-3 files
- Do NOT run tests
- Stop after implementing
OUTPUT:
- Report SUCCESS or FAILURE
```

### Test-Runner Agent

After each batch, launch a dedicated test-runner (haiku):

```javascript
Task({
  subagent_type: "general-purpose",
  model: "haiku",
  prompt: `Run tests, report ONLY failures:
- Failed test name
- File:line
- Error (1 line)
If all pass: "ALL TESTS PASSING"`,
  description: "test-runner",
  run_in_background: false,
});
```

## Success Criteria

- [ ] TodoWrite tracks ALL progress (updated after EVERY task)
- [ ] Task files loaded from `.claude/branches/<slugified-branch>/tasks/`
- [ ] Tasks executed in batches by phase
- [ ] **Max 6 agents per batch** (split larger phases into sub-batches)
- [ ] **Implementation agents inherit parent model** (opus/sonnet)
- [ ] **Agents do NOT run tests** (constraints enforced in prompts)
- [ ] **Test-runner agent (haiku) runs after each batch** - reports only failures
- [ ] Each agent handles ONE small task
- [ ] All parallel tasks launched in SINGLE message
- [ ] Task files renamed on completion (pending → complete)
- [ ] Quality findings added as new task files
- [ ] Native tools used for file operations
- [ ] AskUserQuestion at key decision points
- [ ] PR created with conventional commit
