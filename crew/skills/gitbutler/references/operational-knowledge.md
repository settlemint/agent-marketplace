<objective>

Critical operational knowledge and gotchas for working with GitButler. Read this BEFORE using GitButler commands to avoid common mistakes.

</objective>

<lessons_learned>

**HARD-LEARNED LESSONS FROM REAL MISTAKES**

These mistakes were made in actual sessions. Don't repeat them.

1. **NEVER chain `but rub` commands** - The short IDs (g0, m1, at) are EPHEMERAL and change after every operation. `but rub g0 x && but rub m0 x` FAILS because IDs change after first rub. Run ONE rub at a time with `but status` between each.

2. **ALWAYS use MCP tool for commits** - The MCP tool (`mcp__gitbutler__gitbutler_update_branches`) handles file assignment automatically. It's much simpler than manual `but rub` commands.

3. **NEVER commit to a branch with merged PRs** - Check `gh pr list --head <branch> --state merged` before ANY commit. If merged PRs exist, create a new branch.

4. **NEVER use direct `git commit` with GitButler** - GitButler tracks its own state. Direct git commits break this. Always use `but commit` or the MCP tool.

5. **ALWAYS sync BEFORE making changes** - Run `Bash({ command: "but base update" })` FIRST. If it fails due to uncommitted changes, you're already in trouble.

6. **ALWAYS verify branch is active after creating** - `but branch new` may not activate the branch. Check `but branch list` and look for `*` marker. If not active, run `but branch apply <name>`.

7. **HunkLocks are permanent** - If GitButler shows `🔒` on a file, changes to those lines are bound to existing commits. You can't move them to a new branch.

8. **`but commit` shows "unknown" when it fails silently** - If commit shows `Created commit unknown`, check `but branch show <name>` to verify. 0 commits ahead = commit failed.

9. **Don't mix concerns on branches** - Create new branches for new work. Don't add unrelated commits to existing branches.

</lessons_learned>

<ephemeral_ids>

**CRITICAL: `but status` IDs are Ephemeral**

The short IDs shown in `but status` output (like `g0`, `m1`, `at`) change after EVERY operation.

```
╭┄00 [Unassigned Changes]
┊   g0 M file1.ts        ← These IDs
┊   m0 M file2.ts        ← Change after
┊   r0 M file3.ts        ← EVERY operation
```

**WRONG - Will fail:**

```bash
# IDs change after first rub, second command fails
but rub g0 branch && but rub m0 branch && but rub r0 branch
```

**CORRECT - One at a time:**

```bash
but status           # g0=file1, m0=file2, r0=file3
but rub g0 branch    # Assign file1
but status           # NOW: h0=file2, i0=file3 (IDs CHANGED!)
but rub h0 branch    # Assign file2 (use NEW ID)
but status           # NOW: j0=file3 (ID CHANGED AGAIN!)
but rub j0 branch    # Assign file3
```

**BEST - Use MCP tool instead:**

```javascript
// Handles assignment automatically - no ID issues
mcp__gitbutler__gitbutler_update_branches({
  fullPrompt: "...",
  changesSummary: "...",
  currentWorkingDirectory: "...",
});
```

</ephemeral_ids>

<critical_gotchas>

**MCP Commits Go To The Active Branch**

The `mcp__gitbutler__gitbutler_update_branches` tool commits to whichever branch is currently **applied and active**. It does NOT create a new branch.

```javascript
// WRONG assumption: This creates a new branch and commits to it
mcp__gitbutler__gitbutler_update_branches({...})

// CORRECT understanding: This commits to the ACTIVE branch
// Check active branch first with: but branch list
```

Before using the MCP commit tool:

1. Run `but branch list` to see which branch is active (marked with `*`)
2. If you need a new branch: `but branch new <name>` first
3. Then make changes
4. Then use the MCP tool to commit

**Creating vs Activating Branches**

`but branch new <name>` both creates AND activates a branch. The new branch becomes the active target for commits.

```bash
but branch new feat/new-feature   # Creates AND activates
# Now all changes will be assigned to feat/new-feature
```

**Unapplied Branches Cannot Be Deleted Directly**

You must apply a branch before you can delete it:

```bash
# This FAILS for unapplied branches:
but branch delete old-branch
# Error: Branch 'old-branch' not found in any stack

# This WORKS:
but branch apply old-branch
but branch delete old-branch -f
```

**Branches With 0 Commits Ahead Are Stale**

After a PR merges and you run `but base update`, branches that were merged show `0 commits ahead`. These are stale and should be cleaned up:

```bash
but branch list
# Shows: rvdv-branch-1 (0 commits ahead) ← STALE, should delete

but branch show <branch-name>
# If "No commits ahead of base branch" → delete it
```

**but base update Cleans Integrated Branches**

After merging PRs upstream, always run:

```bash
but base update
```

This:

- Rebases active branches on latest upstream
- Marks integrated branches as `0 commits ahead`
- Does NOT auto-delete them (you must clean up manually)

</critical_gotchas>

