---
name: todo-tracking
description: Persistent task files in .claude/branches/. Use for multi-session work tracking.
triggers:
  - "persistent task"
  - "save progress"
  - "branch.*task"
  - "\\.claude/branches"
  - "task file"
---

<objective>

Tasks in `.claude/branches/<slugified-branch>/tasks/` as individual files with ordering.

**One location. One format. Always on branch. Slugified (/ → -).**

</objective>

<routing>

| Resource                          | Purpose                |
| --------------------------------- | ---------------------- |
| `references/branch-tasks.md`      | Complete documentation |
| `templates/task-file-template.md` | Task file format       |
| `templates/plan-template.md`      | Plan document format   |

</routing>

<quick_start>

**Location:**

```text
.claude/branches/<branch>/tasks/
├── 001-pending-p1-setup-create-structure.md
├── 010-pending-p1-us1-create-user-model.md
├── 050-pending-p1-found-fix-type-error.md
└── 099-pending-p3-polish-update-docs.md
```

**Naming:** `{order}-{status}-{priority}-{story}-{slug}.md`

- order: 001, 002... (3 digits)
- status: pending, in_progress, complete
- priority: p1, p2, p3
- story: setup, found, us1, us2, polish

**Frontmatter:**

```yaml
---
status: pending
priority: p1
story: us1
parallel: true
file_path: src/models/user.ts
depends_on: []
---
```

</quick_start>

<parallel_strategy>

One task = One agent. Launch many in parallel.

```javascript
// Launch ALL parallel tasks in SINGLE message
Task({
  subagent_type: "general-purpose",
  prompt: "T001...",
  run_in_background: true,
});
Task({
  subagent_type: "general-purpose",
  prompt: "T002...",
  run_in_background: true,
});
// Collect ALL before next batch
TaskOutput({ task_id: "t001", block: true });
TaskOutput({ task_id: "t002", block: true });
```

</parallel_strategy>

<command_integration>

| Command        | Action                             |
| -------------- | ---------------------------------- |
| `/crew:design` | Creates plan + task files          |
| `/crew:build`  | Executes tasks in parallel batches |
| `/crew:check`  | Adds findings as tasks             |

</command_integration>

<success_criteria>

- Tasks in `.claude/branches/<slugified-branch>/tasks/`
- Filename: `{order}-{status}-{priority}-{story}-{slug}.md`
- Status in filename matches frontmatter
- Each task has acceptance criteria
- Parallel tasks marked `parallel: true`

</success_criteria>
