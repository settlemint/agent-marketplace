---
name: crew:git:stacked:traverse
description: Sync all stacked branches with parents and remotes
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
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<process>

**If no machete layout:**

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
        { label: "Create manually", description: "Open editor" },
        { label: "Skip", description: "Continue without machete" },
      ],
      multiSelect: false,
    },
  ],
});
```

If "Discover layout":

```javascript
Skill({ skill: "crew:git:stacked:discover" });
```

**If in a WORKTREE:**

⚠️ Full traverse would switch branches, breaking this worktree's checkout.

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
          description: "Run 'git machete update' for this branch",
        },
        {
          label: "Show instructions",
          description: "Manual steps for each worktree",
        },
      ],
    },
  ],
});
```

**Update current only:**

```bash
git fetch origin
git machete update                # Rebase onto parent
git push --force-with-lease       # Push updated branch
```

**Show instructions:**

Print for each branch in stack:

```
To sync your stack across worktrees:

1. In worktree for <parent-branch>:
   git pull --rebase origin main
   git push

2. In worktree for <child-branch>:
   git machete update
   git push --force-with-lease

3. Repeat for each child...
```

**If in MAIN checkout (not a worktree):**

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

# Ensure config is set for update-pr-descriptions
git config machete.github.prDescriptionIntroStyle full

# Update all related PR descriptions with stack chain
git machete github update-pr-descriptions --related
```

## Post-Traverse Actions

After traverse completes, check for merged branches:

```bash
# Check for merged branches (gray edges)
merged=$(git machete status 2>/dev/null | grep -cE "^\s*o\s" || echo "0")
if [[ "$merged" -gt 0 ]]; then
    echo "🔀 $merged merged branch(es) detected"
fi
```

If merged branches found:

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

If yes:

```javascript
Skill({ skill: "crew:git:stacked:slide-out" });
```

Report: branches rebased, pushed, needing manual intervention.

</process>

<flags>

| Flag                    | Effect                                       |
| ----------------------- | -------------------------------------------- |
| `-W`                    | Fetch + traverse entire tree (whole)         |
| `-y`                    | Auto-confirm all prompts (yes)               |
| `-H`                    | Include GitHub PR retargeting (github-sync)  |
| `-n`                    | No push (rebase only, don't push)            |
| `-M`                    | Detect merged branches and suggest slide-out |
| `--start-from=<branch>` | Start traverse from specific branch          |
| `--return-to=<branch>`  | Return to branch after traverse              |

</flags>

<common_patterns>

**Daily sync workflow:**

```bash
# Full sync with PR updates
git machete traverse -W -y -H
```

**Quick local rebase:**

```bash
# No push, no GitHub sync
git machete traverse -W -y -n
```

**After parent PR merged:**

```bash
# Slide out merged, then traverse
Skill({ skill: "crew:git:stacked:slide-out" })
git machete traverse -W -y -H
```

**Sync and cleanup:**

```bash
git machete traverse -W -y -H -M
```

</common_patterns>
