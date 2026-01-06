---
name: crew:git:stack-status
description: Show git-machete branch stack status
allowed-tools: Bash(git machete:*), Bash(git branch:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`

<indicators>

| Edge  | Meaning             |
| ----- | ------------------- |
| Green | In sync with parent |
| Red   | Needs rebase        |
| Gray  | Merged into parent  |

</indicators>

<process>

1. If no layout → offer setup
2. Show status:

```bash
git machete github anno-prs  # Add PR numbers
git machete status --list-commits
```

3. Highlight: red edges (need rebase), gray edges (can slide out)

</process>
