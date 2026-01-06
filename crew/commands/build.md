---
name: crew:build
description: Execute work plans with iteration loops and progress tracking
argument-hint: "[plan] [--loop] [--max-iterations N]"
---

## CRITICAL: Never Run CI Commands Directly

**NEVER use Bash tool for:** `bun run test`, `vitest`, `jest`, `eslint`, `prettier`, `biome`, `ultracite`, or any test/lint/format commands.

**ALWAYS use Task tool with haiku model** for test-runner agent. This is ENFORCED by PreToolUse hook - direct CI commands will be BLOCKED.

```javascript
// CORRECT - test-runner agent
Task({
  subagent_type: "general-purpose",
  model: "haiku",
  prompt: "Run tests, report ONLY failures...",
  description: "test-runner",
  run_in_background: false,
});

// WRONG - will be blocked
Bash({ command: "bun run test" }); // BLOCKED
```

---

!`${CLAUDE_PLUGIN_ROOT}/scripts/workflow/build-context.sh`

## Loop Integration (Ralph Wiggum Technique)

This build command supports two levels of iteration loops:

### 1. Full Build Loop (`--loop` flag)

Wraps the entire build in an iteration loop. The Stop hook intercepts exits and re-feeds the prompt until completion.

```bash
/crew:build .claude/plans/feature.md --loop --max-iterations 15
```

**How it works:**

1. Build initializes loop state in `.claude/branches/{branch}/state.json`
2. Work proceeds through phases
3. If you try to exit before completion, Stop hook re-feeds the prompt
4. Only `<promise>BUILD COMPLETE</promise>` ends the loop
5. Previous work persists in files - each iteration reads prior progress

**Completion criteria:**

- All task files renamed from `*-pending-*` to `*-complete-*`
- `bun run ci` passes
- `bun run test:integration` passes
- Output: `<promise>BUILD COMPLETE</promise>`

### 2. Per-Batch Retry Loop (automatic)

Each batch automatically retries until tests pass:

```
Batch N:
  → Execute parallel tasks (max 6)
  → Run test-runner agent
  → If tests fail:
      → Create fix tasks for failures
      → Re-execute fix tasks
      → Loop until tests pass (max 3 retries)
  → Output: <promise>BATCH N COMPLETE</promise>
  → Continue to next batch
```

**Batch completion promise:**

- Intermediate promises (`BATCH 1 COMPLETE`, etc.) are logged but don't end the main loop
- Only `BUILD COMPLETE` ends the full build loop

### Loop State

Both loops use unified state at `.claude/branches/{branch}/state.json`:

```json
{
  "branch": "feat/my-feature",
  "loop": {
    "active": true,
    "iteration": 2,
    "maxIterations": 15,
    "completionPromise": "BUILD COMPLETE",
    "prompt": "/crew:build .claude/plans/feature.md --loop",
    "startedAt": "2024-01-01T00:00:00Z"
  },
  "build": {
    "currentPhase": "us1",
    "currentBatch": 3,
    "batchRetries": 1,
    "completedBatches": ["setup", "found"]
  }
}
```

### Cancellation

To stop the loop early:

```bash
/crew:cancel-loop "reason for stopping"
```

