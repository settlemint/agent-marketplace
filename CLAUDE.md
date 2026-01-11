# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

This is a Claude Code plugin marketplace repository. It contains the `crew` plugin - an orchestration system for work execution, skill management, and git workflows. This is NOT a traditional application with build/test pipelines.

## TDD Required (MANDATORY)

**ALL code changes MUST follow Test-Driven Development. NO EXCEPTIONS.**

### Before Writing ANY Implementation Code

```javascript
// Load the TDD skill FIRST
Skill({ skill: "devtools:tdd-typescript" })
```

### RED-GREEN-REFACTOR Cycle

| Phase | Action | Verification |
|-------|--------|--------------|
| **RED** | Write failing test FIRST | `bun run test` - MUST fail |
| **GREEN** | Write minimal code | `bun run test` - MUST pass |
| **REFACTOR** | Improve while green | `bun run test` - STILL pass |

### Coverage Requirements (Non-Negotiable)

- Line coverage: **80% minimum**
- Branch coverage: **75% minimum**
- Function coverage: **90% minimum**
- Critical paths: **100%**

### The Three Laws

1. Write NO production code until a failing test exists
2. Write ONLY enough test to demonstrate failure
3. Write ONLY enough code to pass the test

**Hooks enforce TDD on every Edit/Write operation. Follow the workflow.**

## Plugin Structure

```
crew/
├── .claude-plugin/plugin.json    # Plugin metadata
├── commands/                     # Slash commands (/crew:design, /crew:build, etc.)
│   ├── design.md                 # Create implementation plans
│   ├── build.md                  # Execute work with tracking
│   ├── check.md                  # Multi-agent code review
│   ├── fix.md                    # Resolve blockers
│   └── git/                      # Git workflow commands
├── skills/                       # Domain expertise modules
│   ├── agent-architecture/       # Agent patterns, loops, state
│   ├── skill-builder/            # Skill creation framework
│   ├── git/                      # Git conventions
│   ├── mcp/                      # MCP server integration
│   └── todo-tracking/            # File-based task management
├── scripts/                      # Shell/Python automation
│   ├── git/                      # Git helper scripts
│   ├── hooks/                    # Lifecycle hook implementations
│   └── skills/                   # Skill utilities (Python)
├── hooks/hooks.json              # Claude hook definitions
└── .mcp.json                     # MCP server configuration
```

## Architecture Concepts

### Commands (4-Phase Pattern)

- `/crew:design` - Research and create plan in `.claude/plans/<slug>.md`
- `/crew:build` - Execute plan with TodoWrite progress tracking
- `/crew:check` - Multi-agent review, triage findings by severity (P1/P2/P3)
- `/crew:fix` - Repair skills, resolve PR comments, run CI validation

### Skills

Self-contained knowledge modules with:

- YAML frontmatter (name, description, triggers)
- XML semantic structure (no markdown headings in body)
- Required tags: `<objective>`, `<quick_start>`, `<success_criteria>`
- Optional: `<routing>`, `<workflow>`, `<references>`, `<templates>`, `<scripts>`

### State Management

- Branch state: `.claude/branches/{branch}/state.json`
- Session state: Saved on compaction, restored on resume
- Plans stored in: `.claude/plans/`

### Hooks

Lifecycle automation (non-blocking):

- `SessionStart` - Restore state on startup, check available linters
- `PreCompact` - Save state before compaction
- `PreToolUse` - Suggest relevant skills (e.g., /crew:ci for test commands)
- `PostToolUse` - Auto-lint on file edits, sync machete stack, track agents
- `Stop` - Check for agent loops

### MCP Servers

Configured in `crew/.mcp.json`:

- **Context7** - Library documentation lookup
- **OctoCode** - GitHub repository search
- **Codex** - Deep reasoning/code analysis

## Installation Methods

```bash
# Via marketplace
/plugin marketplace add settlemint/agent-marketplace
/plugin install crew@settlemint

# Local development
claude --plugin-dir ~/Development/agent-marketplace/crew
```

## Shell Script Quality

When modifying any `.sh` file, always run:

```bash
shfmt -w -i 2 -ci <file>   # Format with 2-space indent
shellcheck <file>           # Lint for issues
```

## Git Conventions

- **Commits**: Conventional format `type(scope): description`
- **Branches**: `<type>/<short-description>` from main
- **Protected files**: `.env`, `.pem`, `.key`, credentials, secrets

## Version Bumping (MANDATORY)

**Every commit MUST include a version bump in the affected plugin's `plugin.json`.**

| Plugin   | Manifest                              |
| -------- | ------------------------------------- |
| crew     | `crew/.claude-plugin/plugin.json`     |
| devtools | `devtools/.claude-plugin/plugin.json` |

```bash
# Before committing, update the version in ALL affected plugins:
# patch: 1.1.0 → 1.1.1 (bug fixes)
# minor: 1.1.0 → 1.2.0 (new features)
# major: 1.1.0 → 2.0.0 (breaking changes)
```

This ensures users get the latest changes when the plugin syncs from the marketplace.

## Key Files

| File                              | Purpose                 |
| --------------------------------- | ----------------------- |
| `crew/.claude-plugin/plugin.json` | Plugin metadata         |
| `crew/hooks/hooks.json`           | Hook definitions        |
| `crew/.mcp.json`                  | MCP server config       |
| `.claude/settings.json`           | Project Claude settings |
| `.claude-plugin/marketplace.json` | Marketplace registry    |
