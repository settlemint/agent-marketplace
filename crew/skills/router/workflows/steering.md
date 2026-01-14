# Steering Workflow

**Purpose:** Continue or adjust current work in progress without re-planning.

## When This Runs

User provides feedback or adjustment while work is in progress:

- "Actually use async/await instead"
- "Try a different approach"
- "Yes, continue"
- "Instead of X, do Y"

## Workflow

### 1. Preserve Context

The user is steering existing work. Do NOT:

- Create a new plan
- Start from scratch
- Lose track of current progress

DO:

- Acknowledge the adjustment
- Continue with the modification applied

### 2. Check Current State

```javascript
// Read current session state
const state = readState(".claude/branches/{branch}/state.json");

// Verify there's active work to steer
if (!state?.plan?.exists && !state?.execution?.pending_count) {
  // No active work - reclassify as TRIVIAL or SUBSTANTIAL
  return reclassify(userMessage);
}
```

### 3. Apply Adjustment

Based on the steering type:

| Steering Type    | Example                       | Action                               |
| ---------------- | ----------------------------- | ------------------------------------ |
| Affirmative      | "yes", "continue", "go ahead" | Resume current task unchanged        |
| Technique change | "use X instead"               | Retry current task with new approach |
| Scope adjustment | "also include Y"              | Add to current scope                 |
| Rejection        | "no, not that"                | Undo/retry with different approach   |

### 4. Continue Work

If work was paused for user input:

```javascript
// Resume the active workflow with the adjustment noted
Skill({ skill: state.workflow.active, args: state.workflow.args });
```

If this is mid-task feedback:

- The current worker should incorporate the feedback
- No workflow change needed, just apply the adjustment

### 5. Update State

```javascript
// State remains in current mode
// Only note the steering event
state.routing.last_steering = {
  at: new Date().toISOString(),
  adjustment: summarize(userMessage),
};
```

## Success Criteria

- [ ] Current work preserved (not restarted)
- [ ] Adjustment applied to ongoing task
- [ ] No unnecessary re-planning
- [ ] Context maintained
- [ ] State unchanged (still in working mode)
