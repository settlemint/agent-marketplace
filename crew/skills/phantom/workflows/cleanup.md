---
name: cleanup
description: Workflow for cleaning up worktrees
---

<workflow>

## Cleanup Workflow

### Step 1: Ask What to Clean

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What would you like to clean up?",
      header: "Action",
      options: [
        { label: "Specific worktree", description: "Delete a named worktree" },
        { label: "Current worktree", description: "Delete the one you're in" },
        { label: "All merged", description: "Clean up all merged worktrees" },
        {
          label: "List first",
          description: "Show all worktrees before deciding",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

### Step 2: Handle Selection

**If "List first":**

```bash
phantom list
```

Then ask again what to delete.

**If "Specific worktree":**

```javascript
// Show available worktrees and let user select
const worktrees = Bash({ command: "phantom list --names" }).trim().split("\n");

AskUserQuestion({
  questions: [
    {
      question: "Which worktree do you want to delete?",
      header: "Worktree",
      options: worktrees.slice(0, 4).map((wt) => ({
        label: wt,
        description: `Delete ${wt} and its branch`,
      })),
      multiSelect: false,
    },
  ],
});
```

### Step 3: Confirm Deletion

```javascript
// Check for uncommitted changes
const status = Bash({ command: `phantom exec ${name} git status --porcelain` });
if (status.trim()) {
  AskUserQuestion({
    questions: [
      {
        question: `${name} has uncommitted changes. Delete anyway?`,
        header: "Confirm",
        options: [
          {
            label: "Force delete",
            description: "Delete and lose uncommitted work",
          },
          { label: "Cancel", description: "Keep the worktree" },
        ],
        multiSelect: false,
      },
    ],
  });
}
```

### Step 4: Execute Deletion

```bash
# Regular delete
phantom delete <name>

# Force delete if confirmed
phantom delete <name> --force
```

**Note:** After deleting current worktree, navigate elsewhere:

```bash
cd "$(git worktree list | head -1 | awk '{print $1}')"
```

### Cleanup Merged Worktrees

Pattern for cleaning up worktrees after PRs are merged:

```bash
# List all worktrees
for wt in $(phantom list --names); do
  # Check if branch is merged
  if git branch --merged main | grep -q "$wt"; then
    echo "Merged: $wt"
  fi
done
```

### Safe Cleanup Checklist

Before deleting a worktree:

1. **Check for uncommitted changes:**

   ```bash
   phantom exec <name> git status
   ```

2. **Check for unpushed commits:**

   ```bash
   phantom exec <name> git log origin/$(git branch --show-current)..HEAD
   ```

3. **Verify PR is merged (if applicable):**
   ```bash
   gh pr view --state merged
   ```

### preDelete Hooks

If you have cleanup commands in `phantom.config.json`:

```json
{
  "preDelete": {
    "commands": ["docker compose down", "rm -rf .cache"]
  }
}
```

These run automatically before deletion. If they fail, deletion is aborted.

### Recovery from Accidental Delete

Git worktree branches aren't immediately deleted from refs:

```bash
# Check if branch still exists
git branch -a | grep <name>

# If branch exists, recreate worktree
phantom attach <branch-name>

# Check reflog for recent activity
git reflog show <branch-name>
```

### Bulk Cleanup Script

```bash
#!/usr/bin/env bash
# Clean all merged worktrees

MAIN_BRANCH="${1:-main}"

for wt in $(phantom list --names); do
  # Skip main checkout
  if [[ "$wt" == "." ]]; then
    continue
  fi

  # Check if merged
  if git branch --merged "$MAIN_BRANCH" | grep -qw "$wt"; then
    echo "Deleting merged worktree: $wt"
    phantom delete "$wt"
  fi
done
```

</workflow>
