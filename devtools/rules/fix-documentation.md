---
name: fix-documentation
description: Document bug fixes with explanatory comments for future maintainers
globs: "**/*.{ts,tsx,js,jsx,go,rs,py,sol}"
alwaysApply: false
---

# Fix Documentation Rule

Document bug fixes with explanatory comments that capture the "why" for future maintainers.

## Core Principle

Code shows what changed. Comments explain why.

## Required Comment Pattern

When fixing bugs, add a comment explaining:

```typescript
// Fixed: [summary of what changed]
// Why: [root cause explanation of the issue]
```

## Examples

### Good Fix Documentation

```typescript
// Fixed: Added null check before accessing user.profile
// Why: API returns null for deleted users, causing TypeError in dashboard
if (user?.profile) {
  displayProfile(user.profile);
}
```

```typescript
// Fixed: Changed from == to === for type-safe comparison
// Why: "0" == 0 was truthy, incorrectly validating empty string inputs
if (quantity === 0) {
  return "No items selected";
}
```

```typescript
// Fixed: Added timeout to prevent infinite loop on network failure
// Why: Retry logic had no backoff, causing CPU spike when API unreachable
const result = await fetchWithRetry(url, { maxAttempts: 3, timeout: 5000 });
```

### Bad Fix Documentation

```typescript
// WRONG: Just describes the code
// Fixed: Added if statement
if (user?.profile) { ... }

// WRONG: No explanation of root cause
// Fixed: Bug fix
if (quantity === 0) { ... }

// WRONG: Vague
// Fixed: Made it work properly
const result = await fetchWithRetry(url, { maxAttempts: 3 });
```

## When to Document

### Always Document

- Bug fixes that change behavior
- Fixes for edge cases that weren't obvious
- Fixes discovered through production issues
- Fixes that prevent data corruption or security issues

### Skip Documentation For

- Typo fixes
- Formatting changes
- Obvious corrections (wrong variable name)
- Changes covered by failing tests that explain intent

## Comment Placement

Place the comment:
- **Before** the fixed code block
- **Inline** only for single-line fixes
- **In the function docstring** if the fix affects overall behavior

## Linking to Issues

When a fix relates to a tracked issue:

```typescript
// Fixed: Rate limit API calls to 100/minute
// Why: Exceeded third-party API limits causing 429 errors
// See: #1234
const rateLimiter = new RateLimiter({ limit: 100, window: 60000 });
```

## Commit Message Integration

Fix documentation in code complements commit messages:

- **Commit message**: High-level description of fix
- **Code comment**: Specific technical context at the fix location

Both should exist. They serve different audiences (git history vs. code readers).

## Self-Check

Before committing a bug fix:

1. [ ] Did I add a comment explaining what was fixed?
2. [ ] Did I explain the root cause (why)?
3. [ ] Will a future developer understand why this code exists?
4. [ ] Is the comment specific, not generic?
