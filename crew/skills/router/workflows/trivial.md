# Trivial Workflow

**Purpose:** Execute simple, targeted requests immediately without planning overhead.

## When This Runs

User requests a small, well-defined change:

- "Fix the typo on line 42"
- "Rename getUserData to fetchUserData"
- "Add a comment explaining this function"
- "Update the version to 2.0.0"

## Characteristics of Trivial Requests

- **Single target:** One file, one function, one line
- **Clear scope:** No ambiguity about what to change
- **Low risk:** Typos, renames, comments, formatting
- **Quick completion:** Done in seconds to minutes

## Workflow

### 1. Direct Execution

**No planning needed.** Execute the request directly:

```javascript
// Use tools directly - no orchestration
// Read the target file
Read({ file_path: targetFile });

// Make the change
Edit({
  file_path: targetFile,
  old_string: original,
  new_string: updated,
});
```

### 2. Verify (If Applicable)

For code changes, run quick verification:

```javascript
// Only if tests exist and change is in source code
Bash({ command: "bun run test --related " + targetFile });

// Or just lint check
Bash({ command: "bun run lint " + targetFile });
```

Skip verification for:

- Documentation changes (README, comments)
- Configuration tweaks
- Pure formatting

### 3. Report Completion

Brief confirmation:

```
Done. Fixed typo on src/utils.ts:42.
```

No elaborate summaries needed.

### 4. State (Optional)

For trivial changes, state tracking is optional. If tracking:

```javascript
// Briefly note the trivial action
state.routing.last_trivial = {
  at: new Date().toISOString(),
  action: "fixed typo",
  file: "src/utils.ts",
};
```

## What NOT to Do

- **Don't create a plan** for a typo fix
- **Don't spawn background workers** for a rename
- **Don't run full CI** for a comment addition
- **Don't ask permission** for clearly scoped changes

## Escalation

If during execution you discover the change is more complex:

```javascript
// Reclassify to SUBSTANTIAL
AskUserQuestion({
  questions: [
    {
      question:
        "This change is more complex than expected. Want me to create a plan?",
      header: "Scope Change",
      options: [
        {
          label: "Yes, plan first",
          description: "Create a proper implementation plan",
        },
        {
          label: "No, keep it simple",
          description: "Just make the minimal change",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

## Success Criteria

- [ ] Request completed quickly (< 2 minutes)
- [ ] Minimal overhead (no unnecessary steps)
- [ ] Change verified (if applicable)
- [ ] User informed of completion
- [ ] No over-engineering of simple tasks
