---
name: file-todos
description: This skill provides file-based todo tracking in .claude/todos/. It should be used for creating, triaging, and managing work items.
triggers: ["\\.claude/todos", "work items", "triage"]
depends_on: []
---

<overview>

## File-Based Todo System

Markdown files in `.claude/todos/` with YAML frontmatter for tracking code review feedback, technical debt, and work items.

**Naming:** `{id}-{status}-{priority}-{description}.md`

- **id**: Sequential (001, 002...)
- **status**: `pending` (needs triage), `ready` (approved), `complete`
- **priority**: `p1` (critical), `p2` (important), `p3` (nice-to-have)

**Example:** `002-ready-p1-fix-n-plus-1.md`

</overview>

<frontmatter>

## YAML Structure

```yaml
---
status: ready # pending | ready | complete
priority: p1 # p1 | p2 | p3
issue_id: "002"
tags: [typescript, performance]
dependencies: ["001"] # Blocked by these issue IDs
feature: "transfer-form" # Feature branch name (optional)
---
```

</frontmatter>

<required_sections>

## Required Sections

- **Problem Statement** - What needs fixing?
- **Findings** - Investigation results, root cause
- **Proposed Solutions** - Options with pros/cons
- **Recommended Action** - Clear plan (filled during triage)
- **Acceptance Criteria** - Testable checklist
- **Work Log** - Dated entries with actions and learnings

**Template:** `assets/todo-template.md`

</required_sections>

<workflows>

## Common Operations

**Create todo:**

```bash
ls .claude/todos/ | grep -o '^[0-9]\+' | sort -n | tail -1  # Get last ID
cp .claude/skills/crew/templates/todo-template.md .claude/todos/{NEXT_ID}-pending-{pri}-{desc}.md
```

**Triage (pending → ready):**

```bash
mv .claude/todos/{id}-pending-{pri}-{desc}.md .claude/todos/{id}-ready-{pri}-{desc}.md
# Update status in frontmatter, fill Recommended Action
```

**Complete:**

```bash
mv .claude/todos/{id}-ready-{pri}-{desc}.md .claude/todos/{id}-complete-{pri}-{desc}.md
# Update status, verify acceptance criteria checked

# Commit this fix separately (granular history)
git add .claude/todos/{id}-complete-{pri}-{desc}.md
git commit -m "fix: complete todo {id} - {description}"
```

Each todo completion should be its own commit for granular history.

**After completing todos, ALWAYS create handoff (which triggers compounding):**

```javascript
Skill({ skill: "workflows:handoff", args: "task Fixed: [brief description]" });
```

</workflows>

<quick_commands>

## Quick Commands

```bash
# Find unblocked P1 work
grep -l 'dependencies: \[\]' .claude/todos/*-ready-p1-*.md

# List pending items
ls .claude/todos/*-pending-*.md

# Check dependencies
grep "^dependencies:" .claude/todos/003-*.md

# Find what depends on issue 002
grep -l 'dependencies:.*"002"' .claude/todos/*.md
```

</quick_commands>

<when_to_use>

## When to Create Todo vs Act Immediately

**Create todo:** >15 min work, needs research, has dependencies, needs approval
**Act immediately:** <15 min, trivial fix, complete context available

</when_to_use>

<distinctions>

## Key Distinctions

- **file-todos (this)**: Markdown files in `.claude/todos/`, persisted
- **TodoWrite tool**: In-memory session tracking, not persisted
- **Database Todo model**: User-facing app feature, different system

</distinctions>

<related_skills>

- `troubleshooting` - Document solutions from investigations
- `git-conventions` - Link todos to PRs/issues

</related_skills>

<checklist>

- [ ] Issue ID is sequential
- [ ] Status matches filename prefix
- [ ] Priority documented (p1/p2/p3)
- [ ] All required sections present
- [ ] Dependencies tracked if blocked

</checklist>
