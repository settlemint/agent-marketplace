---
name: crew:git:stacked:status
description: Show git-machete branch stack status
allowed-tools:
  - Bash
  - AskUserQuestion
  - Skill
context: fork
hooks:
  PostToolUse: false
  PreToolUse: false
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<gitbutler_incompatible>

**This command does not work with GitButler.**

If `GITBUTLER_ACTIVE=true` from `<butler_context>`:

```
Stacked branches (git-machete) are not compatible with GitButler virtual branches.

GitButler has its own stacking system. Use these instead:
- `crew:git:butler:status` - View virtual branches
- `crew:git:butler:branch` - Create virtual branch
- `crew:git:butler:sync` - Sync with upstream

To use machete, first disable GitButler in this repository.
```

Exit immediately. Do not proceed with machete commands.

</gitbutler_incompatible>

<objective>

Show stack status with edge colors. Suggest actions for issues.

</objective>

<edge_colors>

| Color       | Meaning            | Action                           |
| ----------- | ------------------ | -------------------------------- |
| 🟢 Green    | In sync            | None                             |
| 🟡 Yellow   | Sync, fork differs | May need investigation           |
| 🔴 Red      | Out of sync        | Run `crew:git:stacked:traverse`  |
| ⚫ Gray (o) | Merged             | Run `crew:git:stacked:slide-out` |

</edge_colors>

<workflow>

## Step 1: Check for Layout

If no layout:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "No layout found. What to do?",
      header: "Setup",
      options: [
        {
          label: "Discover (Recommended)",
          description: "Auto-detect from history",
        },
        { label: "Skip", description: "Continue without machete" },
      ],
      multiSelect: false,
    },
  ],
});
```

If "Discover": `Skill({ skill: "crew:git:stacked:discover" })`

## Step 2: Update Annotations

```bash
git machete github anno-prs 2>/dev/null || true
```

## Step 3: Show Status

```bash
git machete status --list-commits
```

## Step 4: Suggest Actions

If red edges: "Run `crew:git:stacked:traverse` to sync"
If gray edges: "Run `crew:git:stacked:slide-out` to clean up"
If all green: "All branches in sync"

</workflow>

<success_criteria>

- [ ] Status displayed
- [ ] Issues identified
- [ ] Actions suggested

</success_criteria>