This creates a handoff document, clears loop state, and returns control.

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
      content: "Set up branch",
      status: "pending",
      activeForm: "Setting up branch",
    },
    {
      content: "Load task files",
      status: "pending",
      activeForm: "Loading tasks",
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
    {
      content: "Show summary",
      status: "pending",
      activeForm: "Showing summary",
    },
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
OUTPUT: Your FINAL message MUST start with "SUCCESS: <summary>" or "FAILURE: <reason>"`,
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
OUTPUT: Your FINAL message MUST start with "SUCCESS: <summary>" or "FAILURE: <reason>"`,
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

### Phase 0: Initialize Loop State (if `--loop` flag)

**Only runs when `--loop` flag is present in arguments.**

```javascript
// Parse arguments for --loop flag
const hasLoopFlag = "$ARGUMENTS".includes("--loop");
const maxIterations = parseInt(
  "$ARGUMENTS".match(/--max-iterations\s+(\d+)/)?.[1] || "15",
);

if (hasLoopFlag) {
  // Get branch for state file
  const branch = Bash({ command: "git branch --show-current" }).trim();
  const slugBranch = branch.replace(/\//g, "-");
  const stateFile = `.claude/branches/${slugBranch}/state.json`;

  // Ensure directory exists
  Bash({ command: `mkdir -p .claude/branches/${slugBranch}` });

  // Check if loop already active (resuming)
  let existingState = {};
  try {
    existingState = JSON.parse(Read({ file_path: stateFile }));
  } catch {}

  if (existingState?.loop?.active) {
    // Resuming existing loop - read iteration count
    console.log(`
═══════════════════════════════════════════════════════════
RESUMING BUILD LOOP (Iteration ${existingState.loop.iteration} of ${existingState.loop.maxIterations})
═══════════════════════════════════════════════════════════

Previous work detected. Checking task files for progress...
`);
  } else {
    // Initialize new loop
    const loopState = {
      branch: branch,
      loop: {
        active: true,
        iteration: 1,
        maxIterations: maxIterations,
        completionPromise: "BUILD COMPLETE",
        prompt: `/crew:build $ARGUMENTS`,
        startedAt: new Date().toISOString(),
      },
      build: {
        currentPhase: null,
        currentBatch: 0,
        batchRetries: 0,
        completedBatches: [],
      },
    };

    Write({
      file_path: stateFile,
      content: JSON.stringify(loopState, null, 2),
    });

    console.log(`
═══════════════════════════════════════════════════════════
BUILD LOOP INITIALIZED (1 of ${maxIterations} iterations)
═══════════════════════════════════════════════════════════

COMPLETION CRITERIA:
- All tasks complete (files renamed *-pending-* → *-complete-*)
- bun run ci passes
- bun run test:integration passes

TO COMPLETE: Output <promise>BUILD COMPLETE</promise>

STRICT REQUIREMENTS:
  ✓ Use <promise> XML tags EXACTLY as shown
  ✓ Statement MUST be TRUE (all criteria met)
  ✓ Do NOT output false promises to exit early

TO CANCEL: /crew:cancel-loop "reason"
═══════════════════════════════════════════════════════════
`);
  }
}
```

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

### Phase 2: Branch Setup

**IMPORTANT:** Set up the branch before loading task files (they live in `.claude/branches/{branch}/`).

```javascript
// Check current branch
const currentBranch = Bash({ command: "git branch --show-current" }).trim();
const isMainBranch = currentBranch === "main" || currentBranch === "master";

if (isMainBranch) {
  // On main - MUST create or switch to a feature branch
  AskUserQuestion({
    questions: [
      {
        question: "You're on main. Create a new branch for this work:",
        header: "Branch Type",
        options: [
          {
            label: "Feature branch (Recommended)",
            description: "Independent branch from main",
          },
          {
            label: "Stacked branch",
            description: "Child of existing feature branch (for stacked PRs)",
          },
        ],
        multiSelect: false,
      },
    ],
  });

  // Generate branch name from plan slug
  const branchName = `feat/${planSlug}`;

  // If feature branch:
  Bash({ command: `git checkout -b ${branchName}` });

  // If stacked branch:
  // 1. Show existing feature branches
  // 2. Ask which to stack on
  // 3. git checkout -b ${branchName}
  // 4. git machete add --onto <parent>
} else {
  // On a feature branch - ask whether to stay or create new
  AskUserQuestion({
    questions: [
      {
        question: `You're on '${currentBranch}'. How should we proceed?`,
        header: "Branch",
        options: [
          {
            label: "Stay on this branch (Recommended)",
            description: "Continue work here",
          },
          {
            label: "Create stacked branch",
            description: `New branch stacked on ${currentBranch}`,
          },
        ],
        multiSelect: false,
      },
    ],
  });

  // If staying: nothing to do, continue with current branch

  // If stacked:
  // git checkout -b feat/${planSlug}
  // git machete add --onto ${currentBranch}
}

// Sync machete if on stacked branch
const isStackedBranch =
  Bash({
    command:
      "git machete is-managed $(git branch --show-current) 2>/dev/null && echo 'true' || echo 'false'",
  }).trim() === "true";

if (isStackedBranch) {
  Bash({ command: "git machete status", description: "Check stack status" });
}
```

### Phase 3: Load Task Files

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

OUTPUT FORMAT (MANDATORY):
Your FINAL message MUST start with either:
  "SUCCESS: <brief summary>"
  "FAILURE: <reason>"
This is required for task tracking.`,
    description: task.id,
    run_in_background: true,
  });
}

