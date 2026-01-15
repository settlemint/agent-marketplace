# Agent Marketplace

SettleMint development tools for Claude Code.

## Installation

**Interactive (inside Claude Code):**

```bash
/plugin marketplace add settlemint/agent-marketplace
/plugin install devtools@settlemint
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
    "devtools@settlemint": true,
    "flow@settlemint": true
  }
}
```

## Plugins

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

## License

MIT
