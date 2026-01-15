# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

This is a Claude Code plugin marketplace repository. It contains the `devtools` and `flow` plugins for development tools and workflow automation. This is NOT a traditional application with build/test pipelines.

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

## Plugin Structure

```
devtools/
├── .claude-plugin/plugin.json    # Plugin metadata
├── .mcp.json                     # MCP server configuration
└── skills/                       # Domain expertise modules

flow/
├── .claude-plugin/plugin.json    # Plugin metadata
├── skills/                       # Workflow skills
├── scripts/                      # Hook implementations
└── hooks/hooks.json              # Hook definitions
```

## Skills

Self-contained knowledge modules with:

- YAML frontmatter (name, description, triggers)
- XML semantic structure (no markdown headings in body)
- Required tags: `<objective>`, `<quick_start>`, `<success_criteria>`
- Optional: `<routing>`, `<workflow>`, `<references>`, `<templates>`, `<scripts>`

**Skill Reference Format (MANDATORY):** When referencing skills in documentation, always use the `Skill()` call format:

```javascript
// Correct - executable format
Skill({ skill: "devtools:react-best-practices" })

// Wrong - plain text reference
Load `devtools:react-best-practices`
```

This ensures skills can be loaded programmatically when users follow the documentation.

## MCP Servers

Configured in `devtools/.mcp.json`:

- **Context7** - Library documentation lookup
- **OctoCode** - GitHub repository search
- **Codex** - Deep reasoning/code analysis
- **Shadcn** - shadcn/ui component integration
- **Playwright** - E2E testing support

## Installation Methods

```bash
# Via marketplace
/plugin marketplace add settlemint/agent-marketplace
/plugin install devtools@settlemint

# Local development
claude --plugin-dir ~/Development/agent-marketplace/devtools
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
| devtools | `devtools/.claude-plugin/plugin.json` |
| flow     | `flow/.claude-plugin/plugin.json`     |

```bash
# Before committing, update the version in ALL affected plugins:
# patch: 1.1.0 → 1.1.1 (bug fixes)
# minor: 1.1.0 → 1.2.0 (new features)
# major: 1.1.0 → 2.0.0 (breaking changes)
```

This ensures users get the latest changes when the plugin syncs from the marketplace.

## Key Files

| File                                 | Purpose                 |
| ------------------------------------ | ----------------------- |
| `devtools/.claude-plugin/plugin.json`| Plugin metadata         |
| `devtools/.mcp.json`                 | MCP server config       |
| `flow/.claude-plugin/plugin.json`    | Plugin metadata         |
| `flow/hooks/hooks.json`              | Hook definitions        |
| `.claude/settings.json`              | Project Claude settings |
| `.claude-plugin/marketplace.json`    | Marketplace registry    |
