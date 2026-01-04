---
name: crew
description: Unified orchestration skill for work execution, skill creation, git conventions, and system management. Use for any multi-step task.
triggers:
  - "implement"
  - "build feature"
  - "create plan"
  - "review code"
  - "fix issues"
  - "create skill"
  - "new skill"
  - "commit"
  - "branch"
  - "\\bpr\\b"
  - "pull request"
  - "todo"
  - "agent.*native"
  - "prompt.*native"
---

<objective>

Your crew handles complex work autonomously across four domains:

**Work Orchestration:** `/design`, `/build`, `/check`, `/fix`
**Skill Creation:** Create, audit, and maintain skills
**Git Conventions:** Commits, branches, PRs
**System Management:** Todos, architecture, iteration loops

</objective>

<essential_principles>

## The Crew Philosophy

**Agents work, you orchestrate.** Spawn agents for heavy lifting, keep main thread light for decisions.

**State survives compaction.** All branch state lives in `.claude/branches/{branch}/state.json`.

**Handoffs are mandatory.** Every task completion creates a handoff. Knowledge persists.

**Iteration until done.** Use `crew:loop` for tasks with verifiable completion criteria.

</essential_principles>

<commands>

## User Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/design` | Create validated implementation plan | Starting new features |
| `/build` | Execute work with progress tracking | Implementing plans |
| `/check` | Multi-agent code review + triage | Before shipping |
| `/fix` | Repair skills, resolve blockers | System tuning |

</commands>

<routing>

## Task Routing

### Work Orchestration
Read `references/orchestration.md`, `references/iteration-loop.md`, `references/state-management.md`

### Skill Creation
| Task | Workflow |
|------|----------|
| Create new skill | `workflows/create-new-skill.md` |
| Audit existing skill | `workflows/audit-skill.md` |
| Add workflow to skill | `workflows/add-workflow.md` |
| Add reference to skill | `workflows/add-reference.md` |
| Upgrade to router | `workflows/upgrade-to-router.md` |

Reference: `references/skills/` (structure, patterns, templates)

### Architecture Patterns
Read from `references/architecture/`:
- `architecture-patterns.md` - Prompt-native design
- `mcp-tool-design.md` - MCP tool patterns
- `system-prompt-design.md` - System prompts
- `orchestrator-patterns.md` - Agent orchestration

### Git Conventions
Read `references/git/conventions.md`:
- Conventional commit format
- Branch naming
- PR workflow

Helper scripts: `scripts/gh-pr-*.sh`

### File Todos
Read `references/todos/file-todos.md`
Template: `templates/todo-template.md`

</routing>

<internal_workflows>

## Internal Workflows

| Workflow | Purpose |
|----------|---------|
| `loop.md` | Iteration loop for autonomous completion |
| `cancel-loop.md` | Graceful loop termination |
| `handoff.md` | Create context preservation documents |
| `compound.md` | Extract learnings into permanent knowledge |
| `triage.md` | Categorize and prioritize findings |
| `create-new-skill.md` | Create a new skill from scratch |
| `audit-skill.md` | Review and improve existing skill |

</internal_workflows>

<scripts>

## Scripts Organization

```
scripts/
├── hooks/           # Hook scripts (registered in settings.json)
│   ├── session-start/
│   ├── pre-compact/
│   ├── stop/
│   ├── pre-tool/
│   ├── post-tool/
│   └── lib/
├── git/             # Git helper scripts
│   ├── gh-pr-info.sh
│   ├── gh-pr-threads.sh
│   └── gh-pr-resolve-thread.sh
└── skills/          # Skill management scripts
    ├── init_skill.py
    ├── package_skill.py
    └── quick_validate.py
```

## Hook Scripts (`scripts/hooks/`)

| Hook | Script | Purpose |
|------|--------|---------|
| SessionStart | `session-start/restore-session-state.sh` | Recover state |
| PreCompact | `pre-compact/save-session-state.sh` | Persist state |
| Stop | `stop/check-loop.sh` | Manage loops |
| PostToolUse | `post-tool/lint-modified-file.sh` | Auto-lint |
| PreToolUse | `pre-tool/check-git-commit.sh` | Validate commits |

## Git Scripts (`scripts/git/`)

| Script | Purpose |
|--------|---------|
| `gh-pr-info.sh` | Get PR info for current branch |
| `gh-pr-threads.sh` | Get unresolved PR comments |
| `gh-pr-resolve-thread.sh` | Resolve a PR thread |

## Skill Scripts (`scripts/skills/`)

| Script | Purpose |
|--------|---------|
| `init_skill.py` | Initialize new skill structure |
| `package_skill.py` | Package skill for distribution |
| `quick_validate.py` | Validate skill structure |

</scripts>

<templates>

## Templates

| Template | Purpose |
|----------|---------|
| `simple-skill.md` | Basic skill structure |
| `router-skill.md` | Complex skill with routing |
| `todo-template.md` | File-based todo format |

</templates>

<references>

## Domain Knowledge

### Work Orchestration
- `orchestration.md` - Agent spawning patterns
- `iteration-loop.md` - Loop mechanics, completion promises
- `state-management.md` - Unified state format

### Skill Creation (`references/skills/`)
- `skill-structure.md` - SKILL.md format
- `core-principles.md` - Skill design principles
- `common-patterns.md` - Reusable patterns
- `native-ui-components.md` - UI integration

### Architecture (`references/architecture/`)
- `architecture-patterns.md` - Prompt-native design
- `mcp-tool-design.md` - MCP tool patterns
- `self-modification.md` - Self-modifying systems

### Git (`references/git/`)
- `conventions.md` - Commit format, branches, PRs

### Todos (`references/todos/`)
- `file-todos.md` - File-based todo tracking

</references>

<quick_start>

## Quick Start

```bash
# Plan and build a feature
/design "Add user authentication"
/build .claude/plans/user-auth.md

# Review and ship
/check
/fix "resolve review comments"

# Create a new skill
# → Routes to workflows/create-new-skill.md

# Git workflow
# → Routes to references/git/conventions.md
```

</quick_start>

<related_skills>

- `context7` - Fetch framework documentation
- `codex` - Deep reasoning delegation

</related_skills>
