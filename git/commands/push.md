---
name: push
description: Push commits to remote safely
argument-hint: [--force-with-lease]
---

Push commits to remote with safety checks.

## Current State

```bash
git branch --show-current
git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null || echo "New branch"
git status --short
```

## Workflow

1. **Check for uncommitted changes** - Warn if working directory is dirty
2. **Verify not on protected branch** - Block push to main/master
3. **Determine push type** - New branch vs existing, rebased vs normal
4. **Execute push** - With appropriate flags
5. **Auto-retry if rejected** - Fetch, rebase, push again

## Commands

```bash
# New branch (set upstream)
git push -u origin $(git branch --show-current)

# Existing branch (normal push)
git push

# After rebase (force with lease for safety)
git push --force-with-lease
```

## Push Types

| Situation | Command | Why |
|-----------|---------|-----|
| New branch | `git push -u origin branch` | Sets upstream tracking |
| Normal commits | `git push` | Standard push |
| After rebase | `git push --force-with-lease` | Safer than --force |
| After amend | `git push --force-with-lease` | History rewritten |

## Auto-Retry on Conflict

If push is rejected because remote has new commits, automatically rebase and retry:

```bash
BRANCH=$(git branch --show-current)

# Attempt push
if ! git push; then
  # Fetch latest from remote
  git fetch origin "$BRANCH"

  # Check if remote has commits we don't have
  if [ -n "$(git log HEAD..origin/$BRANCH --oneline 2>/dev/null)" ]; then
    echo "Remote has new commits. Rebasing..."
    git rebase "origin/$BRANCH"

    # Retry push (use --force-with-lease since we rebased)
    git push --force-with-lease
  fi
fi
```

**Note:** Retry uses `--force-with-lease` for safety after rebase.

## Safety Checks

### Protected Branches

```bash
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  echo "ERROR: Cannot push directly to $BRANCH"
  exit 1
fi
```

### Force Push Safety

Always use `--force-with-lease` instead of `--force`:
- Fails if remote has new commits you haven't seen
- Prevents accidentally overwriting others' work

## Multi-Agent Safety

In environments with multiple Claude instances:
- Check `git status` for uncommitted work from other agents
- Use `--force-with-lease` (fails if remote changed unexpectedly)
- Never use `git push --force` without explicit user confirmation

## Constraints

**Banned:**
- `git push --force` (use `--force-with-lease` instead)
- Pushing directly to main/master
- Pushing with uncommitted changes (warn user)

**Required:**
- Use `-u` flag for new branches
- Use `--force-with-lease` after rebase/amend
- Verify not on protected branch

## Success Criteria

- [ ] Not pushing to protected branch
- [ ] Using `-u` flag for new branches
- [ ] Using `--force-with-lease` (not `--force`) if needed
- [ ] Auto-retry with rebase if push rejected
- [ ] Push completed successfully
