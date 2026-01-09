---
name: crew:git:branch:create
description: Create a feature branch (worktree, stacked, or simple)
allowed-tools:
  - AskUserQuestion
  - Skill
---

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>

<objective>

Ask isolation strategy. Delegate to worktree:create, branch:new + stacked:add, or branch:new.

</objective>

<workflow>

## Step 1: Check Worktree Context

If already in a worktree → offer worktree or stacked options only.

## Step 2: Ask Isolation Strategy

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

## Step 3: Execute Choice

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