// 3. Collect ALL results and update task files IMMEDIATELY
for (const task of batch) {
  const output = TaskOutput({ task_id: task.agentId, block: true });

  // 4. MANDATORY: Update task file status based on agent output
  // Agent output contains "SUCCESS" or "FAILURE"
  const succeeded = output.includes("SUCCESS");

  if (succeeded) {
    // Rename file: pending → complete
    const oldFile = `.claude/branches/${slugBranch}/tasks/${task.filename}`;
    const newFile = oldFile.replace("-pending-", "-complete-");

    Bash({
      command: `mv "${oldFile}" "${newFile}"`,
      description: `Mark ${task.id} complete`,
    });

    // Update frontmatter
    Edit({
      file_path: newFile,
      old_string: "status: pending",
      new_string: "status: complete",
    });

    // Add completion to work log
    Edit({
      file_path: newFile,
      old_string: "## Work Log",
      new_string: `## Work Log\n\n### ${new Date().toISOString()} - Completed\n**By:** Agent\n**Result:** ${output.slice(0, 100)}`,
    });

    // GRANULAR COMMIT: Commit this task immediately
    // This creates a detailed git history of each change
    Bash({
      command: `git add . && git commit -m "$(cat <<'EOF'
feat(${task.scope}): ${task.title}

Task: ${task.id}
File: ${task.file_path}
Status: Complete

${output.slice(0, 200)}
EOF
)"`,
      description: `Commit ${task.id}`,
    });
  } else {
    // Task failed - log but keep as pending for retry
    console.log(`Task ${task.id} failed: ${output.slice(0, 200)}`);
  }
}

// VALIDATION: Verify task files were updated
const stillPending = Glob({
  pattern: `.claude/branches/${slugBranch}/tasks/*-pending-*.md`,
});
// If batch tasks still pending, something went wrong

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

// 6. Per-Batch Retry Loop (max 3 retries)
const testOutput = TaskOutput({ task_id: "test-runner-id", block: true });
let batchRetries = 0;
const MAX_BATCH_RETRIES = 3;

while (!testOutput.includes("ALL TESTS PASSING") && batchRetries < MAX_BATCH_RETRIES) {
  batchRetries++;

  // Update build state with retry count
  const stateFile = `.claude/branches/${slugBranch}/state.json`;
  const state = JSON.parse(Read({ file_path: stateFile }));
  state.build.batchRetries = batchRetries;
  Write({ file_path: stateFile, content: JSON.stringify(state, null, 2) });

  console.log(`
───────────────────────────────────────────────────────────
BATCH RETRY ${batchRetries}/${MAX_BATCH_RETRIES}
───────────────────────────────────────────────────────────
Test failures detected. Creating fix tasks...
`);

  // Parse failures from test output and create fix tasks
  const failures = parseTestFailures(testOutput);

  for (const failure of failures) {
    // Create fix task file
    const nextOrder = getNextOrderNumber(existingTasks);
    Write({
      file_path: `.claude/branches/${slugBranch}/tasks/${nextOrder}-pending-p1-fix-${failure.slug}.md`,
      content: `---
status: pending
priority: p1
story: fix
parallel: true
file_path: ${failure.file}
---

# T${nextOrder}: Fix test failure

## Description
${failure.testName} failed: ${failure.error}

## File Path
\`${failure.file}:${failure.line}\`

## Acceptance Criteria
- [ ] Test passes
`
    });
  }

  // Re-execute fix tasks (same batch pattern)
  const fixTasks = Glob({ pattern: `.claude/branches/${slugBranch}/tasks/*-pending-p1-fix-*.md` });

  for (const fixTask of fixTasks.slice(0, 6)) {
    Task({
      subagent_type: "general-purpose",
      prompt: `TASK: Fix test failure
FILE: ${fixTask.file_path}
ERROR: ${fixTask.error}
OUTPUT: "SUCCESS: fixed" or "FAILURE: reason"`,
      description: fixTask.id,
      run_in_background: true,
    });
  }

  // Collect fix results
  for (const fixTask of fixTasks.slice(0, 6)) {
    TaskOutput({ task_id: fixTask.agentId, block: true });
  }

  // Re-run tests
  Task({
    subagent_type: "general-purpose",
    model: "haiku",
    prompt: `Run tests, report ONLY failures. If all pass: "ALL TESTS PASSING"`,
    description: "test-runner",
    run_in_background: false,
  });

  testOutput = TaskOutput({ task_id: "test-runner-id", block: true });
}

// 7. Batch complete - output promise and update state
const batchNum = state.build.currentBatch;
const phaseName = state.build.currentPhase;

