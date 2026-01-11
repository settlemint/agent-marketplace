---
name: gitbutler
description: GitButler virtual branch management and Butler Flow workflow. Use when working with GitButler, virtual branches, the `but` CLI, or parallel feature development without context switching.
triggers:
  - "gitbutler"
  - "\\bbut\\b"
  - "virtual branch"
  - "butler"
---

<objective>

GitButler reimagines source code management with virtual branches - work on multiple independent branches simultaneously in a single working directory. This skill guides usage of the `but` CLI and MCP server for branch management, commits, and AI integration.

</objective>

<critical_warnings>

**READ BEFORE USING ANY GITBUTLER COMMAND**

1. **PREFER MCP TOOL OVER `but rub` FOR COMMITS** - The MCP tool (`mcp__gitbutler__gitbutler_update_branches`) handles file assignment automatically. Use it instead of manual `but rub` commands whenever possible.

2. **`but status` IDs ARE EPHEMERAL** - The short IDs shown in `but status` (like `g0`, `m1`, `at`) change after EVERY operation. NEVER chain multiple `but rub` commands - each rub changes all subsequent IDs. If you must use `but rub`, run ONE command, then `but status` again to get new IDs.

3. **MCP commits go to the ACTIVE branch only** - `mcp__gitbutler__gitbutler_update_branches` does NOT create branches. Always check `but branch list` first to see which branch has the `*` marker.

4. **`but branch new` may NOT activate the new branch** - After creating, VERIFY the new branch is active by checking for `*` marker. If not active, run `but branch apply <name>` before committing.

5. **ALWAYS verify active branch before ANY commit** - Check `but branch list` immediately before using MCP tool or `but commit`. The active branch (`*`) receives all commits.

6. **Unapplied branches must be applied before deletion** - `but branch delete` fails on unapplied branches. Apply first: `but branch apply <name> && but branch delete <name> -f`

7. **Branches with 0 commits ahead are stale** - After PR merge + `but base update`, clean up stale branches with `crew:git:butler:cleanup`.

8. **Don't reuse old branch names** - Create new branches with meaningful names for each task. Never commit unrelated work to an existing branch.

See `references/operational-knowledge.md` for detailed gotchas and workflows.

</critical_warnings>

<essential_principles>

**Virtual Branches Are Different**

Virtual branches exist only in GitButler, not as traditional Git branches. All uncommitted changes must belong to a virtual branch. Changes are "assigned" to branches before committing, then pushed as normal Git branches for review.

**Butler Flow**

1. Work stems from a "target branch" (typically `origin/main`)
2. Changes immediately exist in virtual branches
3. Share early with team via push
4. Test integration locally before merging
5. Branches auto-cleanup when integrated

**MCP Server Available**

GitButler provides an MCP server enabling AI tools to manage commits automatically. Use `mcp__gitbutler__gitbutler_update_branches` to auto-commit changes with context.

</essential_principles>

<quick_start>

**Starting New Work (ALWAYS do this first):**

```javascript
// 1. Sync with upstream
Bash({ command: "but base update" });

// 2. Check if active branch has merged PRs
Bash({ command: "gh pr list --head <active-branch> --state merged" });

// 3. If merged PRs exist, create new branch
Bash({ command: "but branch new feat/my-feature" });

// 4. Verify new branch is active (look for *)
Bash({ command: "but branch list" });
```

**MCP Auto-Commit (Preferred for AI workflows):**

```javascript
mcp__gitbutler__gitbutler_update_branches({
  fullPrompt: "User's original request",
  changesSummary: "- Added X\n- Modified Y",
  currentWorkingDirectory: "/path/to/project",
});
```

**CLI - Create and work on a branch:**

```bash
but branch new feature-name
# ... make changes ...
but commit -m "feat: add new feature"
but push feature-name
```

**Check upstream status:**

```bash
but base check    # View integration state
but base update   # Rebase on upstream changes
```

**Recovery:**

```bash
but oplog         # View operation history
but undo          # Revert last operation
```

</quick_start>

<routing>

