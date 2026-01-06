---
name: crew:git:stack-add
description: Add current or specified branch to the machete stack
allowed-tools: Bash(git machete:*), Bash(git branch:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`

## Purpose

Add a branch to the git-machete layout, specifying its parent in the stack.

## Task

1. **Get current branch**:

   ```bash
   git branch --show-current
   ```

2. **If no machete layout exists**, create one:

   ```bash
   git machete discover
   # Or manually: git machete edit
   ```

3. **Add branch to layout**:

   ```bash
   # Add current branch with parent
   git machete add --onto <parent-branch>

   # Add specific branch
   git machete add <branch> --onto <parent-branch>
   ```

4. **Verify addition**:
   ```bash
   git machete status
   ```

## Interactive Flow

If parent not specified, ask:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Which branch should be the parent?",
      header: "Parent",
      options: [
        { label: "main", description: "Base off main branch" },
        { label: "develop", description: "Base off develop branch" },
        // Dynamic: list other branches in layout
      ],
      multiSelect: false,
    },
  ],
});
```

## Examples

```bash
# Add current branch under main
git machete add --onto main

# Add current branch under another feature
git machete add --onto feature/base

# Add specific branch
git machete add feature/new --onto feature/existing
```
