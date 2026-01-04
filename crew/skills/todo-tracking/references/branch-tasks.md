---
name: branch-tasks
description: Branch-scoped task system. Individual task files in .claude/branches/<branch>/tasks/ with ordering support.
triggers: ["branch task", "tasks/", "implementation task", "user story task", "task file"]
depends_on: []
---

<overview>

## Branch-Scoped Task System

All tasks live in `.claude/branches/<branch>/tasks/` as individual files.

**One location. One format. Always on a branch.**

**Key Principles:**
- **One file per task** - Easy to manage, merge, and track
- **Ordered by filename** - Sequential numbering for execution order
- **Small agent chunks** - Each task handled by focused parallel agent

**Location:** `.claude/branches/<branch>/tasks/*.md`

**Created by:**
- `/crew:design` - Generates initial task files from plan
- `/crew:check` - Adds finding files as additional tasks
- `/crew:build` - May add discovered tasks during implementation
- `/crew:fix` - Works through pending tasks

</overview>

<file_naming>

## File Naming Convention

```text
{order}-{status}-{priority}-{story}-{slug}.md
```

| Component | Values | Description |
|-----------|--------|-------------|
| `order` | 001, 002... | Execution order (3 digits) |
| `status` | pending, ready, in_progress, complete | Current state |
| `priority` | p1, p2, p3 | Priority level |
| `story` | us1, us2, setup, found, polish | User story or phase |
| `slug` | kebab-case | Brief description |

**Examples:**

```text
001-pending-p1-setup-create-project-structure.md
002-pending-p1-setup-install-dependencies.md
010-pending-p1-us1-create-user-model.md
011-pending-p1-us1-implement-auth-service.md
020-pending-p2-us2-add-profile-endpoint.md
050-pending-p1-found-fix-type-error-auth.md    # From /crew:check
099-pending-p3-polish-update-documentation.md
```

**Story Labels:**

| Label | Meaning |
|-------|---------|
| `setup` | Phase 1: Project initialization |
| `found` | Phase 2: Foundational/blocking |
| `us1` | User Story 1 (P1/MVP) |
| `us2` | User Story 2 (P2) |
| `us3` | User Story 3 (P3) |
| `found` | Check finding (added later) |
| `polish` | Final phase: cleanup |

</file_naming>

<task_file_structure>

## Task File Structure

```markdown
---
status: pending
priority: p1
story: us1
parallel: true
file_path: src/models/user.ts
depends_on: []
---

# T010: Create User model

## Description

Create the User model with authentication fields.

## Acceptance Criteria

- [ ] **Given** no user exists, **When** creating user, **Then** model validates required fields
- [ ] **Given** user model created, **When** saving, **Then** persists to database

## File Path

`src/models/user.ts`

## Implementation Notes

[Context for the implementing agent]

## Work Log

### [DATE] - Created
**By:** /crew:design
**Status:** Generated from plan
```

</task_file_structure>

<parallel_execution>

## Parallel Agent Strategy

**CRITICAL**: Each agent handles ONE small task. Launch many in parallel.

### Chunking Rules

1. **One task = One agent** - Never give agent multiple tasks
2. **Small scope** - Each task should be completable in ~5-10 minutes
3. **Clear boundaries** - Task touches ONE file or small set
4. **No dependencies** - Only parallel tasks marked `parallel: true`

### Batch Execution Pattern

```javascript
// Phase 1: Launch all parallel setup tasks
Task({subagent_type: "implementer", prompt: "T001: Create project structure", description: "T001", run_in_background: true})
Task({subagent_type: "implementer", prompt: "T002: Install dependencies", description: "T002", run_in_background: true})
Task({subagent_type: "implementer", prompt: "T003: Configure linting", description: "T003", run_in_background: true})

// Collect all results
TaskOutput({task_id: "t001-id", block: true})
TaskOutput({task_id: "t002-id", block: true})
TaskOutput({task_id: "t003-id", block: true})

// Phase 2: Launch next batch of parallel tasks
Task({subagent_type: "implementer", prompt: "T010: Create User model", description: "T010", run_in_background: true})
Task({subagent_type: "implementer", prompt: "T011: Create Profile model", description: "T011", run_in_background: true})

// Continue batching...
```

