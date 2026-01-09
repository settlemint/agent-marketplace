---
name: crew:git:stacked:cleanup
description: Delete local branches not in machete layout
allowed-tools:
  - Bash
  - AskUserQuestion
context: fork
hooks:
  PostToolUse: false
  PreToolUse: false
---

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh 2>&1`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<objective>

Clean up local branches that are not tracked in the machete layout file.

</objective>

<workflow>

## Step 1: Identify Unmanaged Branches

```bash
echo "=== Branches in machete layout ==="
git machete list managed 2>/dev/null || cat .git/machete

echo
echo "=== Local branches NOT in layout ==="
git machete list unmanaged 2>/dev/null
```

## Step 2: Dry Run

```bash
git machete delete-unmanaged --dry-run
```

## Step 3: Confirm Deletion

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Delete the unmanaged branches listed above?",
      header: "Delete",
      options: [
        {
          label: "Yes, delete all",
          description: "Delete all unmanaged branches",
        },
        {
          label: "Select individually",
          description: "Choose which branches to delete",
        },
        { label: "No, keep all", description: "Don't delete any branches" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 4: Execute Deletion

**Delete all:**

```bash
git machete delete-unmanaged --yes
```

**Delete specific:**

```bash
git branch -d <branch-name>   # Safe
git branch -D <branch-name>   # Force
```

## Step 5: Clean Remote Tracking

```bash
git fetch --prune
git branch -vv | grep ': gone]'
```

## Step 6: Verify

```bash
echo "=== Remaining branches ==="
git branch -a

echo
git machete status
```

</workflow>

<success_criteria>

- [ ] Unmanaged branches identified
- [ ] Branches deleted (if approved)
- [ ] Remote tracking refs pruned
- [ ] Remaining branches verified

</success_criteria>
