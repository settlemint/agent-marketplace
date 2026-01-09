---
name: crew:git:worktree:checkout-pr
description: Create a worktree from a GitHub PR or issue
argument-hint: "<PR or issue number>"
allowed-tools:
  - Bash
---

<objective>

Checkout PR or issue into a new phantom worktree.

</objective>

<workflow>

## Step 1: Checkout PR/Issue

```bash
phantom gh checkout ${number}
```

## Step 2: Instruct User

```
Checked out PR/issue #${number}
Worktree created at: $(phantom where ${branchName})

To work on this:
  phantom shell ${branchName}
```

</workflow>

<success_criteria>

- [ ] PR/issue checked out
- [ ] Worktree created

</success_criteria>
