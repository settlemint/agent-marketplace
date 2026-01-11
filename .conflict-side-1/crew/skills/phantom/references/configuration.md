---
name: phantom-configuration
description: Configuration options for Phantom CLI
---

<configuration>

## Global Preferences (Git Config)

Phantom stores preferences in Git's global config under `phantom.*` namespace.

```bash
# View all phantom preferences
git config --global --get-regexp '^phantom\.'

# Set a preference
phantom preferences set <key> <value>

# Get a preference
phantom preferences get <key>

# Remove a preference
phantom preferences remove <key>
```

### Available Preferences

| Key                  | Description           | Default                  | Example                |
| -------------------- | --------------------- | ------------------------ | ---------------------- |
| `editor`             | Editor command        | `$EDITOR`                | `code --reuse-window`  |
| `ai`                 | AI assistant command  | (none)                   | `claude`               |
| `worktreesDirectory` | Worktree storage path | `.git/phantom/worktrees` | `../phantom-worktrees` |

### Recommended Setup

```bash
# Use VS Code with window reuse
phantom preferences set editor "code --reuse-window"

# Enable Claude AI integration
phantom preferences set ai "claude"

# Store worktrees in a central location (outside .git)
phantom preferences set worktreesDirectory "/path/to/worktrees"
```

## Repository Configuration (phantom.config.json)

Create a `phantom.config.json` file in your repository root for project-specific settings.

```json
{
  "postCreate": {
    "copyFiles": [".env", ".env.local", "config/local.yml"],
    "commands": ["npm install", "npm run db:migrate"]
  },
  "preDelete": {
    "commands": ["docker compose down"]
  }
}
```

### postCreate.copyFiles

Files to automatically copy from current worktree to newly created worktrees.

```json
{
  "postCreate": {
    "copyFiles": [
      ".env",
      ".env.local",
      "config/database.local.yml",
      ".vscode/settings.json"
    ]
  }
}
```

**Notes:**

- Paths are relative to repository root
- Non-existent files are silently skipped
- Glob patterns are not supported

### postCreate.commands

Commands to run after creating a new worktree.

```json
{
  "postCreate": {
    "commands": ["pnpm install", "pnpm db:migrate", "pnpm db:seed"]
  }
}
```

**Behavior:**

- Commands execute sequentially
- Stops on first failure
- Runs in the new worktree directory

### preDelete.commands

Cleanup commands to run before deleting a worktree.

```json
{
  "preDelete": {
    "commands": ["docker compose down", "rm -rf node_modules/.cache"]
  }
}
```

**Behavior:**

- Commands execute sequentially
- If a command fails, the worktree is NOT deleted
- Useful for stopping services, cleaning caches

## Complete Example Configuration

```json
{
  "postCreate": {
    "copyFiles": [".env", ".env.local", ".env.development.local"],
    "commands": [
      "pnpm install --frozen-lockfile",
      "pnpm run codegen",
      "pnpm run db:migrate"
    ]
  },
  "preDelete": {
    "commands": ["docker compose down --volumes"]
  }
}
```

## Worktree Location Strategies

### Default (.git/phantom/worktrees)

```bash
# Default - worktrees inside .git directory
# Pros: Clean, hidden from project
# Cons: Long paths, inside git directory
```

### Sibling Directory

```bash
phantom preferences set worktreesDirectory "../worktrees"

# Results in:
# /project/main-repo/        <- main checkout
# /project/worktrees/feat-a/ <- worktree
# /project/worktrees/feat-b/ <- worktree
```

### Central Location

```bash
phantom preferences set worktreesDirectory "/Users/me/.worktrees"

# Results in:
# /Users/me/.worktrees/repo-name/feat-a/
# /Users/me/.worktrees/repo-name/feat-b/
```

### Project-Specific (Recommended for Claude Code)

Store worktrees in a central location per project:

```bash
phantom preferences set worktreesDirectory "/Users/me/.conductor/worktrees"
```

This keeps worktrees organized and accessible across all projects.

</configuration>
