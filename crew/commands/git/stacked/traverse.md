---
name: crew:git:stacked:traverse
description: Sync all stacked branches with parents and remotes
allowed-tools:
  - Bash
  - AskUserQuestion
  - Skill
---

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh 2>&1`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<objective>

Sync all branches in the machete stack with their parents and remotes.

</objective>

<workflow>

## Step 1: Check Layout

If no machete layout:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "No git-machete layout. What to do?",
      header: "Setup",
      options: [
        {
          label: "Discover layout (Recommended)",
          description: "Auto-detect from history",
        },
        { label: "Skip", description: "Continue without machete" },
      ],
      multiSelect: false,
    },
  ],
});
```

If "Discover layout": `Skill({ skill: "crew:git:stacked:discover" })`

## Step 2: Handle Worktree

If `<worktree_status>` shows worktree:

```javascript
AskUserQuestion({
  questions: [
    {
      question:
        "You're in a worktree. Full traverse would switch branches. What to do?",
      header: "Worktree",
      options: [
        {
          label: "Update current only (Recommended)",
          description: "Run 'git machete update'",
        },
        {
          label: "Show instructions",
          description: "Manual steps for each worktree",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

Update current only:

```bash
git fetch origin
git machete update
git push --force-with-lease
```

## Step 3: Ask Sync Mode (main checkout only)

```javascript
AskUserQuestion({
  questions: [
    {
      question: "How should traverse handle GitHub PRs?",
      header: "PR Sync",
      options: [
        { label: "Local only", description: "Just rebase branches locally" },
        {
          label: "Retarget PRs (Recommended)",
          description: "Update PR base branches on GitHub",
        },
        {
          label: "Full sync",
          description: "Retarget + update PR descriptions",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 4: Execute Traverse

**Local only:**

```bash
git machete traverse -W -y
```

**Retarget PRs:**

```bash
git machete traverse -W -y -H
```

**Full sync:**

```bash
git machete traverse -W -y -H
git config machete.github.prDescriptionIntroStyle full
git machete github update-pr-descriptions --related
```

## Step 5: Check for Merged Branches

```bash
merged=$(git machete status 2>/dev/null | grep -cE "^\s*o\s" || echo "0")
if [[ "$merged" -gt 0 ]]; then
    echo "$merged merged branch(es) detected"
fi
```

If merged branches:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Merged branches detected. Clean them up?",
      header: "Cleanup",
      options: [
        {
          label: "Yes (Recommended)",
          description: "Slide out merged branches",
        },
        { label: "No", description: "Keep them in the layout" },
      ],
      multiSelect: false,
    },
  ],
});
```

If yes: `Skill({ skill: "crew:git:stacked:slide-out" })`

</workflow>

<flags>

| Flag | Effect                        |
| ---- | ----------------------------- |
| `-W` | Fetch + traverse entire tree  |
| `-y` | Auto-confirm all prompts      |
| `-H` | Include GitHub PR retargeting |
| `-n` | No push (rebase only)         |

</flags>

<success_criteria>

- [ ] All branches rebased onto parents
- [ ] Changes pushed to remotes
- [ ] PRs retargeted (if selected)
- [ ] Merged branches cleaned up (if any)

</success_criteria>