<branch_states>

GitButler branches exist in different states:

| State              | Visible in Working Dir | Can Commit | Can Delete       |
| ------------------ | ---------------------- | ---------- | ---------------- |
| Applied (active)   | Yes                    | Yes        | Yes              |
| Applied (inactive) | Yes                    | Yes        | Yes              |
| Unapplied          | No                     | No         | Must apply first |

**Checking Branch State:**

```bash
but branch list
# Applied Branches:
# 00   active  ✗ *current-branch   ← Active (commits go here)
# 01   active    other-branch      ← Applied but not active
#
# Unapplied Branches:
# 02   local   ✓ old-branch        ← Hidden, must apply to delete
```

**The asterisk (\*) marks the active branch** where MCP commits go.

</branch_states>

<cleanup_workflow>

**After Merging PRs:**

```bash
# 1. Update base to detect merged branches
but base update

# 2. Check if ACTIVE branch has merged PRs
gh pr list --head <active-branch> --state merged
# If merged PRs exist → DO NOT commit to this branch!
# Create a new branch for new work instead.

# 3. List branches and check for stale ones
but branch list

# 4. For each branch with 0 commits ahead:
but branch show <branch-name>
# If "No commits ahead" → it's stale

# 5. Apply and delete stale branches
but branch apply <stale-branch>
but branch delete <stale-branch> -f
```

**CRITICAL: Check for Merged PRs Before Committing**

Even if a branch shows commits ahead, it may have already-merged PRs. New commits to such branches are orphaned and won't be part of any PR.

```bash
# Before ANY commit, check:
gh pr list --head $(but branch list | grep '\*' | awk '{print $NF}') --state merged

# If any PRs are merged, create a new branch:
but branch new feat/new-work
```

**Quick Cleanup Script:**

```bash
# List branches as JSON and find stale ones
but branch -j | jq -r '.branches[] | select(.commitsAhead == 0) | .name'

# Then for each stale branch:
for branch in $(but branch -j | jq -r '.branches[] | select(.commitsAhead == 0) | .name'); do
  but branch apply "$branch" && but branch delete "$branch" -f
done
```

</cleanup_workflow>

<pre_work_checklist>

**BEFORE STARTING ANY NEW WORK:**

1. **Sync with upstream:** `Bash({ command: "but base update" })`
2. **Check for merged PRs on active branch:** `Bash({ command: "gh pr list --head <active-branch> --state merged" })`
3. **If merged PRs exist:** Create a new branch for new work
4. **Verify active branch:** `Bash({ command: "but branch list" })` - look for `*` marker

</pre_work_checklist>

<pre_commit_checklist>

**BEFORE ANY COMMIT:**

1. **Check active branch:** `Bash({ command: "but branch list" })`
2. **Verify it's the right one:** Look for `*` marker
3. **Check no merged PRs:** `Bash({ command: "gh pr list --head <branch> --state merged" })`
4. **If wrong branch or has merged PRs:** Create new branch: `Bash({ command: "but branch new feat/<name>" })`
5. **Verify new branch is active:** Check for `*` marker again
6. **Then commit:** Use MCP tool or `but commit`

**Example Flow:**

```javascript
// Starting new work - ALWAYS sync first
Bash({ command: "but base update" });

// Check what's active and if it has merged PRs
Bash({ command: "but branch list" });
Bash({ command: "gh pr list --head <active-branch> --state merged" });

// If merged PRs exist or wrong branch, create new one
Bash({ command: "but branch new feat/my-feature" });

// Verify new branch is active (CRITICAL!)
Bash({ command: "but branch list" });
// If not active: Bash({ command: "but branch apply feat/my-feature" });

// ... make changes ...

// Commit (only after verification)
mcp__gitbutler__gitbutler_update_branches({...});
// OR: Bash({ command: 'but commit -m "feat: add feature"' });

// Push when ready
Bash({ command: "but push feat/my-feature" });
```

</pre_commit_checklist>

<mcp_vs_cli>

**When to Use MCP Tool:**

- AI-driven workflows where context should flow to commit message
- Automated commits after code changes
- When you want GitButler to auto-assign files

**When to Use CLI:**

- Manual commits with specific messages
- Complex operations (squash, amend, rub)
- Recovery operations (undo, restore)
- Cleanup and maintenance

**MCP Tool Parameters:**

| Parameter                 | Required | Purpose                           |
| ------------------------- | -------- | --------------------------------- |
| `fullPrompt`              | Yes      | Original user request for context |
| `changesSummary`          | Yes      | Bullet list of what changed       |
| `currentWorkingDirectory` | Yes      | Project path                      |

The MCP tool:

- Auto-detects which files changed
- Assigns them to active branch
- Generates commit message from context
- Creates the commit

</mcp_vs_cli>

<success_criteria>

- Understand MCP commits go to active branch only
- Check branch state before committing
- Clean up stale branches after PR merges
- Apply unapplied branches before deleting
- Use appropriate tool (MCP vs CLI) for the task

</success_criteria>
