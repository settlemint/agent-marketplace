<patterns>

<pattern name="user-questions-constraint">
**MANDATORY: ALWAYS use AskUserQuestion tool for user choices.**

NEVER output plain text questions with options like:

```
What would you like to do?
- Option 1
- Option 2
```

ALWAYS use the AskUserQuestion tool instead:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What would you like to do?",
      header: "Action",
      options: [
        { label: "Option 1", description: "What this does" },
        { label: "Option 2", description: "Alternative" },
      ],
      multiSelect: false,
    },
  ],
});
```

This applies to:

- End-of-workflow "what next?" prompts
- Decision points during execution
- Clarification requests
- All user-facing choices
  </pattern>

<pattern name="spawn-batch">
Launch max 6 parallel agents in SINGLE message:

```javascript
// All calls in ONE message block for parallelism
Task({
  subagent_type: "general-purpose",
  prompt: `TASK: ${id}\nFILE: ${file}\nACCEPTANCE: ${criteria}\nCONSTRAINTS:\n- Max 2-3 file reads\n- Do NOT run tests\nOUTPUT: "SUCCESS: <summary>" or "FAILURE: <reason>"`,
  description: id,
  run_in_background: true,
});
// Repeat for each task in batch (max 6)
```

</pattern>

<pattern name="test-runner">
Use the Bash subagent for test execution (NEVER run tests directly via Bash in main thread).

The Bash subagent runs in a separate context window, preventing output pollution in the main thread.

```javascript
Task({
  subagent_type: "Bash",
  prompt: `Run the test suite and report results:

1. Run: bun run test
2. Report summary:
   - If pass: "ALL TESTS PASSING"
   - If fail: List failures with test name, file:line, error message

The Bash subagent handles large output automatically in its own context.`,
  description: "test-runner",
  run_in_background: false,
});
```

**Why Bash subagent?**
- Separate context window prevents main thread pollution
- Only has Bash tool access (focused, efficient)
- No need for temp file piping - output stays in subagent context
- Results returned as summary to main thread

</pattern>

<pattern name="large-output">
**PREFERRED: Use Bash subagent** for commands with large output.

The Bash subagent (`subagent_type: "Bash"`) runs in a separate context window, preventing output pollution in the main thread. This is the recommended approach for:

- Test runs (`bun run test`, `vitest`, `jest`, `playwright`)
- Linting (`eslint`, `biome lint`, `tsc`)
- Build processes (`bun run build`, `turbo build`)
- Package installs (`bun install`, `npm i`)
- Docker builds (`docker build`, `docker compose up`)
- Database ops (`prisma migrate`, `drizzle-kit push`)

```javascript
Task({
  subagent_type: "Bash",
  prompt: `Run CI checks and report results:
1. Run: bun run ci
2. Report: PASS or list errors with file:line`,
  description: "ci-check",
  run_in_background: true,
});
```

**Why Bash subagent?**
- Output stays in subagent's context (no main thread pollution)
- No temp files needed
- Summary returned to main thread
- Can run in background while you continue other work

**Fallback (direct Bash in main thread):**

The `wrap-long-output.sh` PreToolUse hook still wraps long-running commands with `tee` to temp files as a safety net, but prefer the Bash subagent pattern above.

</pattern>

<pattern name="collect-results">
Collect ALL results before next batch:

```javascript
for (const task of batch) {
  const output = TaskOutput({ task_id: task.agentId, block: true });
  if (output.includes("SUCCESS")) {
    // Rename: *-pending-* → *-complete-*
    // Update frontmatter status
    // Commit task
  }
}
```

</pattern>

<pattern name="todo-progress">
Track progress with TodoWrite (update IMMEDIATELY after each task):

```javascript
TodoWrite({
  todos: [
    {
      content: "Task description",
      status: "in_progress",
      activeForm: "Doing task",
    },
    { content: "Next task", status: "pending", activeForm: "Doing next" },
  ],
});
```

States: `pending` → `in_progress` → `completed`
Only ONE task `in_progress` at a time.
</pattern>

<pattern name="ask-user">
User decision points:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Question text?",
      header: "Short label",
      options: [
        { label: "Option 1 (Recommended)", description: "What happens" },
        { label: "Option 2", description: "Alternative" },
      ],
      multiSelect: false,
    },
  ],
});
```

</pattern>

<pattern name="task-file">
Task file format in `.claude/branches/{slugified-branch}/tasks/`:

```markdown
---
status: pending
priority: p1
story: us1
parallel: true
file_path: src/path/to/file.ts
depends_on: []
---

# TXXX: Task title

## Description

What to do.

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2

## File Path

`src/path/to/file.ts`

## Work Log

### {date} - Created

**By:** /crew:design
```

Naming: `{order}-{status}-{priority}-{story}-{slug}.md`
Example: `010-pending-p1-us1-create-model.md`
</pattern>

<pattern name="branch-state">
Branch state at `.claude/branches/{slugified-branch}/state.json`:

```json
{
  "branch": "feat/feature-name",
  "loop": {
    "active": true,
    "iteration": 1,
    "maxIterations": 15,
    "completionPromise": "BUILD COMPLETE",
    "prompt": "/crew:build ...",
    "startedAt": "ISO-8601"
  },
  "build": {
    "currentPhase": "us1",
    "completedTasks": 0,
    "totalTasks": 10
  }
}
```

</pattern>

<pattern name="quality-agents">
Seven-leg review agents (launch ALL in single message):

```javascript
const legs = [
  "correctness",
  "performance",
  "security",
  "elegance",
  "resilience",
  "style",
  "smells",
];
for (const leg of legs) {
  Task({
    subagent_type: `${leg}-reviewer`,
    prompt: `CONTEXT: Review ${scope}\nFOCUS: ${legFocus[leg]}\nOUTPUT: [P0|P1|P2|Obs] file:line - description`,
    description: `${leg} review`,
    run_in_background: true,
  });
}
```

</pattern>

<pattern name="research-agents">
Design research agents (launch ALL in single message):

```javascript
// Foundational (3)
Task({
  subagent_type: "repo-research-analyst",
  prompt: "...",
  run_in_background: true,
});
Task({
  subagent_type: "best-practices-researcher",
  prompt: "...",
  run_in_background: true,
});
Task({
  subagent_type: "git-history-analyzer",
  prompt: "...",
  run_in_background: true,
});

// Dimension analysis (6)
Task({
  subagent_type: "api-interface-analyst",
  prompt: "...",
  run_in_background: true,
});
Task({
  subagent_type: "data-model-architect",
  prompt: "...",
  run_in_background: true,
});
Task({
  subagent_type: "ux-workflow-analyst",
  prompt: "...",
  run_in_background: true,
});
Task({
  subagent_type: "scale-performance-analyst",
  prompt: "...",
  run_in_background: true,
});
Task({
  subagent_type: "security-threat-analyst",
  prompt: "...",
  run_in_background: true,
});
Task({
  subagent_type: "integration-dependency-analyst",
  prompt: "...",
  run_in_background: true,
});
```

</pattern>

</patterns>
