---
name: crew:restart
description: Resume pending work from a previous session
---

<prerequisite>

**Load patterns skill first:**

```javascript
Skill({ skill: "crew:crew-patterns" });
```

This provides: `<pattern name="user-questions-constraint"/>`.

</prerequisite>

!`${CLAUDE_PLUGIN_ROOT}/scripts/workflow/restart-context.sh`
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`

<constraints>

**CRITICAL: Follow `<pattern name="user-questions-constraint"/>` - NEVER output plain text questions.**

</constraints>

<process>

Based on context above, determine the appropriate action:

<phase name="detect-state">
```javascript
// Check what needs to be resumed based on script output
const hasPendingTasks = /* task files found */;
const hasActiveWorkflow = /* state.json has activeWorkflow */;
const hasStateFile = /* state.json exists */;
```
</phase>

<phase name="resume-work">

**If pending task files found:**

```javascript
Skill({ skill: "crew:build" });
```

**If active workflow in state.json:**

```javascript
// Invoke the workflow skill from state
const workflow = state.activeWorkflow; // e.g., "crew:design", "crew:check"
Skill({ skill: workflow });
```

**If state.json exists with todos:**

```javascript
// Restore TodoWrite state and continue
TodoWrite({ todos: state.todos });
// Resume from last in_progress item
```

**If nothing pending but context shows actionable items (PRs, branches, etc.):**

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What would you like to do?",
      header: "Action",
      options: [
        {
          label: "Create PR",
          description: "Open pull request for current branch",
        },
        {
          label: "Clean branches",
          description: "Remove merged branches from the git-machete stack",
        },
        { label: "Sync stack", description: "Traverse and sync branch stack" },
      ],
      multiSelect: false,
    },
  ],
});
```

**If truly nothing to resume:**

Report: "No pending work found."

</phase>

</process>
