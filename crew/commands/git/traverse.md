---
name: crew:git:traverse
description: Sync all stacked branches with parents and remotes
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite, WebFetch, WebSearch, MCPSearch, Skill
---

<constraints>

**CRITICAL: NEVER output plain text questions. Use AskUserQuestion tool for all user choices.**

</constraints>

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<process>

**If no machete layout:**

```javascript
AskUserQuestion({
  questions: [
    {
      question: "No git-machete layout. What to do?",
      header: "Setup",
      options: [
        { label: "Discover layout", description: "Auto-detect from history" },
        { label: "Create manually", description: "Open editor" },
        { label: "Skip", description: "Continue without machete" },
      ],
    },
  ],
});
```

**If in a WORKTREE:**

⚠️ Full traverse would switch branches, breaking this worktree's checkout.

```javascript
AskUserQuestion({
  questions: [
    {
      question:
        "You're in a worktree. Full traverse would switch branches. What to do?",
      header: "Worktree",
      options: [
        {
          label: "Update current only (Recommended)",
          description: "Run 'git machete update' for this branch",
        },
        {
          label: "Show instructions",
          description: "Manual steps for each worktree",
        },
      ],
    },
  ],
});
```

**Update current only:**

```bash
git fetch origin
git machete update                # Rebase onto parent
git push --force-with-lease       # Push updated branch
```

**Show instructions:**

Print for each branch in stack:

```
To sync your stack across worktrees:

1. In worktree for <parent-branch>:
   git pull --rebase origin main
   git push

2. In worktree for <child-branch>:
   git machete update
   git push --force-with-lease

3. Repeat for each child...
```

**If in MAIN checkout (not a worktree):**

Full traverse is safe:

```bash
git machete traverse -W -y      # Basic sync
git machete traverse -W -y -H   # With PR retargeting
```

Report: branches rebased, pushed, needing manual intervention.

</process>

<flags>

| Flag | Effect                        |
| ---- | ----------------------------- |
| `-W` | Fetch + traverse entire tree  |
| `-y` | Auto-confirm                  |
| `-H` | Include GitHub PR retargeting |

</flags>
