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

If `GITBUTLER_ACTIVE=false`:

```
GitButler is not initialized. Use git pull --rebase instead.
```

Exit if not active.

## Step 2: Check Upstream Status

```bash
but base check
```

Review what will happen:

- Branches to rebase
- Integrated branches to remove
- Potential conflicts

## Step 3: Update Base

```bash
but base update
```

This automatically:

- Rebases all virtual branches on upstream
- Removes branches that have been merged
- Detects and preserves conflicts for resolution

## Step 4: Handle Conflicts

If conflicts detected:

```
Conflicts detected. Edit the conflicted files directly, then:
  but commit -m "fix: resolve merge conflicts"
```

## Step 5: Show Result

```bash
but branch list
but base check
```

</workflow>

<success_criteria>

- [ ] Branches rebased on upstream
- [ ] Integrated branches removed
- [ ] Conflicts identified (if any)

</success_criteria>
