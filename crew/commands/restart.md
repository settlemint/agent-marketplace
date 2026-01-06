---
name: crew:restart
description: Resume pending work from a previous session
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/workflow/restart-context.sh`

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

**If nothing pending:**

```javascript
// Inform user - no pending work to resume
```

</phase>

Execute immediately without confirmation.

</process>
