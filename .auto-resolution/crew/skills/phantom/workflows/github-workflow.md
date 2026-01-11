---
name: github-workflow
description: Workflow for working with GitHub PRs and issues via phantom
---

<workflow>

## GitHub Integration Workflow

### Step 1: Ask What to Checkout

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What would you like to check out?",
      header: "Type",
      options: [
        {
          label: "Pull Request",
          description: "Review or contribute to an existing PR",
        },
        { label: "Issue", description: "Start work on an issue" },
      ],
      multiSelect: false,
    },
  ],
});
```

### Step 2: Get the Number

If not provided in the command, ask:

```javascript
// User provides the PR/issue number
// Auto-detect if it's a PR or issue from GitHub API
```

### Step 3: Checkout

**For Pull Requests:**

```bash
phantom gh checkout <number>
```

**What happens:**

1. Phantom queries GitHub API for PR details
2. For same-repo PRs: Fetches the actual branch
3. For fork PRs: Fetches `origin/pull/<number>/head`
4. Creates worktree with the PR branch name

**For Issues:**

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What branch should the issue be based on?",
      header: "Base",
      options: [
        { label: "main", description: "Default branch (Recommended)" },
        { label: "develop", description: "Development branch" },
      ],
      multiSelect: false,
    },
  ],
});
```

```bash
phantom gh checkout <number> --base <selected-base>
```

**What happens:**

1. Phantom queries GitHub API for issue details
2. Creates new branch named `issues/<number>`
3. Creates worktree based on selected branch

### Step 4: Ask Next Action

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What would you like to do with this checkout?",
      header: "Action",
      options: [
        {
          label: "Open shell",
          description: "Enter the worktree (Recommended)",
        },
        { label: "Open editor", description: "Open in VS Code" },
        { label: "Run tests", description: "Execute test suite" },
        { label: "Just checkout", description: "Stay in current directory" },
      ],
      multiSelect: false,
    },
  ],
});
```

Handle responses:

- "Open shell" → Tell user: `phantom shell <branch-name>`
- "Open editor" → `Bash({ command: "phantom edit <branch-name>" })`
- "Run tests" → `Bash({ command: "phantom exec <branch-name> npm test" })`
- "Just checkout" → Done, inform user of location

### Recommended PR Review Flow

```bash
# 1. Checkout the PR
phantom gh checkout 123 --shell

# 2. Run tests in the PR context
npm test
npm run build

# 3. Explore the changes
git log --oneline main..HEAD
git diff main...HEAD

# 4. Leave review comments via gh
gh pr review 123 --comment --body "Looks good!"
# or
gh pr review 123 --approve
# or
gh pr review 123 --request-changes --body "Please fix X"

# 5. Exit and cleanup
exit
phantom delete 123
```

### Contributing to a PR

```bash
# 1. Checkout the PR
phantom gh checkout 123 --shell

# 2. Make your changes
# ... edit files ...

# 3. Commit and push
git commit -m "fix: address review feedback"
git push

# 4. Exit
exit
```

### Working on Multiple PRs Simultaneously

```bash
# Checkout multiple PRs in parallel
phantom gh checkout 123
phantom gh checkout 456
phantom gh checkout 789

# Work on them in different terminals/tmux
phantom shell 123
# In another terminal:
phantom shell 456

# Run tests across all
phantom exec 123 npm test
phantom exec 456 npm test
phantom exec 789 npm test

# Cleanup when done
phantom delete 123 456 789
```

### Issue to PR Workflow

```bash
# 1. Checkout issue
phantom gh checkout 42 --shell

# 2. Implement the feature
# ... write code ...

# 3. Commit
git commit -m "feat: implement feature for issue #42"

# 4. Push and create PR
git push -u origin issues/42
gh pr create --title "Implement feature for issue #42" \
  --body "Closes #42"

# 5. Exit worktree (keep for future work)
exit
```

</workflow>
