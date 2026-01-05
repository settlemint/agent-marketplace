# Agent Marketplace

SettleMint agent orchestration and development tools for Claude Code.

## Installation

**One-liner (all plugins):**

```bash
claude plugin marketplace add settlemint/agent-marketplace 2>/dev/null; \
claude plugin marketplace add anthropics/claude-plugins-official 2>/dev/null; \
claude plugin marketplace add sawyerhood/dev-browser 2>/dev/null; \
claude plugin marketplace update settlemint; \
claude plugin marketplace update claude-plugins-official; \
claude plugin marketplace update dev-browser-marketplace; \
claude plugin install crew@settlemint; \
claude plugin install devtools@settlemint; \
claude plugin install typescript-lsp@claude-plugins-official; \
claude plugin install frontend-design@claude-plugins-official; \
claude plugin install dev-browser@dev-browser-marketplace;
```

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

## Recommended Additional Plugins

For the best experience, add these complementary plugins:

```bash
claude plugin marketplace add anthropics/claude-plugins-official
claude plugin marketplace add sawyerhood/dev-browser
claude plugin install typescript-lsp@claude-plugins-official frontend-design@claude-plugins-official dev-browser@dev-browser-marketplace
```

Or add to your `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "claude-plugins-official": {
      "source": {
        "source": "github",
        "repo": "anthropics/claude-plugins-official"
      }
    },
    "dev-browser-marketplace": {
      "source": {
        "source": "github",
        "repo": "sawyerhood/dev-browser"
      }
    }
  },
  "enabledPlugins": {
    "typescript-lsp@claude-plugins-official": true,
    "dev-browser@dev-browser-marketplace": true,
    "frontend-design@claude-plugins-official": true
  }
}
```

| Plugin | Source | Purpose |
|--------|--------|---------|
| `typescript-lsp` | claude-plugins-official | TypeScript language server integration |
| `frontend-design` | claude-plugins-official | Frontend design assistance |
| `dev-browser` | dev-browser-marketplace | Browser automation for development |

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

### devtools

Modern development tools with MCP-first skills. Uses Context7 for up-to-date library documentation.

**Skills:**

| Skill | Domain | MCP Source |
|-------|--------|------------|
| `react` | React components, Tailwind, TanStack | Context7 |
| `tanstack-start` | Full-stack React framework | Context7 |
| `radix` | Accessible UI primitives | Context7 |
| `api` | oRPC API routes | OctoCode |
| `drizzle` | Drizzle ORM, PostgreSQL | Context7 |
| `zod` | Zod schemas | Context7 |
| `viem` | Ethereum blockchain client | Context7 |
| `solidity` | Smart contracts, Foundry | OctoCode |
| `vitest` | Unit testing | Context7 |
| `playwright` | E2E testing | Context7 |
| `thegraph` | TheGraph subgraphs | OctoCode |
| `helm` | Kubernetes Helm charts | OctoCode |
| `turbo` | Turborepo builds | Context7 |
| `restate` | Durable execution | OctoCode |
| `better-auth` | Authentication | OctoCode |
| `i18n` | Internationalization (i18next) | Context7 |
| `motion` | Animations (Motion/Framer) | Context7 |
| `recharts` | Data visualization | OctoCode |
| `pino` | Structured logging | OctoCode |
| `troubleshooting` | Debug patterns | - |

**Key feature:** Every skill fetches documentation from MCP before implementing, ensuring up-to-date API usage.

## Acknowledgments

This plugin builds on ideas and patterns from:

- [compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) - Knowledge compounding and session handoffs
- [ralph-wiggum](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/ralph-wiggum) - Iteration loop mechanics
- [gas town](https://github.com/steveyegge/gastown) - Agent orchestration

## License

MIT
