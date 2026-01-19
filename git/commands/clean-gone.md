---
name: clean-gone
description: Remove local branches deleted from remote
---

Clean up local branches that have been deleted from the remote repository (marked as [gone]).

## Workflow

1. **Fetch with prune** - Update remote tracking and remove stale references
2. **Identify gone branches** - Find branches marked as [gone]
3. **Remove worktrees** - Handle any associated worktrees
4. **Delete branches** - Remove the local branches

## Commands

```bash
# Fetch and prune stale remote-tracking branches
git fetch --prune

# List branches with their tracking status
git branch -vv

# Find branches marked as [gone]
git branch -vv | grep ': gone]' | awk '{print $1}'

# Delete a gone branch
git branch -D <branch-name>
```

## Full Cleanup Script

```bash
# Fetch and prune
git fetch --prune

# Get list of gone branches
GONE_BRANCHES=$(git branch -vv | grep ': gone]' | awk '{print $1}')

if [ -z "$GONE_BRANCHES" ]; then
  echo "No branches to clean up"
  exit 0
fi

echo "Branches to remove:"
echo "$GONE_BRANCHES"

# Remove each branch
for branch in $GONE_BRANCHES; do
  # Check for associated worktree
  WORKTREE=$(git worktree list | grep "$branch" | awk '{print $1}')
  if [ -n "$WORKTREE" ]; then
    echo "Removing worktree: $WORKTREE"
    git worktree remove "$WORKTREE" --force
  fi

  echo "Deleting branch: $branch"
  git branch -D "$branch"
done

echo "Cleanup complete"
```

## What Gets Cleaned

| Status | Meaning | Action |
|--------|---------|--------|
| `[gone]` | Remote branch deleted | Delete local branch |
| `[ahead X]` | Local commits not pushed | Keep (warn user) |
| `[behind X]` | Remote has new commits | Keep |

## Safety

This command only deletes branches where:
- The remote tracking branch no longer exists
- The branch is marked as `[gone]` by git

It will NOT delete:
- Branches with unpushed commits (unless they're gone)
- The current branch
- main/master branches

## Constraints

**Banned:**
- Deleting branches with unpushed work without warning
- Deleting the current branch

**Required:**
- Fetch with prune first
- Show user what will be deleted
- Handle worktrees properly

## Success Criteria

- [ ] Fetched with prune
- [ ] Identified all [gone] branches
- [ ] Removed associated worktrees
- [ ] Deleted gone branches
- [ ] Reported results to user
