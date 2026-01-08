---
name: crew:git:retarget-pr
description: Change PR base branch to match machete parent
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

<constraints>

**CRITICAL: NEVER output plain text questions. Use AskUserQuestion tool for all user choices.**

</constraints>

<pr_info>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-info.sh 2>&1`
</pr_info>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<objective>
Change the base branch of a PR to match the machete parent branch.
Used when the upstream PR is merged and you need to retarget to the new parent.
</objective>

<when_to_use>

- Parent PR was merged, need to retarget to main/new parent
- Rearranged stack order in machete layout
- PR was created with wrong base branch
- After `slide-out` of a parent branch

</when_to_use>

<process>

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

If no PR found:

```
No PR found for current branch. Create one first with:
Skill({ skill: "crew:git:pr" })
```

## Step 2: Compare Base and Parent

If `$current_base` equals `$machete_parent`:

```
PR base already matches machete parent ($machete_parent). No retargeting needed.
```

## Step 3: Confirm Retarget

```javascript
AskUserQuestion({
  questions: [
    {
      question: `Retarget PR #${pr_number} from '${current_base}' to '${machete_parent}'?`,
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

If "Different target":

```bash
# List available branches
git branch -r --list 'origin/*' | sed 's/origin\///' | head -20
```

Then ask for target branch selection.

## Step 4: Execute Retarget

```bash
git machete github retarget-pr
```

Or manually:

```bash
gh pr edit $pr_number --base $machete_parent
```

## Step 5: Update PR Descriptions

After retargeting, update PR chain descriptions:

```bash
# Ensure config is set
git config machete.github.prDescriptionIntroStyle full

# Update all related PRs
git machete github update-pr-descriptions --related
```

## Step 6: Verify

```bash
# Check new base
gh pr view --json baseRefName -q '.baseRefName'

# Check PR status
gh pr view --json state,mergeable -q '{state: .state, mergeable: .mergeable}'
```

</process>

<batch_retarget>

**Retarget all PRs in the stack:**

During traverse with `-H` flag, machete automatically retargets PRs:

```bash
git machete traverse -W -y -H
```

Or use update-pr-descriptions to refresh all chain info:

```bash
git machete github update-pr-descriptions --related
```

</batch_retarget>

<common_scenarios>

**Scenario: Parent PR merged to main**

```text
Before:
main
    feature-base (merged)
        feature-part-1 (PR base: feature-base)

After slide-out and retarget:
main
    feature-part-1 (PR base: main)
```

```bash
git machete slide-out feature-base --no-rebase
git checkout feature-part-1
git machete github retarget-pr
```

**Scenario: Reordered stack**

If you edited `.git/machete` to change the order:

```bash
git machete github retarget-pr
git machete github update-pr-descriptions --related
```

</common_scenarios>

<success_criteria>

- [ ] PR base branch matches machete parent
- [ ] PR description updated with new chain info
- [ ] Related PRs updated with `--related` flag
- [ ] PR shows as mergeable (no conflicts)

</success_criteria>
