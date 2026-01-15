---
name: flow:workflow:start
description: Start a new workflow with structured task tracking. Use when beginning a feature, bug fix, or any structured work.
triggers:
  - "start workflow"
  - "begin workflow"
  - "new workflow"
  - "create workflow"
---

<objective>

Start a new workflow with defined tasks and tracking.

**Updates:** `.claude/flow/state.json`

</objective>

<quick_start>

1. Check for existing workflow in `.claude/flow/state.json`
2. Define workflow type (feature, bug, refactor, docs, tests, custom)
3. Create workflow entry and initialize TodoWrite tracking

</quick_start>

<workflow>

## Phase 1: Check State

Load `.claude/flow/state.json`. If not initialized, suggest `flow:init`. If workflow exists, offer to pause, complete, or cancel.

## Phase 2: Define Workflow

**Types:** feature, bug, refactor, docs, tests, custom

**Gather:** name, description, expected tasks, priority (high/medium/low)

## Phase 3: Create Workflow

Add to state with: id, name, type, description, status (active), priority, startedAt, tasks, progress counters.

## Phase 4: Initialize and Confirm

Create TodoWrite items for session visibility. Display confirmation with current tasks and next steps.

</workflow>

<related_skills>

```javascript
Skill({ skill: "flow:guides:patterns" }); // Workflow templates
Skill({ skill: "flow:workflow:pause" }); // Pause workflow
Skill({ skill: "flow:workflow:complete" }); // Complete workflow
Skill({ skill: "flow:status" }); // Check status
```

</related_skills>

<success_criteria>

- [ ] Workflow created in state.json
- [ ] TodoWrite initialized with tasks
- [ ] Confirmation displayed to user

</success_criteria>
