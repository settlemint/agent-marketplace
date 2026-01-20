---
name: iterative-retrieval
description: This skill should be used when the user asks to "investigate a bug", "gather context", "research the code", or when spawning subagents where single-pass results may miss critical details. Dispatches subagents with automatic refinement loops.
version: 1.0.0
---

# Iterative Subagent Retrieval

Evaluate every subagent return. Follow up until sufficient. Max 3 cycles.

## When to Use

- Bug investigation (root cause)
- Gathering fix context
- Reviewer finding clarification
- Legacy code research

## 4-Phase Protocol

### Phase 1: Dispatch

Include OBJECTIVE + QUERIES + WHY:
```javascript
Task({
  subagent_type: "general-purpose",
  description: "Investigate [issue]",
  prompt: `OBJECTIVE: [what decision this supports]
  QUERIES: [specific items]
  WHY: [reason needed]`
})
```

### Phase 2: Evaluate

Ask: Would I confidently proceed with ONLY this information?
- Root cause or just symptoms?
- Both success and failure paths?
- Async/timing factors explored?

If **SUFFICIENT** → Proceed
If **INSUFFICIENT** → Phase 3

### Phase 3: Refine

```javascript
Task({
  resume: agentId,
  prompt: `FOLLOW-UP:
  1. [specific gap]
  2. [specific gap]
  WHY: [reason needed]`
})
```

### Phase 4: Loop

Stop when:
- Sufficient
- 3 cycles reached
- Source exhausted

## Output

```
Investigation Complete (N cycles)
Initial: [finding]
Cycle 1: [additional]
Root cause: [conclusion]
Agent ID: [id]
```

## Anti-Patterns

- Accepting symptom without root cause
- Not exploring error paths
- Exceeding 3 cycles (wrong approach)
