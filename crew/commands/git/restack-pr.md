---
name: crew:git:restack-pr
description: Retarget PR, force push, and manage draft state atomically
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

<pr_info>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-info.sh 2>&1`
</pr_info>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<objective>
Atomically retarget a PR, force push rebased changes, and optionally manage draft state.
This prevents reviewers from seeing an inconsistent state during the update.
</objective>

<when_to_use>

- After rebasing a branch that has an open PR
- When you need to update both PR base and branch contents
- To avoid CI running on an intermediate broken state
- When the branch history has been rewritten

</when_to_use>

<process>

## Step 1: Check Current State

```bash
branch=$(git branch --show-current)
pr_number=$(gh pr view --json number -q '.number' 2>/dev/null || echo "")
pr_state=$(gh pr view --json state,isDraft -q '{state: .state, draft: .isDraft}' 2>/dev/null || echo "{}")
current_base=$(gh pr view --json baseRefName -q '.baseRefName' 2>/dev/null || echo "")
machete_parent=$(git machete show up 2>/dev/null || echo "main")

echo "Branch: $branch"
echo "PR #: $pr_number"
echo "PR state: $pr_state"
echo "Current base: $current_base"
echo "Machete parent: $machete_parent"
```

## Step 2: Check for Unpushed Changes

```bash
# Check if local differs from remote
local_sha=$(git rev-parse HEAD)
remote_sha=$(git rev-parse origin/$branch 2>/dev/null || echo "none")

if [[ "$local_sha" != "$remote_sha" ]]; then
    echo "Local branch has unpushed changes"
    git log --oneline origin/$branch..HEAD 2>/dev/null | head -5
fi
```

## Step 3: Confirm Restack

```javascript
AskUserQuestion({
  questions: [
    {
      question:
        "Restack will retarget PR and force push. This may trigger CI. Continue?",
      header: "Restack",
      options: [
        {
          label: "Yes with draft (Recommended)",
          description: "Set to draft, restack, then ready for review",
        },
        {
          label: "Yes without draft",
          description:
            "Restack immediately (CI will run on intermediate state)",
        },
        { label: "Cancel", description: "Don't restack" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 4: Execute Restack

**With draft state management:**

```bash
# Convert to draft first (if not already)
gh pr ready --undo $pr_number 2>/dev/null || true

# Retarget PR to machete parent
git machete github retarget-pr

# Force push rebased branch
git push --force-with-lease origin $branch

# Convert back to ready for review
gh pr ready $pr_number
```

**Without draft (using machete command):**

```bash
git machete github restack-pr
```

## Step 5: Update Related PRs

```bash
# Ensure config is set
git config machete.github.prDescriptionIntroStyle full

# Update PR descriptions for entire stack
git machete github update-pr-descriptions --related
```

## Step 6: Verify

```bash
# Check PR status
gh pr view --json state,mergeable,baseRefName -q '{state: .state, mergeable: .mergeable, base: .baseRefName}'

# Check CI status
gh pr checks
```

</process>

<restack_vs_retarget>

| Aspect          | `retarget-pr`           | `restack-pr`                      |
| --------------- | ----------------------- | --------------------------------- |
| Changes base    | Yes                     | Yes                               |
| Force pushes    | No                      | Yes                               |
| Draft handling  | No                      | Optional                          |
| Use when        | Base changed, no rebase | After rebase with history rewrite |
| CI implications | Minimal                 | Full CI re-run                    |

</restack_vs_retarget>

<common_scenarios>

**Scenario: After syncing with main**

```bash
# You rebased onto latest main
git fetch origin main
git rebase origin/main

# Now restack the PR
Skill({ skill: "crew:git:restack-pr" })
```

**Scenario: After traverse updated the branch**

```bash
# Traverse rebased this branch
git machete traverse -W -y

# Restack PRs that were rebased
Skill({ skill: "crew:git:restack-pr" })
```

**Scenario: Batch restack entire stack**

```bash
# Traverse with GitHub sync handles this automatically
git machete traverse -W -y -H
```

</common_scenarios>

<success_criteria>

- [ ] PR base matches machete parent
- [ ] Branch force pushed successfully
- [ ] PR is not in draft state (if was ready before)
- [ ] CI checks triggered on new state
- [ ] Related PRs updated with chain info
- [ ] PR shows as mergeable

</success_criteria>
