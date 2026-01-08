---
description: CRITICAL TDD rules - tests required for ALL code changes
globs: "**/*.ts,**/*.tsx,**/*.js,**/*.jsx,**/*.py,**/*.go,**/*.rs,**/*.sol"
alwaysApply: true
---

# Test-Driven Development

## ⛔ ABSOLUTE RULE - NO EXCEPTIONS ⛔

# EVERY CODE CHANGE REQUIRES TESTS

**New code, existing code, bug fixes, refactoring - ALL require tests.**

## THE RULE

| Change Type          | Test Requirement                               |
| -------------------- | ---------------------------------------------- |
| New feature          | Write failing test FIRST, then implement       |
| Bug fix              | Write test that reproduces bug FIRST, then fix |
| Refactoring          | Ensure test coverage EXISTS before refactoring |
| Existing code change | Add tests if missing, then modify              |

## RED-GREEN-REFACTOR CYCLE

1. **RED** - Write failing test FIRST
2. **GREEN** - Write minimal code to pass
3. **REFACTOR** - Clean up while tests stay green

```bash
# 1. Write test, run to confirm FAIL
bun run test

# 2. Implement, run to confirm PASS
bun run test

# 3. Refactor, ensure still PASS
bun run test
```

## CHANGING EXISTING CODE

**Before modifying ANY existing code:**

1. Check if tests exist for that code
2. If NO tests exist → write tests FIRST
3. If tests exist → ensure they pass
4. Make your changes
5. Verify tests still pass (or update if behavior intentionally changed)

```typescript
// WRONG - Changing code without tests
function existingFunction() {
  // Just modify it and hope for the best ❌
}

// CORRECT - Add tests first
describe("existingFunction", () => {
  it("should handle the existing behavior", () => {
    // Document current behavior with tests FIRST ✅
  });

  it("should handle the new behavior", () => {
    // Then add test for new behavior ✅
  });
});
```

## NO UNTESTED CODE

```typescript
// ❌ BANNED - Code without corresponding test
export function newHelper() {
  return "untested";
}

// ✅ REQUIRED - Test exists and was written first
// __tests__/helper.test.ts
describe("newHelper", () => {
  it("should return expected value", () => {
    expect(newHelper()).toBe("tested");
  });
});

// helper.ts
export function newHelper() {
  return "tested";
}
```

## BUG FIXES

**Every bug fix starts with a failing test:**

```typescript
// 1. FIRST: Write test that exposes the bug
it("should not crash when input is null", () => {
  // This test FAILS initially - proving the bug exists
  expect(() => processInput(null)).not.toThrow();
});

// 2. THEN: Fix the code
function processInput(input: string | null) {
  if (input === null) return; // Fix
  // ... rest of implementation
}

// 3. VERIFY: Test now passes
```

## TEST COMMANDS

Always from repository root:

```bash
bun run test              # Unit tests
bun run test:watch        # Watch mode
bun run test:coverage     # With coverage report
bun run test:integration  # Integration tests (after CI passes)
```

## QUALITY GATE

**Work is NOT done until:**

- [ ] All new/changed code has tests
- [ ] All tests pass
- [ ] `bun run ci` passes
- [ ] `bun run test:integration` passes (if exists)

## ENFORCEMENT

This rule is enforced by:

- Code review requirements
- Coverage thresholds in CI
- PR checks for test files

**PRs without tests for changed code will be rejected.**
