---
name: reviewing-code
description: This skill should be used when the user asks to "review code", "check best practices", "audit implementation", or when looking for review guidance by technology. 353 patterns from React, Vue, Bun, Node.js, Vite, Playwright.
version: 1.0.0
---

# Code Review Patterns

353 patterns from top open-source repos. Source: [awesome-reviewers](https://github.com/baz-scm/awesome-reviewers)

## Coverage

| Technology | Count | Technology | Count |
|------------|-------|------------|-------|
| GraphQL | 40 | Prettier | 28 |
| TanStack Router | 38 | React | 24 |
| Bun | 37 | TypeScript | 20 |
| Node.js | 32 | Better Auth | 15 |
| Playwright | 31 | Vitest | 13 |
| Tailwind/Vite | 30 | Drizzle | 8 |

## Usage

```bash
# Browse index
Read references/reviewers-index.md

# Load pattern
Read references/reviewers/[pattern-name].md

# Search
grep -l "async" references/reviewers/*.md
```

## Common Scenarios

| Reviewing | Key Patterns |
|-----------|--------------|
| React | `complete-hook-dependencies`, `react-hooks-best-practices` |
| Async | `always-await-promises`, `cancel-aborted-async-operations` |
| Tests | `test-behavior-not-calls`, `avoid-timing-dependent-tests` |
| Errors | `clean-all-error-paths`, `propagate-errors-with-context` |
| API | `api-backward-compatibility`, `api-consistency-patterns` |

## References

- `references/reviewers-index.md` - Full pattern index
- `references/reviewers/*.md` - Individual patterns
- `references/smart-contract-checklist.md` - Blockchain patterns
