---
name: crew:git:stacked:advance
description: Fast-forward merge child into current branch, slide out child, and update PRs
allowed-tools:
  - Bash
  - AskUserQuestion
---

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh 2>&1`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<objective>

Fast-forward merge a child branch into current branch, then slide out the child.

</objective>

<workflow>

## Step 1: Validate State

```bash
current=$(git branch --show-current)
children=$(git machete show down 2>/dev/null || echo "")
if [[ -z "$children" ]]; then
    echo "No child branches to advance into $current"
    exit 1
fi
echo "Current: $current"
echo "Child: $children"
```

## Step 2: Check Fast-Forward Possibility

```bash
child=$(git machete show down | head -1)
if git merge-base --is-ancestor "$current" "$child" 2>/dev/null; then
    echo "Fast-forward merge is possible"
else
    echo "Fast-forward not possible - child has diverged"
fi
```

If not fast-forward:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Fast-forward not possible. What to do?",
      header: "Diverged",
      options: [
        {
          label: "Rebase child first",
          description: "Run git machete update on child",
        },
        { label: "Cancel", description: "Keep branches separate" },
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
      question:
        "Advance will merge child into current and slide out child. Continue?",
      header: "Confirm",
      options: [
        {
          label: "Yes (Recommended)",
          description: "Fast-forward merge and slide out",
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

## Step 5: Push and Cleanup

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Push the advanced branch?",
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

If push: `git push origin $(git branch --show-current)`
If force push: `git push --force-with-lease origin $(git branch --show-current)`

## Step 6: Update PRs

```bash
if git machete is-managed "$(git branch --show-current)" 2>/dev/null; then
  git config machete.github.prDescriptionIntroStyle full
  git machete github anno-prs
  git machete github update-pr-descriptions --related
fi
```

## Step 7: Show Result

```bash
git machete status --list-commits
```

</workflow>

<success_criteria>

- [ ] Child merged into current via fast-forward
- [ ] Child slid out of layout
- [ ] Changes pushed (optional)
- [ ] PRs updated

</success_criteria>
