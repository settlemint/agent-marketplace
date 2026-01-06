---
name: crew:git:traverse
description: Sync all stacked branches with parents and remotes
allowed-tools: Bash(git machete:*), Bash(git fetch:*), Bash(git rebase:*), Bash(git push:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`

<flags>

| Flag | Effect                        |
| ---- | ----------------------------- |
| `-W` | Fetch + traverse entire tree  |
| `-y` | Auto-confirm                  |
| `-H` | Include GitHub PR retargeting |

</flags>

<process>

**If no layout:**

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

**If layout exists:**

```bash
git machete traverse -W -y      # Basic sync
git machete traverse -W -y -H   # With PR retargeting
```

Report: branches rebased, pushed, needing manual intervention.

</process>
