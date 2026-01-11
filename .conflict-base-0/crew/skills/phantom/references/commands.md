---
name: phantom-commands
description: Complete reference for all Phantom CLI commands
---

<commands>

## Worktree Management

### phantom create

Create a new worktree with a matching branch.

```bash
phantom create <name> [options]
```

**Options:**

| Option                           | Description                              |
| -------------------------------- | ---------------------------------------- |
| `--shell`                        | Open interactive shell after creation    |
| `--exec <command>`               | Execute command in new worktree          |
| `--tmux` / `-t`                  | Open in new tmux window                  |
| `--tmux-vertical` / `--tmux-v`   | Open in vertical tmux split              |
| `--tmux-horizontal` / `--tmux-h` | Open in horizontal tmux split            |
| `--copy-file <file>`             | Copy files from current worktree         |
| `--base <branch/commit>`         | Branch/commit to base on (default: HEAD) |

**Examples:**

```bash
# Create and enter shell
phantom create feat/user-auth --shell

# Create from main branch
phantom create feat/new-feature --base main

# Create and run command
phantom create hotfix/critical --exec "npm install"

# Create with files copied
phantom create feat/test --copy-file .env --copy-file .env.local

# Create in tmux window
phantom create feat/parallel -t
```

### phantom attach

Attach an existing branch as a worktree.

```bash
phantom attach <branch-name> [options]
```

**Options:** Same as `create` (--shell, --exec, --tmux, etc.)

**Examples:**

```bash
# Attach and enter shell
phantom attach feature-branch --shell

# Attach in tmux horizontal split
phantom attach fix/bug-123 --tmux-h
```

### phantom list

Display all worktrees and their status.

```bash
phantom list [options]
```

**Options:**

| Option    | Description                             |
| --------- | --------------------------------------- |
| `--fzf`   | Interactive selection with fuzzy finder |
| `--names` | Machine-readable format (names only)    |

**Examples:**

```bash
# Show all worktrees
phantom list

# Interactive selection
phantom list --fzf

# Script-friendly output
phantom list --names
```

### phantom where

Get the absolute path to a worktree.

```bash
phantom where <name> [options]
```

**Options:**

| Option  | Description                   |
| ------- | ----------------------------- |
| `--fzf` | Select worktree interactively |

**Examples:**

```bash
# Get path
phantom where feat/user-auth

# Use in scripts
cd "$(phantom where feat/user-auth)"
```

### phantom delete

Remove worktrees and their branches.

```bash
phantom delete <name...> [options]
```

**Options:**

| Option           | Description                             |
| ---------------- | --------------------------------------- |
| `--force` / `-f` | Force deletion with uncommitted changes |
| `--current`      | Delete current worktree                 |
| `--fzf`          | Interactive selection                   |

**Examples:**

```bash
# Delete single worktree
phantom delete feat/completed-feature

# Delete multiple
phantom delete feat-a feat-b feat-c

# Force delete with uncommitted changes
phantom delete feat/abandoned -f

# Interactive deletion
phantom delete --fzf
```

## Working in Worktrees

### phantom shell

Open an interactive shell in a worktree.

```bash
phantom shell <name> [options]
```

Sets environment variables: `PHANTOM`, `PHANTOM_NAME`, `PHANTOM_PATH`

**Options:** --fzf, --tmux, --tmux-vertical, --tmux-horizontal

**Examples:**

```bash
# Enter worktree shell
phantom shell feat/user-auth

# In tmux vertical split
phantom shell feat/user-auth --tmux-v
```

### phantom exec

Execute commands within a worktree context.

```bash
phantom exec [options] <name> <command> [args...]
```

**Options:** --fzf, --tmux variants

**Examples:**

```bash
# Run tests in another worktree
phantom exec feat/user-auth npm test

# Build in background
phantom exec feat/user-auth npm run build

# Run in tmux
phantom exec -t feat/user-auth npm run dev
```

### phantom edit

Open worktree in configured editor.

```bash
phantom edit <name> [path]
```

Uses `phantom.editor` preference, falls back to `$EDITOR`.

**Examples:**

```bash
# Open entire worktree
phantom edit feat/user-auth

# Open specific file
phantom edit feat/user-auth src/main.ts
```

### phantom ai

Launch AI coding assistant in worktree.

```bash
phantom ai <name>
```

Requires `phantom.ai` preference to be set.

**Examples:**

```bash
# Launch Claude in worktree
phantom ai feat/user-auth
```

## Preferences

### phantom preferences get

Get a preference value.

```bash
phantom preferences get <key>
```

### phantom preferences set

Set a preference value.

```bash
phantom preferences set <key> <value>
```

**Available preferences:**

| Key                  | Description               | Default                  |
| -------------------- | ------------------------- | ------------------------ |
| `editor`             | Editor command            | `$EDITOR`                |
| `ai`                 | AI assistant command      | (none)                   |
| `worktreesDirectory` | Worktree storage location | `.git/phantom/worktrees` |

**Examples:**

```bash
# Set editor
phantom preferences set editor "code --reuse-window"

# Set AI assistant
phantom preferences set ai "claude"

# Set worktree directory (relative to repo root)
phantom preferences set worktreesDirectory "../phantom-worktrees"
```

### phantom preferences remove

Remove a preference value.

```bash
phantom preferences remove <key>
```

## GitHub Integration

### phantom github checkout

Create worktrees from GitHub pull requests or issues.

```bash
phantom github checkout <number> [options]
# Alias: phantom gh checkout <number>
```

**Options:**

| Option                           | Description                                            |
| -------------------------------- | ------------------------------------------------------ |
| `--base <branch>`                | Base branch for issue branches (default: repo default) |
| `--tmux` / `-t`                  | Open in new tmux window                                |
| `--tmux-vertical` / `--tmux-v`   | Open in vertical tmux split                            |
| `--tmux-horizontal` / `--tmux-h` | Open in horizontal tmux split                          |

**Behavior:**

- **Pull Requests**: Creates worktree with PR branch name
- **Issues**: Creates worktree at `issues/<number>` with new local branch

**Examples:**

```bash
# Checkout PR #123
phantom gh checkout 123

# Checkout issue #456 based on develop
phantom gh checkout 456 --base develop

# Checkout and open in tmux
phantom gh checkout 789 -t
```

**Requirements:** GitHub CLI (`gh`) must be installed and authenticated.

## Other Commands

### phantom mcp

Manage MCP server for AI integration.

```bash
phantom mcp serve
```

Starts the MCP server with stdio transport.

### phantom version

Display installed version.

```bash
phantom version
```

### phantom completion

Generate shell completions.

```bash
phantom completion <shell>
```

Shells: `fish`, `zsh`, `bash`

## Exit Codes

| Code | Meaning                    |
| ---- | -------------------------- |
| 0    | Success                    |
| 1    | General error              |
| 2    | Invalid arguments          |
| 3    | Git operation failure      |
| 4    | Worktree operation failure |
| 127  | Command not found          |

</commands>
