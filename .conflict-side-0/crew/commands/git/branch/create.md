---
name: crew:git:branch:create
description: Create a feature branch (worktree, stacked, or simple)
allowed-tools:
  - AskUserQuestion
  - Skill
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>

<objective>

Ask isolation strategy. Delegate to appropriate branch creation command based on context.

</objective>

<workflow>

## Step 1: Check GitButler Context

If `GITBUTLER_ACTIVE=true` from `<butler_context>`:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "GitButler detected. How should the branch be created?",
      header: "Branch Type",
      options: [
        {
          label: "Virtual branch (Recommended)",
          description: "GitButler virtual branch",
        },
        {
          label: "Traditional branch",
          description: "Disable GitButler workflow",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

If "Virtual branch" → delegate to `crew:git:butler:branch` and exit.
If "Traditional branch" → warn user and continue to Step 2.

## Step 2: Check Worktree Context

If already in a worktree → offer worktree or stacked options only.

## Step 3: Ask Isolation Strategy

```javascript
AskUserQuestion({
  questions: [
    {
      question: "How should the new branch be isolated?",
      header: "Isolation",
      options: [
        {
          label: "New worktree (Recommended)",
          description: "Isolated phantom worktree",
        },
        { label: "Stacked branch", description: "Add to machete stack" },
        {
          label: "Simple branch",
          description: "Regular branch in current checkout",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 4: Execute Choice

**If "Virtual branch":**

```javascript
Skill({ skill: "crew:git:butler:branch" });
```

**If "New worktree":**

```javascript
Skill({ skill: "crew:git:worktree:create" });
```

**If "Stacked branch":**

```javascript
Skill({ skill: "crew:git:branch:new", args: "--base current" });
Skill({ skill: "crew:git:stacked:add" });
```

**If "Simple branch":**

```javascript
Skill({ skill: "crew:git:branch:new", args: "--base main" });
```

</workflow>

<success_criteria>

- [ ] User chose isolation strategy
- [ ] Branch created via delegated skill

</success_criteria>
