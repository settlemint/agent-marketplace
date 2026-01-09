---
name: crew:git:worktree:checkout-pr
description: Create a worktree from a GitHub PR or issue
argument-hint: "<PR or issue number>"
allowed-tools:
  - Bash
---

<process>

```bash
# Checkout PR or issue into a new worktree
phantom gh checkout <number>
```

**Output:**

```
Checked out PR/issue #<number>
Worktree created at: <path>

To work on this:
  phantom shell <branch-name>
```

</process>
