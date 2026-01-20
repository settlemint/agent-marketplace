---
name: iterative-retrieval
description: This skill should be used when the user asks to "research a bug", "gather debugging context", "follow up on review findings", or when any implementation task may need multiple passes to gather sufficient context. Dispatches subagents with automatic refinement loops.
version: 1.0.0
---

# Iterative Subagent Retrieval Protocol

A systematic approach to gathering context through subagents during implementation that ensures sufficient information before proceeding. Instead of accepting single-pass results, the orchestrator evaluates sufficiency and asks follow-up questions until confident.

## Core Insight

**Orchestrators have semantic context that subagents lack.**

When you dispatch a subagent to investigate a bug or gather implementation context, you know the purpose behind the request—the fix or feature the information will support. The subagent only knows the literal query. Single-pass summaries often miss key details because the subagent lacks this implicit context.

**Solution:** Evaluate every subagent return and ask follow-up questions before accepting it. Loop until sufficient.

## When to Use

- Investigating bugs and failures (root cause analysis)
- Gathering context before implementing fixes
- Following up on reviewer findings that need clarification
- Researching existing patterns before writing new code
- Understanding legacy code before modifying it

## When NOT to Use

- Simple, targeted queries with clear answers
- Time-critical hotfixes where speed matters
- Following established patterns with clear examples
- Queries where the first result is definitionally sufficient

## The 4-Phase Protocol

### Phase 1: Initial Dispatch

Before dispatching, explicitly define your context needs:

1. **Define PRIMARY OBJECTIVE** - What implementation decision does this information support?
2. **Define INITIAL QUERIES** - Specific items to retrieve
3. **Dispatch with BOTH** - Include queries AND objective context in the prompt
4. **Store agent ID** - Returned by Task tool for potential resumption

```javascript
// Example: Investigating a test failure
const result = Task({
  subagent_type: "general-purpose",
  description: "Investigate test failure",
  prompt: `OBJECTIVE: Fix flaky test in user-service.test.ts

  QUERIES:
  1. What is the exact test that's failing?
  2. What error message is produced?
  3. What code path does this test exercise?

  WHY: Need to understand the failure before writing a fix.
  Report findings with file paths and line numbers.`
})

// Store the agent ID for potential follow-up
const agentId = result.agentId
```

### Phase 2: Sufficiency Evaluation

Upon receiving the subagent's summary, **critically evaluate** before proceeding:

**Ask yourself:**

| Question | If YES |
|----------|--------|
| Do I understand the root cause, not just symptoms? | Consider sufficient |
| Are there async/timing factors the summary didn't explore? | Continue to Phase 3 |
| Did the subagent show both success and failure code paths? | Consider sufficient |
| Would I confidently write a fix with ONLY this information? | SUFFICIENT - proceed |

**Decision:**
- If **SUFFICIENT** → Proceed with implementation, note agent ID for future resumption
- If **INSUFFICIENT** → Continue to Phase 3

### Phase 3: Refinement Request

Resume the subagent using its agent ID with a targeted follow-up:

```javascript
Task({
  resume: agentId,  // Resume with full previous context preserved
  prompt: `Good findings on the test assertion failure.

  FOLLOW-UP NEEDED:
  1. You showed the failing assertion but not the test setup - what mock data is used?
  2. The error mentions "timeout" but you didn't show any async code - where are the promises?
  3. Were there any related tests that pass that I could use as a reference?

  WHY: Need to understand the async behavior to fix the race condition.`
})
```

**Refinement request structure:**
1. **Acknowledge** what was useful from the initial return
2. **Specify EXACTLY** what additional context is needed and WHY
3. **Ask** if there's related information the subagent noticed but didn't include

### Phase 4: Loop

Repeat Phases 2-3 until one of these conditions:

| Condition | Action |
|-----------|--------|
| Sufficiency achieved | Proceed with implementation |
| Maximum 3 refinement cycles reached | Proceed with best available (prevent infinite loops) |
| Subagent confirms source is exhausted | Proceed with what's available |

## Build-Mode Integration Patterns

### Pattern 1: Debugging Context Gathering

When investigating bugs before writing fixes:

