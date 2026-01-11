<objective>

Understanding GitButler's virtual branches - how they differ from Git branches and how to work with them effectively.

</objective>

<core_concepts>

**What Are Virtual Branches?**

Virtual branches exist only within GitButler. They allow multiple independent lines of work in a single working directory simultaneously. Traditional Git requires checking out one branch at a time; GitButler removes this limitation.

**Key Differences from Git:**

| Aspect            | Git Branches                      | Virtual Branches              |
| ----------------- | --------------------------------- | ----------------------------- |
| Existence         | In `.git/refs/heads/`             | In GitButler state            |
| Working directory | One at a time                     | Multiple simultaneously       |
| Changes           | All uncommitted belong to current | Assigned to specific branches |
| Context switching | Requires checkout, stashing       | Instant - no stashing         |

**Lifecycle:**

1. Create virtual branch with `but branch new`
2. Assign changes to branch (automatic or via `but rub`)
3. Commit changes with `but commit`
4. Push to remote - becomes normal Git branch
5. After merge, branch auto-removed with `but base update`

</core_concepts>

<change_assignment>

Changes must be assigned to a virtual branch before committing. GitButler handles this automatically based on rules, or you can assign manually.

**Automatic Assignment:**

- New files in branch's directory pattern
- Changes matching content rules
- Files touched by Claude Code session

**Manual Assignment:**

```bash
# Assign file to branch
but rub path/to/file.ts my-branch

# Unassign file (back to unassigned state)
but rub path/to/file.ts 00
```

**Rules System:**

Rules auto-assign files to branches based on:

1. **Path Matches Regex** - File location patterns
2. **Content Matches Regex** - Changed line patterns
3. **Claude Code Session ID** - AI-generated rules (lower priority)

Multiple rules combine with AND logic. Rules evaluate sequentially.

</change_assignment>

<stacked_branches>

Virtual branches can be stacked for dependent changes:

```
main
  └── feature-base (PR #1 → main)
        └── feature-extension (PR #2 → feature-base)
              └── feature-polish (PR #3 → feature-extension)
```

**Creating stacks:**

```bash
but branch new feature-base
# ... work and commit ...
but branch new feature-extension
# ... work depending on feature-base ...
```

**Requirements for stacked PRs:**

- Enable GitHub automatic branch deletion
- Use "Merge" strategy (not squash) for cleaner experience
- Each PR targets its parent branch (except bottom → main)

</stacked_branches>

<applied_unapplied>

Branches exist in two states:

**Applied:** Active in working directory, changes visible
**Unapplied:** Hidden but preserved, changes not visible

```bash
# Hide branch without deleting
but branch unapply feature-branch

# Show branch again
but branch apply feature-branch

# List all branches (both states)
but branch list
```

Use unapply for:

- Temporarily setting aside work
- Reducing working directory complexity
- Preserving context for later

</applied_unapplied>

<conflict_handling>

GitButler handles conflicts differently than Git:

1. Stores conflicted commits rather than stopping rebase
2. Shows "Resolve conflict" button in UI
3. Direct file editing with conflict markers visible
4. Saves changes and rebases dependent commits automatically

**In CLI:**

```bash
# Check for conflicts after base update
but base check

# If conflicts exist, edit files directly
# Then commit the resolution
but commit -m "fix: resolve merge conflicts"
```

</conflict_handling>

<integration_with_git>

Virtual branches become Git branches when pushed:

```bash
# Virtual branch → Git branch
but push feature-branch
# Creates origin/feature-branch
```

**Direct Git access (escape hatch):**

```bash
# View virtual branch in Git
git show refs/gitbutler/feature-branch

# Manual push if needed
git push origin refs/gitbutler/feature:refs/heads/feature
```

**WIP commits:**
GitButler may create WIP (work-in-progress) commits to preserve uncommitted state. These are internal and auto-cleaned.

**Integration commits:**
When viewing applied state, GitButler creates integration commits showing combined branch state.

</integration_with_git>

<success_criteria>

- Understand difference between virtual and Git branches
- Know how to assign changes to branches
- Can create and manage stacked branches
- Understand applied/unapplied states
- Know how to resolve conflicts
- Can access virtual branches via Git when needed

</success_criteria>
