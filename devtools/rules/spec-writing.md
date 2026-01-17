---
name: spec-writing
description: Rules for writing effective specifications that AI agents can implement correctly
globs: "**/*.md"
alwaysApply: false
---

# Spec Writing Rules

Apply these rules when writing specifications, requirements, or project briefs.

## The Six Core Areas

Every spec MUST include these sections:

| Area | Required Content |
|------|------------------|
| Commands | Executable commands with flags and expected output |
| Testing | Framework, location, coverage requirements |
| Project Structure | Where code, tests, and docs live |
| Code Style | Real code example (not just description) |
| Git Workflow | Branch naming, commit format, PR requirements |
| Boundaries | Always/Ask First/Never three-tier system |

## Goal-Oriented Framing

Before details, answer:

```
Who is the user? → [specific persona]
What do they need? → [concrete requirement]
Why does this matter? → [measurable value]
What does success look like? → [verifiable outcome]
```

## Banned Language

Never use vague terms without definition:

| Banned | Replace With |
|--------|--------------|
| "appropriate" | Specific criteria |
| "best practices" | Named practice or linked standard |
| "as needed" | Explicit trigger condition |
| "properly" | Specific validations |
| "handle errors" | Catch X, log Y, return Z |
| "secure" | Specific security measures |
| "performant" | Numeric target (e.g., <200ms p95) |
| "scalable" | Capacity target (e.g., 1000 concurrent) |

## Boundary System Required

Every spec must define three tiers:

```markdown
## Boundaries

### Always Do
- [specific actions without asking]

### Ask First
- [high-impact decisions needing approval]

### Never Do
- [categorically off-limits actions]
```

**Key finding:** "Never commit secrets" was most helpful constraint in GitHub's 2,500+ agent file study.

## Code Examples Required

Style sections must include real code:

```typescript
// Good: Shows actual pattern
const validate = (input: string): Result<string, Error> => {
  if (!input.trim()) return err('Empty input');
  return ok(input.toLowerCase());
};

// Bad: Just describes pattern
// "Use Result types for validation"
```

## Measurable Success Criteria

Every success criterion must be verifiable:

| Bad | Good |
|-----|------|
| "Works correctly" | "`bun run test` exits with code 0" |
| "Performs well" | "API responds in <200ms p95" |
| "Is secure" | "Passes OWASP ZAP scan with no high findings" |
| "Looks good" | "Matches Figma design within 2px tolerance" |

## Self-Verification Prompt

Include in every spec:

```markdown
## Post-Implementation Audit

After implementing, compare result with this spec:
- [ ] All requirements addressed
- [ ] All boundaries respected
- [ ] Success criteria verified
```

## Spec Size Guidelines

| Complexity | Max Words | Core Areas |
|------------|-----------|------------|
| Simple (1-3 files) | 500 | Abbreviated |
| Medium (4-10 files) | 1500 | Full |
| Complex (>10 files) | 3000 + TOC | Full + Extended TOC |

For specs >2000 words, include hierarchical summarization (Extended TOC).

## Pre-Submission Checklist

Before finalizing spec:

- [ ] Goal-oriented framing complete
- [ ] All six core areas covered
- [ ] No banned vague language
- [ ] Boundaries defined (Always/Ask/Never)
- [ ] Real code examples included
- [ ] Success criteria measurable
- [ ] Self-verification prompt included
