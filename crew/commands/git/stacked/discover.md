---
name: crew:git:stacked:discover
description: Auto-detect branch layout from git reflog
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - AskUserQuestion
  - TodoWrite
  - WebFetch
  - WebSearch
  - MCPSearch
  - Skill
---

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh 2>&1`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<objective>
Auto-detect branch dependencies from git reflog and create a machete layout file.
</objective>

<process>

## Step 1: Check for Existing Layout

```bash
git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
machete_file="${git_common_dir}/machete"
if [[ -f "$machete_file" ]]; then
    echo "Existing layout found at $machete_file"
    cat "$machete_file"
fi
```

If layout exists:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "A machete layout already exists. What to do?",
      header: "Existing",
      options: [
        {
          label: "Keep existing",
          description: "Don't modify the current layout",
        },
        {
          label: "Re-discover",
          description: "Backup existing and create new layout",
        },
        { label: "Edit manually", description: "Open editor to modify layout" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 2: Run Discovery

```bash
# Backup existing layout if present
if [[ -f "$machete_file" ]]; then
    cp "$machete_file" "${machete_file}~"
    echo "Backed up existing layout to ${machete_file}~"
fi

# Run discovery (suggests layout based on reflog)
git machete discover --list-commits
```

## Step 3: Review and Confirm

Discovery shows a preview. Ask user to confirm:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Accept the discovered layout?",
      header: "Confirm",
      options: [
        {
          label: "Yes (Recommended)",
          description: "Accept the discovered layout",
        },
        {
          label: "Edit first",
          description: "Open editor to modify before saving",
        },
        { label: "Cancel", description: "Don't save, keep previous layout" },
      ],
      multiSelect: false,
    },
  ],
});
```

If "Yes":

```bash
git machete discover --yes
```

If "Edit first":

```bash
git machete discover --yes
git machete edit
```

## Step 4: Annotate with PRs

If GitHub PRs exist for branches:

```bash
# Annotate branches with PR numbers
git machete github anno-prs
```

## Step 5: Show Final Status

```bash
echo "=== Discovered Layout ==="
git machete status --list-commits
```

</process>

<discovery_tips>

**How discovery works:**

1. Analyzes git reflog to find branch creation points
2. Determines parent-child relationships from fork points
3. Creates hierarchy based on commit ancestry

**When discovery might be inaccurate:**

- Old branches with expired reflogs
- Branches created before git-machete was installed
- Complex merge histories

**Manual adjustment:**

```bash
# Edit layout file directly
git machete edit

# Add a branch to the layout
git machete add <branch> --onto <parent>

# Reorder branches
# Just edit the .git/machete file (indentation = hierarchy)
```

</discovery_tips>

<success_criteria>

- [ ] Layout file created at `.git/machete`
- [ ] All relevant branches included
- [ ] Parent-child relationships correct
- [ ] PR annotations added (if applicable)
- [ ] `git machete status` shows correct tree

</success_criteria>
