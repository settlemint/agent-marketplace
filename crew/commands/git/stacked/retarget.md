---
name: crew:git:stacked:retarget
description: Change PR base branch to match machete parent
allowed-tools:
  - Bash
  - AskUserQuestion
  - Skill
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<pr_info>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-info.sh 2>&1`
</pr_info>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
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

Change the base branch of a PR to match the machete parent branch.

</objective>

<workflow>

## Step 1: Check Current State

```bash
branch=$(git branch --show-current)
pr_number=$(gh pr view --json number -q '.number' 2>/dev/null || echo "")
current_base=$(gh pr view --json baseRefName -q '.baseRefName' 2>/dev/null || echo "")
machete_parent=$(git machete show up 2>/dev/null || echo "main")

echo "Branch: $branch"
echo "PR #: $pr_number"
echo "Current base: $current_base"
echo "Machete parent: $machete_parent"
```

If no PR: Create one with `Skill({ skill: "crew:git:pr:create" })`

## Step 2: Compare Base and Parent

If `$current_base` equals `$machete_parent`:

```
PR base already matches machete parent. No retargeting needed.
```

## Step 3: Confirm Retarget

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Retarget PR from current base to machete parent?",
      header: "Retarget",
      options: [
        { label: "Yes (Recommended)", description: "Change PR base branch" },
        { label: "No", description: "Keep current base" },
        {
          label: "Different target",
          description: "Choose a different base branch",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

If "Different target": list branches and ask for selection.

## Step 4: Execute Retarget

```bash
git machete github retarget-pr
```

Or manually:

```bash
gh pr edit $pr_number --base $machete_parent
```

## Step 5: Update PR Descriptions

```bash
git config machete.github.prDescriptionIntroStyle full
git machete github update-pr-descriptions --related
```

## Step 6: Verify

```bash
gh pr view --json baseRefName -q '.baseRefName'
gh pr view --json state,mergeable -q '{state: .state, mergeable: .mergeable}'
```

</workflow>

<success_criteria>

- [ ] PR base matches machete parent
- [ ] PR description updated
- [ ] Related PRs updated
- [ ] PR shows as mergeable

</success_criteria>
