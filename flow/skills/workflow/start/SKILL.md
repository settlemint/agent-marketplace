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

```javascript
// Load this skill
Skill({ skill: "flow:workflow:start" });

// For workflow patterns and templates
Skill({ skill: "flow:flow-patterns" });
```

</quick_start>

<workflow>

## Phase 1: Check State

1. Load current state from `.claude/flow/state.json`
2. If not initialized:
   ```javascript
   Skill({ skill: "flow:init" });
   ```
3. If workflow already in progress, ask whether to:
   - Pause current and start new
   - Complete current first
   - Cancel operation

## Phase 2: Define Workflow

Ask user for workflow type:

```
What type of workflow would you like to start?

1. Feature Implementation
2. Bug Fix
3. Refactoring
4. Documentation
5. Testing
6. Custom (enter name)
```

## Phase 3: Gather Requirements

Based on workflow type, gather:

- Workflow name
- Description
- Expected tasks (can be refined later)
- Priority level

## Phase 4: Create Workflow

Add to state:

```json
{
  "currentWorkflow": {
    "id": "uuid",
    "name": "workflow-name",
    "type": "feature|bug|refactor|docs|tests|custom",
    "description": "...",
    "status": "active",
    "priority": "high|medium|low",
    "startedAt": "ISO date",
    "tasks": [],
    "completedTasks": 0,
    "totalTasks": 0
  }
}
```

## Phase 5: Initialize TodoWrite

Create TodoWrite items from workflow tasks for session visibility.

## Phase 6: Confirm

Display:

- Workflow started confirmation
- Current tasks
- Next steps

</workflow>

<related_skills>

```javascript
Skill({ skill: "flow:flow-patterns" }); // Workflow templates
Skill({ skill: "flow:workflow:pause" }); // Pause workflow
Skill({ skill: "flow:workflow:complete" }); // Complete workflow
Skill({ skill: "flow:status" }); // Check status
```

</related_skills>

<success_criteria>

- [ ] State checked for conflicts
- [ ] Workflow type determined
- [ ] Requirements gathered
- [ ] State updated
- [ ] TodoWrite initialized
- [ ] Confirmation displayed

</success_criteria>
