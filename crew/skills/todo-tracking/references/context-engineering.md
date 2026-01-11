---
name: context-engineering
description: Manus-inspired context engineering patterns for long-running agent tasks.
triggers:
  - "manus"
  - "context engineering"
  - "attention"
  - "long task"
  - "50 tool calls"
  - "progressive disclosure"
depends_on: []
---

<overview>

## Context Engineering Principles

Based on patterns from Manus progressive disclosure. These principles help agents maintain focus across 50+ tool calls without losing track of goals.

**Core Insight:** Context windows have limits. Use the filesystem as unlimited external memory with strategic attention refreshing and progressive disclosure.

**Progressive Disclosure:** "Show what exists and its retrieval cost first. Let the agent decide what to fetch based on relevance and need."

</overview>

<progressive_disclosure>

## Three-Layer Information Architecture

### Layer 1: Index (Lightweight Metadata)

- Compact list with titles, types, token counts
- Cost: ~50 tokens per entry
- Purpose: Rapid scanning without full context commitment

### Layer 2: Timeline (Contextual Narrative)

- Chronological view with before/after context
- Cost: ~100-200 tokens per observation
- Purpose: Understand sequence and causality

### Layer 3: Full Details (Complete Records)

- Fetch complete content only when justified
- Cost: ~500+ tokens per item
- Purpose: Deep dive on validated high-value items

**Token efficiency:** 10 tasks × 50 (index) = 500 tokens vs 10 × 500 (full) = 5000 tokens

</progressive_disclosure>

<legend_system>

## Semantic Compression with Icons

Use categorical icons for visual scanning efficiency:

| Icon | Type      | When to Use                                |
| ---- | --------- | ------------------------------------------ |
| 🔴   | Gotcha    | Critical edge case that breaks assumptions |
| 🟡   | Problem   | Fix/workaround for known issue             |
| 🔵   | How-to    | Technical explanation or implementation    |
| 🟢   | Change    | Code/architecture modification (default)   |
| 🟣   | Discovery | Non-obvious insight learned                |
| 🟠   | Rationale | Design reasoning (why it exists)           |
| 🟤   | Decision  | Architectural choice made                  |
| ⚖️   | Trade-off | Deliberate compromise accepted             |

**Semantic compression in titles (~10 words max):**

Poor: `Observation about a thing`
Good: `🔴 Hook timeout: 60s default too short for npm install`

**Benefits:**

- Visual pattern recognition across sessions
- Token-efficient categorization
- Priority signaling without reading content
- Language-agnostic scanning

</legend_system>

<cost_visibility>

## Token Cost Visibility

Every index entry should display approximate token counts:

```markdown
| File      | Priority | Type | Title                | ~Tokens |
| --------- | -------- | ---- | -------------------- | ------- |
| 001-\*.md | 🔴 P1    | 🟢   | Create structure     | ~150    |
| 010-\*.md | 🔴 P1    | 🔴   | Fix null pointer     | ~85     |
| 050-\*.md | 🟡 P2    | 🟣   | Discovered API quirk | ~280    |
```

**ROI Decision Making:**

- "Cheap" observations: ~50-100 tokens
- "Medium" observations: ~150-300 tokens
- "Expensive" observations: ~500+ tokens

Fetch cheap items freely, evaluate ROI for expensive ones.

</cost_visibility>

<principle_1>

## Principle 1: Filesystem as External Memory

> "Markdown is my 'working memory' on disk."

**Problem:** Context windows fill up. Stuffing everything in context degrades performance and loses information.

**Solution:** Store content in files, keep only paths in context:

```javascript
// BAD - stuffing context
const allFindings = await gatherAllFindings(); // 10000 lines
console.log(allFindings); // Fills context window

// GOOD - store externally
Write({
  file_path: ".claude/branches/main/notes.md",
  content: allFindings,
});
// Context only has: "Findings saved to .claude/branches/main/notes.md"
// Agent can read when needed
```

**Key Files Pattern:**

| File        | Purpose                    | When to Update     |
| ----------- | -------------------------- | ------------------ |
| `plan.md`   | Goals, phases, progress    | After each phase   |
| `notes.md`  | Research findings, context | During exploration |
| `errors.md` | Failed attempts, lessons   | On every failure   |

</principle_1>

<principle_2>

## Principle 2: Read Before Decide (Attention Manipulation)

**Problem:** After ~50 tool calls, the model forgets original goals ("lost in the middle" effect).

**Solution:** Re-read the plan file before every major decision:

```text
[Start of context: Original goal - far away, forgotten]
...many tool calls...
[End of context: Recently read plan.md - gets ATTENTION!]
```

**Implementation:**

```javascript
// Before EVERY major decision:
const plan = Read({ file_path: ".claude/branches/main/plan.md" });
// Now goals are fresh in attention window
// Make the decision with refreshed context
```

