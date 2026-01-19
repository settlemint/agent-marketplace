# Rule of Five Framework

Iterative refinement through multiple review passes with escalating scope until quality converges.

## Table of Contents

- [Core Principle](#core-principle)
- [Five-Pass Framework](#five-pass-framework)
  - [Pass 1: Standard Review](#pass-1-standard-review)
  - [Pass 2: Deep Review](#pass-2-deep-review)
  - [Pass 3: Architecture Review](#pass-3-architecture-review)
  - [Pass 4: Existential Review](#pass-4-existential-review)
  - [Pass 5: Strategic Review](#pass-5-strategic-review-if-needed)
- [Convergence Signals](#convergence-signals)
- [Evidence Requirements](#evidence-requirements)
- [Spec-Specific Reviews](#spec-specific-reviews)
- [Banned Vague Language](#banned-vague-language)
- [Convergence Cycle Workflow](#convergence-cycle-workflow)
- [Quality Score](#quality-score)
- [Anti-Patterns](#anti-patterns)

## Core Principle

Generating output is easy; reviewing deeply is hard. Initial drafts undergo 4-5 sequential passes with broadening scope until work reaches "as good as it can get."

## Five-Pass Framework

### Pass 1: Standard Review

Focus on obvious issues and basic correctness.

**Review prompts:**
- Are all required elements present?
- Any obvious gaps or missing steps?
- Does the plan compile/make sense at face value?
- Are there typos or unclear wording?

**Evidence required:** List specific gaps found with locations.

### Pass 2: Deep Review

Examine non-obvious issues and edge cases.

**Review prompts:**
- What edge cases are not addressed?
- What error scenarios are missing?
- Are there subtle logic issues?
- What assumptions are unstated?
- Is test coverage adequate?

**Evidence required:** Specific edge cases identified with impact assessment.

### Pass 3: Architecture Review

Evaluate system-level concerns.

**Review prompts:**
- Does this follow existing patterns in the codebase?
- Are dependencies properly ordered?
- Is coupling appropriate?
- Are there YAGNI violations (over-engineering)?
- Will this integrate cleanly?

**Evidence required:** Pattern comparisons, dependency analysis.

### Pass 4: Existential Review

Question fundamental assumptions.

**Review prompts:**
- Is this solving the right problem?
- Is this the right approach at all?
- What paradigm shifts might help?
- Are we missing a simpler solution?
- Will this still make sense in 6 months?

**Evidence required:** Alternative approaches considered, rationale for current choice.

### Pass 5: Strategic Review (if needed)

Broader context and future implications.

**Review prompts:**
- How does this align with project roadmap?
- What precedent does this set?
- Are there team/org implications?
- What technical debt does this create or resolve?

**Evidence required:** Strategic alignment assessment.

## Convergence Signals

### Strong Signals (Stop reviewing)

- **Zero findings:** Pass produces no new issues
- **Cosmetic only:** Only style/formatting suggestions remain
- **Agent declaration:** Explicit statement that work is complete
- **All dimensions covered:** Every review aspect addressed

### Weak Signals (Consider stopping)

- **Diminishing severity:** P1s → P2s → P3s across passes
- **Smaller diffs:** Each pass produces fewer changes
- **Faster completion:** Passes take less time

### Anti-Signals (Keep reviewing)

- **New P1/P2 findings:** Critical issues still emerging
- **Scope expansion:** Plan keeps growing
- **Conflicting advice:** Suggestions contradict each other
- **Uncertainty:** Reviewer expresses doubt

## Evidence Requirements

Each pass must provide proof, not claims:

**Valid evidence:**
- Specific line/task references
- Concrete examples
- Test case descriptions
- Comparison with codebase patterns
- Risk quantification

**Invalid evidence:**
- "Looks good"
- "Should be fine"
- "I think it covers everything"
- Vague assurances

## Spec-Specific Reviews

When reviewing specifications or requirements:

### Pass 1: Completeness Check

- Are all six core areas covered? (Goal, Context, Requirements, Constraints, Success Criteria, Non-goals)
- Is framing goal-oriented, not task-oriented?

### Pass 2: Clarity Check

- Could another engineer implement without clarifying questions?
- Are all terms defined?
- No ambiguous pronouns?

### Pass 3: Testability Check

- Are all success criteria measurable?
- Can acceptance be verified objectively?

### Pass 4: Boundaries Check

- Are Always/Ask/Never behaviors defined?
- No vague language? (See banned words below)

### Pass 5: Strategic Check

- Is this the right problem to solve?
- Is scope appropriate?

## Banned Vague Language

Replace these with specific criteria:

| Vague | Replace With |
|-------|--------------|
| "appropriate" | Exact criteria or threshold |
| "best practices" | Name the specific practice |
| "as needed" | Specific trigger condition |
| "properly" | List specific validations |
| "handle errors" | Specify catch, log, return behavior |
| "ensure" | Specific verification method |
| "consider" | Specific decision criteria |

## Convergence Cycle Workflow

```
Generate Initial Plan
        ↓
┌─→ Pass N Review
│       ↓
│   Findings?
│       ↓
│   Yes → Apply Fixes → Next Pass
│       ↓
│   No → Check Convergence
│       ↓
│   Converged? → Done
│       ↓
└── No (and < 5 passes) ───┘
```

## Quality Score

Rate plans on 12-point scale:

| Score | Meaning | Action |
|-------|---------|--------|
| 10-12 | Ready for implementation | Proceed |
| 7-9 | Minor gaps | One more pass |
| 4-6 | Significant gaps | Two+ passes needed |
| 0-3 | Fundamental issues | Restart planning |

**Scoring criteria (2 points each):**
1. Context complete and accurate
2. Research thorough
3. Architecture decision justified
4. Tasks INVEST-compliant
5. Acceptance criteria clear
6. Risks identified

## Anti-Patterns

### Premature Convergence
Stopping after 1-2 passes without evidence of completeness.

### Rubber-Stamping
Passes that claim "looks good" without specific evidence.

### No Escalation
All passes at same depth; never reaching architecture/existential levels.

### Evidence-Free Claims
Assertions without proof ("tests will cover this").

### Infinite Loop
Never declaring convergence despite diminishing returns.
