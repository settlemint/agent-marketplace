---
name: crew:git:branch
description: Create a feature branch from main
allowed-tools: Bash(git checkout:*), Bash(git fetch:*), Bash(git branch:*), Bash(git machete:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/branch-context.sh`
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`

## Naming Convention

`type/short-description`

| Type        | Use For       |
| ----------- | ------------- |
| `feat/`     | New feature   |
| `fix/`      | Bug fix       |
| `refactor/` | Restructuring |
| `docs/`     | Documentation |
| `chore/`    | Maintenance   |

## Task

### Step 1: Check Current State

```bash
git branch --show-current
```

### Step 2: Determine Branch Type

Ask user what kind of branch they want:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What type of branch do you want to create?",
      header: "Branch Type",
      options: [
        {
          label: "Regular branch",
          description: "Independent branch from main",
        },
        {
          label: "Stacked branch",
          description: "Child of current branch (for stacked PRs)",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

### Step 3a: Regular Branch (from main)

```bash
git fetch origin main
git checkout -b <type>/<name> origin/main
```

### Step 3b: Stacked Branch (from current)

```bash
# Create branch from current HEAD
git checkout -b <type>/<name>

# Add to machete layout under current branch
git machete add --onto $(git rev-parse --abbrev-ref @{-1})

# Verify layout
git machete status
```

**If NOT on main/master when creating regular branch:**
Warn user they're on a feature branch and ask to confirm switching to main first.

### Step 4: Verify

```bash
git branch --show-current
git machete status  # if machete is set up
```

## Stacked Branch Workflow

When creating stacked branches:

1. Stay on parent branch
2. Create child: `git checkout -b feat/child`
3. Add to stack: `git machete add --onto feat/parent`
4. Work, commit, repeat for deeper stacks

## Quick Reference

```bash
# Regular branch from main
git checkout -b feat/new-feature origin/main

# Stacked branch from current
git checkout -b feat/child-feature
git machete add --onto feat/parent-feature

# View stack
git machete status -l
```

If no name provided, ask user what they're working on.
