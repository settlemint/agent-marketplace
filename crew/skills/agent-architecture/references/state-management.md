# State Management

## Unified Branch State

All branch state lives in a single location:

```
.claude/branches/{branch}/state.json
```

Where `{branch}` is the sanitized branch name (slashes replaced with dashes).

## State Schema

```json
{
  "branch": "feat-example",
  "session": "session-id",
  "compacted_at": "2024-01-01T00:00:00Z",

  "workflow": {
    "phase": "building",
    "active": "build",
    "args": ""
  },

  "plan": {
    "exists": true,
    "file": ".claude/plans/feature.md",
    "preview": "First 40 lines..."
  },

  "loop": {
    "active": true,
    "iteration": 3,
    "maxIterations": 15,
    "completionPromise": "BUILD COMPLETE",
    "prompt": "Original task...",
    "startedAt": "2024-01-01T00:00:00Z"
  },

  "execution": {
    "todos": [
      {"content": "Task 1", "status": "completed", "activeForm": "Working on task 1"},
      {"content": "Task 2", "status": "in_progress", "activeForm": "Working on task 2"}
    ],
    "pending_count": 1,
    "completed_count": 1
  },

  "handoff": {
    "count": 3,
    "last": ".claude/branches/feat-example/handoffs/task-2024-01-01.md"
  }
}
```

## State Lifecycle

### Creation

State is created/updated by:
- `save-session-state.sh` (PreCompact hook)
- `/crew:loop` command (initializes loop state)
- `/crew:handoff` command (updates handoff count)

### Recovery

State is read by:
- `restore-session-state.sh` (SessionStart hook) - recovers after compaction
- `check-loop.sh` (Stop hook) - manages iteration continuation
- `/crew:build` - checks workflow state

### Directory Structure

```
.claude/branches/{branch}/
├── state.json           # Unified state
└── handoffs/            # Handoff documents
    ├── task-2024-01-01.md
    └── session-2024-01-02.md
```

## State vs Plans

- **Plans** stay in `.claude/plans/` - they're tracked in git
- **State** lives in `.claude/branches/` - runtime only, gitignored
- Plans are persistent documents; state is ephemeral context