if (testOutput.includes("ALL TESTS PASSING")) {
  // Update state - mark batch complete
  state.build.completedBatches.push(`${phaseName}-batch-${batchNum}`);
  state.build.batchRetries = 0;
  Write({ file_path: stateFile, content: JSON.stringify(state, null, 2) });

  console.log(`<promise>BATCH ${batchNum} COMPLETE</promise>`);

  // Continue to next batch
  TodoWrite({ todos: /* update with next batch */ });
} else {
  // Max retries exceeded - need intervention
  console.log(`
═══════════════════════════════════════════════════════════
BATCH ${batchNum} BLOCKED - Max retries exceeded
═══════════════════════════════════════════════════════════
Failures persisting after ${MAX_BATCH_RETRIES} retries.
Manual intervention required.
`);

  AskUserQuestion({
    questions: [{
      question: "Batch failed after max retries. How to proceed?",
      header: "Blocked",
      options: [
        { label: "Continue anyway", description: "Skip failing tests, proceed" },
        { label: "Stop build", description: "Pause for manual fixes" },
        { label: "More retries", description: "Allow 3 more retry attempts" }
      ],
      multiSelect: false
    }]
  });
}
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

### Phase 7: Final Validation (MANDATORY - Fix ALL Issues)

**CRITICAL: This phase is NON-NEGOTIABLE. You MUST fix ALL issues found, even those unrelated to the current changes.**

