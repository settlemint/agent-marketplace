---
name: sync
description: Sync branch with main via merge or rebase
argument-hint: [--rebase | --merge] [base-branch]
---

Sync current branch with main (or specified base) using merge or rebase.

## Current State

```bash
git branch --show-current
git fetch origin main
git log --oneline HEAD..origin/main | head -5
```

## Workflow

1. **Fetch latest** from origin
2. **Choose strategy** - Merge (default) or rebase
3. **Execute sync** - Handle any conflicts
4. **Push** - Normal for merge, force-with-lease for rebase
5. **Auto-retry if rejected** - Fetch, rebase, push again

## Commands

```bash
# Set base branch (default: main)
BASE="${1:-main}"

# Fetch latest
git fetch origin "$BASE"

# MERGE (preserves history, creates merge commit)
git merge "origin/$BASE" --no-edit

# OR REBASE (linear history, rewrites commits)
git rebase "origin/$BASE"

# Push after merge
git push

# Push after rebase
git push --force-with-lease
```

## Auto-Retry on Conflict

If push is rejected because remote has new commits (e.g., another agent pushed), automatically rebase and retry:

```bash
BRANCH=$(git branch --show-current)

# Attempt push (after merge)
if ! git push; then
  git fetch origin "$BRANCH"
  if [ -n "$(git log HEAD..origin/$BRANCH --oneline 2>/dev/null)" ]; then
    echo "Remote has new commits. Rebasing..."
    git rebase "origin/$BRANCH"
    git push --force-with-lease
  fi
fi
```

**Note:** This handles cases where another agent or collaborator pushed while you were syncing.

## Merge vs Rebase Decision

| Aspect | Merge | Rebase |
|--------|-------|--------|
| History | Preserves branches | Linear, clean |
| Commit | Creates merge commit | Rewrites commits |
| Push | Normal push | Force push required |
| Shared branch | Safe | Dangerous |
| Solo feature | OK | Preferred |

**Use MERGE when:**
- Branch is shared with others
- Want to preserve full history
- Already pushed many commits

**Use REBASE when:**
- Solo feature branch
- Want clean linear history
- Few commits, not yet pushed (or OK with force-push)

## Conflict Resolution

**Conflict markers:**
```
<<<<<<< HEAD
your changes
=======
incoming changes
>>>>>>> origin/main
```

**Resolution options:**
- Keep yours: Remove incoming section
- Keep theirs: Remove your section
- Keep both: Combine logically
- Rewrite: Create new version

**Common patterns:**

| Pattern | Resolution |
|---------|------------|
| Version bumps | Keep higher version |
| Added vs deleted | Usually keep addition |
| Both modified same line | Combine based on intent |
| Import order | Keep alphabetical, include both |

**After resolving:**

```bash
# For merge
git add <resolved-files>
git commit -m "merge: resolve conflicts with main"

# For rebase
git add <resolved-files>
git rebase --continue
```

## Abort Options

If things go wrong:

```bash
# Abort merge in progress
git merge --abort

# Abort rebase in progress
git rebase --abort

# Reset to before sync
git reset --hard ORIG_HEAD
```

## Constraints

**Banned:**
- `git push --force` (use `--force-with-lease`)
- Rebasing shared/public branches
- Leaving conflict markers in files
- Committing with unresolved conflicts

**Required:**
- Fetch before merge/rebase
- Resolve ALL conflicts before continuing
- Use `--force-with-lease` after rebase
- Verify build passes after conflict resolution

## Success Criteria

- [ ] Fetched latest from origin
- [ ] Merged/rebased without unresolved conflicts
- [ ] No conflict markers in any files
- [ ] Build/tests pass after sync
- [ ] Auto-retry with rebase if push rejected
- [ ] Pushed successfully
