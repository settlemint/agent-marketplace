# Agent Marketplace

SettleMint agent orchestration and development tools for Claude Code.

## Installation

```bash
/plugin marketplace add settlemint/agent-marketplace
/plugin install crew@settlemint-marketplace
```

Or add to your project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "settlemint-marketplace": {
      "source": {
        "source": "github",
        "repo": "settlemint/agent-marketplace"
      }
    }
  },
  "enabledPlugins": {
    "crew@settlemint-marketplace": true
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

## License

MIT
