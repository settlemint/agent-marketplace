# SettleMint Agent Marketplace

Claude Code plugins for disciplined, structured software development workflows. Plan with rigor, build with TDD, commit with conventions.

## Quick Start

### 1. Install Plugins

```bash
curl -sL https://raw.githubusercontent.com/settlemint/agent-marketplace/main/setup.sh | bash
```

This installs:
- **plan-mode** - 7-phase structured planning with Linear integration
- **build-mode** - TDD-driven implementation with quality gates
- **git** - Conventional commits, smart branching, PR templates

### 2. Copy Settings

Copy the settings file to your project's `.claude` directory:

```bash
mkdir -p .claude
curl -sL https://raw.githubusercontent.com/settlemint/agent-marketplace/main/.claude/settings.json > .claude/settings.json
```

Or manually copy `.claude/settings.json` from this repository to your project.

## Overview

This marketplace provides three integrated plugins that work together:

| Plugin | Purpose | Key Features |
|--------|---------|--------------|
| **plan-mode** | Structured planning | 7-phase workflow, clarifying questions, 2-5 min tasks |
| **build-mode** | TDD implementation | Red-Green-Refactor, subagent reviewers, quality gates |
| **git** | Git automation | Conventional commits, branch naming, PR templates |

## Prerequisites

- **Claude Code CLI** - [Install from claude.ai/code](https://claude.ai/code)
- **GitHub CLI** - Run `gh auth login` for Octocode MCP features
- **Linear account** (optional) - For ticket integration during planning

## Typical Workflow

```bash
# 1. Plan your implementation
/plan "Add user authentication with OAuth"

# 2. Build with TDD
/build continue

# 3. Commit your changes
/commit

# 4. Create a PR
/pr
```

## Plugins

### Plan Mode (v2.3.3)

Structured planning with a 7-phase workflow:

1. **Context Gathering** - 4-phase codebase exploration
2. **Clarifying Questions** - One question at a time, resolve ambiguities
3. **Specification** - Six Core Areas checklist
4. **Architecture** - Trade-off evaluation, clean implementation
5. **Task Decomposition** - 2-5 minute tasks with parallelization markers
6. **Validation** - Confidence-based filtering (≥80% only)
7. **Documentation** - Linear ticket creation/update

**Commands:**
- `/plan [description]` - Start enhanced planning session

**MCP Servers:**
- **Octocode** - Semantic code research, LSP analysis, GitHub search
- **Context7** - Fetch latest package documentation
- **Linear** - Ticket management integration

### Build Mode (v1.1.1)

TDD-driven implementation with quality gates:

- **Red-Green-Refactor** cycle for all changes
- **Subagent orchestration** - Fresh context per task
- **Two-stage review** - Spec compliance, then quality
- **Visual testing** - Chrome MCP + Playwright
- **Evidence-based completion** - No claims without proof

**Commands:**
- `/build [task]` - Execute implementation with TDD
- `/fixup [PR#]` - Fix PR review comments and CI failures

**Agents:**
| Agent | Purpose |
|-------|---------|
| `task-implementer` | TDD implementation |
| `spec-reviewer` | Requirement verification |
| `quality-reviewer` | Code quality assessment |
| `silent-failure-hunter` | Error handling gaps |
| `visual-tester` | UI verification |
| `completion-validator` | Final gate |

### Git (v1.2.1)

Git workflow automation:

**Commands:**
| Command | Purpose |
|---------|---------|
| `/commit` | Conventional commit with selective staging |
| `/commit-push` | Commit and push in one step |
| `/branch` | Create branch: `username/type/slug` |
| `/pr` | Create PR with template body |
| `/update-pr` | Update PR title and body from commits |
| `/push` | Safe push with force-with-lease |
| `/sync` | Merge/rebase from main |
| `/clean-gone` | Remove deleted branches |

**Commit Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `refactor` - Code restructure
- `test` - Tests
- `chore` - Maintenance
- `perf` - Performance

## Configuration

The `settings.json` enables these key features:

```json
{
  "env": {
    "ENABLE_BACKGROUND_TASKS": "1",
    "FORCE_AUTO_BACKGROUND_TASKS": "1",
    "ENABLE_LSP_TOOLS": "1",
    "FORCE_AUTOUPDATE_PLUGINS": "1"
  },
  "permissions": {
    "defaultMode": "bypassPermissions"
  },
  "enableAllProjectMcpServers": true,
  "enabledPlugins": {
    "plan-mode@settlemint": true,
    "build-mode@settlemint": true,
    "git@settlemint": true
  }
}
```

| Setting | Purpose |
|---------|---------|
| `ENABLE_BACKGROUND_TASKS` | Run background operations |
| `ENABLE_LSP_TOOLS` | Code intelligence features |
| `enableAllProjectMcpServers` | Load MCP servers from plugins |
| `bypassPermissions` | Full autonomy for plugins |

## Manual Installation

If you prefer manual installation:

```bash
# Add the marketplace
claude plugin marketplace add settlemint/agent-marketplace

# Install individual plugins
claude plugin install plan-mode@settlemint
claude plugin install build-mode@settlemint
claude plugin install git@settlemint
```

## What setup.sh Does

The setup script:
1. Adds the SettleMint marketplace to Claude Code
2. Updates marketplace indices
3. Force-updates all plugins (uninstall + reinstall for latest versions)
4. Cleans up unauthorized plugins/marketplaces
5. Installs official Anthropic plugins (plugin-dev, typescript-lsp)

It can run:
- Directly via curl for initial setup
- As a SessionStart hook for automatic updates

## License

MIT
