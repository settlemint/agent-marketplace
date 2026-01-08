---
name: todo-tracking
description: Persistent task files in .claude/branches/. Use for multi-session work tracking.
triggers:
  - "persistent task"
  - "save progress"
  - "branch.*task"
  - "\\.claude/branches"
  - "task file"
  - "manus"
  - "context engineering"
context: fork
---

<objective>

Tasks in `.claude/branches/<slugified-branch>/tasks/` as individual files with ordering.

**One location. One format. Always on branch. Slugified (/ → -).**

**Key Insight:** Use filesystem as external memory. Re-read plan before major decisions.

</objective>

<routing>

| Resource                              | Purpose                           | ~Tokens | Load When              |
| ------------------------------------- | --------------------------------- | ------- | ---------------------- |
| `references/branch-tasks.md`          | Complete documentation            | ~800    | First time setup       |
| `references/context-engineering.md`   | Manus-inspired attention patterns | ~600    | 50+ tool calls         |
| `templates/task-file-template.md`     | Task file format with legend      | ~200    | Creating tasks         |
| `templates/plan-template.md`          | Plan document format              | ~300    | Creating plans         |

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
type: change        # gotcha | problem | howto | change | discovery | rationale | decision | tradeoff
parallel: true
file_path: src/models/user.ts
depends_on: []
tokens: ~150        # Approximate content size for ROI decisions
---
```

</quick_start>

<legend>

## Task Type Legend (Progressive Disclosure)

Icons for semantic compression in task titles (~10 words max):

| Icon | Type       | When to Use                              |
| ---- | ---------- | ---------------------------------------- |
| 🔴   | Gotcha     | Critical edge case that breaks assumptions |
| 🟡   | Problem    | Fix/workaround for known issue           |
| 🔵   | How-to     | Technical explanation or implementation  |
| 🟢   | Change     | Code/architecture modification (default) |
| 🟣   | Discovery  | Non-obvious insight learned              |
| 🟠   | Rationale  | Design reasoning (why it exists)         |
| 🟤   | Decision   | Architectural choice made                |
| ⚖️   | Trade-off  | Deliberate compromise accepted           |

**Example titles:**
- `🔴 Hook timeout: 60s default too short for npm install`
- `🟡 Race condition in auth: add mutex lock`
- `🟢 Add user validation middleware to API routes`
- `🟤 Use Redis over Memcached for session caching`

**Benefits:** Visual scanning (~50 tokens to scan 10 titles), priority signaling, pattern recognition.

</legend>

<index_pattern>

## Task Index (Progressive Disclosure Layer 1)

Generate `INDEX.md` for token-efficient task scanning:

```markdown
# Task Index

| File | Pri | Type | Title | ~Tokens |
|------|-----|------|-------|---------|
| 001-pending-p1-setup-*.md | 🔴 P1 | 🟢 | Create project structure | ~150 |
| 010-pending-p1-us1-*.md | 🔴 P1 | 🟢 | User model with auth | ~280 |
| 050-pending-p1-found-*.md | 🔴 P1 | 🔴 | Fix null pointer in parser | ~85 |
```

**Workflow:**
1. Scan INDEX.md (~50 tokens per row)
2. Identify relevant tasks by priority/type
3. Fetch full details only for selected tasks (~500 tokens each)

**Token savings:** 10 tasks × 50 = 500 tokens vs 10 × 500 = 5000 tokens

</index_pattern>

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

<context_engineering>

## Attention Management (Manus Patterns)

**Read before decide:** Re-read plan file before every major decision to keep goals in attention window.

```javascript
// Before EVERY major decision:
Read({ file_path: `.claude/branches/${branch}/plan.md` });
// Goals are now fresh - make the decision
```

**Keep failure traces:** Document ALL errors in work log immediately:

```markdown
## Errors Encountered

- [DATE] TypeError: null check missing → Added validation
- [DATE] API timeout → Retried with backoff
```

**Store, don't stuff:** Large content goes to files, not context:

```javascript
// Store findings externally
Write({ file_path: `.claude/branches/${branch}/notes.md`, content: findings });
// Context only has the path, not 10000 lines
```

See `references/context-engineering.md` for complete patterns.

</context_engineering>

<success_criteria>

- Tasks in `.claude/branches/<slugified-branch>/tasks/`
- Filename: `{order}-{status}-{priority}-{story}-{slug}.md`
- Status in filename matches frontmatter
- Each task has acceptance criteria
- Parallel tasks marked `parallel: true`
- Plan file re-read before major decisions
- Errors documented in work log

</success_criteria>
