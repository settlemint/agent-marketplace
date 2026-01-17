---
name: spec-writing
description: Write effective specs for AI agents using the Six Core Areas framework, three-tier boundary system, and goal-oriented framing. Based on GitHub's analysis of 2,500+ agent files.
license: MIT
triggers:
  # Intent triggers
  - "write spec"
  - "create spec"
  - "specification"
  - "requirements"
  - "product brief"
  - "PRD"
  - "project spec"
  - "feature spec"
  - "define requirements"

  # Context triggers
  - "what should I build"
  - "scope the work"
  - "plan the feature"
  - "before we start"
---

<objective>

Write effective specifications for AI agents that guide without overwhelming. Specs should cover just enough nuance to direct the AI while staying within practical context limits. Based on Addy Osmani's research and GitHub's analysis of 2,500+ agent configuration files.

Key principle: "Vague specs produce vague code." Be specific.

</objective>

<quick_start>

1. **Start with goal-oriented framing** - Who, What, Why, Success
2. **Cover the Six Core Areas** - Commands, Testing, Structure, Style, Git, Boundaries
3. **Define three-tier boundaries** - Always/Ask First/Never
4. **Include real code examples** - One snippet beats paragraphs of description
5. **Apply Rule of Five** - 5 passes for spec quality convergence

</quick_start>

<goal_oriented_framing>

Before writing details, answer these questions:

| Question | Purpose |
|----------|---------|
| **Who is the user?** | Identifies the target audience |
| **What do they need?** | Defines the core requirement |
| **Why does this matter?** | Establishes the value proposition |
| **What does success look like?** | Creates measurable criteria |

**Example:**

```
Who: Developers using Claude Code
What: A skill that guides spec writing
Why: Vague specs waste time and produce poor code
Success: Specs consistently produce working implementations on first try
```

</goal_oriented_framing>

<six_core_areas>