### Agent Context Template

Give each agent minimal, focused context:

```javascript
Task({
  subagent_type: "implementer",
  prompt: `TASK: T010 - Create User model

FILE: src/models/user.ts

ACCEPTANCE:
- Model has id, email, passwordHash, createdAt fields
- Email must be unique
- Validation for required fields

CONTEXT:
- TypeScript, Prisma ORM
- Follow existing model patterns in src/models/

OUTPUT:
- Create the file
- Run tests
- Report completion`,
  description: "T010: User model",
  run_in_background: true
})
```

</parallel_execution>

<integration>

## Command Integration

### /crew:design Creates Tasks

```javascript
// Ensure tasks directory exists
Bash({command: `mkdir -p .claude/branches/${branch}/tasks`})

// Write individual task files
Write({
  file_path: `.claude/branches/${branch}/tasks/001-pending-p1-setup-create-structure.md`,
  content: taskContent
})

Write({
  file_path: `.claude/branches/${branch}/tasks/010-pending-p1-us1-create-user-model.md`,
  content: taskContent
})
// ... one file per task
```

### /crew:build Consumes Tasks

```javascript
// List all task files in order
const taskFiles = Glob({pattern: `.claude/branches/${branch}/tasks/*.md`})

// Read and sort by filename (already ordered)
// Parse status from filename and frontmatter

// Group by parallel capability
const parallelTasks = tasks.filter(t => t.parallel && t.status === 'pending')
const sequentialTasks = tasks.filter(t => !t.parallel && t.status === 'pending')

// Launch parallel batch
parallelTasks.forEach(task => {
  Task({...})
})
```

### /crew:check Adds Findings

```javascript
// Find next order number
const existing = Glob({pattern: `.claude/branches/${branch}/tasks/*.md`})
const nextOrder = getNextOrderNumber(existing)

// Add finding as new task
Write({
  file_path: `.claude/branches/${branch}/tasks/${nextOrder}-pending-p1-found-fix-type-error.md`,
  content: findingContent
})
```

</integration>

<status_transitions>

## Status Transitions

```text
pending → in_progress → complete
              ↓
          blocked (if dependency fails)
```

### Updating Status

Status lives in BOTH filename and frontmatter. Update both:

```javascript
// 1. Update frontmatter
Edit({
  file_path: taskPath,
  old_string: "status: pending",
  new_string: "status: in_progress"
})

// 2. Rename file
Bash({
  command: `mv "${oldPath}" "${newPath}"`,
  description: "Update task status"
})
// pending → in_progress
// 010-pending-p1-us1-... → 010-in_progress-p1-us1-...
```

### Completion

```javascript
// Mark complete
Edit({
  file_path: taskPath,
  old_string: "status: in_progress",
  new_string: "status: complete"
})

// Rename
// 010-in_progress-p1-us1-... → 010-complete-p1-us1-...

// Add to work log
Edit({
  file_path: taskPath,
  old_string: "## Work Log",
  new_string: `## Work Log

### ${date} - Completed
**By:** Agent
**Changes:** Created src/models/user.ts
**Tests:** All passing`
})
```

</status_transitions>

<quick_commands>

## Quick Commands

```bash
# List pending tasks in order
ls .claude/branches/$(git branch --show-current)/tasks/*-pending-*.md

# Count tasks by status
ls .claude/branches/$(git branch --show-current)/tasks/ | grep -c pending
ls .claude/branches/$(git branch --show-current)/tasks/ | grep -c complete

# Find parallel tasks
grep -l "parallel: true" .claude/branches/$(git branch --show-current)/tasks/*-pending-*.md

# Find tasks for specific story
ls .claude/branches/$(git branch --show-current)/tasks/*-us1-*.md
```

</quick_commands>

<checklist>

## Validation Checklist

- [ ] Task files in `.claude/branches/<branch>/tasks/`
- [ ] Filenames follow ordering convention
- [ ] Status matches in filename AND frontmatter
- [ ] Each task has acceptance criteria
- [ ] Parallel tasks marked appropriately
- [ ] Dependencies tracked if blocked
- [ ] Work log updated on completion

</checklist>
