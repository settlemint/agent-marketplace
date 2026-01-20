---
name: reviewing-code
description: This skill should be used when the user asks to "review code", "check best practices", "audit implementation", "review my changes", or when looking for review guidance by technology (React, TypeScript, Vite, Playwright, Drizzle, etc.). Provides 353 curated code review patterns from top open-source projects.
version: 1.0.0
---

## Overview

This skill provides access to 353 code review patterns curated from top open-source repositories including React, Vue, Bun, Node.js, Vite, Playwright, and more. Each pattern includes a description, problem example, and solution example.

**Source:** [awesome-reviewers](https://github.com/baz-scm/awesome-reviewers) catalog

## Pattern Coverage by Technology

| Technology | Count | Focus Areas |
|------------|-------|-------------|
| GraphQL | 40 | API design, response transformation, polling |
| TanStack Router | 38 | File routing, loaders, compatibility |
| Bun | 37 | Async/await, error handling, memory |
| Node.js | 32 | Streams, event loop, buffers |
| Playwright | 31 | Test organization, security, flaky tests |
| Tailwind/Vite | 30 | Build config, hot reload, CSS |
| Prettier | 28 | Formatting, parser consistency |
| React | 24 | Component APIs, hooks, testing |
| TypeScript | 20 | Type safety, inference, config |
| Better Auth | 15 | Sessions, API consistency, config |
| Vitest | 13 | Test patterns, mocking, coverage |
| Drizzle | 8 | Schema design, migrations, types |

## Usage

### Finding Relevant Patterns

1. **Browse the index** to find patterns by technology:
   ```
   Read references/reviewers-index.md
   ```

2. **Load specific pattern** when reviewing related code:
   ```
   Read references/reviewers/cache-expensive-calculations.md
   ```

3. **Search by keyword** for specific concerns:
   ```bash
   grep -l "async" references/reviewers/*.md
   grep -l "test" references/reviewers/*.md
   grep -l "error" references/reviewers/*.md
   ```

### Common Review Scenarios

| Reviewing | Load These Patterns |
|-----------|---------------------|
| React components | `complete-hook-dependencies.md`, `react-hooks-best-practices.md`, `defensive-handling-of-nullable-react-components.md` |
| Async code | `always-await-promises.md`, `cancel-aborted-async-operations.md`, `await-all-promises.md` |
| Tests | `test-behavior-not-calls.md`, `avoid-timing-dependent-tests.md`, `test-edge-cases.md` |
| API design | `api-backward-compatibility.md`, `api-consistency-patterns.md`, `api-naming-consistency.md` |
| Error handling | `clean-all-error-paths.md`, `propagate-errors-with-context.md`, `never-swallow-errors.md` |
| Caching | `cache-expensive-calculations.md`, `cache-invalidation-strategy.md`, `cache-key-serialization.md` |
| Naming | `descriptive-identifier-names.md`, `consistent-naming-patterns.md`, `choose-semantic-descriptive-names.md` |
| Database | `database-migration-best-practices.md`, `database-type-consistency.md`, `optimize-database-queries.md` |

## Pattern Format

Each pattern file follows this structure:

```markdown
# Pattern Name

> **Repository:** source/repo
> **Dependencies:** related-technology

[Description of the pattern and why it matters]

Example of the problem:
[Code showing the anti-pattern]

Example of the solution:
[Code showing the correct approach]

[Additional context and edge cases]
```

## Integration with Code Review Agent

The `code-reviewer` agent automatically has access to these patterns. When performing code reviews:

1. Agent identifies domains touched by changes
2. Agent consults relevant patterns from this skill
3. Agent applies patterns to specific code issues found

For manual pattern lookup during review, use the index to find technology-specific guidance.

## Key Pattern Categories

### Code Quality
- `avoid-code-duplication.md` - Create reusable components
- `break-down-complex-functions.md` - Decompose for readability
- `extract-complex-logical-expressions.md` - Named variables for clarity

### Performance
- `cache-expensive-calculations.md` - Avoid redundant computation
- `batch-operations-efficiently.md` - Group similar operations
- `optimize-algorithmic-performance.md` - Algorithmic efficiency

### Testing
- `test-behavior-not-implementation.md` - Focus on behavior
- `comprehensive-test-coverage.md` - Cover new functionality
- `mock-external-dependencies-only.md` - Mock at boundaries

### Documentation
- `document-non-intuitive-code.md` - Explain complex logic
- `clear-accurate-documentation.md` - Accuracy and context
- `code-example-consistency.md` - Syntactically correct examples

### Security
- `test-security-boundaries.md` - Test success and failure
- `derive-from-session-context.md` - Never trust client data
- `validate-network-inputs.md` - Input validation

## Additional Resources

### Reference Files

- **`references/reviewers-index.md`** - Full index of 353 patterns by technology
- **`references/reviewers/*.md`** - Individual pattern files
- **`references/smart-contract-checklist.md`** - Blockchain-specific patterns
