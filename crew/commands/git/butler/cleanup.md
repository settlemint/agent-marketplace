---
name: crew:git:butler:cleanup
description: Clean up stale GitButler branches (0 commits ahead)
allowed-tools:
  - Bash
  - AskUserQuestion
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<objective>

Sync with upstream and delete branches that have been merged (0 commits ahead). Always run this after PR merges.

</objective>

<workflow>

## Step 1: Check GitButler Active

If `GITBUTLER_ACTIVE=false`:

```
GitButler is not active in this repository.
```

Exit if not active.

## Step 2: Sync with Upstream

```bash
but base update
```

This rebases active branches and marks merged branches as `0 commits ahead`.

## Step 3: Find Stale Branches

```bash
# Get branch list as JSON
STALE_BRANCHES=$(but branch -j | jq -r '.branches[] | select(.commitsAhead == 0) | .name')

# Show what will be cleaned
echo "Stale branches (0 commits ahead):"
echo "$STALE_BRANCHES"
```

## Step 4: Confirm Cleanup

If stale branches found:

```javascript
AskUserQuestion({
  questions: [
    {
      question: `Delete ${count} stale branches?`,
      header: "Cleanup",
      options: [
        { label: "Yes, delete all", description: "Remove all merged branches" },
        { label: "No, keep them", description: "Cancel cleanup" },
      ],
      multiSelect: false,
    },
  ],
});
```

If no stale branches:

```
No stale branches found. Workspace is clean.
```

Exit.

## Step 5: Delete Stale Branches

For each stale branch:

```bash
# Must apply before delete (GitButler requirement)
but branch apply "$branch"
but branch delete "$branch" -f
echo "Deleted: $branch"
```

## Step 6: Confirm Completion

```bash
but branch list
```

Show remaining branches and confirm cleanup complete.

</workflow>

<success_criteria>

- [ ] Base updated with upstream
- [ ] Stale branches identified
- [ ] User confirmed deletion
- [ ] All stale branches removed
- [ ] Final state shown

</success_criteria>
