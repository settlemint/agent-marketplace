# Crew Plugin

Unified orchestration for work execution, skill creation, git conventions, and system management.

## Commands

### Core Workflow

| Command        | Purpose                                                 |
| -------------- | ------------------------------------------------------- |
| `/crew:design` | Create validated implementation plan from feature/issue |
| `/crew:build`  | Execute plan with TodoWrite progress tracking           |
| `/crew:check`  | Multi-agent 7-leg code review with triage               |
| `/crew:fix`    | Repair skills, resolve blockers                         |

### Git Operations

| Command                     | Purpose                                  |
| --------------------------- | ---------------------------------------- |
| `/crew:git:sync`            | Rebase on main/parent + push + update PR |
| `/crew:git:commit`          | Create conventional commit               |
| `/crew:git:commit-and-push` | Commit + push + update PR                |
| `/crew:git:push`            | Push to origin + update PR               |
| `/crew:git:pr`              | Create pull request                      |
| `/crew:git:fix-reviews`     | Resolve PR comments and CI failures      |

### Stacked PRs (git-machete)

| Command                  | Purpose                                  |
| ------------------------ | ---------------------------------------- |
| `/crew:git:branch`       | Create feature branch from main          |
| `/crew:git:stack-add`    | Add branch to machete stack              |
| `/crew:git:stack-status` | Show branch stack with visual indicators |
| `/crew:git:go`           | Navigate between branches in stack       |
| `/crew:git:traverse`     | Sync entire stack with parents/remotes   |
| `/crew:git:slide-out`    | Remove merged branches, update child PRs |
| `/crew:git:retarget-pr`  | Change PR base to match machete parent   |
| `/crew:git:restack-pr`   | Retarget + force push after rebase       |
| `/crew:git:advance`      | Fast-forward merge child into current    |

### Code Review

| Command           | Purpose                                        |
| ----------------- | ---------------------------------------------- |
| `/crew:check`     | Multi-agent 7-leg code review                  |
| `/crew:review-pr` | Review external PR with GitHub comment posting |

## Installation

Add the marketplace to your Claude Code settings:

```json
{
  "extraKnownMarketplaces": {
    "agent-marketplace": {
      "source": {
        "source": "local",
        "path": "~/Development/agent-marketplace"
      }
    }
  },
  "enabledPlugins": {
    "crew@agent-marketplace": true
  }
}
```

Or use a local plugin directory:

```bash
claude --plugin-dir ~/Development/agent-marketplace/crew
```

## Standard Workflows

### Feature Development

The standard flow for implementing new features or addressing issues:

```
/crew:design      # Research and create implementation plan
/crew:build       # Execute the plan with progress tracking
/crew:check       # Multi-agent code review (7-leg)
/crew:git:pr      # Create pull request
/crew:git:fix-reviews  # Address reviewer feedback
```

### Daily Git Sync

Keep your branch up-to-date with main and sync PR state:

```
/crew:git:sync    # Rebase on main/parent + push + update PR
```

For stacked branches (git-machete):

```
/crew:git:traverse   # Sync entire stack with parents and remotes
/crew:git:slide-out  # Remove merged branches and update child PRs
```

### Quick Commits

```
/crew:git:commit         # Create conventional commit
/crew:git:commit-and-push  # Commit + push + update PR
/crew:git:push           # Push + update PR
```

### Stacked PRs

```
/crew:git:branch         # Create feature branch from main
/crew:git:stack-add      # Add branch to machete stack
/crew:git:pr             # Create PR with stack annotations
/crew:git:retarget-pr    # Change PR base to match machete parent
/crew:git:restack-pr     # Retarget + force push after rebase
/crew:git:go down        # Navigate to child branch in stack
```

### Worktrees + Stacked PRs

**Recommended pattern: One worktree per stack**

```
main-checkout/          # Stack A: feat/auth → feat/auth-ui → feat/auth-tests
worktree-payments/      # Stack B: feat/payments (independent feature)
worktree-hotfix/        # Stack C: fix/critical (independent bugfix)
```

**Why this works:**

- Stacked PRs are sequential (depend on each other) → work naturally with machete
- Worktrees isolate independent work → no context switching between unrelated features
- Each worktree can use full machete commands (`traverse`, `go`) within its stack

**Navigation within a stack:**

```
/crew:git:go up          # Go to parent branch
/crew:git:go down        # Go to child branch
/crew:git:go next        # Go to sibling branch
```

The machete context automatically suggests next steps:

- ✅ **PR approved** → suggests moving to child branch
- ⏳ **PR open** → can continue on child while awaiting review
- 🔀 **PR merged** → suggests slide-out then move to child

**Safety detection:**

- Single stack in worktree → all machete commands work normally
- Multi-stack layout shared → warns about cross-stack navigation

### Code Review

```
/crew:check              # Full 7-leg review (correctness, security, etc.)
/crew:git:fix-reviews    # Resolve PR comments and CI failures
```

## Features

### Work Orchestration

- Plan-driven development with `/crew:design`
- Progress tracking with TodoWrite integration
- Handoffs for context preservation across sessions
- Iteration loops for autonomous completion

### Skill Management

- Create new skills with guided workflows
- Audit and improve existing skills
- Templates for common skill patterns

### Git Conventions

- Conventional commit format enforcement
- Branch naming standards
- PR workflow automation

### Hooks

- Session state recovery on startup/resume
- Auto-lint on file modifications
- Git commit validation (requires CI pass)
- PR creation validation

## Structure

```
crew/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── design.md
│   ├── build.md
│   ├── check.md
│   └── fix.md
├── skills/
│   └── crew/
│       ├── SKILL.md
│       ├── references/
│       ├── templates/
│       ├── workflows/
│       └── scripts/
├── hooks/
│   └── hooks.json
└── README.md
```

## Recommended companion plugins

These plugins work well alongside crew:

- [ralph-loop](https://github.com/anthropics/claude-code-plugins) - Persistent iteration loops with custom prompts
- [frontend-design](https://github.com/anthropics/claude-code-plugins) - UI/UX design assistance
- [code-review](https://github.com/anthropics/claude-code-plugins) - Automated code review

## Acknowledgments

Some patterns in this plugin are inspired by or adapted from:

- [jarrodwatts/claude-code-config](https://github.com/jarrodwatts/claude-code-config) - Context engineering patterns (Manus-style planning), comment policy hooks, todo enforcement, and intent classification patterns
- [Manus context engineering principles](https://manus.im/de/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus) - Filesystem as external memory, attention manipulation, failure traces
- [shanev/skills](https://github.com/shanev/skills) - Decomplect (Rich Hickey simplicity, FCIS, coupling) and Unslopify (type strictness, SRP, fail-fast) code quality patterns

## License

MIT
