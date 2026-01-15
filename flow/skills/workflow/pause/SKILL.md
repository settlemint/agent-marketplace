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

```javascript
// Load this skill
Skill({ skill: "flow:workflow:pause" });
```

</quick_start>

<workflow>

## Phase 1: Load State

1. Read `.claude/flow/state.json`
2. Check if there's an active workflow
3. If no active workflow, inform user

## Phase 2: Capture Progress

Document current progress:

- Completed tasks
- In-progress tasks
- Any notes or context

## Phase 3: Update State

Update workflow status:

```json
{
  "currentWorkflow": {
    "...existing",
    "status": "paused",
    "pausedAt": "ISO date",
    "pauseReason": "user requested",
    "resumeContext": "notes about where to resume"
  }
}
```

## Phase 4: Update TodoWrite

Mark current tasks as pending (not in_progress) to reflect paused state.

## Phase 5: Confirm

Display:

- Workflow paused confirmation
- Progress summary
- How to resume:
  ```javascript
  Skill({ skill: "flow:workflow:start" }); // Will offer to resume
  ```

</workflow>

<related_skills>

```javascript
Skill({ skill: "flow:workflow:start" }); // Resume workflow
Skill({ skill: "flow:workflow:complete" }); // Complete instead
Skill({ skill: "flow:status" }); // Check status
```

</related_skills>

<success_criteria>

- [ ] State loaded
- [ ] Progress captured
- [ ] State updated to paused
- [ ] TodoWrite updated
- [ ] Confirmation displayed with Skill() references

</success_criteria>