| Task                    | Resource                              |
| ----------------------- | ------------------------------------- |
| **Gotchas & workflows** | `references/operational-knowledge.md` |
| CLI commands            | `references/cli-commands.md`          |
| Virtual branch concepts | `references/virtual-branches.md`      |
| MCP/AI integration      | `references/mcp-integration.md`       |

</routing>

<common_patterns>

<pattern name="ai_workflow">
```javascript
// After making code changes, auto-commit with context
mcp__gitbutler__gitbutler_update_branches({
  fullPrompt: "Add user authentication with login form",
  changesSummary: "- Created auth controller\n- Added login component\n- Updated routes",
  currentWorkingDirectory: process.cwd()
})
// Then push when ready
// but push branch-name
```
</pattern>

<pattern name="typical_workflow">
```bash
# Start feature
but branch new add-user-auth

# Work and commit iteratively

but commit -m "feat: add login form"
but commit -m "feat: add session handling"

# Push for review

but push add-user-auth

# After upstream merge

but base update
```
</pattern>

<pattern name="parallel_features">
```bash
# Create multiple branches
but branch new feature-a
but branch new feature-b

# IMPORTANT: File assignment happens automatically based on ownership rules

# Or use MCP tool which handles assignment automatically

# For manual assignment, run ONE rub at a time:

but status # Get current IDs
but rub g0 feature-a # Assign one file
but status # IDs changed! Get new IDs
but rub h0 feature-b # Assign next file

# Better: Use MCP tool which handles everything

mcp__gitbutler__gitbutler_update_branches({ ... })
```
</pattern>

<pattern name="recovery">
```bash
# Made a mistake? View history
but oplog

# Undo last operation

but undo

# Or restore to specific snapshot

but restore <snapshot-sha>
```
</pattern>

<pattern name="cleanup_stale_branches">
```bash
# After PR merges - sync and cleanup
but base update

# Check for stale branches (0 commits ahead)

but branch list

# For each stale unapplied branch:

but branch apply <stale-branch>
but branch delete <stale-branch> -f

# Or use crew command:

# crew:git:butler:cleanup
```
</pattern>

<pattern name="pre_commit_check">
```bash
# ALWAYS check active branch before committing
but branch list  # Look for * marker

# If wrong branch, create new one

but branch new feat/correct-branch

# Then commit (MCP or CLI)
```
</pattern>

<pattern name="explicit_branch_assignment">
```javascript
// RECOMMENDED: Use MCP tool directly - it handles assignment automatically
// The MCP tool assigns changes to the active branch

// 1. First, ensure target branch exists and is active
Bash({ command: "but branch new feat/my-feature" });
Bash({ command: "but status" }); // Verify branch is active (has *)

// 2. Use MCP tool - it commits to the active branch
mcp__gitbutler__gitbutler_update_branches({
  fullPrompt: "Original user request",
  changesSummary: "- Change 1\n- Change 2",
  currentWorkingDirectory: process.cwd()
});

// WARNING: Do NOT loop over files with `but rub` - IDs are ephemeral!
// Each rub operation changes all subsequent IDs.
// If you must use rub, run ONE at a time with `but status` between each.
```
</pattern>

<pattern name="pr_fix_workflow">
```javascript
// When fixing PR comments, ensure changes go to the PR's branch:

// 1. Get PR branch name
const prBranch = Bash({ command: "gh pr view --json headRefName -q '.headRefName'" });

// 2. Check if PR branch exists as virtual branch and is active
Bash({ command: "but status" });
// Look for the branch in the output - it should have * marker

// 3. Make your fixes
// ...

// 4. Use MCP tool to commit (commits to active branch)
mcp__gitbutler__gitbutler_update_branches({
  fullPrompt: "Fix PR review comments",
  changesSummary: "- Fixed issue X\n- Addressed comment Y",
  currentWorkingDirectory: process.cwd()
});

// 5. Push the branch
Bash({ command: `but push ${prBranch}` });
```
</pattern>

</common_patterns>

<success_criteria>

- Virtual branches created for features
- Changes assigned to appropriate branches
- Commits follow conventional format (via MCP or CLI)
- Branches pushed for review
- Integration tested with `but base check`
- Stale branches cleaned up after PR merges

</success_criteria>
