---
name: todo-tracking
description: File-based task tracking in .claude/branches/. Persistent across sessions.
triggers:
  - "persistent task"
  - "branch.*task"
  - "\\.claude/branches"
  - "task file"
context: fork
---

<objective>

Tasks as files in `.claude/branches/<slugified-branch>/tasks/` with ordering and status in filename.

**Key:** Filesystem as external memory. Re-read plan before major decisions.

</objective>

<quick_start>

**Location:**

```text
.claude/branches/<branch>/tasks/
├── 001-pending-p1-setup-create-structure.md
├── 010-pending-p1-us1-create-user-model.md
└── 050-complete-p1-found-fix-type-error.md
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
type: change # gotcha | problem | howto | change | discovery | decision
parallel: true
file_path: src/models/user.ts
depends_on: []
---
```

</quick_start>

<routing>

| Resource                            | Purpose                | Load When        |
| ----------------------------------- | ---------------------- | ---------------- |
| `references/branch-tasks.md`        | Complete documentation | First time setup |
| `references/context-engineering.md` | Attention patterns     | 50+ tool calls   |
| `templates/task-file-template.md`   | Task file format       | Creating tasks   |
| `templates/plan-template.md`        | Plan document format   | Creating plans   |

**For TodoWrite patterns:** Use `n-skills:orchestration` skill.

</routing>

<context_engineering>

**Read before decide:** Re-read plan file before every major decision.

```javascript
Read({ file_path: `.claude/branches/${branch}/plan.md` });
```

**Store, don't stuff:** Large content goes to files, not context.

```javascript
Write({ file_path: `.claude/branches/${branch}/notes.md`, content: findings });
```

</context_engineering>

<success_criteria>

- Tasks in `.claude/branches/<slugified-branch>/tasks/`
- Filename status matches frontmatter
- Plan file re-read before major decisions

</success_criteria>
