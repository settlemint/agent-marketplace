---
name: crew:git:worktree:delete
description: Delete a phantom worktree and its branch
argument-hint: "<worktree-name>"
allowed-tools:
  - Bash
  - AskUserQuestion
---

<process>

**Confirm deletion if worktree has uncommitted changes:**

```javascript
// Check for uncommitted changes
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

**Delete the worktree:**

```bash
# Regular delete
phantom delete <name>

# Force delete if confirmed
phantom delete <name> --force
```

</process>
