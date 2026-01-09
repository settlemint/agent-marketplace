---
name: crew:git:worktree:create
description: Create a new phantom worktree for isolated development
argument-hint: "[branch name or feature description]"
allowed-tools:
  - Bash
  - AskUserQuestion
skills:
  - crew:phantom
---

<phantom_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/phantom-context.sh`
</phantom_context>

<objective>

Create phantom worktree with username-prefixed branch. Ask type and base. Open editor.

</objective>

<workflow>

## Step 1: Ask Type and Base

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What type of worktree?",
      header: "Type",
      options: [
        { label: "Feature (Recommended)", description: "feat/" },
        { label: "Bug fix", description: "fix/" },
        { label: "Hotfix", description: "hotfix/" },
        { label: "Experiment", description: "experiment/" },
      ],
      multiSelect: false,
    },
    {
      question: "Base branch?",
      header: "Base",
      options: [
        { label: "main (Recommended)", description: "Start fresh from main" },
        { label: "Current branch", description: "Branch from current work" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 2: Generate Branch Name

```javascript
const username = Bash({ command: "whoami" }).trim();
const typePrefix = {
  Feature: "feat",
  "Bug fix": "fix",
  Hotfix: "hotfix",
  Experiment: "experiment",
}[type];
const slug = slugify(description); // kebab-case, max 30 chars
const branchName = `${username}/${typePrefix}/${slug}`;
```

## Step 3: Create Worktree

```bash
phantom create ${branchName} --base ${base}
phantom edit ${branchName} 2>/dev/null || true
```

## Step 4: Instruct User

```
Worktree created: ${branchName}
Location: $(phantom where ${branchName})

To continue in new worktree:
  cd $(phantom where ${branchName}) && claude
  # or: phantom shell ${branchName}

Do NOT use 'git checkout' - worktrees have dedicated branches.
```

</workflow>

<success_criteria>

- [ ] Branch name follows `username/type/slug` pattern
- [ ] Worktree created with phantom
- [ ] Editor opened (non-blocking)
- [ ] User instructed how to switch

</success_criteria>
