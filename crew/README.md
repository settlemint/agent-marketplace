# Crew Plugin

Unified orchestration for work execution, skill creation, git conventions, and system management.

## Commands

| Command | Purpose | Usage |
|---------|---------|-------|
| `/crew:design` | Create validated implementation plan | Starting new features |
| `/crew:build` | Execute work with progress tracking | Implementing plans |
| `/crew:check` | Multi-agent code review + triage | Before shipping |
| `/crew:fix` | Repair skills, resolve blockers | System tuning |

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

## License

MIT
