---
name: sync
description: Sync branch with main via merge or rebase
user_invocable: true
command: /sync
---

<context>
!`${SKILL_ROOT}/scripts/context.sh`
</context>

<objective>
Sync current branch with main (or specified base): fetch, merge/rebase, resolve conflicts, push.
</objective>

<workflow>

1. **Set base:** Default to main if not provided
2. **Fetch:** Get latest from origin
3. **Merge or rebase:** Choose based on context
4. **Resolve conflicts:** Fix each conflict, stage files
5. **Push:** Normal push after merge, `--force-with-lease` after rebase

</workflow>

<commands>

```bash
# Set base branch
BASE="${1:-main}"

# Fetch latest
git fetch origin "$BASE"

# Merge (preserves history, creates merge commit)
git merge "origin/$BASE" --no-edit

# OR Rebase (linear history, rewrites commits)
git rebase "origin/$BASE"

# After merge conflicts resolved
git add <resolved-files>
git commit -m "merge: resolve conflicts with $BASE"

# After rebase conflicts resolved
git add <resolved-files>
git rebase --continue

# Push after merge
git push

# Push after rebase (history rewritten)
git push --force-with-lease
```

</commands>

<conflict_resolution>

**Common conflict patterns:**

| Pattern | Resolution |
|---------|------------|
| Version bumps | Keep higher version |
| Added vs deleted | Usually keep addition |
| Both modified same line | Combine or choose based on intent |
| Import order | Keep alphabetical, include both |
| Config changes | Merge settings from both |

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
- Keep neither: Write new version

**CRITICAL:** Remove ALL conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)

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
- Haven't pushed yet (or willing to force-push)

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

- [ ] Fetched latest from origin
- [ ] Merged/rebased without unresolved conflicts
- [ ] No conflict markers in any files
- [ ] All tests pass after sync
- [ ] Pushed successfully

</success_criteria>
