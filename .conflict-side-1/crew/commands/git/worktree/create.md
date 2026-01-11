---
name: crew:git:worktree:create
description: Create a new phantom worktree for isolated development
argument-hint: "[branch name or feature description]"
allowed-tools:
  - Bash
  - AskUserQuestion
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<phantom_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/phantom-context.sh`
</phantom_context>

<gitbutler_incompatible>

**This command does not work with GitButler.**

If `GITBUTLER_ACTIVE=true` from `<butler_context>`:

```
Git worktrees are not compatible with GitButler virtual branches.

GitButler uses virtual branches instead of worktrees for parallel development.
All virtual branches exist in the same working directory simultaneously.

Use these instead:
- `crew:git:butler:branch` - Create virtual branch
- `crew:git:butler:status` - View virtual branches

To use worktrees, first disable GitButler in this repository.
```

Exit immediately. Do not proceed with worktree commands.

</gitbutler_incompatible>

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

<notes>

Follow @patterns/phantom-workflow.md and @patterns/worktree-safety.md for worktree operations.

</notes>
