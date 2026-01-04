# Agent-Native Infrastructure

This skill provides infrastructure for agent-native development.

## Discovery Scripts (`scripts/discovery/`)

| Script                 | Purpose                                    |
| ---------------------- | ------------------------------------------ |
| `list-agents.sh`       | List all agents with metadata              |
| `list-skills.sh`       | List skills with triggers and dependencies |
| `list-commands.sh`     | List available slash commands              |
| `list-mcp-tools.sh`    | List MCP server configurations             |
| `dependency-graph.sh`  | Generate skill dependency graph            |
| `validate-triggers.sh` | Validate skill trigger patterns            |

## Dynamic Context Detection

Skills declare their triggers in frontmatter:

```yaml
triggers: ["pattern1", "pattern2"]
depends_on: ["other-skill"]
```

The `detect-context-dynamic.sh` script reads these at runtime - no hardcoded patterns.

## CRUD Commands (`/context:*`)

| Command                   | Purpose                  |
| ------------------------- | ------------------------ |
| `/context:delete-skill`   | Delete with confirmation |
| `/context:archive-skill`  | Move to archive          |
| `/context:restore-skill`  | Restore from archive     |
| `/context:list-archived`  | View archived items      |
| `/context:delete-agent`   | Delete an agent          |
| `/context:archive-agent`  | Archive an agent         |
| `/context:restore-agent`  | Restore an agent         |
| `/context:delete-command` | Delete a command         |
| `/context:rollback`       | Rollback recent changes  |

## Debug Commands (`/debug:*`)

| Command                    | Purpose                      |
| -------------------------- | ---------------------------- |
| `/debug:session-state`     | View current session state   |
| `/debug:clear-session`     | Reset session state          |
| `/debug:hook-history`      | View hook execution history  |
| `/debug:audit-log`         | View .claude/ modifications  |
| `/debug:dependency-graph`  | Visualize skill dependencies |
| `/debug:validate-triggers` | Validate trigger patterns    |

## Hook System

Hooks are configured in `.claude/settings.json`:

| Hook Type        | Purpose                       |
| ---------------- | ----------------------------- |
| SessionStart     | Run on session initialization |
| UserPromptSubmit | Run when user submits prompt  |
| PreToolUse       | Run before tool execution     |
| PostToolUse      | Run after tool execution      |
| PreCompact       | Run before context compaction |

### Hook Feedback

Hooks can output feedback that requires action:

| Prefix             | Meaning                                         |
| ------------------ | ----------------------------------------------- |
| `STOP:`            | PreToolUse - blocks the action                  |
| `ACTION REQUIRED:` | PostToolUse - must fix issues before continuing |
| `CONTEXT:`         | Informational guidance                          |
| `AUDIT:`           | Tracking notification                           |
| `LINT:`            | Linting results (may need attention)            |

**Critical:** When you see `ACTION REQUIRED:`, you must address the issue immediately before continuing with other work.

## Sub-Agent Warning

`AskUserQuestion` calls from sub-agents trigger a warning - the UI won't display properly.
