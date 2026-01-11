---
name: phantom-mcp
description: Phantom MCP server for AI integration
---

<mcp_integration>

## Overview

Phantom provides an MCP (Model Context Protocol) server that enables AI assistants to manage Git worktrees programmatically.

## Installation

### Claude Code

```bash
claude mcp add --scope user Phantom phantom mcp serve
```

### VS Code (Copilot)

```bash
code --add-mcp '{"name": "Phantom", "command": "phantom", "args": ["mcp", "serve"], "transport": "stdio"}'
```

### Cursor

Add to `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "Phantom": {
      "command": "phantom",
      "args": ["mcp", "serve"],
      "transport": "stdio"
    }
  }
}
```

### Other AI Assistants

Start the server manually:

```bash
phantom mcp serve
```

## Available MCP Tools

### phantom_create_worktree

Create a new Git worktree.

**Parameters:**

| Parameter    | Type   | Required | Description                               |
| ------------ | ------ | -------- | ----------------------------------------- |
| `name`       | string | Yes      | Name for the worktree and branch          |
| `baseBranch` | string | No       | Branch to base on (default: current HEAD) |

**Example:**

```javascript
phantom_create_worktree({
  name: "feat/user-auth",
  baseBranch: "main",
});
```

### phantom_list_worktrees

List all existing worktrees.

**Parameters:** None

**Returns:** Array of worktree objects with name, path, and branch info.

**Example:**

```javascript
phantom_list_worktrees();
// Returns: [
//   { name: "feat-user-auth", path: "/path/to/worktree", branch: "feat/user-auth" },
//   ...
// ]
```

### phantom_delete_worktree

Remove a worktree and optionally its branch.

**Parameters:**

| Parameter | Type    | Required | Description                             |
| --------- | ------- | -------- | --------------------------------------- |
| `name`    | string  | Yes      | Name of the worktree to delete          |
| `force`   | boolean | No       | Force deletion with uncommitted changes |

**Example:**

```javascript
phantom_delete_worktree({
  name: "feat/completed-feature",
  force: false,
});
```

### phantom_github_checkout

Create a worktree from a GitHub issue or pull request.

**Parameters:**

| Parameter | Type   | Required | Description                                    |
| --------- | ------ | -------- | ---------------------------------------------- |
| `number`  | number | Yes      | GitHub issue or PR number                      |
| `base`    | string | No       | Base branch for issues (default: repo default) |

**Example:**

```javascript
// Checkout PR #123
phantom_github_checkout({ number: 123 });

// Checkout issue #456 with develop as base
phantom_github_checkout({ number: 456, base: "develop" });
```

## Use Cases

### Parallel Feature Development

AI can create isolated worktrees for different features:

```javascript
// Create worktrees for multiple features
phantom_create_worktree({ name: "feat/auth", baseBranch: "main" });
phantom_create_worktree({ name: "feat/dashboard", baseBranch: "main" });
phantom_create_worktree({ name: "feat/api", baseBranch: "main" });
```

### Testing Alternative Approaches

Create worktrees to test different implementation strategies:

```javascript
phantom_create_worktree({
  name: "experiment/approach-a",
  baseBranch: "feat/feature",
});
phantom_create_worktree({
  name: "experiment/approach-b",
  baseBranch: "feat/feature",
});
```

### PR Review Workflow

Checkout PRs for review without affecting current work:

```javascript
phantom_github_checkout({ number: 456 });
// Run tests, review code
phantom_delete_worktree({ name: "pr-456" });
```

### Progressive Feature Building

Build features incrementally with dependent worktrees:

```javascript
phantom_create_worktree({ name: "feat/base-types", baseBranch: "main" });
// ... implement base types ...
phantom_create_worktree({
  name: "feat/services",
  baseBranch: "feat/base-types",
});
// ... implement services using base types ...
```

## Integration with Crew Plugin

The crew plugin integrates Phantom MCP for autonomous worktree management:

```json
// In crew/.mcp.json
{
  "mcpServers": {
    "Phantom": {
      "command": "phantom",
      "args": ["mcp", "serve"],
      "transport": "stdio"
    }
  }
}
```

This enables:

- `/crew:plan` to create worktrees for feature isolation
- `/crew:work` to execute in isolated environments
- Background agents to work in separate worktrees

</mcp_integration>
