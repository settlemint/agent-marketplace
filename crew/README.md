# Crew Plugin

Unified orchestration for work execution, skill creation, git conventions, and system management.

## Commands

### Core Workflow

| Command      | Purpose                                                 |
| ------------ | ------------------------------------------------------- |
| `/crew:plan` | Create validated implementation plan from feature/issue |
| `/crew:work` | Execute plan with TodoWrite progress tracking           |
| `/crew:restore` | Show compacted session state details                |

### Git Operations

| Command                     | Purpose                             |
| --------------------------- | ----------------------------------- |
| `/crew:git:sync`            | Rebase on main + push + update PR   |
| `/crew:git:commit`          | Create conventional commit          |
| `/crew:git:commit-and-push` | Commit + push + update PR           |
| `/crew:git:push`            | Push to origin + update PR          |
| `/crew:git:branch:new`      | Create branch with username prefix  |
| `/crew:git:pr:create`       | Create pull request                 |
| `/crew:git:pr:fix-reviews`  | Resolve PR comments and CI failures |
| `/crew:git:clean`           | Clean up stale branches             |
| `/crew:git:undo`            | Undo last commit (keep changes)     |

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
/crew:plan        # Research and create implementation plan
/crew:work        # Execute the plan with progress tracking
/crew:check       # Multi-agent code review (7-leg)
/crew:git:pr:create      # Create pull request
/crew:git:pr:fix-reviews  # Address reviewer feedback
```

### Daily Git Sync

Keep your branch up-to-date with main and sync PR state:

```
/crew:git:sync    # Rebase on main + push + update PR
```

### Quick Commits

```
/crew:git:commit         # Create conventional commit
/crew:git:commit-and-push  # Commit + push + update PR
/crew:git:push           # Push + update PR
```

### Code Review

```
/crew:check              # Full 7-leg review (correctness, security, etc.)
/crew:git:pr:fix-reviews    # Resolve PR comments and CI failures
```

## Features

### Work Orchestration

- Plan-driven development with `/crew:plan`
- Progress tracking with TodoWrite integration
- Handoffs for context preservation across sessions

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
- Agent type detection (skip hooks for subagents since Claude Code 2.1.2)

### Token Saver / Quiet Mode

Reduce context usage on heavy days by setting env vars in `.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_TOKEN_SAVER": "1",
    "CREW_QUIET": "0",
    "CREW_TIPS": "0"
  }
}
```

Notes:
- `CLAUDE_TOKEN_SAVER=1` trims hook output.
- `CREW_QUIET=1` disables optional banners/tips.
- `CREW_TIPS=0` disables skill suggestions (`CREW_TIPS=all` shows every time).

### Auto-Update Behavior

Set `FORCE_AUTOUPDATE_PLUGINS=1` in `.claude/settings.json` to force plugin reinstall on every startup:

```json
{
  "env": {
    "FORCE_AUTOUPDATE_PLUGINS": "1"
  }
}
```

**When to use:**

- Developing plugin locally
- Testing latest marketplace versions
- Troubleshooting plugin issues

**Trade-off:** Adds ~2-5 seconds to startup time.

## Structure

```
crew/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── plan.md
│   ├── work.md
│   ├── check.md
│   └── git/
│       ├── branch/
│       │   ├── create.md
│       │   └── new.md
│       ├── pr/
│       │   ├── create.md
│       │   ├── fix-reviews.md
│       │   └── update.md
│       ├── commit.md
│       ├── commit-and-push.md
│       ├── push.md
│       ├── sync.md
│       ├── clean.md
│       └── undo.md
├── skills/
│   ├── git/
│   │   └── references/conventions.md
│   └── todo-tracking/
├── scripts/
│   └── git/
├── hooks/
│   └── hooks.json
└── README.md
```

## Recommended companion plugins

These plugins work well alongside crew:

- [frontend-design](https://github.com/anthropics/claude-code-plugins) - UI/UX design assistance
- [code-review](https://github.com/anthropics/claude-code-plugins) - Automated code review

## Acknowledgments

Some patterns in this plugin are inspired by or adapted from:

- [jarrodwatts/claude-code-config](https://github.com/jarrodwatts/claude-code-config) - Context engineering patterns (Manus-style planning), comment policy hooks, todo enforcement, and intent classification patterns
- [Manus context engineering principles](https://manus.im/de/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus) - Filesystem as external memory, attention manipulation, failure traces
- [shanev/skills](https://github.com/shanev/skills) - Decomplect (Rich Hickey simplicity, FCIS, coupling) and Unslopify (type strictness, SRP, fail-fast) code quality patterns

## License

MIT
