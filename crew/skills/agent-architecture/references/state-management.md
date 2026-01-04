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

## Agent Tracking (Witness Pattern)

Background agents are tracked in a separate file:

```
.claude/branches/{branch}/agents.json
```

### Agent Schema

```json
{
  "agents": [
    {
      "id": "agent-1234567890-12345",
      "type": "general-purpose",
      "description": "T001 - Create user model",
      "spawned_at": "2024-01-01T00:00:00Z",
      "spawned_epoch": 1704067200,
      "background": true,
      "status": "running",
      "completed_at": null,
      "result": null,
      "nudge_count": 0,
      "last_nudge": null
    }
  ],
  "stats": {
    "total_spawned": 10,
    "completed": 8,
    "failed": 1,
    "stuck": 1
  }
}
```

### Agent States

| Status | Description |
|--------|-------------|
| `running` | Agent is actively executing |
| `completed` | Finished successfully |
| `failed` | Encountered an error |

### Stuck Detection

Agents are considered stuck when:
- Status is `running`
- Elapsed time exceeds threshold (default: 5 minutes)

On session resume, the witness hook automatically:
1. Detects agents running past threshold
2. Reports them with recovery options
3. Marks them as `stuck` in the tracking file

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
