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
phantom create feat/my-feature --shell
# Now in isolated directory with new branch
```

**Work on an existing branch:**

```bash
phantom attach existing-branch --shell
```

**Run command in another worktree (without switching):**

```bash
phantom exec feat/other npm run build
```

**Open editor in worktree:**

```bash
phantom edit feat/my-feature
```

**Clean up when done:**

```bash
phantom delete feat/my-feature
```

</quick_start>

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
