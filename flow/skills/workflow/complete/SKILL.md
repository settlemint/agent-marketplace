---
name: flow:workflow:complete
description: Complete the current workflow. Use when finishing work and ready to archive the workflow.
triggers:
  - "complete workflow"
  - "finish workflow"
  - "end workflow"
  - "done with workflow"
---

<objective>

Complete the current workflow, archive it, and generate a summary.

**Updates:** `.claude/flow/state.json`, `.claude/flow/history/`

</objective>

<quick_start>

```javascript
// Load this skill
Skill({ skill: "flow:workflow:complete" });
```

</quick_start>

<workflow>

## Phase 1: Load State

1. Read `.claude/flow/state.json`
2. Check if there's an active/paused workflow
3. If no workflow, inform user

## Phase 2: Review Completion

Check task completion status:

- If all tasks completed: proceed to completion
- If tasks incomplete, ask user:

```
Some tasks are not marked complete:
- [ ] Task A
- [ ] Task B

Would you like to:
1. Mark all as complete
2. Complete workflow anyway (tasks remain incomplete)
3. Cancel and continue working
```

## Phase 3: Generate Summary

Create workflow summary:

```json
{
  "id": "uuid",
  "name": "workflow-name",
  "type": "feature|bug|refactor|docs|tests|custom",
  "description": "...",
  "startedAt": "ISO date",
  "completedAt": "ISO date",
  "duration": "human readable",
  "tasks": [...],
  "completedTasks": N,
  "totalTasks": N,
  "completionRate": "N%"
}
```

## Phase 4: Archive Workflow

1. Save summary to `.claude/flow/history/{id}.json`
2. Clear current workflow from state
3. Update last activity

## Phase 5: Update TodoWrite

Clear workflow-related todos, mark as completed.

## Phase 6: Present Summary

Display:

- Completion confirmation
- Summary statistics
- What was accomplished
- Next steps:
  ```javascript
  Skill({ skill: "flow:workflow:start" }); // Start new workflow
  Skill({ skill: "flow:status" }); // Check status
  ```

</workflow>

<related_skills>

```javascript
Skill({ skill: "flow:workflow:start" }); // Start new workflow
Skill({ skill: "flow:status" }); // Check status
Skill({ skill: "flow:analyze" }); // Analyze results
```

</related_skills>

<success_criteria>

- [ ] State loaded
- [ ] Task completion verified or acknowledged
- [ ] Summary generated
- [ ] Workflow archived
- [ ] State cleared
- [ ] Summary presented with Skill() recommendations

</success_criteria>
