---
name: crew:git:butler:sync
description: Sync GitButler branches with upstream (rebase on target branch)
allowed-tools:
  - Bash
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<objective>

Rebase all virtual branches on the latest upstream changes. Remove integrated branches.

</objective>

<workflow>

## Step 1: Check GitButler Active

```javascript
if (GITBUTLER_ACTIVE === false) {
  // Output: "GitButler is not initialized. Use git pull --rebase instead."
  // Exit
}
```

## Step 2: Check Upstream Status

```javascript
Bash({ command: "but base check" });
```

Review what will happen:

- Branches to rebase
- Integrated branches to remove
- Potential conflicts

## Step 3: Update Base

```javascript
Bash({ command: "but base update" });
```

This automatically:

- Rebases all virtual branches on upstream
- Removes branches that have been merged
- Detects and preserves conflicts for resolution

## Step 4: Handle Conflicts

If conflicts detected:

```javascript
// Output: "Conflicts detected. Edit the conflicted files directly, then:"
Bash({ command: 'but commit -m "fix: resolve merge conflicts"' });
```

## Step 5: Show Result

```javascript
Bash({ command: "but branch list" });
Bash({ command: "but base check" });
```

</workflow>

<success_criteria>

- [ ] Branches rebased on upstream
- [ ] Integrated branches removed
- [ ] Conflicts identified (if any)

</success_criteria>
