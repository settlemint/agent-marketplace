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
