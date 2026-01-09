---
name: crew:git:stacked:go
description: Navigate to branches in the machete stack
argument-hint: "[up | down | next | prev | root | first | last]"
allowed-tools:
  - Bash
  - AskUserQuestion
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

| Direction | Target                      |
| --------- | --------------------------- |
| `up`      | Parent branch               |
| `down`    | First child branch          |
| `next`    | Next sibling (same level)   |
| `prev`    | Previous sibling            |
| `root`    | Root of current branch tree |
| `first`   | First branch in layout      |
| `last`    | Last branch in layout       |

</directions>

<workflow>

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
direction="${1:-up}"
target=$(git machete show "$direction" 2>/dev/null || echo "")
if [[ -z "$target" ]]; then
    echo "No branch in direction '$direction'"
    git machete status
    exit 1
fi
echo "Will checkout: $target"
```

## Step 3: Handle Uncommitted Changes

```bash
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "Uncommitted changes:"
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
        { label: "Cancel", description: "Stay on current branch" },
      ],
      multiSelect: false,
    },
  ],
});
```

If "Stash": `git stash push -m "Auto-stash before go $direction"`
If "Commit": `Skill({ skill: "crew:git:commit" })`

## Step 4: Navigate

```bash
git machete go "$direction"
```

## Step 5: Show New Context

```bash
echo "=== Now on: $(git branch --show-current) ==="
git machete status
```

</workflow>

<success_criteria>

- [ ] Target branch identified
- [ ] Uncommitted changes handled
- [ ] Switched to target branch
- [ ] New context displayed

</success_criteria>
