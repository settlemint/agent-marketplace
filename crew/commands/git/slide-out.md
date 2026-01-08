---
name: crew:git:slide-out
description: Remove merged branches from stack and reconnect children
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - AskUserQuestion
  - TodoWrite
  - WebFetch
  - WebSearch
  - MCPSearch
  - Skill
---

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<what_happens>

1. Branch removed from `.git/machete`
2. Children attached to parent
3. Children rebased onto new parent (default)
4. Optionally delete local branch

</what_happens>

<process>

**If in a WORKTREE:**

⚠️ Slide-out can be problematic in worktrees:

- Cannot slide out the branch checked out in THIS worktree
- Cannot slide out a branch checked out in ANOTHER worktree
- `--delete` won't work for branches with active worktrees

```javascript
AskUserQuestion({
  questions: [
    {
      question: "You're in a worktree. Which branch to slide out?",
      header: "Branch",
      options: [
        {
          label: "A different branch",
          description: "Slide out a branch NOT checked out in any worktree",
        },
        {
          label: "Show worktree list",
          description: "See which branches have worktrees",
        },
      ],
    },
  ],
});
```

**To slide out a branch with an active worktree:**

1. First remove the worktree: `git worktree remove <path>`
2. Then slide out: `git machete slide-out <branch>`
3. Optionally delete: `git branch -d <branch>`

**Safe slide-out in worktree (for non-worktree branches):**

```bash
# Use --no-rebase if children are in separate worktrees (they'll update themselves)
git machete slide-out <branch> --no-rebase

# Or with local branch deletion (only if no worktree)
git machete slide-out <branch> --delete --no-rebase
```

**If in MAIN checkout (not a worktree):**

Standard flow:

1. Check for merged (gray edges): `git machete status`
2. Slide out:

```bash
git machete slide-out <branch> --no-rebase  # For remote merges
git machete slide-out <branch> --delete     # Also delete local
```

3. Sync remaining: `git machete traverse -W -y -H`

</process>

<worktree_considerations>

When using worktrees for stacked branches:

- Each worktree keeps its branch checked out
- Use `--no-rebase` since child worktrees will run `git machete update` themselves
- Remove worktree before deleting its branch
- After slide-out, each child worktree runs: `git machete update && git push --force-with-lease`

</worktree_considerations>
