#!/usr/bin/env bash
# Inject available crew skills and commands at session start
# Helps Claude know what tools are available
#
# AGENT_TYPE DETECTION (Claude Code 2.1.2+):
# Subagents (task, background, etc.) get no output to reduce context noise

set +e

# Read stdin to get hook input (includes agent_type since v2.1.2)
INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // ""' 2>/dev/null)
AGENT_TYPE="${AGENT_TYPE:-}"

# Skip output for subagents - they have specific missions and don't need the full banner
# Known subagent types: task, background, Bash, Explore, Plan, haiku, general-purpose
if [[ -n "$AGENT_TYPE" && "$AGENT_TYPE" != "null" ]]; then
	# Any non-empty agent_type means this is a subagent, skip output
	exit 0
fi

cat <<'EOF'
## Crew Plugin - Available Commands & Skills

### Slash Commands
| Command | Purpose |
|---------|---------|
| `/crew:plan` | Create implementation plans with research |
| `/crew:work` | Execute plans with Ralph Loop for completion |
| `/crew:work:ci` | Run CI in background haiku agent |
| `/crew:git:commit` | Guided commit with context |
| `/crew:git:pr:create` | Create PR with template |
| `/crew:git:branch:new` | Create feature branch |
| `/crew:git:sync` | Sync branch with main |

### Skills - Crew Plugin (auto-loaded by triggers)
| Skill | Triggers | Purpose |
|-------|----------|---------|
| ast-grep | rename, replace, refactor, imports | AST-aware code search & refactor |
| git | commit, branch, pr | Git conventions and workflows |
| skill-builder | skill, create skill | Skill creation framework |
| todo-tracking | todo, task | File-based task management |

### Skills - Devtools Plugin (auto-loaded by triggers)
| Skill | Triggers | Purpose |
|-------|----------|---------|
| react | .tsx, component, tailwind, tanstack | React 19 + Tailwind CSS v4 + shadcn |
| shadcn | shadcn, components/ui, cn() | shadcn/ui components via MCP |
| drizzle | drizzle, pgTable, db.select | Drizzle ORM for PostgreSQL |
| vitest | vitest, describe, it, expect | Unit testing patterns |
| playwright | playwright, e2e, getByRole | E2E testing with Page Objects |
| tdd-typescript | implement, add feature | RED-GREEN-REFACTOR workflow |
| solidity | .sol, contract, forge | Smart contracts with Foundry |
| viem | viem, publicClient, walletClient | Ethereum client interactions |
| tanstack-start | createFileRoute, loader | Full-stack React framework |
| troubleshooting | help debug, troubleshoot | Structured debugging workflow |

### LSP Features (typescript-lsp plugin)
When working with TypeScript/JavaScript files, you have LSP capabilities:
- **Go to definition**: Find where symbols are defined
- **Find references**: Find all usages of a symbol
- **Error checking**: Real-time type errors and diagnostics

### Code Simplifier Agent (code-simplifier plugin)
Use Task tool with subagent_type="code-simplifier" to refine recently modified code:
- Simplifies code for clarity, consistency, and maintainability
- Preserves all functionality while improving structure
- Applies project-specific standards from CLAUDE.md

### Browser Validation (Claude-in-Chrome)
Use native browser tools (mcp__claude-in-chrome__*) to validate your work:
- **After UI changes**: Take screenshots to verify implementation
- **During debugging**: Read console logs, inspect network requests
- **For testing**: Navigate user flows to verify functionality
Load tools via MCPSearch before use: `MCPSearch({ query: "select:mcp__claude-in-chrome__navigate" })`

### Best Practices
- **Git commits**: Use conventional format `type(scope): description`
- **CI checks**: Use Skill(skill: "crew:work:ci") to run in background (keeps main thread free)
- **Code refactoring**: Use Skill(skill: "crew:ast-grep") for mass rename/replace (NOT grep+sed)
- **Planning**: Use Skill(skill: "crew:plan") before implementing complex features
- **Progress**: Use TodoWrite to track multi-step tasks
- **Validate work**: Use browser tools to verify UI changes and debug issues
EOF

exit 0
