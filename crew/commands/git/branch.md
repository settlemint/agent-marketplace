---
name: crew:git:branch
description: Create a feature branch from main
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

<branch_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/branch-context.sh`
</branch_context>

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>

<phantom_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/phantom-context.sh`
</phantom_context>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<notes>
Branch naming per @rules/git-safety.md: `type/short-description`
</notes>

<process>

<phase name="ask-isolation">
**Ask for branch isolation strategy:**

```javascript
AskUserQuestion({
  questions: [
    {
      question: "How should the new branch be isolated?",
      header: "Isolation",
      options: [
        {
          label: "New worktree (Recommended)",
          description: "Isolated phantom worktree for independent work",
        },
        {
          label: "Stacked branch",
          description: "Add to machete stack for dependent changes",
        },
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

</phase>

<phase name="execute-choice">
**Delegate to canonical skill based on choice:**

If "New worktree" selected:

```javascript
Skill({ skill: "crew:git:worktree" });
// Worktree skill handles: username prefix, type selection, name confirmation, phantom create
```

If "Stacked branch" selected:

```javascript
// Create branch with username prefix (from current)
Skill({ skill: "crew:git:branch-new", args: "--base current" });

// Add to machete stack
Skill({ skill: "crew:git:stack-add" });
```

If "Simple branch" selected:

```javascript
// Create branch with username prefix (from main)
Skill({ skill: "crew:git:branch-new", args: "--base main" });
```

</phase>

<phase name="worktree-context">
**If already in a WORKTREE:**

When working in a worktree, cannot switch branches. Options:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "You're in a worktree. How do you want to proceed?",
      header: "Method",
      options: [
        {
          label: "Create new worktree",
          description: "New branch in a separate worktree directory",
        },
        {
          label: "Stack on current",
          description: "Child of current branch in this worktree (advanced)",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

If "Create new worktree":

```javascript
Skill({ skill: "crew:git:worktree" });
```

If "Stack on current":

```javascript
// Create branch with username prefix (from current)
Skill({ skill: "crew:git:branch-new", args: "--base current" });

// Add to machete stack
Skill({ skill: "crew:git:stack-add" });
```

</phase>

</process>
