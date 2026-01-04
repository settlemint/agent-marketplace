# Iteration Loop

## Overview

The iteration loop is a self-referential feedback mechanism where the same prompt is repeatedly fed to Claude. The prompt never changes, but Claude's previous work persists in files.

## How It Works

1. **Start**: `/crew:loop "task description" --max-iterations 15 --completion-promise "DONE"`
2. **Work**: Claude works on the task
3. **Exit attempt**: Claude tries to complete/exit
4. **Stop hook**: `check-loop.sh` intercepts the exit
5. **Check promise**: If `<promise>DONE</promise>` was output, allow exit
6. **Continue**: If not done and iterations remain, re-feed the prompt
7. **Repeat**: Steps 2-6 until complete or max iterations

## Completion Promise

The completion promise is a specific string that signals genuine completion:

```
<promise>BUILD COMPLETE</promise>
```

Rules:
- Must use exact `<promise>` XML tags
- The statement MUST be completely true
- Do NOT output false statements to exit early
- If blocked, document blockers instead of lying

## State Management

Loop state is stored in unified branch state:

```json
{
  "loop": {
    "active": true,
    "iteration": 3,
    "maxIterations": 15,
    "completionPromise": "BUILD COMPLETE",
    "prompt": "Original task...",
    "startedAt": "2024-01-01T00:00:00Z"
  }
}
```

## Stop Hook Behavior

The `check-loop.sh` Stop hook:

1. Reads loop state from `.claude/branches/{branch}/state.json`
2. If no active loop, allows normal exit
3. If max iterations reached, clears loop and allows exit
4. Checks for completion promise in CLAUDE_STOP_TRANSCRIPT
5. If promise found, clears loop and allows exit
6. Otherwise, increments iteration and outputs continuation prompt
7. Exit code 1 blocks exit, feeding continuation to Claude

## Best Practices

### Clear Completion Criteria

```bash
/crew:loop "Build REST API for todos.
When complete:
- All CRUD endpoints working
- Tests passing (bun run test)
- CI passing (bun run ci)
Output: <promise>API COMPLETE</promise>" --max-iterations 15
```

### Incremental Goals

```bash
/crew:loop "Implement feature in phases:
Phase 1: Database schema
Phase 2: API endpoints
Phase 3: Tests with >80% coverage

After EACH phase: bun run ci
Output <promise>ALL PHASES DONE</promise> when complete." --max-iterations 20
```

### With Handoffs

```bash
/crew:loop "Implement auth per .claude/plans/auth.md

After completing each task:
1. Run tests
2. Create handoff: /crew:handoff task [description]

Output <promise>AUTH COMPLETE</promise> when done." --max-iterations 25
```

## Cancellation

To stop a loop early:

```bash
/crew:cancel-loop "reason for stopping"
```

This:
1. Creates a handoff documenting progress
2. Sets loop.active to false
3. Returns control to user
