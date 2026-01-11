---
name: crew:git:butler:undo
description: Undo last GitButler operation or restore to snapshot
argument-hint: "[snapshot sha - optional]"
allowed-tools:
  - Bash
  - AskUserQuestion
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<objective>

Undo the last GitButler operation or restore to a specific snapshot.

</objective>

<workflow>

## Step 1: Check GitButler Active

```javascript
if (GITBUTLER_ACTIVE === false) {
  // Output: "GitButler is not initialized. Use git reflog for recovery."
  // Exit
}
```

## Step 2: Show Operation Log

```javascript
Bash({ command: "but oplog" });
```

## Step 3: Choose Action

If no argument provided:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What would you like to do?",
      header: "Action",
      options: [
        {
          label: "Undo last operation (Recommended)",
          description: "Revert the most recent change",
        },
        {
          label: "Restore to specific snapshot",
          description: "Pick a point from the operation log",
        },
        {
          label: "Create manual snapshot",
          description: "Save current state before risky operation",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 4: Execute

**Undo last:**

```javascript
Bash({ command: "but undo" });
```

**Restore to snapshot:**

```javascript
Bash({ command: `but restore "${snapshotSha}"` });
```

**Create snapshot:**

```javascript
Bash({ command: 'but snapshot -m "manual checkpoint before risky operation"' });
```

## Step 5: Confirm

```javascript
Bash({ command: "but branch list" });
Bash({ command: "but oplog | head -5" });
```

</workflow>

<success_criteria>

- [ ] Operation undone or snapshot restored
- [ ] Current state confirmed
- [ ] User understands recovery options

</success_criteria>
