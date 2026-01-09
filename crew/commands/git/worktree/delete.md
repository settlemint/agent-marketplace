---
name: crew:git:worktree:delete
description: Delete a phantom worktree and its branch
argument-hint: "<worktree-name>"
allowed-tools:
  - Bash
  - AskUserQuestion
---

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
