# Workflow: Sync Stacked Branches

<objective>
Rebase and push all branches in a stack to keep them synchronized with their parents and remote tracking branches.
</objective>

<process>
## Step 1: Check Current State

View the branch tree and sync status:

```bash
git machete status --list-commits
```

**Interpret the output:**

- **Green edge**: Branch is in sync with parent
- **Red edge**: Branch is out of sync (parent has commits branch doesn't have)
- **Gray edge**: Branch is merged into parent

## Step 2: Fetch Latest Changes

Always fetch before syncing:

```bash
git fetch --all
```

Or include it in traverse:

```bash
git machete traverse --fetch
```

## Step 3: Sync Single Branch

To update just the current branch:

```bash
git machete update
```

This rebases the current branch onto its parent as defined in `.git/machete`.

## Step 4: Sync Entire Stack

For full automation, use traverse:

```bash
# Interactive mode (confirms each action)
git machete traverse

# Fully automated
git machete traverse -W -y
```

**Traverse actions:**

1. Fetches from remote (`-W` includes `--fetch`)
2. Walks through each branch in layout
3. Rebases out-of-sync branches onto parents
4. Pushes branches that are ahead of remote
5. Pulls branches that are behind remote
6. Offers to slide out merged branches

## Step 5: Handle Rebase Conflicts

If a rebase conflict occurs during traverse:

```bash
# Resolve conflicts in your editor
git add <resolved-files>
git rebase --continue

# Resume traverse
git machete traverse
```

To abort and skip:

```bash
git rebase --abort
git machete traverse --skip
```

## Step 6: Force Push After Rebase

After rebasing, branches need force push:

```bash
git push --force-with-lease
```

Traverse handles this automatically with `-y` flag.

## Step 7: Verify Sync

Check all branches are in sync:

```bash
git machete status
```

All edges should be green (or gray for merged branches).
</process>

<traverse_options>
**Common flag combinations:**

```bash
# Full sync with auto-confirm
git machete traverse -W -y

# Sync from first root branch
git machete traverse --start-from=first-root

# Sync only current branch and descendants
git machete traverse --start-from=here

# Include retargeting GitHub PRs
git machete traverse -W -y -H

# Use merge instead of rebase (not recommended for stacks)
git machete traverse --merge
```

</traverse_options>

<fork_point_issues>
**If too many commits are rebased:**

The fork point detection may fail. Override it:

```bash
# Check current fork point
git machete fork-point

# Override with specific commit
git machete update --fork-point <commit-hash>
```

**Prevention:** Don't immediately delete merged branches. Their reflogs help detect fork points.
</fork_point_issues>

<success_criteria>

- [ ] All branches show green edges in status
- [ ] No rebase conflicts remain
- [ ] Branches are pushed to remote
- [ ] PRs show correct diffs (no extra commits)
      </success_criteria>
