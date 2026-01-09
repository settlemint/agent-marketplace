---
name: crew:git:stacked:checkout-prs
description: Checkout PR branches from GitHub and add to machete layout
argument-hint: "[--mine | --all | --by=<user> | PR numbers]"
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

Checkout PR branches from GitHub and add them to the machete layout.

</objective>

<workflow>

## Step 1: Determine Which PRs

If no argument:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Which PRs do you want to checkout?",
      header: "PRs",
      options: [
        {
          label: "My PRs (Recommended)",
          description: "All open PRs authored by you",
        },
        {
          label: "All open PRs",
          description: "All open PRs in the repository",
        },
        { label: "Specific PRs", description: "Enter PR numbers" },
        { label: "By author", description: "PRs by a specific user" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 2: List Available PRs

```bash
# My PRs
gh pr list --author @me --state open --json number,title,headRefName

# All open PRs
gh pr list --state open --limit 20 --json number,title,headRefName,author

# By author
gh pr list --author "$username" --state open --json number,title,headRefName
```

## Step 3: Checkout PRs

**My PRs:**

```bash
git machete github checkout-prs --mine
```

**All open PRs:**

```bash
git machete github checkout-prs --all
```

**Specific PRs:**

```bash
git machete github checkout-prs 123 456 789
```

**By author:**

```bash
git machete github checkout-prs --by=username
```

## Step 4: Review Layout

```bash
git machete status --list-commits
```

## Step 5: Optionally Sync

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Sync the checked-out stack with latest changes?",
      header: "Sync",
      options: [
        { label: "Yes", description: "Run traverse to sync all branches" },
        { label: "No", description: "Keep branches as-is" },
      ],
      multiSelect: false,
    },
  ],
});
```

If yes: `Skill({ skill: "crew:git:stacked:traverse" })`

</workflow>

<qualifiers>

When checking out someone else's PRs, branches are annotated:

```
feature-branch  PR #123 rebase=no push=no
```

- `rebase=no` — Don't rebase (you don't own it)
- `push=no` — Don't push (you don't own it)

To remove qualifiers: `git machete anno <branch> ""`

</qualifiers>

<success_criteria>

- [ ] PR branches checked out
- [ ] Branches added to layout
- [ ] Qualifiers set appropriately
- [ ] Stack structure preserved

</success_criteria>