Every spec MUST cover these six areas (from GitHub's 2,500+ agent file analysis):

## 1. Commands

Executable commands with flags and expected behavior.

```markdown
## Commands

- Build: `bun run build` (compiles TypeScript, outputs to dist/)
- Test: `bun run test` (runs Vitest, must pass before commits)
- Lint: `bun run lint --fix` (auto-fixes ESLint errors)
- Typecheck: `bun run typecheck` (runs tsc --noEmit)
```

**Be specific:** Include flags, expected output, and when to run.

## 2. Testing

Framework, location, coverage requirements, and strategy.

```markdown
## Testing

- Framework: Vitest
- Location: `__tests__/` directories adjacent to source
- Coverage: 80% line, 75% branch minimum
- Strategy: Unit tests for logic, integration tests for API endpoints
- Run: `bun run test` before every commit
```

## 3. Project Structure

Where code, tests, and docs live.

```markdown
## Project Structure

- `src/` - Application source code
- `src/components/` - React components
- `src/services/` - Business logic
- `src/__tests__/` - Unit tests (colocated)
- `docs/` - Documentation
- `scripts/` - Build and deployment scripts
```

## 4. Code Style

Real code examples showing your style preferences. One example beats paragraphs.

```markdown
## Code Style

Functional Core, Imperative Shell pattern:

```typescript
// Pure function (core)
const calculateTotal = (items: Item[]): number =>
  items.reduce((sum, item) => sum + item.price * item.quantity, 0);

// Side effects at edges (shell)
async function processOrder(orderId: string): Promise<void> {
  const order = await db.orders.find(orderId);
  const total = calculateTotal(order.items);
  await db.orders.update(orderId, { total });
}
```

Prefer: `const`, arrow functions, explicit return types.
Avoid: `class`, mutation, `any` type.
```

## 5. Git Workflow

Branch naming, commit format, PR requirements.

```markdown
## Git Workflow

- Branch naming: `<username>/<type>/<short-description>`
  - Example: `alice/feat/user-auth`
- Commit format: Conventional Commits
  - `feat(scope): description`
  - `fix(scope): description`
- PR requirements: Tests pass, lint clean, 1 approval
- Protected branches: `main` requires PR
```

## 6. Boundaries

Three-tier system defining what the agent should always do, ask about, and never do.

```markdown
## Boundaries

### Always Do (without asking)
- Run tests before commits
- Follow naming conventions in style guide
- Log errors to monitoring service
- Use TypeScript strict mode

### Ask First (high-impact decisions)
- Adding new dependencies
- Modifying database schemas
- Changing CI/CD configuration
- Architectural changes

### Never Do (categorically off-limits)
- Commit secrets or API keys
- Edit node_modules/ or vendor/
- Remove failing tests without approval
- Push directly to main
- Disable TypeScript strict checks
```

**Key finding:** "Never commit secrets" was the single most helpful constraint in GitHub's study.

</six_core_areas>

<boundary_system>

The three-tier boundary system provides nuanced guidance:

| Tier | Symbol | Meaning | Examples |
|------|--------|---------|----------|
| Always | ✅ | Do without asking | Run tests, follow style guide |
| Ask First | ⚠️ | High-impact, needs approval | New deps, schema changes |
| Never | 🚫 | Categorically off-limits | Commit secrets, edit vendor |

**Effective boundaries are:**

- **Specific** - "Never commit .env files" not "Be careful with secrets"
- **Actionable** - Clear what to do or avoid
- **Justified** - Team understands why the boundary exists
- **Testable** - Can verify compliance

**Anti-patterns:**

- ❌ "Be careful" (too vague)
- ❌ "Use best practices" (undefined)
- ❌ "Don't break things" (not actionable)

</boundary_system>

<spec_template>

Use this template for new specs:

```markdown
# Project Spec: [Name]

## Objective

[1-2 sentence goal statement]

**Goal-Oriented Framing:**
- Who: [target user]
- What: [core requirement]
- Why: [value proposition]
- Success: [measurable criteria]

## Tech Stack

- [Framework] [version]
- [Language] [version]
- [Database] [type]
- [Key dependencies with versions]

## Commands

- Build: `[command]` ([description])
- Test: `[command]` ([description])
- Lint: `[command]` ([description])

## Testing

- Framework: [name]
- Location: [path pattern]
- Coverage: [requirements]
- Strategy: [approach]

## Project Structure

- `[path]/` - [purpose]
- `[path]/` - [purpose]

## Code Style

[Real code example demonstrating preferred style]

## Git Workflow

- Branch naming: [convention]
- Commit format: [convention]
- PR requirements: [list]

## Boundaries

### Always Do
- [action]

### Ask First
- [action]

### Never Do
- [action]

## Success Criteria

- [ ] [measurable criterion]
- [ ] [measurable criterion]
```

</spec_template>

<self_verification>

After writing a spec, verify with these checks:

## Self-Audit Prompts

Ask yourself:

1. "Can an AI agent implement this with no clarifying questions?"
2. "Are all ambiguous terms defined?"
3. "Is every boundary specific and actionable?"
4. "Do code examples show exactly what I want?"
5. "Would a new team member understand the context?"

## Spec Completeness Checklist

- [ ] All six core areas covered
- [ ] Goal-oriented framing complete
- [ ] Tech stack specific (with versions)
- [ ] Real code examples included
- [ ] Boundaries defined (Always/Ask/Never)
- [ ] Success criteria measurable
- [ ] No vague language ("appropriate", "best practices", "as needed")

## Post-Implementation Audit

Include this instruction in the spec:

```
After implementing, compare result with this spec and confirm all
requirements met. List any spec items not addressed.
```

This pushes the AI to reflect on output relative to spec, catching omissions.

</self_verification>

<hierarchical_summarization>

For large specs (>2000 words), create an Extended Table of Contents:

```markdown
## Extended TOC

| Section | Summary | Reference |
|---------|---------|-----------|
| Auth | JWT tokens, 24h expiry, refresh flow | See §4.1 |
| Security | HTTPS only, rate limiting, input validation | See §4.2 |
| Database | PostgreSQL, Drizzle ORM, connection pooling | See §5.1 |
| API | REST endpoints, OpenAPI spec, versioned | See §6.1 |
```

**Benefits:**
- Hierarchical summary stays in prompt
- Details offloaded unless needed
- Agent consults like an index
- Reduces token waste

</hierarchical_summarization>

<common_pitfalls>

Avoid these spec-writing mistakes:

## Vague Prompts

| Bad | Good |
|-----|------|
| "Build me something cool" | "Build a task management app where users can add, edit, complete, and delete tasks" |
| "Make it work better" | "Reduce API response time to <200ms for list endpoints" |
| "Use best practices" | "Follow Functional Core, Imperative Shell pattern (see Code Style)" |

## Overlong Contexts

❌ Dump 50 pages hoping model figures it out
✅ Use hierarchical summaries or RAG

"Context length is not substitute for context quality"

## The Lethal Trifecta

Three properties making AI agents risky:

1. **Speed** - Work faster than you can review
2. **Non-Determinism** - Same input, different outputs
3. **Cost** - Encourages corner-cutting on verification

Your spec must account for all three with:
- Clear boundaries (speed check)
- Deterministic success criteria (non-determinism check)
- Mandatory verification steps (cost check)

## Missing Core Areas

Before handing spec to agent, checklist:

- [ ] Commands defined
- [ ] Testing specified
- [ ] Project structure documented
- [ ] Code style shown (with example)
- [ ] Git workflow defined
- [ ] Boundaries in place (Always/Ask/Never)

</common_pitfalls>

<spec_driven_development>

Follow the four-phase gated workflow:

| Phase | Focus | Agent Role |
|-------|-------|------------|
| **1. Specify** | What + Why | Generates detailed spec from brief |
| **2. Plan** | How | Generates technical plan with options |
| **3. Tasks** | Breakdown | Chunks spec into reviewable pieces |
| **4. Implement** | Build | Tackles tasks one-by-one |

**Key insight:** "House of cards code" - fragile AI outputs collapse under scrutiny without proper gating.

**Phase transitions require human approval.** Each gate prevents compounding errors.

</spec_driven_development>

<modularity>

Break large specs into modular documents:

```
SPEC_overview.md     # High-level vision, success criteria
SPEC_backend.md      # API, database, services
SPEC_frontend.md     # UI, components, state
SPEC_security.md     # Auth, permissions, audit
```

**Benefits:**
- Each sub-agent gets relevant context only
- Reduced token usage per task
- Parallel work on independent modules
- Clear ownership of spec sections

**Reference pattern:**

"For backend tasks, refer to SPEC_backend.md. For frontend tasks, refer to SPEC_frontend.md."

</modularity>

<success_criteria>

- [ ] Spec covers all six core areas
- [ ] Goal-oriented framing complete (Who/What/Why/Success)
- [ ] Three-tier boundaries defined (Always/Ask/Never)
- [ ] Real code examples included (not just descriptions)
- [ ] Tech stack specific with versions
- [ ] Success criteria measurable and verifiable
- [ ] No vague language used
- [ ] Self-verification checklist included

</success_criteria>

<constraints>

**Banned:**

- Vague language: "appropriate", "best practices", "as needed", "etc."
- Missing boundaries: Specs without Always/Ask/Never section
- No code examples: Style sections without real code
- Unversioned tech: "React" without version

**Required:**

- Six core areas coverage
- Goal-oriented framing
- Real code examples
- Specific boundaries
- Measurable success criteria

</constraints>

<integration>

**Load with enhance skill:**

```javascript
Skill({ skill: "flow:enhance" })
Skill({ skill: "devtools:spec-writing" })
```

**Use with planning:**

Load before entering plan mode to ensure specs follow the six core areas framework.

**Apply Rule of Five:**

Run 5 passes on specs before finalizing:
1. Completeness - All six areas covered?
2. Clarity - Can agent implement without questions?
3. Testability - Success criteria measurable?
4. Boundaries - Always/Ask/Never defined?
5. Strategic - Right problem being solved?

</integration>

<references>

- Addy Osmani: "How to Write a Good Spec for AI Agents" (2026)
- GitHub: Analysis of 2,500+ agent configuration files
- Claude Code: Plan Mode best practices
- Spec-Driven Development: Four-phase gated workflow

</references>
