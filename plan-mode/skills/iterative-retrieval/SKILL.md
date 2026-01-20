---
name: iterative-retrieval
description: Dispatch subagents with automatic refinement loop until sufficient context is gathered. Use when spawning Explore agents, researching codebases, gathering context for planning, or any task where single-pass results may miss critical details.
version: 1.0.0
---

# Iterative Subagent Retrieval Protocol

A systematic approach to gathering context through subagents that ensures sufficient information before proceeding. Instead of accepting single-pass results, the orchestrator evaluates sufficiency and asks follow-up questions until confident.

## Core Insight

**Orchestrators have semantic context that subagents lack.**

When you dispatch a subagent, you know the purpose behind the request—the decision or action the information will support. The subagent only knows the literal query. Single-pass summaries often miss key details because the subagent lacks this implicit context.

**Solution:** Evaluate every subagent return and ask follow-up questions before accepting it. Loop until sufficient.

## When to Use

- Spawning Explore agents for codebase research
- Gathering context before planning decisions
- Investigating unfamiliar code areas
- Researching external documentation
- Any context-gathering task where completeness matters

## When NOT to Use

- Simple, targeted queries with clear answers
- Time-critical operations where latency matters
- Queries where the first result is definitionally sufficient
- Follow-up operations on already-gathered context

## The 4-Phase Protocol

### Phase 1: Initial Dispatch

Before dispatching, explicitly define your context needs:

1. **Define PRIMARY OBJECTIVE** - What decision or action does this information support?
2. **Define INITIAL QUERIES** - Specific items to retrieve
3. **Dispatch with BOTH** - Include queries AND objective context in the prompt
4. **Store agent ID** - Returned by Task tool for potential resumption

```javascript
// Example: Explore agent for understanding auth system
const result = Task({
  subagent_type: "Explore",
  description: "Research auth system",
  prompt: `OBJECTIVE: Planning implementation of OAuth2 refresh tokens

  QUERIES:
  1. Where is authentication currently handled?
  2. What token formats are used?
  3. How are sessions managed?

  WHY: Need to understand current auth architecture before adding refresh token support.
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
| Does the summary contain gaps that the objective requires filling? | Continue to Phase 3 |
| Did the subagent mention adjacent information I didn't ask for but now realize I need? | Continue to Phase 3 |
| Are there ambiguities in what was returned that require clarification from the source? | Continue to Phase 3 |
| Would I be confident proceeding with ONLY this information? | SUFFICIENT - proceed |

**Decision:**
- If **SUFFICIENT** → Proceed with task, note agent ID for potential future resumption
- If **INSUFFICIENT** → Continue to Phase 3

### Phase 3: Refinement Request

Resume the subagent using its agent ID with a targeted follow-up:

```javascript
Task({
  resume: agentId,  // Resume with full previous context preserved
  prompt: `Good findings on the JWT handling in auth/tokens.ts.

  FOLLOW-UP NEEDED:
  1. You mentioned "session store" but didn't specify where it's implemented - where is session state persisted?
  2. I notice the token has a 'refresh' field - is there existing refresh logic I should know about?
  3. Were there any related auth utilities or helpers you noticed but didn't include?

  WHY: Need session persistence details to ensure refresh tokens integrate correctly.`
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
| Sufficiency achieved | Proceed with gathered context |
| Maximum 3 refinement cycles reached | Proceed with best available (prevent infinite loops) |
| Subagent confirms source is exhausted | Proceed with what's available |

## Output Format

When reporting to user or continuing work, document:

- Total refinement cycles used (0 = first pass sufficient)
- What additional context was gathered beyond initial request
- Agent ID for future resumption if needed

```
## Context Gathered (2 refinement cycles)

Initial query found: JWT handling in auth/tokens.ts
Cycle 1 added: Session persistence in redis/sessions.ts
Cycle 2 added: Existing refresh stub in auth/refresh.ts (unused)

Agent ID: abc123 (available for follow-up)
```

## Integration with Explore Agents

When using this protocol with Explore agents during planning:

```javascript
// Phase 1: Initial exploration with objective context
const exploreResult = Task({
  subagent_type: "Explore",
  description: "Explore payment system",
  prompt: `OBJECTIVE: Adding support for subscription billing

  QUERIES:
  1. How are payments currently processed?
  2. What payment providers are integrated?
  3. Where is billing logic located?

  WHY: Need to understand payment architecture before adding recurring billing.`
})

// Phase 2: Evaluate sufficiency
// Ask: Do I understand enough to plan the subscription feature?
// If the response mentions "webhooks" but doesn't explain them, that's a gap

// Phase 3: Resume with follow-up if needed
Task({
  resume: exploreResult.agentId,
  prompt: `You mentioned webhook handlers but didn't detail them.

  FOLLOW-UP:
  1. What events do the current webhooks handle?
  2. Where is webhook validation performed?

  WHY: Subscriptions will need webhook handling for payment status updates.`
})
```

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Instead |
|--------------|----------------|---------|
| Accepting first result without evaluation | Misses gaps you don't know exist | Always run sufficiency check |
| Vague follow-ups ("tell me more") | Wastes cycles, gets unfocused results | Be specific about what's missing |
| Exceeding 3 cycles | Diminishing returns, context pollution | Accept best available, note gaps |
| Skipping objective in dispatch | Subagent can't prioritize relevance | Always include WHY |

## Additional Resources

### Reference Files

- **`references/sufficiency-checklist.md`** - Detailed evaluation criteria for different task types
