---
name: sync
description: Sync branch with main and resolve conflicts. Use when asked to "sync with main", "merge main", "update branch", or "pull latest".
license: MIT
user_invocable: true
command: /sync
argument-hint: "[base branch, defaults to main]"
triggers:
  - "sync"
  - "sync with main"
  - "merge main"
  - "update branch"
  - "pull latest"
  - "rebase"
---

<objective>
Sync current branch with main (or specified base): fetch, merge/rebase, resolve conflicts, push.
</objective>

<quick_start>

1. **Set base:** `BASE=${1:-main}` (defaults to main if not provided)
2. **Fetch:** `git fetch origin $BASE`
3. **Merge:** `git merge origin/$BASE` (or rebase if preferred)
4. **Resolve conflicts:** Fix each conflict, stage files
5. **Push:** `git push --force-with-lease` (if rebased)

</quick_start>

<workflow>

**Step 1: Set base branch and check state**

```bash
# Use provided base branch or default to main
BASE="${1:-main}"
git status
git branch --show-current
```

**Step 2: Fetch latest from base branch**

```bash
git fetch origin "$BASE"
```

**Step 3: Merge or rebase**

```bash
# Merge (preserves history, creates merge commit)
git merge "origin/$BASE" --no-edit

# OR Rebase (linear history, rewrites commits)
git rebase "origin/$BASE"
```

**Step 4: Resolve conflicts (if any)**

For each conflicted file:

1. Open the file and look for conflict markers:
   ```
   <<<<<<< HEAD
   your changes
   =======
   incoming changes
   >>>>>>> origin/$BASE
   ```

2. Decide which version to keep:
   - Keep yours: Remove incoming section
   - Keep theirs: Remove your section
   - Keep both: Combine logically
   - Keep neither: Write new version

3. Remove ALL conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)

4. Stage the resolved file:
   ```bash
   git add <resolved-file>
   ```

**Step 5: Complete merge/rebase**

```bash
# After merge conflicts resolved
git commit -m "merge: resolve conflicts with $BASE"

# After rebase conflicts resolved
git rebase --continue
```

**Step 6: Push**

```bash
# After merge
git push

# After rebase (history rewritten)
git push --force-with-lease
```

</workflow>

<conflict_resolution>

**Common conflict patterns:**

| Pattern | Resolution |
|---------|------------|
| Version bumps | Keep higher version |
| Added vs deleted | Usually keep addition |
| Both modified same line | Combine or choose based on intent |
| Import order | Keep alphabetical, include both |
| Config changes | Merge settings from both |

**Version conflict example:**

```json
<<<<<<< HEAD
  "version": "1.39.0",
=======
  "version": "1.38.2",
>>>>>>> origin/main
```

Resolution: Keep `1.39.0` (higher version)

**Code conflict example:**

```typescript
<<<<<<< HEAD
function processData(data: Data) {
  return transform(data);
}
=======
function processData(input: Data) {
  return validate(input);
}
>>>>>>> origin/main
```

Resolution: Combine both changes:
```typescript
function processData(data: Data) {
  return transform(validate(data));
}
```

</conflict_resolution>

<merge_vs_rebase>

| Aspect | Merge | Rebase |
|--------|-------|--------|
| History | Preserves branches | Linear |
| Commit | Creates merge commit | Rewrites commits |
| Push | Normal push | Force push required |
| Shared branch | Safe | Dangerous |
| Feature branch | OK | Preferred |

**Use merge when:**
- Branch is shared with others
- Want to preserve full history
- Already pushed commits

**Use rebase when:**
- Solo feature branch
- Want clean linear history
- Haven't pushed yet

</merge_vs_rebase>

<abort_options>

If things go wrong:

```bash
# Abort merge in progress
git merge --abort

# Abort rebase in progress
git rebase --abort

# Reset to before sync (if already committed)
git reset --hard ORIG_HEAD
```

</abort_options>

<constraints>

**Banned:**
- `git push --force` (use `--force-with-lease` instead)
- Rebasing shared/public branches
- Leaving conflict markers in files
- Committing without resolving all conflicts

**Required:**
- Fetch before merge/rebase
- Resolve ALL conflicts before committing
- Use `--force-with-lease` after rebase
- Verify build passes after conflict resolution

</constraints>

<success_criteria>

1. [ ] Fetched latest from origin
2. [ ] Merged/rebased without unresolved conflicts
3. [ ] No conflict markers in any files
4. [ ] All tests pass after sync
5. [ ] Pushed successfully

</success_criteria>
