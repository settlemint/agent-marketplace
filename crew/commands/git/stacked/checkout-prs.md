---
name: crew:git:stacked:checkout-prs
description: Checkout PR branches from GitHub and add to machete layout
argument-hint: "[--mine | --all | --by=<user> | PR numbers]"
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
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh 2>&1`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<objective>
Checkout PR branches from GitHub locally and optionally add them to the machete layout.
Useful for reviewing someone's stacked PRs or resuming work on your own PRs.
</objective>

<process>

## Step 1: Determine Which PRs to Checkout

If no argument provided:

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
# Show available PRs based on selection
case "$selection" in
    "My PRs")
        gh pr list --author @me --state open --json number,title,headRefName
        ;;
    "All open PRs")
        gh pr list --state open --limit 20 --json number,title,headRefName,author
        ;;
    "By author")
        # Prompt for username
        gh pr list --author "$username" --state open --json number,title,headRefName
        ;;
esac
```

## Step 3: Checkout PRs

**For your own PRs:**

```bash
git machete github checkout-prs --mine
```

**For all open PRs:**

```bash
git machete github checkout-prs --all
```

**For specific PRs:**

```bash
git machete github checkout-prs 123 456 789
```

**For PRs by a specific author:**

```bash
git machete github checkout-prs --by=username
```

## Step 4: What Happens

When checking out PRs, git-machete:

1. Fetches PR branches from GitHub
2. Creates local tracking branches
3. Adds branches to the machete layout (preserving stack structure)
4. Adds `rebase=no push=no` qualifiers for branches not authored by you

## Step 5: Review the Layout

```bash
git machete status --list-commits
```

## Step 6: Optionally Sync the Stack

After checkout, you may want to sync:

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

If yes:

```javascript
Skill({ skill: "crew:git:stacked:traverse" });
```

</process>

<qualifiers>

When checking out someone else's PRs, branches are automatically annotated:

```
feature-branch  PR #123 rebase=no push=no
```

**Qualifiers meaning:**

- `rebase=no` — Don't rebase this branch during traverse (you don't own it)
- `push=no` — Don't push this branch during traverse (you don't own it)

**To remove qualifiers** (if you take ownership):

```bash
git machete anno <branch> ""
# Or keep just the PR annotation:
git machete anno <branch> "PR #123"
```

</qualifiers>

<use_cases>

**Review someone's stacked PRs:**

```bash
git machete github checkout-prs --by=colleague
git machete status --list-commits
```

**Resume work on your own PRs from another machine:**

```bash
git machete github checkout-prs --mine
git machete traverse -W -y
```

**Checkout a specific PR chain:**

```bash
# Checkout PR and its dependencies
git machete github checkout-prs 456
```

</use_cases>

<success_criteria>

- [ ] PR branches checked out locally
- [ ] Branches added to machete layout
- [ ] Qualifiers set appropriately (rebase=no push=no for others' PRs)
- [ ] Stack structure preserved from GitHub PR base relationships
- [ ] `git machete status` shows correct tree

</success_criteria>
