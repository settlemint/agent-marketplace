---
name: flow:workflow:pause
description: Pause the current workflow. Use when needing to switch context or take a break from current work.
triggers:
  - "pause workflow"
  - "stop workflow"
  - "suspend workflow"
---

<objective>

Pause the current active workflow while preserving state for later resumption.

**Updates:** `.claude/flow/state.json`

</objective>

<quick_start>

1. Load active workflow from `.claude/flow/state.json`
2. Capture current progress and context
3. Update status to paused with resume notes

</quick_start>

<workflow>

## Phase 1: Load State

Read `.claude/flow/state.json`. If no active workflow, inform user.

## Phase 2: Capture and Update

Document progress (completed/in-progress tasks, context notes). Update status to paused with pausedAt, pauseReason, resumeContext.

## Phase 3: Finalize

Mark TodoWrite tasks as pending. Display confirmation with progress summary and how to resume.

</workflow>

<related_skills>

```javascript
Skill({ skill: "flow:workflow:start" }); // Resume workflow
Skill({ skill: "flow:workflow:complete" }); // Complete instead
Skill({ skill: "flow:status" }); // Check status
```

</related_skills>

<success_criteria>

- [ ] Workflow paused with context preserved
- [ ] Confirmation displayed with resume instructions

</success_criteria>
