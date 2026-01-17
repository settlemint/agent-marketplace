# Spec Review Prompts Reference

Escalating prompts for each pass when reviewing specifications. Apply the Rule of Five to specs with these focus areas.

## Pass 1: Completeness Review

**Focus:** Coverage of the Six Core Areas

**Self-Audit Questions:**

1. Does the spec have a clear objective/goal statement?
2. Is the goal-oriented framing complete (Who/What/Why/Success)?
3. Are commands documented with expected behavior?
4. Is the testing strategy defined (framework, location, coverage)?
5. Is the project structure documented?
6. Are code style preferences shown with real examples?
7. Is the git workflow defined (branches, commits, PRs)?
8. Are boundaries defined (Always/Ask/Never)?

**Checklist:**

- [ ] Objective stated
- [ ] Goal-oriented framing complete
- [ ] Commands section present
- [ ] Testing section present
- [ ] Project structure documented
- [ ] Code style with examples
- [ ] Git workflow defined
- [ ] Boundaries section present

## Pass 2: Clarity Review

**Focus:** Precision and implementability

**Self-Audit Questions:**

1. Can an AI agent implement this with zero clarifying questions?
2. Are all technical terms defined or obvious from context?
3. Are file paths and directory names accurate?
4. Are external dependencies listed with versions?
5. Could this spec be misinterpreted? How?
6. Would a new team member understand the context?

**Clarity Signals:**

| Signal | Status |
|--------|--------|
| No ambiguous terms | [ ] |
| All paths verifiable | [ ] |
| Versions specified | [ ] |
| Examples for complex concepts | [ ] |

## Pass 3: Testability Review

**Focus:** Verification and measurability

**Self-Audit Questions:**

1. Is every success criterion measurable?
2. Can each acceptance criterion be verified with a command or observation?
3. Are there edge cases not covered by criteria?
4. What would demonstrate failure vs. success?
5. Can progress be tracked incrementally?

**Testability Patterns:**

Replace vague criteria with measurable ones:

| Vague | Measurable |
|-------|------------|
| "Works correctly" | "`bun run test` exits with code 0" |
| "Is fast" | "API responds in <200ms p95" |
| "Is secure" | "Passes OWASP ZAP scan with no high findings" |
| "Handles errors" | "Returns 4xx with JSON error body" |

## Pass 4: Boundaries Review

**Focus:** Safety, constraints, and edge cases

**Self-Audit Questions:**

1. What should the agent always do without asking?
2. What decisions require explicit approval?
3. What should never happen under any circumstances?
4. Are boundaries specific and actionable, not vague?
5. Do boundaries cover known risk areas?

**Boundary Validation:**

For each boundary, verify:
- [ ] Specific action (not vague principle)
- [ ] Actionable (can verify compliance)
- [ ] Justified (team understands why)

**Vague Language Scan:**

Search spec for these banned terms:
- "appropriate" → must specify exact criteria
- "best practices" → must name the practice
- "as needed" → must define trigger condition
- "properly" → must list specific validations
- "handle errors" → must specify: catch, log, return

## Pass 5: Strategic Review

**Focus:** Alignment and scope

**Self-Audit Questions:**

1. Are we solving the right problem?
2. Is the scope appropriate (not too narrow, not too broad)?
3. Does this align with project/team goals?
4. Are there simpler approaches we're missing?
5. What are the risks of this spec?
6. What would change this spec significantly?

**Strategic Signals:**

| Question | Answer |
|----------|--------|
| Right problem being solved? | [ ] Yes / [ ] Uncertain |
| Scope appropriate? | [ ] Yes / [ ] Too narrow / [ ] Too broad |
| Simpler alternative exists? | [ ] No / [ ] Maybe |
| Risks identified? | [ ] Yes / [ ] No |

## Convergence Declaration

After completing all passes, declare convergence with evidence:

```
SPEC CONVERGENCE DECLARATION

Passes completed: [1-5]

Pass findings:
- Pass 1 (Completeness): [findings or "No gaps"]
- Pass 2 (Clarity): [findings or "No ambiguity"]
- Pass 3 (Testability): [findings or "All criteria measurable"]
- Pass 4 (Boundaries): [findings or "All boundaries specific"]
- Pass 5 (Strategic): [findings or "Aligned with goals"]

Convergence status: [Converged / Needs more passes / Blocked]

If not converged, reason: [explanation]
```

## Quick Reference

| Pass | Focus | Key Question |
|------|-------|--------------|
| 1 | Completeness | All six core areas covered? |
| 2 | Clarity | Zero clarifying questions needed? |
| 3 | Testability | All criteria measurable? |
| 4 | Boundaries | Always/Ask/Never defined? No vague language? |
| 5 | Strategic | Right problem? Right scope? |

## Spec Quality Score

After all passes, rate the spec:

| Criterion | Score (0-2) |
|-----------|-------------|
| Six core areas complete | |
| Goal-oriented framing | |
| Real code examples | |
| Boundaries specific | |
| Success criteria measurable | |
| No vague language | |
| **Total** | **/12** |

**Interpretation:**
- 10-12: Ready for implementation
- 7-9: One more pass needed
- 4-6: Significant gaps
- 0-3: Restart with goal-oriented framing
