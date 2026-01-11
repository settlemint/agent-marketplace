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

```javascript
if (GITBUTLER_ACTIVE === false) {
  // Output: "GitButler is not active in this repository."
  // Exit
}
```

## Step 2: Sync with Upstream

```javascript
Bash({ command: "but base update" });
```

This rebases active branches and marks merged branches as `0 commits ahead`.

## Step 3: Find Stale Branches

```javascript
const result = Bash({
  command:
    "but branch -j | jq -r '.branches[] | select(.commitsAhead == 0) | .name'",
});
const staleBranches = result.trim().split("\n").filter(Boolean);
```

## Step 4: Confirm Cleanup

```javascript
if (staleBranches.length === 0) {
  // Output: "No stale branches found. Workspace is clean."
  // Exit
}

AskUserQuestion({
  questions: [
    {
      question: `Delete ${staleBranches.length} stale branch(es): ${staleBranches.join(", ")}?`,
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

If user selects "No", exit.

## Step 5: Delete Stale Branches

```javascript
for (const branch of staleBranches) {
  // Must apply before delete (GitButler requirement)
  Bash({ command: `but branch apply "${branch}"` });
  Bash({ command: `but branch delete "${branch}" -f` });
  // Output: "Deleted: ${branch}"
}
```

## Step 6: Confirm Completion

```javascript
Bash({ command: "but branch list" });
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
