---
name: flow:status
description: Show current workflow status. Use when checking progress, active workflows, or recent activity.
triggers:
  - "flow status"
  - "workflow status"
  - "check status"
  - "show progress"
---

<objective>

Display the current workflow status including active workflow, progress, and recent activity.

</objective>

<quick_start>

```javascript
// Load this skill
Skill({ skill: "flow:status" });
```

Then read the state file and display formatted status.

</quick_start>

<workflow>

## Phase 1: Load State

1. Read `.claude/flow/state.json`
2. Read `.claude/flow/config.json`
3. If not initialized, suggest:
   ```javascript
   Skill({ skill: "flow:init" });
   ```

## Phase 2: Display Status

Show formatted status:

```
Flow Status
===========

Project: {projectName}
Initialized: {date}

Current Workflow: {name or "None"}
Status: {status}
Progress: {completed}/{total} tasks

Recent Activity:
- {activity 1}
- {activity 2}
- {activity 3}

Available Skills:
- Skill({ skill: "flow:workflow:start" }) - Start a new workflow
- Skill({ skill: "flow:analyze" }) - Analyze codebase
- Skill({ skill: "flow:suggest" }) - Get improvement suggestions
```

## Phase 3: Recommendations

Based on current state, suggest next actions:

- If no workflow: suggest `Skill({ skill: "flow:workflow:start" })`
- If workflow in progress: show current task
- If workflow paused: suggest resuming

</workflow>

<success_criteria>

- [ ] State loaded successfully
- [ ] Status displayed in readable format
- [ ] Recommendations provided with Skill() format

</success_criteria>
