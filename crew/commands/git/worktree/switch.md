---
name: crew:git:worktree:switch
description: Switch to a different worktree
argument-hint: "[worktree name]"
allowed-tools:
  - Bash
  - AskUserQuestion
---

<phantom_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/phantom-context.sh`
</phantom_context>

<objective>

Switch to a different worktree. Ask user to select if no argument provided.

</objective>

<workflow>

## Step 1: List Available Worktrees

```bash
phantom list
```

## Step 2: Select Worktree (if no argument)

```javascript
const worktrees = Bash({ command: "phantom list --names" }).trim().split("\n");
AskUserQuestion({
  questions: [
    {
      question: "Which worktree?",
      header: "Worktree",
      options: worktrees.slice(0, 4).map((wt) => ({
        label: wt,
        description: `Switch to ${wt}`,
      })),
      multiSelect: false,
    },
  ],
});
```

## Step 3: Switch

```bash
wtPath=$(phantom where ${worktreeName})
cd "$wtPath"
pwd && git branch --show-current
```

</workflow>

<success_criteria>

- [ ] Worktree selected
- [ ] Directory changed to worktree path

</success_criteria>
