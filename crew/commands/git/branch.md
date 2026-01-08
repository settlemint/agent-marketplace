---
name: crew:git:branch
description: Create a feature branch from main
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

<branch_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/branch-context.sh`
</branch_context>

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<notes>
Branch naming per @rules/git-safety.md: `type/short-description`
</notes>

<process>

**If in a WORKTREE:**

When working with worktrees, you typically want each branch in its own worktree:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "You're in a worktree. How do you want to create the branch?",
      header: "Method",
      options: [
        {
          label: "Create worktree (Recommended)",
          description: "New branch in a new worktree directory",
        },
        {
          label: "Stacked branch here",
          description: "Child of current branch, stay in this worktree",
        },
        {
          label: "Switch branch (not recommended)",
          description: "Checkout new branch in this worktree",
        },
      ],
    },
  ],
});
```

**Create worktree:**

```bash
# For stacked branch (child of current)
git worktree add ../<new-branch-name> -b <type>/<name>
git machete add <type>/<name> --onto $(git branch --show-current)

# For regular branch (from main)
git worktree add ../<new-branch-name> -b <type>/<name> origin/main
```

Tell user: `cd ../<new-branch-name>` to work in the new worktree.

**If NOT in a worktree (main checkout):**

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What type of branch?",
      header: "Type",
      options: [
        { label: "Regular branch", description: "From main" },
        {
          label: "Stacked branch",
          description: "Child of current (stacked PRs)",
        },
      ],
    },
  ],
});
```

**Regular:**

```bash
git fetch origin main && git checkout -b <type>/<name> origin/main
```

**Stacked:**

```bash
git checkout -b <type>/<name>
git machete add --onto $(git rev-parse --abbrev-ref @{-1})
```

</process>
