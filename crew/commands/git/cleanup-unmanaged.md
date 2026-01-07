---
name: crew:git:cleanup-unmanaged
description: Delete local branches not in machete layout
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite, WebFetch, WebSearch, MCPSearch, Skill
---

<constraints>

**CRITICAL: NEVER output plain text questions. Use AskUserQuestion tool for all user choices.**

</constraints>

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh 2>&1`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<objective>
Clean up local branches that are not tracked in the machete layout file.
Useful for removing stale feature branches after PRs are merged.
</objective>

<process>

## Step 1: Identify Unmanaged Branches

```bash
echo "=== Branches in machete layout ==="
git machete list managed 2>/dev/null || cat .git/machete

echo
echo "=== Local branches NOT in layout ==="
git machete list unmanaged 2>/dev/null || {
    # Fallback: manual comparison
    all_branches=$(git branch --format='%(refname:short)')
    managed=$(cat .git/machete 2>/dev/null | grep -v '^[[:space:]]*$' | sed 's/^[[:space:]]*//' | cut -d' ' -f1)
    comm -23 <(echo "$all_branches" | sort) <(echo "$managed" | sort)
}
```

## Step 2: Dry Run First

```bash
# Show what would be deleted (dry run)
git machete delete-unmanaged --dry-run
```

## Step 3: Review and Confirm

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Delete the unmanaged branches listed above?",
      header: "Delete",
      options: [
        {
          label: "Yes, delete all",
          description: "Delete all unmanaged branches",
        },
        {
          label: "Select individually",
          description: "Choose which branches to delete",
        },
        { label: "No, keep all", description: "Don't delete any branches" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 4: Execute Deletion

**Delete all unmanaged:**

```bash
git machete delete-unmanaged --yes
```

**Delete specific branches:**

```bash
# For each selected branch
git branch -d <branch-name>

# Force delete if not fully merged
git branch -D <branch-name>
```

## Step 5: Clean Remote Tracking

```bash
# Prune remote tracking branches that no longer exist on remote
git fetch --prune

# Show any remaining stale remote refs
git branch -vv | grep ': gone]'
```

## Step 6: Verify

```bash
echo "=== Remaining branches ==="
git branch -a

echo
echo "=== Machete status ==="
git machete status
```

</process>

<protected_branches>

The following branches are typically NOT deleted even if unmanaged:

- `main` / `master`
- `develop` / `development`
- Current branch (can't delete checked-out branch)
- Branches with worktrees

**To delete anyway:**

```bash
git branch -D <branch-name>
```

</protected_branches>

<related_cleanup>

**Full cleanup workflow:**

```bash
# 1. Slide out merged branches from layout
Skill({ skill: "crew:git:slide-out" })

# 2. Delete unmanaged local branches
Skill({ skill: "crew:git:cleanup-unmanaged" })

# 3. Clean stale branches (deleted on remote)
Skill({ skill: "crew:git:clean" })

# 4. Prune remote tracking refs
git fetch --prune
```

**Or use the combined clean command:**

```javascript
Skill({ skill: "crew:git:clean" });
```

</related_cleanup>

<safe_deletion>

**Safe deletion** (`git branch -d`):

- Only deletes if branch is fully merged
- Fails if branch has unmerged commits
- Recommended for most cases

**Force deletion** (`git branch -D`):

- Deletes regardless of merge status
- Use with caution
- May lose unmerged work

**Check before force deleting:**

```bash
# See what commits would be lost
git log <branch> --not --remotes
```

</safe_deletion>

<success_criteria>

- [ ] Identified all unmanaged branches
- [ ] Reviewed branches before deletion
- [ ] Deleted appropriate branches
- [ ] Pruned remote tracking refs
- [ ] Verified remaining branches are correct

</success_criteria>
