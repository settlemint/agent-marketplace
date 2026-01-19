# Spec Patterns Reference

Patterns for writing high-quality specifications that AI agents can implement correctly on the first attempt.

## Table of Contents

- [Six Core Areas Checklist](#six-core-areas-checklist)
  - [1. Commands](#1-commands)
  - [2. Testing](#2-testing)
  - [3. Project Structure](#3-project-structure)
  - [4. Code Style](#4-code-style)
  - [5. Git Workflow](#5-git-workflow)
  - [6. Boundaries](#6-boundaries)
- [Self-Audit Prompts](#self-audit-prompts)
- [Vague Language Detection](#vague-language-detection)
- [Post-Implementation Audit](#post-implementation-audit)
- [Spec Quality Score](#spec-quality-score)
- [Spec Template](#spec-template)
- [Anti-Patterns](#anti-patterns)

## Six Core Areas Checklist

Every specification must address these six areas:

### 1. Commands

Document all commands with flags, expected output, and when to run:

```markdown
| Command | Description | When to Run |
|---------|-------------|-------------|
| `bun run build` | Compile TypeScript to dist/ | Before deploy |
| `bun run test` | Run Vitest test suite | Before every commit |
| `bun run lint` | Run ESLint with auto-fix | Before commit |
| `bun run typecheck` | Run tsc --noEmit | Before commit |
```

### 2. Testing

Specify framework, location, coverage requirements, and strategy:

```markdown
- **Framework**: Vitest
- **Location**: `*.test.ts` adjacent to source
- **Coverage Requirements**:
  - Line: 80% minimum
  - Branch: 75% minimum
  - Function: 90% minimum
- **Strategy**:
  - Unit tests for pure logic
  - Integration tests for API endpoints
  - E2E tests for critical user flows
```

### 3. Project Structure

Document where code, tests, and docs live:

```markdown
src/
├── components/    # UI components
├── services/      # Business logic
├── utils/         # Pure utilities
└── types/         # TypeScript types
tests/
└── e2e/           # End-to-end tests
```

### 4. Code Style

Include real code examples showing preferred patterns:

```typescript
// Pure function (core) - no side effects
const validateEmail = (email: string): Result<string, ValidationError> => {
  const pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return pattern.test(email)
    ? { ok: true, value: email.toLowerCase() }
    : { ok: false, error: { code: 'INVALID_EMAIL' } };
};

// Side effects at edges (shell)
async function createUser(input: CreateUserInput): Promise<User> {
  const result = validateEmail(input.email);
  if (!result.ok) throw new ValidationError(result.error);
  return db.users.create({ email: result.value });
}
```

### 5. Git Workflow

Define branch naming, commit format, and PR requirements:

```markdown
- **Branch naming**: `<username>/<type>/<short-description>`
- **Commit format**: Conventional Commits
  - `feat(auth): add password reset flow`
  - `fix(api): handle null user gracefully`
- **PR requirements**:
  - [ ] All tests pass
  - [ ] Lint clean
  - [ ] At least 1 approval
```

### 6. Boundaries

Define the three-tier boundary system:

```markdown
### ✅ Always Do (without asking)
- Run tests before committing
- Follow naming conventions
- Add tests for new functionality

### ⚠️ Ask First (high-impact decisions)
- Adding new dependencies
- Modifying database schema
- Changing CI/CD configuration
- Architectural changes

### 🚫 Never Do (categorically off-limits)
- Commit secrets or credentials
- Push directly to main
- Remove failing tests without approval
- Disable TypeScript strict checks
```

## Self-Audit Prompts

Run these checks before finalizing any spec:

### Completeness Audit

1. "Can an AI agent implement this with zero clarifying questions?"
2. "Have I defined every technical term that might be ambiguous?"
3. "Are all external dependencies explicitly listed with versions?"
4. "Is every file path and directory mentioned actually correct?"

### Clarity Audit

1. "Would a new team member understand the context?"
2. "Have I shown examples instead of just describing?"
3. "Are success criteria measurable and verifiable?"
4. "Could this be misinterpreted? How?"

### Boundary Audit

1. "What should the agent always do without asking?"
2. "What decisions require my approval first?"
3. "What should the agent never do under any circumstances?"
4. "Are boundaries specific and actionable, not vague?"

### Testability Audit

1. "How will I verify each acceptance criterion?"
2. "What commands demonstrate success?"
3. "What output proves the implementation works?"
4. "Are there edge cases not covered by success criteria?"

## Vague Language Detection

Flag and replace these patterns:

| Vague Term | Problem | Specific Replacement |
|------------|---------|---------------------|
| "appropriate" | Undefined standard | "matching pattern X" or "following rule Y" |
| "best practices" | Which practices? | [cite specific practice or link to standard] |
| "as needed" | When is it needed? | "when condition X occurs, do Y" |
| "properly" | What's proper? | "with validations A, B, C" |
| "handle errors" | How exactly? | "catch X, log to Y, return Z" |
| "secure" | Means many things | "HTTPS, input validation, rate limiting" |
| "performant" | Not measurable | "<200ms p95 latency" |
| "scalable" | Vague goal | "handles 1000 concurrent users" |
| "user-friendly" | Subjective | "follows WCAG 2.1 AA, <3 clicks to goal" |
| "clean code" | Opinion-based | "follows patterns in Code Style section" |

## Post-Implementation Audit

Include this in specs to trigger self-verification:

```markdown
## Post-Implementation Audit

After completing implementation, answer:

1. Which spec requirements are fully implemented?
   - [ ] List each with evidence

2. Which spec requirements are partially implemented?
   - [ ] List with explanation of gaps

3. Which spec requirements are not implemented?
   - [ ] List with reason (blocked, out of scope, etc.)

4. Were any spec boundaries violated?
   - [ ] If yes, explain circumstances

5. What would you change about this spec for next time?
   - [ ] Suggestions for improvement
```

## Spec Quality Score

Rate your spec before finalizing:

| Criterion | Score (0-2) |
|-----------|-------------|
| Six Core Areas all covered | |
| Boundaries specific and actionable | |
| Code examples included | |
| Success criteria measurable | |
| No vague language | |
| Self-audit questions pass | |
| **Total** | **/12** |

**Interpretation:**
- 10-12: Ready for implementation
- 7-9: Needs one more pass
- 4-6: Significant gaps, iterate
- 0-3: Start over with framing

## Spec Template

```markdown
---
spec: <spec-name>
author: <author>
created: <ISO-timestamp>
status: draft|review|approved
---

# <Spec Title>

## Objective

<1-2 sentence description>

## Six Core Areas

### Commands
[table of commands]

### Testing
[framework, location, coverage, strategy]

### Project Structure
[directory tree]

### Code Style
[real code examples]

### Git Workflow
[branch naming, commits, PR requirements]

### Boundaries
[Always/Ask/Never tiers]

## Acceptance Criteria

- [ ] Given <context>, when <action>, then <expected outcome>

## Success Criteria

- [ ] <Measurable, verifiable criterion>

## Self-Verification Checklist

- [ ] All six core areas addressed
- [ ] No vague language used
- [ ] Boundaries are specific
- [ ] Criteria are measurable
```

## Anti-Patterns

### Spec by Exception

❌ "Follow standard practices except when..."

✅ State what to do, not what not to do

### Implicit Knowledge

❌ "Use the usual authentication approach"

✅ "Use JWT with RS256, 24h expiry, refresh tokens in httpOnly cookies"

### Future-Proofing

❌ "Design for extensibility in case we need X later"

✅ Spec current requirements; update spec when requirements change

### Over-Specification

❌ 50-page spec for a single feature

✅ Minimum viable spec that enables correct implementation
