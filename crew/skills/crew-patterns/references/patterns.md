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
Haiku agent for test execution (NEVER run tests directly via Bash).

**Use `<pattern name="large-output"/>` to capture full results:**

```javascript
Task({
  subagent_type: "general-purpose",
  model: "haiku",
  prompt: `Run tests with output captured to temp file (see large-output pattern):

1. Create log file:
   LOG=$(mktemp /tmp/test-run-XXXXXX.log)
   echo "Log file: $LOG"

2. Run tests with full output:
   bun run test 2>&1 | tee $LOG

3. Report summary:
   - If pass: "ALL TESTS PASSING"
   - If fail: Parse $LOG for failures, report: test name, file:line, error
   - Always include: "Full output: $LOG"

The log file allows re-reading without re-running tests.`,
  description: "test-runner",
  run_in_background: false,
});
```

</pattern>

<pattern name="large-output">
**For commands with potentially large output (tests, lint, build):**

Capture output to a temp file to:

- Avoid truncation in terminal
- Allow re-reading without re-running
- Preserve full stack traces and error details

```bash
# Create temp log file
LOG=$(mktemp /tmp/${cmd}-XXXXXX.log)
echo "Output will be logged to: $LOG"

# Run command, capture everything
${command} 2>&1 | tee $LOG

# Parse results from file
if [ $? -eq 0 ]; then
  echo "SUCCESS - see $LOG for details"
else
  echo "FAILED - analyzing $LOG..."
  # Extract relevant errors from $LOG
  grep -E "ERROR|FAIL|error:" $LOG | head -20
  echo "Full output: $LOG"
fi
```

**When to use:**

- Test runs (`bun run test`, `vitest`, `jest`)
- Linting (`eslint`, `biome lint`)
- Type checking (`tsc --noEmit`)
- Build processes (`bun run build`)
- Any command that may produce >100 lines of output

**Benefits:**

- Full stack traces preserved
- No need to re-run to get more details
- Can grep/search the log file
- Multiple reads without re-execution

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
