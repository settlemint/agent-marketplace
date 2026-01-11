---
name: create-worktree
description: Workflow for creating a new worktree with phantom
---

<workflow>

## Create Worktree Workflow

### Step 1: Ask for Worktree Type

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What type of worktree do you want to create?",
      header: "Type",
      options: [
        { label: "Feature", description: "New feature development (feat/)" },
        { label: "Bug fix", description: "Fix an existing bug (fix/)" },
        { label: "Hotfix", description: "Critical production fix (hotfix/)" },
        { label: "Experiment", description: "Test an approach (experiment/)" },
      ],
      multiSelect: false,
    },
    {
      question: "What should it be based on?",
      header: "Base",
      options: [
        {
          label: "main",
          description: "Start fresh from main branch (Recommended)",
        },
        { label: "Current branch", description: "Branch from current work" },
      ],
      multiSelect: false,
    },
  ],
});
```

### Step 2: Generate and Confirm Branch Name

Auto-generate a name with username prefix, then let user confirm or customize:

```javascript
// Get username from system
const username = Bash({ command: "whoami" }).trim();

// Pattern: username/type/short-description
const type = selectedType; // feat, fix, hotfix, experiment
const description = slugify(taskDescription); // kebab-case, max 30 chars
const suggestedName = `${username}/${type}/${description}`;

AskUserQuestion({
  questions: [
    {
      question: `Use this branch name: ${suggestedName}?`,
      header: "Name",
      options: [
        { label: "Use suggested", description: suggestedName },
        { label: "Customize", description: "Enter a different name" },
      ],
      multiSelect: false,
    },
  ],
});

// If "Customize" selected, user provides name via "Other" option
```

**Naming conventions:**

| Pattern                             | Example                         |
| ----------------------------------- | ------------------------------- |
| `username/feat/<description>`       | `roderik/feat/user-auth`        |
| `username/fix/<description>`        | `roderik/fix/login-bug`         |
| `username/hotfix/<description>`     | `roderik/hotfix/critical`       |
| `username/experiment/<description>` | `roderik/experiment/approach-a` |

### Step 3: Create Worktree and Switch

```bash
# Create from main (default for new features)
phantom create <branchName> --base main

# Or create from current branch (for related work)
phantom create <branchName> --base $(git branch --show-current)

# Auto-switch to the new worktree
wtPath=$(phantom where <branchName>)
cd "$wtPath"

# Verify the switch
pwd
git branch --show-current
```

### Step 4: Confirm Switch

After creation and switch:

```
Switched to worktree: <branchName>
Location: /path/to/worktree
Branch: <branchName>

Ready to continue working.
```

### Step 5: Ask About Next Steps

Since we're already in the worktree, offer relevant options:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What would you like to do next?",
      header: "Next",
      options: [
        {
          label: "Continue here",
          description: "Stay in worktree and continue work",
        },
        {
          label: "Open in editor",
          description: "Also open worktree in VS Code",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

Handle responses:

- "Continue here" → Already switched, continue with task
- "Open in editor" → `Bash({ command: "code ." })`

## Common Patterns

### Independent Feature

```bash
phantom create feat/independent --base main
wtPath=$(phantom where feat/independent)
cd "$wtPath"
```

### Hotfix from Production

```bash
phantom create hotfix/critical --base origin/production
wtPath=$(phantom where hotfix/critical)
cd "$wtPath"
```

### Review a PR

```bash
phantom gh checkout 123
wtPath=$(phantom where 123)
cd "$wtPath"
# Work is done in isolated worktree
# When done: phantom delete 123
```

### Parallel Experiments

Note: For parallel experiments, use separate terminal sessions or `phantom exec`:

```bash
phantom create experiment/approach-a --base feat/feature
phantom create experiment/approach-b --base feat/feature
# Run commands in each without switching:
phantom exec experiment/approach-a npm test
phantom exec experiment/approach-b npm test
```

</workflow>
