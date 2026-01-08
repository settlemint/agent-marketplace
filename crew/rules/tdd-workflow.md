---
description: Test-driven development workflow for code changes
globs: "**/*.ts,**/*.tsx"
alwaysApply: false
---

# Test-Driven Development

## The Rule

**WRITE TESTS FIRST. NO EXCEPTIONS.**

## RED-GREEN-REFACTOR Cycle

1. **RED** - Write failing test FIRST, run tests to confirm FAIL
2. **GREEN** - Write minimal code to pass, run tests to confirm PASS
3. **REFACTOR** - Clean up while tests stay green

## Why TDD

- Forces clear requirements before coding
- Catches regressions immediately
- Documents expected behavior
- Produces testable, modular code

## When to Apply

- New features
- Bug fixes (write test that reproduces bug first)
- Refactoring (ensure coverage first)

## Test Commands

Use root scripts only (never `cd` into packages):

```bash
bun run test           # Unit tests
bun run test:watch     # Watch mode
bun run test:coverage  # With coverage
```

## Example Workflow

```typescript
// 1. RED - Write failing test
it("should calculate total with tax", () => {
  const result = calculateTotal(100, 0.1);
  expect(result).toBe(110);
});
// Run: bun run test → FAIL (function doesn't exist)

// 2. GREEN - Minimal implementation
function calculateTotal(amount: number, taxRate: number): number {
  return amount * (1 + taxRate);
}
// Run: bun run test → PASS

// 3. REFACTOR - Clean up if needed
// Tests stay green throughout
```

## Quality Gate

**Work is NOT done until CI passes.** Always run:

```bash
bun run ci
```

Before marking any task complete.