```javascript
// Phase 1: Initial investigation
const debugResult = Task({
  subagent_type: "general-purpose",
  description: "Investigate API 500 error",
  prompt: `OBJECTIVE: Fix intermittent 500 errors on /api/users endpoint

  QUERIES:
  1. What code handles this endpoint?
  2. What error handling exists?
  3. What are the recent changes to this code?

  WHY: Need to identify root cause before implementing fix.`
})

// Phase 2: Evaluate - do I understand the failure mode?
// If response shows handler but not error boundaries, that's a gap

// Phase 3: Follow up on gaps
Task({
  resume: debugResult.agentId,
  prompt: `You showed the handler but not error propagation.

  FOLLOW-UP:
  1. What middleware wraps this handler?
  2. How do errors get transformed before response?
  3. Are there any try-catch blocks I should know about?

  WHY: The 500 suggests unhandled exception - need to trace error path.`
})
```

### Pattern 2: Reviewer Finding Clarification

When a reviewer identifies issues that need more context:

```javascript
// Reviewer found: "Potential race condition in state update"

// Phase 1: Gather context on the concern
const reviewResult = Task({
  subagent_type: "general-purpose",
  description: "Investigate race condition",
  prompt: `OBJECTIVE: Address reviewer concern about race condition

  REVIEWER COMMENT: "Potential race condition in state update"
  FILE: src/store/actions.ts:45

  QUERIES:
  1. What is the full context around line 45?
  2. What concurrent operations could affect this state?
  3. How is this state accessed elsewhere?

  WHY: Need to understand if this is a real race condition before fixing.`
})

// Phase 2: Evaluate - can I confirm/refute the race condition?

// Phase 3: Follow up if unclear
Task({
  resume: reviewResult.agentId,
  prompt: `You showed the state update but not the concurrent access.

  FOLLOW-UP:
  1. Are there any other components that dispatch to this state?
  2. What is the order of operations when multiple updates occur?
  3. Is there existing synchronization I should be aware of?

  WHY: Need to determine if locking/queuing is required.`
})
```

### Pattern 3: Legacy Code Investigation

Before modifying code without tests:

```javascript
// Phase 1: Understand current behavior
const legacyResult = Task({
  subagent_type: "general-purpose",
  description: "Analyze legacy billing code",
  prompt: `OBJECTIVE: Add retry logic to billing service (no existing tests)

  QUERIES:
  1. What is the current billing flow?
  2. What error handling exists?
  3. What side effects occur during billing?

  WHY: Need to write characterization tests before modifying.`
})

// Phase 2: Can I write accurate characterization tests?
// If response doesn't show ALL code paths, need follow-up

// Phase 3: Get complete picture
Task({
  resume: legacyResult.agentId,
  prompt: `You showed the happy path but not failure modes.

  FOLLOW-UP:
  1. What happens when payment gateway returns error?
  2. Are there any manual intervention points?
  3. What logging/alerting exists for failures?

  WHY: Characterization tests must cover failure modes too.`
})
```

## Output Format

When reporting findings or continuing implementation, document:

- Total refinement cycles used (0 = first pass sufficient)
- What additional context was gathered beyond initial request
- Agent ID for future resumption if needed

```
## Investigation Complete (2 refinement cycles)

Initial query found: Handler in api/users.ts:34
Cycle 1 added: Error middleware in middleware/errors.ts
Cycle 2 added: Unhandled promise rejection in database call

Root cause: Missing await on line 67 causes unhandled rejection

Agent ID: xyz789 (available for follow-up during fix)
```

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Instead |
|--------------|----------------|---------|
| Accepting symptom without root cause | Fix may not address actual problem | Ask "but WHY does this happen?" |
| Skipping related test exploration | Miss regression test examples | Always ask about passing tests |
| Not exploring error paths | Miss failure modes | Explicitly ask for error handling |
| Exceeding 3 cycles | Diminishing returns, may indicate wrong approach | Accept best available, note gaps |

## Integration with TDD

When using iterative retrieval for debugging:

1. **Before investigation:** Have a hypothesis about what test would catch this
2. **During investigation:** Look for existing test patterns to follow
3. **After investigation:** Write failing test BEFORE implementing fix
4. **If stuck after 3 cycles:** The problem may require different approach

## Additional Resources

### Reference Files

- **`references/sufficiency-checklist.md`** - Detailed evaluation criteria for different implementation contexts
