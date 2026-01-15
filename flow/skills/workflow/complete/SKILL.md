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

1. Review task completion status
2. Generate summary and archive to `.claude/flow/history/`
3. Clear current workflow and update TodoWrite

</quick_start>

<workflow>

## Phase 1: Load State

Read `.claude/flow/state.json`. If no active/paused workflow, inform user.

## Phase 2: Review Completion

If tasks incomplete, offer options: mark all complete, complete anyway, or cancel.

## Phase 3: Archive

Generate summary (id, name, type, duration, task stats, completion rate). Save to `.claude/flow/history/{id}.json`. Clear current workflow from state.

## Phase 4: Finalize

Mark TodoWrite items completed. Display summary with accomplishments and next steps.

</workflow>

<related_skills>

```javascript
Skill({ skill: "flow:workflow:start" }); // Start new workflow
Skill({ skill: "flow:status" }); // Check status
Skill({ skill: "flow:analyze" }); // Analyze results
```

</related_skills>

<success_criteria>

- [ ] Workflow archived to history
- [ ] Summary presented with statistics

</success_criteria>
