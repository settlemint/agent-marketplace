---
name: brainstorming
description: Use for early-stage design exploration through Socratic dialogue. Triggers on "brainstorm", "design idea", "explore options", "what should we build", "help me think through". Uses AskUserQuestion for interactive refinement.
license: MIT
triggers:
  # Intent triggers
  - "brainstorm"
  - "brainstorming"
  - "design idea"
  - "explore options"
  - "think through"
  - "help me decide"
  - "what should we build"
  - "design exploration"
  - "ideation"

  # Context triggers
  - "not sure which approach"
  - "several options"
  - "trade-offs"
  - "pros and cons"
  - "early stage"
  - "before we commit"
---

<objective>

Guide early-stage design exploration through Socratic dialogue. Unlike spec-writing (formal specifications), brainstorming is for discovering what to build through iterative questioning. Uses AskUserQuestion tool for interactive refinement, one question at a time, with multiple-choice options for faster decisions.

Key principle: "The answer emerges from good questions, not premature solutions."

</objective>

<quick_start>

1. **Start with context gathering** - Understand the problem space
2. **Ask one question at a time** - Use AskUserQuestion with options
3. **Prefer multiple choice** - Faster decisions, clearer direction
4. **Validate incrementally** - 200-300 word chunks before proceeding
5. **Generate design document** - Capture decisions as you go
6. **Apply YAGNI ruthlessly** - Only design what's needed now

</quick_start>

<socratic_method>

## Core Principle

Don't present solutions. Ask questions that help the user discover the right solution.

## Question Flow

```
1. CONTEXT: What problem are we solving?
   ↓
2. SCOPE: What's in/out for first version?
   ↓
3. CONSTRAINTS: What limits exist?
   ↓
4. OPTIONS: What approaches are possible?
   ↓
5. TRADE-OFFS: What matters most?
   ↓
6. DECISION: Which path forward?
```

## Question Types

| Type | Purpose | Example |
|------|---------|---------|
| **Clarifying** | Understand context | "What problem does this solve for users?" |
| **Scoping** | Define boundaries | "Should v1 include X, or is that v2?" |
| **Trade-off** | Prioritize values | "Is speed or flexibility more important?" |
| **Constraint** | Surface limits | "What tech stack constraints exist?" |
| **Validation** | Confirm understanding | "So the core need is X, correct?" |

</socratic_method>

<askuserquestion_integration>

## MANDATORY: Use AskUserQuestion Tool

All design questions MUST use the AskUserQuestion tool, not plain text questions.

**Why:**
- Structured responses are easier to process
- Multiple choice reduces ambiguity
- User gets clear options to choose from
- Conversation stays focused

**Pattern:**

```javascript
// CORRECT: Use AskUserQuestion
mcp__conductor__AskUserQuestion({
  questions: [{
    question: "What's the primary goal for this feature?",
    options: [
      "Improve user onboarding experience",
      "Reduce support ticket volume",
      "Enable self-service configuration",
      "Increase feature discoverability"
    ]
  }]
})

// INCORRECT: Plain text question
// "What's the primary goal for this feature?"
```

## Option Design Guidelines

**Good options are:**
- **Mutually exclusive** - Choosing one rules out others
- **Collectively exhaustive** - Cover all reasonable cases
- **Actionable** - Each option implies a clear direction
- **Concise** - 5-15 words per option

**Option count:**
- 2 options: Binary decision (yes/no, A/B)
- 3-4 options: Most design questions
- 5+ options: Only when truly needed

**Always available:** "Other" is automatically provided by the tool for free-form input.

## Example Sequences

**Starting a brainstorm:**

```javascript
mcp__conductor__AskUserQuestion({
  questions: [{
    question: "What's the main problem you're trying to solve?",
    options: [
      "Users can't find existing functionality",
      "A common task takes too many steps",
      "Missing capability that users request",
      "Technical debt causing issues"
    ]
  }]
})
```

**Narrowing scope:**

```javascript
mcp__conductor__AskUserQuestion({
  questions: [{
    question: "For the first version, which is most important?",
    options: [
      "Core functionality works reliably",
      "Great user experience from day one",
      "Easy to extend and iterate",
      "Ship fast, learn from users"
    ]
  }]
})
```

**Choosing approach:**

```javascript
mcp__conductor__AskUserQuestion({
  questions: [{
    question: "Which architecture pattern fits best?",
    options: [
      "Simple: Single component, minimal abstraction",
      "Modular: Separate components, clear interfaces",
      "Extensible: Plugin architecture for future growth",
      "Standard: Follow existing codebase patterns"
    ]
  }]
})
```

</askuserquestion_integration>

<incremental_validation>

## Validate in 200-300 Word Chunks

After every 2-3 questions, summarize and validate understanding before proceeding.

**Validation checkpoint format:**

```markdown
## What I've Understood So Far

**Problem:** [1-2 sentences]
**Users:** [target audience]
**Core need:** [what they need to do]
**Constraints:** [any limits mentioned]

**Key decisions made:**
- [Decision 1]: [chosen option]
- [Decision 2]: [chosen option]

Does this capture it correctly?
```

**Then ask:**

```javascript
mcp__conductor__AskUserQuestion({
  questions: [{
    question: "Is this summary accurate?",
    options: [
      "Yes, continue with next questions",
      "Mostly, but need to clarify [X]",
      "No, let me restate the problem"
    ]
  }]
})
```

## Why Incremental?

- **Prevents drift** - Catch misunderstandings early
- **Builds confidence** - User sees you understand
- **Creates artifact** - Summary becomes design doc
- **Enables pivot** - Easy to course-correct

</incremental_validation>

<yagni_enforcement>

## You Aren't Gonna Need It

