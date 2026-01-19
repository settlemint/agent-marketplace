# TDD Patterns Reference

## Table of Contents

- [The Three Laws of TDD](#the-three-laws-of-tdd)
- [Red-Green-Refactor Detailed](#red-green-refactor-detailed)
- [Test Writing Patterns](#test-writing-patterns)
- [Legacy Code and Test Backfilling](#legacy-code-and-test-backfilling)
- [Common Rationalizations (Reject All)](#common-rationalizations-reject-all)
- [Recovery Protocols](#recovery-protocols)
- [Anti-Patterns](#anti-patterns)

## The Three Laws of TDD

1. **Write NO production code until a failing test exists**
2. **Write ONLY enough test to demonstrate failure**
3. **Write ONLY enough code to pass the test**

These are not guidelines - they are laws. Breaking them invalidates the TDD process.

## Red-Green-Refactor Detailed

### RED: Write Failing Test

**Checklist before writing test:**
- [ ] Know exactly what behavior to test
- [ ] Test addresses ONE behavior only
- [ ] Test name describes expected behavior
- [ ] Test uses real code paths (minimal mocking)

**Test structure:**
```typescript
test('descriptive name stating expected behavior', async () => {
  // Arrange - set up preconditions
  const input = createValidInput();

  // Act - perform the action
  const result = await functionUnderTest(input);

  // Assert - verify the outcome
  expect(result).toMatchExpectedState();
});
```

**Verify RED correctly:**
```bash
bun run test path/to/test.ts
```

Must fail with:
- Expected failure reason (missing function, wrong return value)
- NOT syntax errors
- NOT import errors
- NOT unrelated failures

### GREEN: Make Test Pass

**Minimum viable implementation:**
```typescript
// RED: Test expects function to return user
// WRONG GREEN: Build entire user system
// RIGHT GREEN: Return hardcoded user object

// Step 1: Return hardcoded value
function getUser(id: string): User {
  return { id, name: 'Test User' };
}

// Step 2: Add real implementation when more tests demand it
```

**Rules during GREEN:**
- No "while I'm here" improvements
- No anticipated features
- No error handling beyond what test requires
- No optimization
- Just. Make. It. Pass.

### REFACTOR: Improve While Green

**Safe refactorings:**
- Extract method/function
- Rename for clarity
- Remove duplication
- Simplify conditionals
- Inline unnecessary abstractions

**Verify after EACH refactoring:**
```bash
bun run test
```

All tests must remain green. If any fail, revert immediately.

## Test Writing Patterns

### Testing Pure Functions

```typescript
// Input → Output, no side effects
test('calculateTotal returns sum of items', () => {
  const items = [{ price: 10 }, { price: 20 }];
  expect(calculateTotal(items)).toBe(30);
});
```

### Testing Side Effects

```typescript
// Verify observable effects
test('saveUser persists to database', async () => {
  const user = { name: 'Test' };
  await saveUser(user);

  const saved = await db.users.findFirst({ where: { name: 'Test' } });
  expect(saved).toBeDefined();
});
```

### Testing Error Cases

```typescript
test('login throws for invalid credentials', async () => {
  await expect(login('bad@email', 'wrong'))
    .rejects
    .toThrow('Invalid credentials');
});
```

### Testing Async Operations

```typescript
test('fetchUser resolves with user data', async () => {
  const user = await fetchUser('123');
  expect(user.id).toBe('123');
});
```

## Legacy Code and Test Backfilling

Not all code has tests. When working with legacy code, use these strategies:

### When to Backfill Tests

**Always backfill tests when:**

1. **Modifying existing code** - Before changing legacy code, write characterization tests that capture current behavior
2. **Finding untested critical paths** - Security, payment, data integrity code MUST have tests
3. **Discovering silent failure risks** - If silent-failure-hunter finds gaps, add tests
4. **Fixing bugs** - Write regression test that fails before fix, passes after

### Characterization Testing (for legacy code)

When modifying code without tests, first capture what it currently does:

```typescript
// Step 1: Write test that documents current behavior
test('legacy calculateDiscount returns current behavior', () => {
  // Run the function, capture what it actually returns
  const result = calculateDiscount({ price: 100, userType: 'premium' });

  // Document the current output (even if it seems wrong)
  expect(result).toBe(15); // This is what it currently does
});

// Step 2: Now you can safely refactor
// If test fails, you've changed behavior (intentional or not)
```

### Test Coverage Gap Analysis

Before modifying a file, check its test coverage:

```bash
# Check if test file exists
ls src/feature.test.ts

# Check coverage for specific file
bun run test --coverage src/feature.ts
```

**If coverage is lacking:**

1. Identify critical paths in the file
2. Write characterization tests for those paths
3. THEN proceed with modifications using TDD for new code

### Prioritizing Test Backfill

Not all untested code is equal. Prioritize by risk:

| Priority | Code Type | Action |
|----------|-----------|--------|
| P0 | Security, auth, payments | Stop. Write tests first. |
| P1 | Data mutations, business logic | Write tests before modifying |
| P2 | API endpoints, user flows | Add integration tests |
| P3 | Utilities, formatters | Add tests opportunistically |
| P4 | Logging, analytics | Low priority |

### The Backfill Workflow

```
Working on task that touches legacy code?
    ↓
Does test file exist? ─── No ──→ Create it with basic characterization tests
    ↓ Yes
Are touched functions tested? ─── No ──→ Add characterization tests for them
    ↓ Yes
Proceed with TDD for new changes
    ↓
Run all tests (old + new)
    ↓
If coverage increased: Good!
If critical path now tested: Excellent!
```

### Characterization Test Template

```typescript
describe('LegacyModule (characterization)', () => {
  // Document current behavior before modifying
  describe('existingFunction', () => {
    test('handles normal input', () => {
      const result = existingFunction('normal');
      expect(result).toMatchSnapshot(); // or specific value
    });

    test('handles edge case (empty)', () => {
      const result = existingFunction('');
      expect(result).toMatchSnapshot();
    });

    test('handles edge case (null)', () => {
      const result = existingFunction(null);
      expect(result).toMatchSnapshot();
    });

    test('handles error case', () => {
      expect(() => existingFunction('invalid'))
        .toThrow(); // or not throw - document what happens
    });
  });
});
```

### Critical Path Detection

When reviewing code, identify paths that MUST have tests:

**Security-critical:**
- Authentication flows
- Authorization checks
- Input validation
- Token handling
- Password operations

**Data-critical:**
- Database writes
- State mutations
- Financial calculations
- User data handling

**Reliability-critical:**
- Error handling
- Retry logic
- Timeout handling
- Fallback behavior

**If these paths lack tests, add them before proceeding.**

### Integration with Silent Failure Hunter

When silent-failure-hunter identifies error handling gaps:

1. Write test that exercises the error path
2. Verify current (possibly incorrect) behavior
3. Fix the error handling
4. Update test to expect correct behavior

```typescript
// Hunter found: empty catch block in processPayment

// Step 1: Test current behavior (even if wrong)
test('processPayment currently swallows errors silently', async () => {
  const result = await processPayment({ invalid: true });
  expect(result).toBeUndefined(); // Documents the silent failure
});

// Step 2: Fix the code, update test
test('processPayment throws on invalid input', async () => {
  await expect(processPayment({ invalid: true }))
    .rejects.toThrow('Invalid payment data');
});
```

## Common Rationalizations (Reject All)

### "I'll write the test after"

**Problem:** Test passes immediately - proves nothing about test quality.

**Truth:** A test that never failed might not test what you think.

### "This is too simple to test"

**Problem:** "Simple" code has bugs too. And gets complex over time.

**Truth:** If it's worth writing, it's worth testing.

### "I know this works"

**Problem:** Knowledge isn't verification. Code changes, knowledge doesn't.

**Truth:** Tests catch regressions from future changes.

### "Manual testing is faster"

**Problem:** Manual testing doesn't persist. Others can't run it.

**Truth:** Automated tests pay dividends forever.

### "Just this once"

**Problem:** Exceptions become habits.

**Truth:** Discipline is doing it every time.

## Recovery Protocols

### Wrote Code Before Test

**Action:** Delete the code. Write test first. Re-implement.

**Why:** Code written without TDD often has subtle bugs the test would have caught.

### Test Passes Immediately

**Action:** The test is invalid. Either:
1. Test is too weak - make it fail by testing edge cases
2. Implementation existed - find a gap the test should cover
3. Test is wrong - fix the assertion

### Multiple Tests Fail After Change

**Action:** Revert the change. You're making it worse.

1. `git stash` or `git checkout -- .`
2. Re-analyze what you're trying to do
3. Make smaller, incremental changes
4. One test green at a time

### Three Failed Fix Attempts

**Action:** Stop. This is an architectural problem.

1. Step back from the keyboard
2. Map out the system interactions
3. Identify the design flaw
4. Refactor architecture, not symptoms

## Anti-Patterns

### Test-After Development

Writing tests after implementation. Tests become "code confirmation" not "behavior specification."

### Implementation Testing

Testing internal implementation instead of observable behavior:

```typescript
// WRONG: Testing implementation
test('uses cache', () => {
  expect(cache.get).toHaveBeenCalled();
});

// RIGHT: Testing behavior
test('returns same result for same input', () => {
  const first = calculate(5);
  const second = calculate(5);
  expect(first).toBe(second);
});
```

### Flaky Tests

Tests that sometimes pass, sometimes fail. Usually due to:
- Timing dependencies
- Shared state
- External services
- Race conditions

**Fix:** Make tests deterministic. Mock time, isolate state.

### Test Pollution

Tests affecting each other through shared state:

```typescript
// WRONG: Shared state
let counter = 0;
test('increments', () => { counter++; expect(counter).toBe(1); });
test('increments again', () => { counter++; expect(counter).toBe(2); }); // Coupled!

// RIGHT: Isolated
test('increments', () => {
  const counter = new Counter();
  counter.increment();
  expect(counter.value).toBe(1);
});
```

### Over-Mocking

Mocking so much that tests don't verify real behavior:

```typescript
// WRONG: Everything mocked
test('login works', () => {
  mockDatabase();
  mockAuth();
  mockSession();
  // What are we even testing?
});

// RIGHT: Integration test with real dependencies
test('login creates session', async () => {
  const user = await createTestUser();
  const session = await login(user.email, user.password);
  expect(session).toBeDefined();
});
```

### God Tests

Single test verifying too many things:

```typescript
// WRONG: God test
test('user flow works', async () => {
  // 50 lines testing registration, login, profile, logout
});

// RIGHT: Focused tests
test('registration creates user', async () => { /* ... */ });
test('login returns session', async () => { /* ... */ });
test('profile shows user data', async () => { /* ... */ });
test('logout invalidates session', async () => { /* ... */ });
```
