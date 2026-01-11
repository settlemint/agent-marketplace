---
name: crew:git:butler:assign
description: Assign files to a GitButler virtual branch
argument-hint: "<file> <branch>"
allowed-tools:
  - Bash
  - AskUserQuestion
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<objective>

Manually assign files to a virtual branch using the `rub` command.

</objective>

<workflow>

## Step 1: Check GitButler Active

```javascript
if (GITBUTLER_ACTIVE === false) {
  // Output: "GitButler is not initialized. File assignment requires GitButler."
  // Exit
}
```

## Step 2: Get Current State

```javascript
Bash({ command: "but branch list" });
```

## Step 3: Parse Arguments or Ask

If both file and branch provided, proceed to Step 4.

Otherwise:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What operation?",
      header: "Operation",
      options: [
        {
          label: "Assign file to branch",
          description: "Move file to specific branch",
        },
        {
          label: "Unassign file",
          description: "Remove file from all branches",
        },
        {
          label: "Move commit to branch",
          description: "Relocate a commit",
        },
        {
          label: "Squash commits",
          description: "Combine two commits",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 4: Execute Rub Command

**Assign file to branch:**

```javascript
Bash({ command: `but rub "${file}" "${branch}"` });
```

**Unassign file:**

```javascript
Bash({ command: `but rub "${file}" 00` });
```

**Move commit to branch:**

```javascript
Bash({ command: `but rub "${commitSha}" "${branch}"` });
```

**Squash commits:**

```javascript
Bash({ command: `but rub "${commit1}" "${commit2}"` });
```

## Step 5: Confirm

```javascript
Bash({ command: "but branch list" });
```

</workflow>

<rub_reference>

| Operation   | Command                                        | Result                  |
| ----------- | ---------------------------------------------- | ----------------------- |
| Assign file | `Bash({ command: "but rub FILE BRANCH" })`     | File moves to branch    |
| Unassign    | `Bash({ command: "but rub FILE 00" })`         | File becomes unassigned |
| Amend       | `Bash({ command: "but rub FILE COMMIT" })`     | Add file to commit      |
| Move commit | `Bash({ command: "but rub COMMIT BRANCH" })`   | Commit moves to branch  |
| Squash      | `Bash({ command: "but rub COMMIT1 COMMIT2" })` | Commits combined        |

</rub_reference>

<success_criteria>

- [ ] Operation executed successfully
- [ ] Branch state updated
- [ ] User understands rub command options

</success_criteria>