During brainstorming, actively resist scope creep.

**YAGNI questions to ask:**

```javascript
mcp__conductor__AskUserQuestion({
  questions: [{
    question: "You mentioned [X feature]. Is this needed for v1?",
    options: [
      "Yes, core to the solution",
      "Nice to have, but not blocking",
      "Actually, let's defer that",
      "Hmm, let me reconsider"
    ]
  }]
})
```

**Red flags for scope creep:**

| Phrase | Translation | Response |
|--------|-------------|----------|
| "While we're at it..." | Scope creep | "Let's capture that for v2" |
| "It would be nice if..." | Gold plating | "Is it required for launch?" |
| "In case we need to..." | Premature abstraction | "YAGNI - add when needed" |
| "We should also..." | Expanding scope | "Focus: what's the ONE thing?" |

**Challenge complexity:**

```javascript
mcp__conductor__AskUserQuestion({
  questions: [{
    question: "This solution is getting complex. Could we simplify by...",
    options: [
      "Removing [feature X] from v1",
      "Using a simpler approach for [Y]",
      "Hardcoding [Z] instead of making it configurable",
      "The complexity is justified"
    ]
  }]
})
```

</yagni_enforcement>

<design_document_generation>

## Capture Decisions as Design Document

As brainstorming progresses, build a design document incrementally.

**Document structure:**

```markdown
# Design: [Feature Name]

Generated: [date]
Status: Draft / Under Review / Approved

## Problem Statement

[2-3 sentences from initial questions]

## Goals

### Must Have (v1)
- [ ] [Goal 1]
- [ ] [Goal 2]

### Nice to Have (v2+)
- [ ] [Deferred item 1]
- [ ] [Deferred item 2]

## Decisions Made

| Decision | Chosen Option | Rationale |
|----------|---------------|-----------|
| [Topic 1] | [Choice] | [Why] |
| [Topic 2] | [Choice] | [Why] |

## Approach

[200-300 word description of the solution]

## Open Questions

- [ ] [Unresolved question 1]
- [ ] [Unresolved question 2]

## Next Steps

1. [Immediate action]
2. [Following action]
```

**Save location:** `docs/designs/YYYY-MM-DD-[feature-name].md`

**At end of brainstorm:**

```javascript
mcp__conductor__AskUserQuestion({
  questions: [{
    question: "Should I save this design document?",
    options: [
      "Yes, save to docs/designs/",
      "Yes, but I want to review/edit first",
      "Not yet, let's continue brainstorming",
      "No, this was just exploration"
    ]
  }]
})
```

</design_document_generation>

<workflow>

## Full Brainstorming Workflow

```
┌─────────────────────────────────────────┐
│ 1. INITIATE                             │
│    - User triggers brainstorm           │
│    - Ask: "What problem to solve?"      │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 2. CONTEXT GATHER (3-5 questions)       │
│    - Problem space                      │
│    - Users affected                     │
│    - Current state                      │
│    - Success criteria                   │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 3. VALIDATE CHECKPOINT                  │
│    - Summarize understanding (200 words)│
│    - Confirm with user                  │
│    - Adjust if needed                   │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 4. SCOPE DEFINITION (3-5 questions)     │
│    - What's in v1?                      │
│    - What's deferred?                   │
│    - YAGNI check                        │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 5. VALIDATE CHECKPOINT                  │
│    - Update summary with scope          │
│    - Confirm priorities                 │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 6. APPROACH EXPLORATION (3-5 questions) │
│    - Architecture options               │
│    - Trade-offs                         │
│    - Constraints                        │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 7. FINAL VALIDATION                     │
│    - Complete design summary            │
│    - User confirms direction            │
└─────────────────┬───────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 8. OUTPUT                               │
│    - Generate design document           │
│    - Save to docs/designs/              │
│    - Suggest next steps                 │
└─────────────────────────────────────────┘
```

</workflow>

<success_criteria>

- [ ] Used AskUserQuestion for ALL design questions (not plain text)
- [ ] Asked one question at a time (not batched)
- [ ] Provided 3-4 multiple choice options per question
- [ ] Validated understanding every 2-3 questions
- [ ] Applied YAGNI to challenge scope creep
- [ ] Captured decisions in design document
- [ ] User confirmed final direction before concluding

</success_criteria>

<constraints>

**Required:**
- AskUserQuestion tool for all questions
- One question at a time
- Validation checkpoints every 200-300 words
- YAGNI challenges for scope expansion

**Banned:**
- Plain text questions without options
- Batching multiple questions in one ask
- Proposing solutions before understanding problem
- Accepting "while we're at it" scope additions without challenge

</constraints>

<anti_patterns>

- **Solution-first** - Proposing architecture before understanding problem
- **Question dump** - Asking 5+ questions at once overwhelms user
- **Leading questions** - "Don't you think we should use React?" biases response
- **Skipping validation** - Not confirming understanding leads to drift
- **Feature creep acceptance** - Not challenging every scope addition

</anti_patterns>

<integration>

**Use with other skills:**

After brainstorming completes, hand off to:

```javascript
// For formal specification
Skill({ skill: "devtools:spec-writing" })

// For implementation planning
Skill({ skill: "flow:enhance" }) // triggers plan mode
```

**Distinction from spec-writing:**

| Aspect | Brainstorming | Spec-writing |
|--------|---------------|--------------|
| Stage | Early exploration | Formal definition |
| Output | Design direction | Implementation spec |
| Format | Interactive Q&A | Structured document |
| Focus | What to build | How to build |

</integration>

<references>

- Superpowers plugin: brainstorming skill
- Socratic method for design exploration
- YAGNI (You Aren't Gonna Need It) principle
- Incremental design documentation

</references>
