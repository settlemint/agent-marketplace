# Spec Quality Patterns Reference

Shared patterns for writing high-quality specifications. Based on GitHub's analysis of 2,500+ agent configuration files and Addy Osmani's spec-writing research.

## Goal-Oriented Framing Prompts

Before writing spec details, complete this framing:

```
WHO is the user?
→ [specific persona or role]

WHAT do they need?
→ [concrete requirement, not abstract]

WHY does this matter?
→ [business value or user benefit]

WHAT does success look like?
→ [measurable outcome, not subjective]
```

**Example - Good framing:**

```
WHO: Developers using Claude Code for planning
WHAT: Guidance for writing specs that AI agents can implement correctly
WHY: Vague specs waste time with clarification loops and produce poor code
SUCCESS: Specs consistently produce working implementations on first attempt
```

**Example - Bad framing:**

```
WHO: Users
WHAT: Better specs
WHY: To improve things
SUCCESS: Things work better
```

## Self-Audit Prompts

Run these checks before finalizing a spec:

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

## Hierarchical Summarization

For specs exceeding 2000 words, create a condensed index:

### Extended TOC Format

```markdown
## Extended TOC

| Section | Key Points | Reference |
|---------|------------|-----------|
| Auth | JWT tokens, 24h expiry, refresh flow | §3.1 |
| Security | HTTPS required, rate limiting at 100/min | §3.2 |
| Database | PostgreSQL 16, Drizzle ORM, pooling | §4.1 |
| API | REST, OpenAPI 3.0, versioned at /v1/ | §5.1 |
```

### Section Condensation

Each section summary should:
- Fit in 15 words or fewer
- Capture the most decision-relevant points
- Include reference tag for full details

**Example condensation:**

Full section (200 words):
```
## Authentication

The system uses JSON Web Tokens (JWT) for authentication. Tokens are
issued upon successful login and have a 24-hour expiry. Refresh tokens
are provided with a 7-day expiry for seamless re-authentication...
[continues for 200 words]
```

Condensed:
```
| Auth | JWT tokens, 24h access/7d refresh, stored in httpOnly cookies | §3.1 |
```

## Context Management Strategies

### When context is large (>5000 tokens)

1. **Split into modular specs**
   - `SPEC_overview.md` - Vision, success criteria
   - `SPEC_backend.md` - API, database, services
   - `SPEC_frontend.md` - UI, state, components

2. **Use hierarchical summarization**
   - Extended TOC always in prompt
   - Full sections fetched on demand

3. **Task-specific context**
   - "For this task, focus on §4.1 Database Schema"
   - Only relevant spec section in working context

### When implementing from spec

1. **Quote spec requirements in task prompt**
   ```
   Implementing per SPEC §4.1:
   - Database: PostgreSQL 16
   - ORM: Drizzle
   - Tables: users, sessions, audit_log
   ```

2. **Reference boundaries explicitly**
   ```
   Remember from SPEC boundaries:
   - ⚠️ Ask before: schema changes
   - 🚫 Never: commit without tests
   ```

## Vague Language Detection

Flag and replace these patterns:

| Vague | Specific Replacement |
|-------|---------------------|
| "appropriate" | "matching pattern X" or "following rule Y" |
| "best practices" | [cite specific practice or link to standard] |
| "as needed" | "when condition X occurs, do Y" |
| "properly" | "with validations A, B, C" |
| "handle errors" | "catch X, log to Y, return Z" |
| "secure" | "HTTPS, input validation, rate limiting" |
| "performant" | "<200ms p95 latency" |
| "scalable" | "handles 1000 concurrent users" |
| "user-friendly" | "follows WCAG 2.1 AA, <3 clicks to goal" |

## Conformance Testing Patterns

Include testable assertions in specs:

### Command-Based Verification

```markdown
## Verification Commands

| Criterion | Command | Expected |
|-----------|---------|----------|
| Tests pass | `bun run test` | Exit 0, "All tests pass" |
| Coverage met | `bun run test:coverage` | ≥80% lines |
| Types valid | `bun run typecheck` | Exit 0, no errors |
| Lint clean | `bun run lint` | Exit 0, no warnings |
```

### Observable Verification

```markdown
## Observable Criteria

| Criterion | How to Verify |
|-----------|---------------|
| Login works | Navigate to /login, enter valid creds, redirected to /dashboard |
| Error shown | Submit invalid form, see red error message below field |
| Data persists | Create item, refresh page, item still visible |
```

## Post-Implementation Audit Prompt

Include this in spec to trigger self-verification:

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

## Convergence Signals for Specs

### Stop iterating when:

- All six core areas have specific, actionable content
- Goal-oriented framing is complete and measurable
- An agent could implement without clarifying questions
- Boundaries cover known risks and decisions
- Success criteria are all testable

### Continue iterating when:

- Any core area is vague or missing
- Success criteria contain subjective language
- Boundaries don't cover obvious risk areas
- Examples are missing where description is complex
- You find yourself saying "they'll figure it out"

## Anti-Patterns

### Spec by Exception

❌ "Follow standard practices except when..."

✅ State what to do, not what not to do (except in Never boundaries)

### Implicit Knowledge

❌ "Use the usual authentication approach"

✅ "Use JWT with RS256, 24h expiry, refresh tokens in httpOnly cookies"

### Future-Proofing

❌ "Design for extensibility in case we need X later"

✅ Spec current requirements; update spec when requirements change

### Over-Specification

❌ 50-page spec for a single feature

✅ Minimum viable spec that enables correct implementation

## Spec Quality Score

Rate your spec:

| Criterion | Score (0-2) |
|-----------|-------------|
| Goal-oriented framing complete | |
| All six core areas covered | |
| Boundaries specific and actionable | |
| Code examples included | |
| Success criteria measurable | |
| No vague language | |
| **Total** | **/12** |

**Interpretation:**
- 10-12: Ready for implementation
- 7-9: Needs one more pass
- 4-6: Significant gaps, iterate
- 0-3: Start over with framing
