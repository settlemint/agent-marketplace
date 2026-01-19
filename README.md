# Agent Marketplace

SettleMint development tools for Claude Code.

## Philosophy

Claude is smart. It has excellent built-in capabilities for planning, coding, and problem-solving. These plugins don't replace Claude's intelligence—they enhance it.

**Our approach:**

- **Hooks enhance built-in capabilities** — We use hooks to add smart logic on top of Claude's native features, getting the best of both worlds
- **Let Claude decide** — When in doubt, we trust Claude's judgment rather than enforcing rigid rules
- **Learn and improve** — Important events are logged to `.claude/` for analysis, generating learnings that feed back into plugin improvements

## Developer Workflow

After installing the plugins, the typical development flow is:

```
/plan              → Use Claude's built-in plan mode
                   → Review and accept the plan
                   → Claude implements the changes
/pr                → Create a pull request
/fix-pr-reviews    → Address reviewer feedback
```

## Installation

**One-line setup (recommended):**

```bash
curl -fsSL https://raw.githubusercontent.com/settlemint/agent-marketplace/main/setup.sh | bash
```

This installs dependencies, configures marketplaces, and installs the full plugin suite.

**Interactive (inside Claude Code):**

```bash
/plugin marketplace add settlemint/agent-marketplace
/plugin install devtools@settlemint
/plugin install flow@settlemint
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

**Slash Commands:**

| Command | Description |
|---------|-------------|
| `/commit` | Create a conventional commit |
| `/branch` | Create a feature branch |
| `/pr` | Create a pull request |
| `/push` | Push with smart QA check |
| `/sync` | Sync branch with main |

**Skills:**

| Skill | Domain | MCP Source |
|-------|--------|------------|
| `react` | React 19 components, Tailwind v4 | Context7 |
| `tanstack-start` | Full-stack React framework | Context7 |
| `radix` | Accessible UI primitives | Context7 |
| `shadcn` | shadcn/ui components | Shadcn MCP |
| `api` | oRPC API routes | OctoCode |
| `drizzle` | Drizzle ORM, PostgreSQL | Context7 |
| `zod` | Zod v4 schemas | Context7 |
| `viem` | Ethereum blockchain client | Context7 |
| `solidity` | Smart contracts, Foundry | OctoCode |
| `vitest` | Unit testing | Context7 |
| `playwright` | E2E testing | Playwright MCP |
| `thegraph` | TheGraph subgraphs | OctoCode |
| `helm` | Kubernetes Helm charts | OctoCode |
| `turbo` | Turborepo builds | Context7 |
| `restate` | Durable execution | Restate MCP |
| `better-auth` | Authentication | OctoCode |
| `i18n` | Internationalization (i18next) | Context7 |
| `motion` | Animations (Motion/Framer) | Context7 |
| `recharts` | Data visualization | OctoCode |
| `pino` | Structured logging | OctoCode |
| `terraform` | Infrastructure as code | - |
| `tdd-typescript` | Test-driven development | - |
| `troubleshooting` | Debug patterns | - |
| `chrome-testing` | Chrome browser testing | Chrome MCP |
| `ast-grep` | Mass rename/replace | - |
| `code-health` | Code health audit | - |
| `codex-patterns` | Deep code reasoning | Codex MCP |
| `design-principles` | Linear/Notion/Stripe design | - |
| `react-best-practices` | React/Next.js performance | - |
| `rule-of-five` | Multi-pass convergence | - |
| `typescript-lsp` | LSP code navigation | - |
| `vercel-design-guidelines` | UI review | - |

### flow

Hook-based workflow automation that enhances Claude's native capabilities.

**Slash Commands:**

| Command | Description |
|---------|-------------|
| `/fix-pr-reviews` | Fix PR review comments and resolve threads |

**Skills:**

| Skill | Description |
|-------|-------------|
| `init-enhanced` | Deep codebase analysis with progressive disclosure docs |
| `fix-pr-reviews` | Address reviewer feedback with educational responses |

**Hooks:**

The flow plugin uses hooks to enhance Claude's behavior without replacing it. Hooks fire on specific events and add context or trigger actions.

## Configuration

### Environment Variables

Configure in `.claude/settings.json` under the `env` key:

| Variable | Values | Default | Purpose |
|----------|--------|---------|---------|
| `FORCE_AUTOUPDATE_PLUGINS` | `"1"` / `"0"` | Disabled | Force reinstall all plugins on startup |

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
