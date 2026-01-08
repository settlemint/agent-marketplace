---
name: crew:git:advance
description: Fast-forward merge child into current branch, then slide out child
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

<constraints>

**CRITICAL: NEVER output plain text questions. Use AskUserQuestion tool for all user choices.**

</constraints>

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh 2>&1`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<objective>
Fast-forward merge a child branch into the current branch, then slide out the child.
This is useful when you want to incorporate a child's changes without creating a merge commit.
</objective>

<when_to_use>

- Child branch is fully reviewed and ready
- You want to merge child into parent locally (not via GitHub PR)
- You want a linear history
- The child is a direct descendant (fast-forward is possible)

</when_to_use>

<process>

## Step 1: Validate State

```bash
# Check current branch has children
current=$(git branch --show-current)
children=$(git machete show down 2>/dev/null || echo "")

if [[ -z "$children" ]]; then
    echo "No child branches to advance into $current"
    exit 1
fi

echo "Current branch: $current"
echo "Child branch(es): $children"
```

## Step 2: Check Fast-Forward Possibility

```bash
# Get first child
child=$(git machete show down | head -1)

# Check if fast-forward is possible
if git merge-base --is-ancestor "$current" "$child" 2>/dev/null; then
    echo "✓ Fast-forward merge is possible"
else
    echo "⚠️ Fast-forward not possible - child has diverged"
fi
```

If not fast-forward possible:

```javascript
AskUserQuestion({
  questions: [
    {
      question:
        "Fast-forward not possible. The child branch has diverged. What to do?",
      header: "Diverged",
      options: [
        {
          label: "Rebase child first",
          description: "Run git machete update on child, then advance",
        },
        {
          label: "Cancel",
          description: "Don't advance, keep branches separate",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 3: Confirm Advance

```javascript
AskUserQuestion({
  questions: [
    {
      question: `Advance will merge '${child}' into '${current}' and slide out '${child}'. Continue?`,
      header: "Confirm",
      options: [
        {
          label: "Yes (Recommended)",
          description: "Fast-forward merge and slide out child",
        },
        { label: "No", description: "Cancel advance" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 4: Execute Advance

```bash
git machete advance --yes
```

**What happens:**

1. Current branch fast-forwards to child's HEAD
2. Child branch is slid out of the layout
3. Child's children (if any) become children of current branch

## Step 5: Push Changes

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Push the advanced branch to remote?",
      header: "Push",
      options: [
        { label: "Yes", description: "Push to origin" },
        { label: "Force push", description: "Push with --force-with-lease" },
        { label: "No", description: "Don't push yet" },
      ],
      multiSelect: false,
    },
  ],
});
```

If push:

```bash
git push origin $(git branch --show-current)
```

If force push:

```bash
git push --force-with-lease origin $(git branch --show-current)
```

## Step 6: Clean Up (Optional)

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Delete the local child branch?",
      header: "Cleanup",
      options: [
        { label: "Yes", description: "Delete local branch" },
        { label: "No", description: "Keep local branch" },
      ],
      multiSelect: false,
    },
  ],
});
```

If yes:

```bash
git branch -d "$child"
```

## Step 7: Show Result

```bash
git machete status --list-commits
```

</process>

<advance_vs_merge>

| Aspect           | `advance`         | GitHub PR merge       |
| ---------------- | ----------------- | --------------------- |
| Merge type       | Fast-forward only | Squash/merge/rebase   |
| History          | Linear            | Depends on merge type |
| Where it happens | Local             | Remote (GitHub)       |
| PR required      | No                | Yes                   |
| Review           | No formal review  | Code review possible  |
| Best for         | Local development | Team collaboration    |

</advance_vs_merge>

<success_criteria>

- [ ] Child branch merged into current via fast-forward
- [ ] Child branch slid out of machete layout
- [ ] Child's children (if any) re-parented to current
- [ ] Changes pushed to remote (optional)
- [ ] Local child branch deleted (optional)

</success_criteria>
