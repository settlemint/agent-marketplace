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

1. **MCP commits go to the ACTIVE branch only** - `mcp__gitbutler__gitbutler_update_branches` does NOT create branches. Always check `but branch list` first to see which branch has the `*` marker.

2. **Create branch BEFORE making changes** - Run `but branch new <name>` first. This creates AND activates the branch.

3. **Unapplied branches must be applied before deletion** - `but branch delete` fails on unapplied branches. Apply first: `but branch apply <name> && but branch delete <name> -f`

4. **Branches with 0 commits ahead are stale** - After PR merge + `but base update`, clean up stale branches.

5. **Always sync after PR merges** - Run `but base update` to rebase and detect merged branches.

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

**MCP Auto-Commit (Preferred for AI workflows):**

```javascript
mcp__gitbutler__gitbutler_update_branches({
  fullPrompt: "User's original request",
  changesSummary: "- Added X\n- Modified Y",
  currentWorkingDirectory: "/path/to/project",
});

**CLI - Create and work on a branch:**

```bash
but branch new feature-name
# ... make changes ...
but commit -m "feat: add new feature"
but push feature-name

**Check upstream status:**

```bash
but base check    # View integration state
but base update   # Rebase on upstream changes

**Recovery:**

```bash
but oplog         # View operation history
but undo          # Revert last operation

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

</pattern>

<pattern name="parallel_features">
```bash
# Create multiple branches
but branch new feature-a
but branch new feature-b

# Assign files to specific branches (using rub)
but rub src/feature-a.ts feature-a
but rub src/feature-b.ts feature-b

# Commit each independently
but commit -m "feat(a): implement feature A"
but commit -m "feat(b): implement feature B"

</pattern>

<pattern name="recovery">
```bash
# Made a mistake? View history
but oplog

# Undo last operation

but undo

# Or restore to specific snapshot

but restore <snapshot-sha>

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

</pattern>

<pattern name="pre_commit_check">
```bash
# ALWAYS check active branch before committing
but branch list  # Look for * marker

# If wrong branch, create new one

but branch new feat/correct-branch

# Then commit (MCP or CLI)

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
