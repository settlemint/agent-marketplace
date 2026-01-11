# Workflow: Create and Manage Stacked PRs

<objective>
Create GitHub or GitLab pull/merge requests for a stack of branches, with proper base branch targeting and PR chain documentation.
</objective>

<prerequisites>
**Authentication required for private repos or creating PRs:**

1. `GITHUB_TOKEN` or `GITLAB_TOKEN` environment variable, OR
2. `.github-token` or `.gitlab-token` file in home directory, OR
3. `gh` or `glab` CLI already authenticated

If using GitHub CLI:

```bash
gh auth login
```

</prerequisites>

<process>
## Step 1: Ensure Branches Are Synced

Before creating PRs, sync all branches:

```bash
git machete traverse -W -y
```

## Step 2: Create PR for Current Branch

Create a PR with the parent branch (from layout) as base:

```bash
# Regular PR
git machete github create-pr

# Draft PR
git machete github create-pr --draft
```

For GitLab:

```bash
git machete gitlab create-mr [--draft]
```

**What happens:**

1. Identifies parent branch from `.git/machete`
2. Pushes current branch to remote (if needed)
3. Creates PR via API
4. Adds PR chain description (for stacks of 2+ PRs)

## Step 3: Create PRs for Entire Stack

Work through the stack from bottom to top (closest to main first):

```bash
# Start at the root of your stack
git machete go root

# Create PR
git machete github create-pr

# Move to child
git machete go down

# Repeat...
```

Or use traverse with GitHub integration:

```bash
git machete traverse -W -H
```

The `-H` flag enables GitHub operations during traverse.

## Step 4: Checkout Existing PRs

To work on PRs from your team:

```bash
# Checkout your own PRs
git machete github checkout-prs --mine

# Checkout by author
git machete github checkout-prs --by=teammate-username

# Checkout specific PRs
git machete github checkout-prs 123 125 127
```

This automatically adds branches to the layout with correct hierarchy.

## Step 5: Sync PR Base Branches

If you change the parent in `.git/machete`, update the PR:

```bash
git machete github retarget-pr
```

This updates the PR's base branch on GitHub to match the layout.

## Step 6: Annotate with PR Numbers

Add PR numbers to status output:

```bash
git machete github anno-prs
```

Now `git machete status` shows PR numbers next to branches.

## Step 7: Handle PR Reviews

When parent branch is updated after review feedback:

```bash
# Sync all branches
git machete traverse -W -y

# Force push updated branches
# (traverse does this automatically with -y)
```

PRs automatically update with new commits.
</process>

<pr_chain_description>
When creating a stacked PR, git-machete adds a chain description:

```markdown
## PR Chain

⬆️ **Base:** #123 (feature-part-1)
➡️ **This PR:** feature-part-2
⬇️ **Depends on this:** #125 (feature-part-3)
```

This helps reviewers understand the stack and navigate between PRs.
</pr_chain_description>

<merge_order>
**Always merge from top to bottom (closest to main first):**

1. Merge `feature-part-1` into `main`
2. Retarget `feature-part-2` to `main` (or let GitHub auto-retarget)
3. Merge `feature-part-2`
4. Continue down the stack

**After merging:**

```bash
# Remove merged branch from layout
git machete slide-out --no-rebase feature-part-1

# Sync remaining branches
git machete traverse -W -y -H
```

The `-H` flag retargets remaining PRs automatically.
</merge_order>

<success_criteria>

- [ ] All branches in stack have PRs
- [ ] PRs have correct base branches
- [ ] PR descriptions include chain information
- [ ] Status shows PR numbers with `anno-prs`
      </success_criteria>