```javascript
// STEP 1: Run CI checks from repository root
Bash({
  command: "cd $(git rev-parse --show-toplevel) && bun run ci",
  description: "Run CI checks from root",
});

// STEP 2: Run integration tests from repository root
Bash({
  command: "cd $(git rev-parse --show-toplevel) && bun run test:integration",
  description: "Run integration tests from root",
});

// STEP 3: FIX ALL FAILURES
// If ANY failures occur:
// - Type errors: Fix them ALL, even in files you didn't touch
// - Lint errors: Fix them ALL, even pre-existing ones
// - Test failures: Fix them ALL, regardless of origin
// - Integration test failures: Fix them ALL

// STEP 4: Re-run until clean
// Loop until BOTH commands pass with zero errors:
while (!ciPassing || !integrationPassing) {
  // Fix identified issues
  // Re-run: bun run ci
  // Re-run: bun run test:integration
}

// STEP 5: Verify all tasks complete (use slugBranch)
const remaining = Glob({
  pattern: `.claude/branches/${slugBranch}/tasks/*-pending-*.md`,
});
if (remaining.length > 0) {
  // Report incomplete tasks
}
```

**Why fix unrelated issues?**

- Keeps the codebase healthy
- Prevents tech debt accumulation
- Ensures every PR improves overall quality
- The branch should leave the repo better than it found it

### Phase 8: Summary & Completion Promise

**Note: Each task was already committed individually during execution for detailed git history.**

```javascript
// Show summary of all commits made during this build
Bash({
  command: `git log --oneline $(git merge-base HEAD main)..HEAD`,
  description: "Show commits from this build",
});

// Verify all tasks complete
const pendingTasks = Glob({
  pattern: `.claude/branches/${slugBranch}/tasks/*-pending-*.md`,
});
const allTasksComplete = pendingTasks.length === 0;

// Check if loop mode is active
const stateFile = `.claude/branches/${slugBranch}/state.json`;
let loopActive = false;
try {
  const state = JSON.parse(Read({ file_path: stateFile }));
  loopActive = state?.loop?.active === true;
} catch {}

if (allTasksComplete) {
  // Clear loop state if active
  if (loopActive) {
    const state = JSON.parse(Read({ file_path: stateFile }));
    state.loop.active = false;
    Write({ file_path: stateFile, content: JSON.stringify(state, null, 2) });
  }

  // Output completion promise (ends the iteration loop)
  console.log(`
═══════════════════════════════════════════════════════════
BUILD COMPLETE
═══════════════════════════════════════════════════════════

✓ All tasks complete
✓ CI passing
✓ Integration tests passing

- Branch: ${branch}
- Commits: ${commitCount}
- Tasks: .claude/branches/${slugBranch}/tasks/

<promise>BUILD COMPLETE</promise>
`);
} else {
  // Tasks still pending - don't output promise
  console.log(`
───────────────────────────────────────────────────────────
BUILD INCOMPLETE - ${pendingTasks.length} tasks remaining
───────────────────────────────────────────────────────────

Pending tasks:
${pendingTasks.map((t) => `  - ${t}`).join("\n")}

${loopActive ? "Loop will continue to next iteration..." : "Run /crew:build to continue."}
`);
}
```

**Granular Commit Benefits:**

- Full traceability of each change
- Easy to revert specific tasks
- Clear history for code review
- Bisect-friendly for debugging

**Next Steps (manual):**

- Review commits: `git log --oneline`
- Push when ready: `git push -u origin <branch>`
- Create PR: `gh pr create`

## Parallel Batching Strategy

**CRITICAL: Prevent context exhaustion with small agents**

### Rules

1. **One task = One agent** - Never give agent multiple tasks
2. **STRICT: Max 6 agents total at any time** - NEVER exceed this limit
3. **NEVER launch "while waiting"** - Do NOT add more agents while others run
4. **Inherit parent model** - Implementation agents use opus/sonnet
5. **Agents do NOT run tests** - Test-runner agent (haiku) handles this
6. **Limit file reads** - Max 2-3 files per agent
7. **Collect ALL before next batch** - Wait for ENTIRE batch to complete
8. **Update immediately** - Mark tasks complete as agents finish
9. **Process outputs sequentially** - Collect one output at a time to manage context

### Context Management

**Why sessions exhaust context (200K token limit):**

- Each TaskOutput returns full agent output to main thread
- Large file reads accumulate tokens rapidly
- Multiple Grep results compound quickly
- 10 agents × verbose output = context overflow

**Prevention Rules:**

1. **Limit file reads** - Always use `limit` parameter for large files:

   ```javascript
   // WRONG - reads entire 40KB file
   Read({ file_path: "src/handlers/identity.ts" });

   // CORRECT - reads first 200 lines
   Read({ file_path: "src/handlers/identity.ts", limit: 200 });
   ```

2. **Use background agents** - They don't accumulate in main context:

   ```javascript
   Task({ ..., run_in_background: true });  // Results summarized
   ```

3. **Commit frequently** - Each commit is a checkpoint:
   - Commit after each task completes (already in flow)
   - Smaller uncommitted work = easier recovery

4. **Manual `/compact` before large operations**:
   - Before starting a new batch of 6 agents
   - Before reading multiple large files
   - When session feels "heavy"

5. **Strict batch discipline** - Never launch while waiting:

   ```javascript
   // WRONG - launches too many agents
   for (batch1) { Task(..., run_in_background: true) }
   // "while waiting, let me launch more..."
   for (batch2) { Task(..., run_in_background: true) }  // NO!

   // CORRECT - collect ALL before next batch
   for (batch) { Task(..., run_in_background: true) }  // max 6
   for (batch) { TaskOutput({ block: true }) }  // collect ALL
   // ONLY THEN launch next batch
   ```

**Recovery if context exhausted:**

- Session auto-compacts and resumes
- Check `.claude/branches/<branch>/tasks/` for progress
- Completed tasks are renamed `*-complete-*`
- Continue from first `*-pending-*` task

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
OUTPUT FORMAT (MANDATORY):
Your FINAL message MUST start with either:
  "SUCCESS: <brief summary>"
  "FAILURE: <reason>"
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

### Core Execution

- [ ] TodoWrite tracks ALL progress (updated after EVERY task)
- [ ] Task files loaded from `.claude/branches/<slugified-branch>/tasks/`
- [ ] Tasks executed in batches by phase
- [ ] **STRICT: Max 6 agents total at any time** (NEVER launch more while waiting)
- [ ] **Implementation agents inherit parent model** (opus/sonnet)
- [ ] **Agents do NOT run tests** (constraints enforced in prompts)
- [ ] **Agents output "SUCCESS:" or "FAILURE:" prefix** (mandatory for tracking)
- [ ] **Task files renamed immediately after agent completes** (pending → complete)
- [ ] **Test-runner agent (haiku) runs after each batch** - reports only failures
- [ ] Each agent handles ONE small task
- [ ] All parallel tasks launched in SINGLE message
- [ ] Quality findings added as new task files
- [ ] Native tools used for file operations
- [ ] AskUserQuestion at key decision points
- [ ] **MANDATORY: `bun run ci` passes from root** (fix ALL errors, even unrelated)
- [ ] **MANDATORY: `bun run test:integration` passes from root** (fix ALL errors, even unrelated)
- [ ] **Granular commits created for each task** (detailed git history)

### Loop Integration (if `--loop` flag)

- [ ] Loop state initialized in `.claude/branches/{branch}/state.json`
- [ ] Build state tracks currentPhase, currentBatch, completedBatches
- [ ] Per-batch retry loop (max 3) creates fix tasks and re-executes
- [ ] `<promise>BATCH N COMPLETE</promise>` output after each successful batch
- [ ] `<promise>BUILD COMPLETE</promise>` output ONLY when ALL criteria met
- [ ] Loop state cleared when build completes or cancelled
- [ ] Resuming loop reads prior progress from task files
