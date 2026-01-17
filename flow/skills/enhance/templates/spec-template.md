# Spec Template

Use this template for all project and feature specifications. Implements the Six Core Areas framework from GitHub's analysis of 2,500+ agent files.

## Template

```markdown
---
spec: <spec-name>
author: <branch-author>
created: <ISO-timestamp>
status: draft|review|approved
estimated_complexity: low|medium|high
---

# <Spec Title>

## Objective

<1-2 sentence description of what this spec defines>

### Goal-Oriented Framing

| Question | Answer |
|----------|--------|
| **Who is the user?** | <target user or persona> |
| **What do they need?** | <core requirement> |
| **Why does this matter?** | <value proposition> |
| **What does success look like?** | <measurable outcome> |

## Tech Stack

- **Runtime**: <e.g., Node.js 20+, Bun 1.1+>
- **Language**: <e.g., TypeScript 5.4+>
- **Framework**: <e.g., React 19, TanStack Start>
- **Database**: <e.g., PostgreSQL 16, Drizzle ORM>
- **Testing**: <e.g., Vitest, Playwright>
- **Key Dependencies**:
  - <dependency@version> - <purpose>
  - <dependency@version> - <purpose>

## Commands

| Command | Description | When to Run |
|---------|-------------|-------------|
| `bun run build` | Compile TypeScript, output to dist/ | Before deploy |
| `bun run test` | Run Vitest test suite | Before every commit |
| `bun run test:e2e` | Run Playwright E2E tests | Before PR merge |
| `bun run lint` | Run ESLint with auto-fix | Before commit |
| `bun run typecheck` | Run tsc --noEmit | Before commit |

## Testing

- **Framework**: <Vitest/Jest/Playwright>
- **Location**: `<path pattern, e.g., __tests__/ or *.test.ts>`
- **Coverage Requirements**:
  - Line: 80% minimum
  - Branch: 75% minimum
  - Function: 90% minimum
- **Strategy**:
  - Unit tests for pure logic
  - Integration tests for API endpoints
  - E2E tests for critical user flows

## Project Structure

```
<project-root>/
├── src/
│   ├── components/    # UI components
│   ├── services/      # Business logic
│   ├── utils/         # Pure utilities
│   └── __tests__/     # Unit tests
├── tests/
│   └── e2e/           # End-to-end tests
├── docs/              # Documentation
└── scripts/           # Build/deploy scripts
```

## Code Style

<Real code example showing preferred patterns>

```typescript
// Example: Functional Core, Imperative Shell

// Pure function (core) - no side effects
const validateEmail = (email: string): Result<string, ValidationError> => {
  const pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return pattern.test(email)
    ? { ok: true, value: email.toLowerCase() }
    : { ok: false, error: { code: 'INVALID_EMAIL', message: 'Invalid email format' } };
};

// Side effects at edges (shell)
async function createUser(input: CreateUserInput): Promise<User> {
  const emailResult = validateEmail(input.email);
  if (!emailResult.ok) throw new ValidationError(emailResult.error);

  return db.users.create({ email: emailResult.value, name: input.name });
}
```

**Prefer:**
- `const` over `let`
- Arrow functions with explicit return types
- Result types over thrown errors for expected failures
- Composition over inheritance

**Avoid:**
- `any` type (use `unknown` + type guards)
- Mutation of function arguments
- Classes for data containers

## Git Workflow

- **Branch naming**: `<username>/<type>/<short-description>`
  - `roderik/feat/user-authentication`
  - `alice/fix/login-validation`
- **Commit format**: Conventional Commits
  - `feat(auth): add password reset flow`
  - `fix(api): handle null user gracefully`
  - `docs(readme): update installation steps`
- **PR requirements**:
  - [ ] All tests pass
  - [ ] Lint clean (no warnings)
  - [ ] At least 1 approval
  - [ ] Branch up to date with main

## Boundaries

### Always Do (without asking)

- Run `bun run test` before committing
- Follow naming conventions defined in Code Style
- Use TypeScript strict mode
- Add tests for new functionality
- Document public APIs

### Ask First (high-impact decisions)

- Adding new dependencies to package.json
- Modifying database schema
- Changing CI/CD configuration
- Creating new API endpoints
- Modifying authentication logic
- Architectural changes (new patterns, major refactors)

### Never Do (categorically off-limits)

- Commit secrets, API keys, or credentials
- Edit node_modules/, vendor/, or generated files
- Remove or skip failing tests without explicit approval
- Push directly to main branch
- Disable TypeScript strict checks
- Add `// @ts-ignore` without justification comment

## User Stories

- As a <user type>, I want <goal>, so that <benefit>
- As a <user type>, I want <goal>, so that <benefit>

## Acceptance Criteria

- [ ] Given <context>, when <action>, then <expected outcome>
- [ ] Given <context>, when <action>, then <expected outcome>
- [ ] Given <context>, when <action>, then <expected outcome>

## Success Criteria

- [ ] <Measurable, verifiable criterion>
- [ ] <Measurable, verifiable criterion>
- [ ] <Measurable, verifiable criterion>

## Self-Verification Checklist

After implementation, verify:

- [ ] All six core areas addressed in implementation
- [ ] Commands work as documented
- [ ] Tests pass with required coverage
- [ ] Code follows documented style
- [ ] Git workflow followed (commits, PR)
- [ ] No boundary violations occurred

## Open Questions

- [ ] <Any unresolved questions>
```

## Quick Reference

### Six Core Areas Checklist

Before approving spec, verify:

| Area | Covered? | Notes |
|------|----------|-------|
| Commands | [ ] | Executable with flags |
| Testing | [ ] | Framework, location, coverage |
| Project Structure | [ ] | Where code/tests/docs live |
| Code Style | [ ] | Real code example included |
| Git Workflow | [ ] | Branch naming, commit format |
| Boundaries | [ ] | Always/Ask/Never defined |

### Goal-Oriented Framing

| Question | Purpose |
|----------|---------|
| Who is the user? | Target audience |
| What do they need? | Core requirement |
| Why does this matter? | Value proposition |
| What does success look like? | Measurable criteria |

### Three-Tier Boundary System

| Tier | Symbol | Examples |
|------|--------|----------|
| Always | ✅ | Run tests, follow style guide |
| Ask First | ⚠️ | New deps, schema changes |
| Never | 🚫 | Commit secrets, edit vendor |

### Complexity Levels

| Level | Criteria | Review Depth |
|-------|----------|--------------|
| low | 1-3 files, single concern | 2-3 passes |
| medium | 4-10 files, cross-cutting | 3-4 passes |
| high | >10 files, architectural | 5+ passes, Codex review |
