---
name: crew:git:worktree-switch
description: Switch to a different worktree
argument-hint: "[worktree name]"
allowed-tools:
  - Bash
  - AskUserQuestion
skills:
  - crew:phantom
---

<phantom_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/phantom-context.sh`
</phantom_context>

<notes>
Switches the current shell session to a different worktree using cd.
</notes>

<process>

<phase name="list-worktrees">
**Get available worktrees:**

```bash
phantom list
```

</phase>

<phase name="select-worktree">
**If no argument provided, ask user to select:**

```javascript
// Get worktree names
const worktrees = Bash({ command: "phantom list --names" }).trim().split("\n");

AskUserQuestion({
  questions: [
    {
      question: "Which worktree do you want to switch to?",
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

</phase>

<phase name="switch">
**Switch to the selected worktree:**

```bash
# Get the worktree path
wtPath=$(phantom where <worktreeName>)

# Switch to it
cd "$wtPath"

# Verify the switch
pwd
git branch --show-current
```

</phase>

<phase name="confirm">
**Confirm the switch:**

```
Switched to worktree: <worktreeName>
Location: <path>
Branch: <branch>
```

</phase>

</process>

<success_criteria>

- [ ] Worktree selected (from arg or prompt)
- [ ] Directory changed to worktree path
- [ ] Current branch confirmed

</success_criteria>
