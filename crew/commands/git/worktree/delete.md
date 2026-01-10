---
name: crew:git:worktree:delete
description: Delete a phantom worktree and its branch
argument-hint: "<worktree-name>"
allowed-tools:
  - Bash
  - AskUserQuestion
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<gitbutler_incompatible>

**This command does not work with GitButler.**

If `GITBUTLER_ACTIVE=true` from `<butler_context>`:

```
Git worktrees are not compatible with GitButler virtual branches.

GitButler uses virtual branches instead of worktrees for parallel development.
All virtual branches exist in the same working directory simultaneously.

Use these instead:
- `crew:git:butler:status` - View virtual branches
- `but branch delete <name>` - Delete virtual branch

To use worktrees, first disable GitButler in this repository.
```

Exit immediately. Do not proceed with worktree commands.

</gitbutler_incompatible>

<objective>

Delete worktree. Confirm if uncommitted changes exist.

</objective>

<workflow>

## Step 1: Check for Uncommitted Changes

```javascript
const status = Bash({ command: `phantom exec ${name} git status --porcelain` });
if (status.trim()) {
  AskUserQuestion({
    questions: [
      {
        question: `Worktree ${name} has uncommitted changes. Delete anyway?`,
        header: "Confirm",
        options: [
          {
            label: "Delete with changes",
            description: "Force delete, losing uncommitted work",
          },
          { label: "Cancel", description: "Keep the worktree" },
        ],
        multiSelect: false,
      },
    ],
  });
}
```

## Step 2: Delete Worktree

```bash
phantom delete ${name}        # Regular delete
phantom delete ${name} --force  # If confirmed with uncommitted changes
```

</workflow>

<success_criteria>

- [ ] Uncommitted changes confirmed (if any)
- [ ] Worktree deleted

</success_criteria>
