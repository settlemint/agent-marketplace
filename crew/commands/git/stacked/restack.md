---
name: crew:git:stacked:restack
description: Retarget PR, force push, and manage draft state atomically
allowed-tools:
  - Bash
  - AskUserQuestion
---

<pr_info>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-info.sh 2>&1`
</pr_info>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<objective>

Atomically retarget a PR, force push rebased changes, and manage draft state.

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

## Step 2: Check for Unpushed Changes

```bash
local_sha=$(git rev-parse HEAD)
remote_sha=$(git rev-parse origin/$branch 2>/dev/null || echo "none")
if [[ "$local_sha" != "$remote_sha" ]]; then
    echo "Local has unpushed changes"
    git log --oneline origin/$branch..HEAD 2>/dev/null | head -5
fi
```

## Step 3: Confirm Restack

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Restack will retarget PR and force push. Continue?",
      header: "Restack",
      options: [
        {
          label: "Yes with draft (Recommended)",
          description: "Set to draft, restack, then ready",
        },
        { label: "Yes without draft", description: "Restack immediately" },
        { label: "Cancel", description: "Don't restack" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 4: Execute Restack

**With draft state:**

```bash
gh pr ready --undo $pr_number 2>/dev/null || true
git machete github retarget-pr
git push --force-with-lease origin $branch
gh pr ready $pr_number
```

**Without draft:**

```bash
git machete github restack-pr
```

## Step 5: Update Related PRs

```bash
git config machete.github.prDescriptionIntroStyle full
git machete github update-pr-descriptions --related
```

## Step 6: Verify

```bash
gh pr view --json state,mergeable,baseRefName -q '{state: .state, mergeable: .mergeable, base: .baseRefName}'
gh pr checks
```

</workflow>

<success_criteria>

- [ ] PR base matches machete parent
- [ ] Branch force pushed
- [ ] PR not in draft (if was ready)
- [ ] Related PRs updated

</success_criteria>
