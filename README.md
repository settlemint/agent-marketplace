# Agent Marketplace

SettleMint agent orchestration and development tools for Claude Code.

## Installation

**One-liner (recommended):**

```bash
curl -fsSL https://raw.githubusercontent.com/settlemint/agent-marketplace/main/crew/scripts/hooks/session-start/setup-plugins.sh | bash
```

This installs all recommended plugins with status notifications:

- SettleMint crew & devtools
- Dev Browser automation

**Core plugin only:**

```bash
claude plugin marketplace add settlemint/agent-marketplace
claude plugin install crew@settlemint
```

**Interactive (inside Claude Code):**

```bash
/plugin marketplace add settlemint/agent-marketplace
/plugin install crew@settlemint
```

**Or add to your project's `.claude/settings.json`:**

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
    "crew@settlemint": true,
    "devtools@settlemint": true
  }
}
```

## Browser Automation

Claude Code has native browser automation via the `mcp__claude-in-chrome__*` tools when the Claude-in-Chrome extension is installed. Use these tools to:

- **Validate UI changes**: Take screenshots and compare implementations
- **Debug issues**: Inspect page content, console logs, network requests
- **Test workflows**: Navigate through user flows to verify functionality
- **Explore documentation**: Fetch and analyze web content

The browser tools are automatically available when the extension is active. Use `MCPSearch` to load specific tools before calling them.

## Plugins

### crew

Unified orchestration for work execution, skill creation, git conventions, and system management.

**Commands:**

| Command                     | Alias                   | Purpose                                   |
| --------------------------- | ----------------------- | ----------------------------------------- |
| `/crew:design`              |                         | Create validated implementation plan      |
| `/crew:build`               |                         | Execute work with progress tracking       |
| `/crew:check`               |                         | Multi-agent code review + triage          |
| `/crew:restart`             |                         | Resume pending work from previous session |
| `/crew:skill:fix`           | `/crew:fix`             | Repair skills, resolve blockers           |
| `/crew:git:commit`          | `/crew:commit`          | Create conventional commit                |
| `/crew:git:push`            | `/crew:push`            | Push current branch to origin             |
| `/crew:git:commit-and-push` | `/crew:commit-and-push` | Commit and push in one step               |
| `/crew:git:branch`          | `/crew:branch`          | Create feature branch from main           |
| `/crew:git:pr`              | `/crew:pr`              | Commit, push, and open PR                 |
| `/crew:git:sync`            | `/crew:sync`            | Sync current branch with main             |
| `/crew:git:undo`            | `/crew:undo`            | Undo last commit (keeps changes)          |
| `/crew:git:clean`           | `/crew:clean`           | Clean up stale branches                   |
| `/crew:ci`                  |                         | Run CI checks via background haiku agent  |

**Features:**

- Plan-driven development with progress tracking
- Session state preservation across compactions
- Iteration loops for autonomous completion
- Git commit and PR workflow validation
- Auto-linting on file modifications

### devtools

Modern development tools with MCP-first skills. Uses Context7 for up-to-date library documentation.

**Skills:**

| Skill             | Domain                               | MCP Source |
| ----------------- | ------------------------------------ | ---------- |
| `react`           | React components, Tailwind, TanStack | Context7   |
| `tanstack-start`  | Full-stack React framework           | Context7   |
| `radix`           | Accessible UI primitives             | Context7   |
| `api`             | oRPC API routes                      | OctoCode   |
| `drizzle`         | Drizzle ORM, PostgreSQL              | Context7   |
| `zod`             | Zod schemas                          | Context7   |
| `viem`            | Ethereum blockchain client           | Context7   |
| `solidity`        | Smart contracts, Foundry             | OctoCode   |
| `vitest`          | Unit testing                         | Context7   |
| `playwright`      | E2E testing                          | Context7   |
| `thegraph`        | TheGraph subgraphs                   | OctoCode   |
| `helm`            | Kubernetes Helm charts               | OctoCode   |
| `turbo`           | Turborepo builds                     | Context7   |
| `restate`         | Durable execution                    | OctoCode   |
| `better-auth`     | Authentication                       | OctoCode   |
| `i18n`            | Internationalization (i18next)       | Context7   |
| `motion`          | Animations (Motion/Framer)           | Context7   |
| `recharts`        | Data visualization                   | OctoCode   |
| `pino`            | Structured logging                   | OctoCode   |
| `troubleshooting` | Debug patterns                       | -          |

**Key feature:** Every skill fetches documentation from MCP before implementing, ensuring up-to-date API usage.

## Configuration

### Environment Variables

Configure in `.claude/settings.json` under the `env` key:

| Variable                   | Values        | Default  | Purpose                                                                                           |
| -------------------------- | ------------- | -------- | ------------------------------------------------------------------------------------------------- |
| `FORCE_AUTOUPDATE_PLUGINS` | `"1"` / `"0"` | Disabled | Force reinstall all plugins on every startup. Useful for development. Adds ~2-5s to startup time. |

Example:

```json
{
  "env": {
    "FORCE_AUTOUPDATE_PLUGINS": "1"
  }
}
```

## Acknowledgments

This plugin builds on ideas and patterns from:

- [compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) - Knowledge compounding and session handoffs
- [ralph-wiggum](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/ralph-wiggum) - Iteration loop mechanics
- [gas town](https://github.com/steveyegge/gastown) - Agent orchestration

## License

MIT
