# Agent Marketplace

SettleMint agent orchestration and development tools for Claude Code.

## Installation

```bash
/plugin marketplace add settlemint/agent-marketplace
/plugin install crew@settlemint
```

Or add to your project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "settlemint": {
      "source": {
        "source": "github",
        "repo": "settlemint/agent-marketplace"
      }
    }
  },
  "enabledPlugins": {
    "crew@settlemint": true
  }
}
```

## Plugins

### crew

Unified orchestration for work execution, skill creation, git conventions, and system management.

**Commands:**

| Command | Purpose |
|---------|---------|
| `/crew:design` | Create validated implementation plan |
| `/crew:build` | Execute work with progress tracking |
| `/crew:check` | Multi-agent code review + triage |
| `/crew:fix` | Repair skills, resolve blockers |

**Features:**
- Plan-driven development with progress tracking
- Session state preservation across compactions
- Iteration loops for autonomous completion
- Git commit and PR workflow validation
- Auto-linting on file modifications

## Acknowledgments

This plugin builds on ideas and patterns from:

- [compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) - Knowledge compounding and session handoffs
- [ralph-wiggum](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/ralph-wiggum) - Iteration loop mechanics

## License

MIT
