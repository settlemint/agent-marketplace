# Workflow: Setup Stacked Branches

<objective>
Initialize git-machete in a repository and define the branch hierarchy for stacked PR workflows.
</objective>

<process>
## Step 1: Verify Installation

Check if git-machete is installed:

```bash
git machete version
```

If not installed, run the install script from `scripts/install.sh` or:

```bash
# macOS/Linux with Homebrew
brew install git-machete

# Or with pip
pip install --user git-machete
```

## Step 2: Discover Existing Branches

For repositories with existing branches, auto-discover the layout:

```bash
git machete discover
```

This opens an editor with the suggested hierarchy based on commit history. Review and adjust as needed.

## Step 3: Manual Layout Definition

If discovery doesn't match your intent, manually edit:

```bash
git machete edit
```

**Layout syntax:**

- Root branches (main, develop) start at column 0
- Child branches are indented with spaces or tabs
- Deeper nesting = deeper in the stack

**Example layout:**

```text
main
    feature/auth-base
        feature/auth-login
        feature/auth-logout
    feature/dashboard
develop
    hotfix/urgent-fix
```

## Step 4: Add New Branches to Stack

When creating a new branch that's part of a stack:

```bash
# Create and switch to new branch
git checkout -b feature/new-part

# Add to layout with parent
git machete add --onto feature/existing-parent
```

Or add the current branch:

```bash
git machete add
```

## Step 5: Verify Layout

Check the current state:

```bash
git machete status --list-commits
```

**Expected output:**

- Green edges: branches in sync with parent
- Each branch shows commits since fork point
- Hierarchy matches your intended stack

## Step 6: Configure Annotations (Optional)

Add annotations to branches for context:

```bash
# In .git/machete file:
main
    feature/auth-base  PR #123
        feature/auth-login  WIP
```

Or sync with GitHub PRs:

```bash
git machete github anno-prs
```

</process>

<common_patterns>
**Linear Stack (Most Common):**

```text
main
    feature-part-1
        feature-part-2
            feature-part-3
```

**Parallel Features:**

```text
main
    feature-a
    feature-b
    feature-c
```

**Mixed Stack:**

```text
main
    feature-base
        feature-ui
        feature-api
            feature-api-tests
```

</common_patterns>

<success_criteria>

- [ ] git-machete installed and working
- [ ] `.git/machete` file exists with correct hierarchy
- [ ] `git machete status` shows all branches
- [ ] Branch relationships match intended stack structure
- [ ] No orphaned branches in layout
      </success_criteria>