**When to Refresh:**

- Before starting a new phase
- Before making architectural decisions
- When feeling "lost" after many operations
- Before final delivery

</principle_2>

<principle_3>

## Principle 3: Keep Failure Traces

> "Error recovery is one of the clearest signals of TRUE agentic behavior."

**Problem:** Instinct says hide errors, retry silently. This wastes tokens and loses learning.

**Solution:** Document ALL failures in the task file:

```markdown
## Errors Encountered

- [2025-01-08] FileNotFoundError: config.json → Created default config
- [2025-01-08] API timeout on first call → Retried with backoff, succeeded
- [2025-01-08] Type error in User model → Added null check, fixed
```

**Benefits:**

1. Model learns from failures in current context
2. Future agents avoid same mistakes
3. Debugging becomes easier
4. Progress is visible even when struggling

**Implementation in Task Files:**

```javascript
// On any error, append to work log:
Edit({
  file_path: taskPath,
  old_string: "## Work Log",
  new_string: `## Work Log

### ${date} - Error Encountered
**Error:** ${errorMessage}
**Resolution:** ${whatWeDid}
**Lesson:** ${whatWeLearned}`,
});
```

</principle_3>

<principle_4>

## Principle 4: Controlled Variation (Avoid Few-Shot Overfitting)

> "Uniformity breeds fragility."

**Problem:** Repetitive action-observation pairs cause drift and hallucination.

**Solution:** Introduce controlled variation in prompts and actions:

```javascript
// BAD - copy-paste identical patterns
Task({ prompt: "Create user model" });
Task({ prompt: "Create user model" }); // Identical!

// GOOD - vary the framing
Task({ prompt: "Create User model with id, email, passwordHash fields" });
Task({ prompt: "Implement Profile entity linked to User" }); // Different framing
```

**Techniques:**

- Vary prompt phrasing slightly
- Use different entry points for similar tasks
- Recalibrate after repetitive operations

</principle_4>

<principle_5>

## Principle 5: Append-Only Context

**Problem:** Modifying previous context invalidates KV-cache, wasting compute.

**Solution:** Never modify history. Always append new information:

```javascript
// BAD - modifying existing content
Edit({ old_string: "status: pending", new_string: "status: complete" });
// Invalidates cache for entire conversation

// GOOD - append to work log instead
Edit({
  old_string: "## Work Log\n",
  new_string: `## Work Log

### ${date} - Status Update
Changed from pending to complete.
`,
});
// Adds new information without modifying history
```

**For Status Tracking:**

- Keep a running log rather than updating a single status field
- Use the work log as the source of truth for "what happened"
- Summary status in filename for quick filtering

</principle_5>

<workflow>

## The Manus-Inspired Workflow

### Phase 1: Before ANY Complex Task

```javascript
// 1. Create plan file FIRST
Write({
  file_path: `.claude/branches/${branch}/plan.md`,
  content: planTemplate,
});

// 2. Create notes file for findings
Write({
  file_path: `.claude/branches/${branch}/notes.md`,
  content: "# Research Notes\n\n",
});
```

### Phase 2: During Execution

```javascript
// Before each major decision:
Read({ file_path: `.claude/branches/${branch}/plan.md` });

// After each phase:
Edit({
  file_path: planPath,
  old_string: "- [ ] Phase 2",
  new_string: "- [x] Phase 2",
});

// When gathering large information:
Write({
  file_path: `.claude/branches/${branch}/notes.md`,
  content: gatheredInfo,
});
```

### Phase 3: On Errors

```javascript
// Document immediately - don't hide!
Edit({
  file_path: taskPath,
  old_string: "## Errors Encountered\n",
  new_string: `## Errors Encountered

- [${date}] ${errorType}: ${errorMessage} → ${resolution}
`,
});
```

### Phase 4: Before Delivery

```javascript
// Final refresh of goals
Read({ file_path: `.claude/branches/${branch}/plan.md` });
// Verify all acceptance criteria
// Deliver with confidence
```

</workflow>

<statistics>

## Manus Statistics

| Metric                      | Value                  |
| --------------------------- | ---------------------- |
| Average tool calls per task | ~50                    |
| Input-to-output token ratio | 100:1                  |
| Plan refresh frequency      | Every 10-15 tool calls |
| Error documentation rate    | 100% of failures       |

</statistics>

<anti_patterns>

## Anti-Patterns to Avoid

| Don't                       | Do Instead                        |
| --------------------------- | --------------------------------- |
| Stuff everything in context | Store large content in files      |
| State goals once and forget | Re-read plan before each decision |
| Hide errors and retry       | Log errors to plan file           |
| Use identical prompts       | Vary phrasing for similar tasks   |
| Modify previous messages    | Append new information            |
| Start executing immediately | Create plan file FIRST            |

</anti_patterns>
