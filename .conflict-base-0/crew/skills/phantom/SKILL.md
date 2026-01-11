---
name: phantom
description: Phantom CLI for Git worktree management. Enables parallel development across multiple features in isolated directories. Use when creating worktrees, managing parallel workstreams, or working with GitHub issues/PRs.
triggers:
  - "worktree"
  - "phantom"
  - "parallel development"
  - "isolated branch"
  - "new worktree"
  - "feature isolation"
---

<objective>
Manage Git worktrees with Phantom CLI for true parallel development. Each worktree is an isolated directory with its own branch, enabling simultaneous work on multiple features without stashing or context switching.
</objective>

<essential_principles>

**Worktrees vs Stacked Branches**

Choose the right approach for the task:

| Approach                     | Use When                                   | Benefit                             |
| ---------------------------- | ------------------------------------------ | ----------------------------------- |
| **Worktree** (phantom)       | Independent features, hotfixes, PR reviews | Full isolation, no branch switching |
| **Stacked branch** (machete) | Sequential dependent changes               | Easier rebasing, related PRs        |

**Worktree Naming Convention**

Phantom auto-generates worktree names from branch names. Use descriptive branch names:

```
feat/user-auth     -> worktree: feat-user-auth
fix/login-bug      -> worktree: fix-login-bug
hotfix/critical    -> worktree: hotfix-critical
```

**One Branch Per Worktree**

Each worktree is locked to its branch. Cannot switch branches within a worktree.

**Shared Git State**

All worktrees share the same `.git` directory (via symlinks). Commits, stashes, and refs are visible across all worktrees.

</essential_principles>

<constraints>

**NEVER switch branches in a worktree** - use `phantom create` for new branches

**NEVER delete a worktree's branch while in that worktree** - exit first

**NEVER use git checkout in a worktree** - it will fail or cause issues

**ALWAYS use phantom commands** instead of raw git worktree commands for consistency

</constraints>

<quick_start>

**Create a worktree for a new feature:**

```bash
phantom create feat/my-feature
# Worktree created at .git/phantom/worktrees/...
```

**Work on an existing branch:**

```bash
phantom attach existing-branch
```

**Run command in another worktree (without switching):**

```bash
phantom exec feat/other npm run build
```

**Get worktree path for file operations:**

```bash
phantom where feat/my-feature
# Returns: /path/to/worktree
```

**Clean up when done:**

```bash
phantom delete feat/my-feature
```

</quick_start>

<agent_patterns>
**Agent-native alternatives for interactive commands:**

Some phantom commands are interactive (open editor, drop to shell). Agents should use these alternatives:

| Human Command                     | Agent Alternative                   | Notes                                              |
| --------------------------------- | ----------------------------------- | -------------------------------------------------- |
| `phantom create <name> --shell`   | `phantom create <name>`             | Skip `--shell`, use `exec` for commands            |
| `phantom shell <name>`            | `phantom exec <name> "<cmd>"`       | Run specific commands instead of interactive shell |
| `phantom edit <name>`             | `phantom where <name>` + file tools | Get path, then use Read/Edit/Write tools           |
| `phantom attach <branch> --shell` | `phantom attach <branch>`           | Skip `--shell`, use `exec` for commands            |

**Working with files in a worktree:**

```bash
# Get the worktree path
WORKTREE_PATH=$(phantom where feat/my-feature)

# Then use file tools on that path
# Read tool: ${WORKTREE_PATH}/src/file.ts
# Edit tool: ${WORKTREE_PATH}/src/file.ts
# Bash: ls ${WORKTREE_PATH}/src/
```

**Running multiple commands in a worktree:**

```bash
# Chain commands with &&
phantom exec feat/my-feature "npm install && npm run build && npm test"

# Or run separately for better error handling
phantom exec feat/my-feature "npm install"
phantom exec feat/my-feature "npm run build"
phantom exec feat/my-feature "npm test"
```

**Checking worktree status:**

```bash
# Git status in worktree
phantom exec feat/my-feature "git status"

# Check current branch
phantom exec feat/my-feature "git branch --show-current"

# View recent commits
phantom exec feat/my-feature "git log --oneline -5"
```

**MCP tools for worktree management:**

Prefer MCP tools when available for better integration:

```typescript
// Create worktree via MCP
mcp__phantom__phantom_create_worktree({ name: "feat/my-feature" });

// List worktrees via MCP
mcp__phantom__phantom_list_worktrees({});

// Delete worktree via MCP
mcp__phantom__phantom_delete_worktree({ name: "feat/my-feature" });

// Checkout PR/issue via MCP
mcp__phantom__phantom_github_checkout({ number: 123 });
```

</agent_patterns>

<routing>

| Task                      | Resource                       |
| ------------------------- | ------------------------------ |
| Create worktree           | `workflows/create-worktree.md` |
| Work with GitHub PR/issue | `workflows/github-workflow.md` |
| Clean up worktrees        | `workflows/cleanup.md`         |
| Configure phantom         | `references/configuration.md`  |
| All commands              | `references/commands.md`       |
| MCP integration           | `references/mcp.md`            |

</routing>

<commands>

| Command                     | Purpose                                  |
| --------------------------- | ---------------------------------------- |
| `phantom create <name>`     | Create new worktree with matching branch |
| `phantom attach <branch>`   | Create worktree for existing branch      |
| `phantom list`              | Show all worktrees                       |
| `phantom shell <name>`      | Open shell in worktree                   |
| `phantom exec <name> <cmd>` | Run command in worktree                  |
| `phantom edit <name>`       | Open worktree in editor                  |
| `phantom ai <name>`         | Launch AI assistant in worktree          |
| `phantom where <name>`      | Get worktree path                        |
| `phantom delete <name>`     | Remove worktree and branch               |
| `phantom gh checkout <num>` | Create worktree from GitHub PR/issue     |

</commands>

<scripts>

| Script               | Purpose                     |
| -------------------- | --------------------------- |
| `phantom-context.sh` | Get phantom/worktree status |

</scripts>

<integration_with_machete>

Phantom and git-machete work together:

```bash
# In main checkout, use machete for stacked branches
git machete traverse -W -y

# For independent features, use phantom worktrees
phantom create feat/independent-feature

# Worktrees can contain their own stacked branches
phantom shell feat/my-feature
git checkout -b feat/my-feature-part2
git machete add --onto feat/my-feature
```

**Best Practice:** Use phantom for main feature isolation, machete for sub-feature stacking within a worktree.

</integration_with_machete>

<success_criteria>

- [ ] Worktree created in correct location
- [ ] Branch naming follows conventions
- [ ] Can run commands without switching context
- [ ] Cleanup removes both worktree and branch

</success_criteria>
