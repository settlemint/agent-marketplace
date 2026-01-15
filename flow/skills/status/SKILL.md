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

1. Read `.claude/flow/state.json` and `config.json`
2. Display current workflow, progress, and recent activity
3. Suggest relevant next actions based on state

</quick_start>

<workflow>

## Phase 1: Load State

Read `.claude/flow/state.json` and `config.json`. If not initialized, suggest `flow:init`.

## Phase 2: Display Status

Show: project name, current workflow (name, status, progress), recent activity.

## Phase 3: Recommendations

- No workflow: suggest `flow:workflow:start`
- In progress: show current task
- Paused: suggest resuming

</workflow>

<related_skills>

```javascript
Skill({ skill: "flow:init" }); // Initialize flow
Skill({ skill: "flow:workflow:start" }); // Start workflow
Skill({ skill: "flow:analyze" }); // Analyze codebase
```

</related_skills>

<success_criteria>

- [ ] State loaded and status displayed
- [ ] Context-aware recommendations provided

</success_criteria>
