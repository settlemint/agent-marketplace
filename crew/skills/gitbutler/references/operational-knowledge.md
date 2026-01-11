<objective>

Critical operational knowledge and gotchas for working with GitButler. Read this BEFORE using GitButler commands to avoid common mistakes.

</objective>

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

# 2. List branches and check for stale ones
but branch list

# 3. For each branch with 0 commits ahead:
but branch show <branch-name>
# If "No commits ahead" → it's stale

# 4. Apply and delete stale branches
but branch apply <stale-branch>
but branch delete <stale-branch> -f
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

<pre_commit_checklist>

Before using MCP commit or `but commit`:

1. **Check active branch:** `but branch list`
2. **Verify it's the right one:** Look for `*` marker
3. **If wrong branch:** Create new one or switch: `but branch new <name>`
4. **Then commit:** Use MCP tool or `but commit`

**Example Flow:**

```bash
# Starting new work
but branch list                    # Check what's active
but branch new feat/my-feature     # Create and activate new branch
# ... make changes ...
# Use MCP tool to commit OR:
but commit -m "feat: add feature"
but push feat/my-feature
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
