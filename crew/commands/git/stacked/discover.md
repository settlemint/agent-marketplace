---
name: crew:git:stacked:discover
description: Auto-detect branch layout from git reflog
allowed-tools:
  - Bash
  - AskUserQuestion
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

<workflow>

## Step 1: Check for Existing Layout

```bash
git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
machete_file="${git_common_dir}/machete"
if [[ -f "$machete_file" ]]; then
    echo "Existing layout found:"
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
if [[ -f "$machete_file" ]]; then
    cp "$machete_file" "${machete_file}~"
    echo "Backed up to ${machete_file}~"
fi
git machete discover --list-commits
```

## Step 3: Review and Confirm

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

If "Yes": `git machete discover --yes`
If "Edit first": `git machete discover --yes && git machete edit`

## Step 4: Annotate with PRs

```bash
git machete github anno-prs
```

## Step 5: Show Final Status

```bash
git machete status --list-commits
```

</workflow>

<success_criteria>

- [ ] Layout file created at `.git/machete`
- [ ] All relevant branches included
- [ ] Parent-child relationships correct
- [ ] PR annotations added

</success_criteria>
