---
name: crew:git:stacked:go
description: Navigate to branches in the machete stack
argument-hint: "[up | down | next | prev | root | first | last]"
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

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh 2>&1`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<objective>
Navigate between branches in the machete stack using directional commands.
</objective>

<directions>

| Direction | Meaning                                      |
| --------- | -------------------------------------------- |
| `up`      | Parent branch                                |
| `down`    | First child branch                           |
| `next`    | Next sibling (same level, next in order)     |
| `prev`    | Previous sibling (same level, prev in order) |
| `root`    | Root of current branch's tree                |
| `first`   | First branch in the entire layout            |
| `last`    | Last branch in the entire layout             |

</directions>

<process>

## Step 1: Determine Direction

If no argument provided:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Which direction to navigate?",
      header: "Navigate",
      options: [
        { label: "Up", description: "Go to parent branch" },
        { label: "Down", description: "Go to first child branch" },
        { label: "Next", description: "Go to next sibling" },
        { label: "Prev", description: "Go to previous sibling" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 2: Check Target Exists

```bash
direction="${1:-up}"  # default to up

# Show what branch we'll navigate to
target=$(git machete show "$direction" 2>/dev/null || echo "")

if [[ -z "$target" ]]; then
    echo "No branch in direction '$direction' from current branch"
    git machete status
    exit 1
fi

echo "Will checkout: $target"
```

## Step 3: Handle Worktree

Check `<worktree_status>` for `WORKTREE_MACHETE_SAFE` status:

**If safe pattern (single stack):** Proceed normally - navigation within the stack is fine.

**If unsafe pattern (multi-stack layout):**

```javascript
AskUserQuestion({
  questions: [
    {
      question: `Target branch "${target}" may be outside this worktree's stack. Continue?`,
      header: "Worktree",
      options: [
        {
          label: "Continue anyway",
          description: "Switch branches (know what you're doing)",
        },
        {
          label: "Show main checkout path",
          description: "Navigate in main checkout instead",
        },
        {
          label: "Create worktree",
          description: "Create a new worktree for the target branch",
        },
        { label: "Cancel", description: "Stay on current branch" },
      ],
      multiSelect: false,
    },
  ],
});
```

**If "Create worktree":**

```bash
# Create worktree for target branch
git worktree add "../$(basename $(pwd))-${target}" "$target"
echo "Created worktree at: ../$(basename $(pwd))-${target}"
echo "cd there to continue work on $target"
```

## Step 4: Check for Uncommitted Changes

```bash
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "You have uncommitted changes"
    git status --short
fi
```

If uncommitted changes:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "You have uncommitted changes. What to do?",
      header: "Changes",
      options: [
        { label: "Stash", description: "Stash changes and switch" },
        { label: "Commit", description: "Commit changes first" },
        { label: "Discard", description: "Discard changes and switch" },
        { label: "Cancel", description: "Stay on current branch" },
      ],
      multiSelect: false,
    },
  ],
});
```

If "Stash":

```bash
git stash push -m "Auto-stash before go $direction"
```

If "Commit":

```javascript
Skill({ skill: "crew:git:commit" });
```

## Step 5: Navigate

```bash
git machete go "$direction"
```

Or directly:

```bash
git checkout "$target"
```

## Step 6: Show New Context

```bash
echo "=== Now on: $(git branch --show-current) ==="
git machete status
```

</process>

<interactive_mode>

On Unix terminals, `git machete go` supports interactive mode:

```bash
git machete go  # Without argument
```

**Controls:**

- Arrow keys: Navigate
- Shift+Arrow: Jump (e.g., Shift+Up = root)
- Enter/Space: Select
- q: Quit

**Note:** Interactive mode not available on Windows.

</interactive_mode>

<navigation_examples>

**Navigate through a stack:**

```text
main
    feature-base      ← git machete go down (from main)
        feature-1     ← git machete go down (from feature-base)
        feature-2     ← git machete go next (from feature-1)
    hotfix            ← git machete go next (from feature-base)
```

**Common patterns:**

```bash
# Go to parent to check its state
git machete go up

# Go to child to continue work
git machete go down

# Cycle through siblings
git machete go next
git machete go next

# Jump to root of current tree
git machete go root
```

</navigation_examples>

<success_criteria>

- [ ] Correctly identified target branch
- [ ] Handled uncommitted changes appropriately
- [ ] Successfully switched to target branch
- [ ] Displayed new branch context

</success_criteria>
