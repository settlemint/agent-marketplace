# Reference: Test Coverage Patterns

<overview>
Comprehensive test suites converge on standard coverage categories. Use this reference to ensure no critical test cases are missed.
</overview>

<coverage_targets>
**Coverage targets are minimum thresholds, not aspirational goals.**

| Metric                | Minimum | Good | Excellent | Notes                                        |
| --------------------- | ------- | ---- | --------- | -------------------------------------------- |
| **Line coverage**     | 80%     | 85%  | 90%+      | Percentage of code lines executed            |
| **Branch coverage**   | 75%     | 80%  | 85%+      | Critical for logic paths                     |
| **Function coverage** | 90%     | 95%  | 98%+      | All public APIs must be tested               |
| **Critical paths**    | 100%    | 100% | 100%      | Auth, payments, permissions — non-negotiable |

<blocking_criteria>
**Coverage gates that block merges:**

```yaml
# Example CI configuration
coverage:
  statements: 80
  branches: 75
  functions: 90
  lines: 80
  # Critical paths require 100%
  critical:
    - src/auth/**
    - src/payments/**
    - src/permissions/**
```

**Blocking conditions:**

- PR cannot merge if coverage decreases below threshold
- Critical path files must maintain 100% coverage
- New code must have tests (no untested additions)
- Flaky tests must be fixed, not skipped
  </blocking_criteria>
  </coverage_targets>

<priority_analysis>
**Prioritize test coverage by risk and change frequency.**

| Priority | Weight | Criteria                          | Action                                     |
| -------- | ------ | --------------------------------- | ------------------------------------------ |
| **P1**   | 3x     | Critical paths (auth, payments)   | 100% coverage required                     |
| **P2**   | 2x     | Recently changed (30 days)        | High-change files need tests               |
| **P3**   | 1.5x   | High complexity (cyclomatic > 10) | Complex logic needs thorough testing       |
| **P4**   | 2x     | Bug history (issues linked)       | Files with past bugs need regression tests |

<gap_identification>
**Finding untested code:**

```bash
# Generate coverage report
bun run test -- --coverage

# Check for uncovered lines
# Look for files with < 80% in report

# Priority formula:
# Score = (Critical × 3) + (RecentChange × 2) + (Complexity × 1.5) + (BugHistory × 2)
```

**High-priority gaps to address first:**

1. Uncovered error handling in critical paths
2. Missing edge cases in recently modified code
3. Untested branches in complex functions
4. Files with past production bugs lacking regression tests
   </gap_identification>
   </priority_analysis>

<coverage_categories>

<category name="happy_path">
**Happy Path / Nominal Case**

The "it works" scenario with valid, expected inputs.

```typescript
it("should_return_user_when_valid_id_provided", async () => {
  const user = await userService.getById("valid-id");
  expect(user).toEqual({ id: "valid-id", name: "Alice" });
});
```

**Always start here.** This is your first RED test.
</category>

<category name="negative_cases">
**Negative Tests / Failure Cases**

Invalid inputs or conditions that must error or return failure.

```typescript
it("should_throw_NotFound_when_user_does_not_exist", async () => {
  await expect(userService.getById("nonexistent")).rejects.toThrow(
    NotFoundError,
  );
});

it("should_return_empty_array_when_no_results", async () => {
  const results = await searchService.find("gibberish");
  expect(results).toEqual([]);
});
```

</category>

<category name="edge_cases">
**Edge Cases / Boundary Tests**

Limits: 0/1, min/max, empty, overflow, off-by-one, date boundaries.

```typescript
// Empty input
it("should_return_empty_when_input_is_empty_string", () => {
  expect(parser.parse("")).toEqual([]);
});

// Boundary values
it("should_accept_exactly_max_length", () => {
  const input = "a".repeat(MAX_LENGTH);
  expect(() => validator.check(input)).not.toThrow();
});

it("should_reject_one_over_max_length", () => {
  const input = "a".repeat(MAX_LENGTH + 1);
  expect(() => validator.check(input)).toThrow("Too long");
});

// Zero/one
it("should_handle_single_item_array", () => {
  expect(utils.sum([5])).toBe(5);
});

it("should_handle_empty_array", () => {
  expect(utils.sum([])).toBe(0);
});
```

</category>

<category name="corner_cases">
**Corner Cases**

Weird combinations of valid inputs that are rare but possible.

```typescript
it("should_handle_unicode_characters", () => {
  expect(slugify("日本語")).toBe("ri-ben-yu");
});

it("should_handle_concurrent_updates", async () => {
  const results = await Promise.all([
    service.update(id, { count: 1 }),
    service.update(id, { count: 2 }),
  ]);
  // Verify last-write-wins or conflict detection
});
```

</category>

<category name="input_validation">
**Input Validation Tests**

Type/shape/range checks, required fields, normalization.

```typescript
it("should_reject_missing_required_field", () => {
  expect(() => createUser({ email: "a@b.com" })) // missing name
    .toThrow("name is required");
});

it("should_normalize_email_to_lowercase", () => {
  const user = createUser({ name: "Test", email: "TEST@EXAMPLE.COM" });
  expect(user.email).toBe("test@example.com");
});

it("should_reject_invalid_email_format", () => {
  expect(() => createUser({ name: "Test", email: "not-an-email" })).toThrow(
    "Invalid email",
  );
});
```

</category>

<category name="error_handling">
**Error Handling Tests**

Verify error types, messages, codes, and cleanup.

```typescript
it("should_throw_ValidationError_with_field_details", () => {
  try {
    validate({ age: -1 });
  } catch (e) {
    expect(e).toBeInstanceOf(ValidationError);
    expect(e.field).toBe("age");
    expect(e.message).toContain("must be positive");
  }
});

it("should_cleanup_resources_on_failure", async () => {
  const tempFile = await createTempFile();
  await expect(processFile(tempFile)).rejects.toThrow();
  expect(await fileExists(tempFile)).toBe(false); // cleaned up
});
```

</category>

<category name="state_transitions">
**State Transition Tests**

"Given state A, when event X, then state B" — for workflows, reducers, state machines.

```typescript
describe("Order State Machine", () => {
  it("should_transition_from_pending_to_confirmed_on_payment", () => {
    const order = createOrder(); // state: pending
    order.confirmPayment();
    expect(order.status).toBe("confirmed");
  });

  it("should_not_allow_shipping_from_pending_state", () => {
    const order = createOrder(); // state: pending
    expect(() => order.ship()).toThrow("Cannot ship pending order");
  });
});
```

</category>

<category name="behavioral">
**Behavioral Tests**

Test the public contract (what it does), not internals (how it does it).

```typescript
// GOOD: Tests behavior
it("should_calculate_total_with_discount", () => {
  const cart = new Cart([{ price: 100 }, { price: 50 }]);
  cart.applyDiscount(10); // 10%
  expect(cart.total).toBe(135);
});

// BAD: Tests implementation
it("should_call_discountCalculator", () => {
  // Don't test that internal methods are called
});
```

</category>

<category name="interaction">
**Interaction Tests**

Verify calls to collaborators (mocks/spies). Use sparingly—only when collaboration matters.

```typescript
it("should_call_email_service_on_signup", async () => {
  const emailService = { send: vi.fn() };
  const userService = new UserService(emailService);

  await userService.signup({ email: "new@example.com" });

  expect(emailService.send).toHaveBeenCalledWith({
    to: "new@example.com",
    template: "welcome",
  });
});
```

**Use when:**

- Side effects must occur (emails, notifications, audit logs)
- External service calls must happen with correct parameters
- Order of operations matters
  </category>

<category name="determinism">
**Determinism Tests**

Same input → same output. No time/randomness leakage.

```typescript
// Inject time dependency
it("should_format_date_consistently", () => {
  const formatter = new DateFormatter(new Date("2024-01-15"));
  expect(formatter.relative()).toBe("today");
});

// Inject randomness
it("should_generate_id_from_seed", () => {
  const generator = new IdGenerator({ seed: 42 });
  expect(generator.next()).toBe("fixed-id-from-seed");
});
```

</category>

</coverage_categories>

<test_design_patterns>

<pattern name="aaa">
**Arrange-Act-Assert (AAA)**

```typescript
it("should_calculate_total", () => {
  // Arrange
  const cart = new Cart();
  cart.add({ price: 100 });
  cart.add({ price: 50 });

  // Act
  const total = cart.getTotal();

  // Assert
  expect(total).toBe(150);
});
```

</pattern>

<pattern name="table_driven">
**Table-Driven / Parameterized Tests**

One test definition, many cases.

```typescript
describe("isValidEmail", () => {
  const cases = [
    { input: "test@example.com", expected: true },
    { input: "invalid", expected: false },
    { input: "a@b.co", expected: true },
    { input: "@missing.com", expected: false },
    { input: "spaces @bad.com", expected: false },
  ];

  it.each(cases)("returns $expected for $input", ({ input, expected }) => {
    expect(isValidEmail(input)).toBe(expected);
  });
});
```

</pattern>

<pattern name="property_based">
**Property-Based Testing**

Check invariants over many generated inputs. Use `fast-check` library.

```typescript
import fc from "fast-check";

it("should_round_trip_json", () => {
  fc.assert(
    fc.property(fc.anything(), (value) => {
      const serialized = JSON.stringify(value);
      const deserialized = JSON.parse(serialized);
      expect(deserialized).toEqual(value);
    }),
  );
});

it("should_preserve_array_length_after_sort", () => {
  fc.assert(
    fc.property(fc.array(fc.integer()), (arr) => {
      expect(arr.sort().length).toBe(arr.length);
    }),
  );
});
```

</pattern>

<pattern name="regression">
**Regression Tests**

Codify a bug so it never returns.

```typescript
// Issue #1234: User with empty roles caused crash
it("should_handle_user_with_empty_roles_array", () => {
  const user = { id: "1", roles: [] };
  expect(() => checkPermissions(user)).not.toThrow();
  expect(checkPermissions(user)).toBe(false);
});
```

**Always add a regression test when fixing a bug.** Reference the issue number.
</pattern>

</test_design_patterns>

<correctness_properties>

<property name="idempotency">
**Idempotency:** Calling twice has same effect as calling once.

```typescript
it("should_be_idempotent", async () => {
  await service.process(data);
  const state1 = await getState();

  await service.process(data);
  const state2 = await getState();

  expect(state2).toEqual(state1);
});
```

</property>

<property name="round_trip">
**Round-Trip:** serialize→deserialize yields original.

```typescript
it("should_round_trip_serialize_deserialize", () => {
  const original = { name: "test", value: 42 };
  const serialized = serialize(original);
  const deserialized = deserialize(serialized);
  expect(deserialized).toEqual(original);
});
```

</property>

<property name="invariants">
**Invariants:** Must always hold, before and after every operation.

```typescript
describe("BankAccount invariants", () => {
  it("should_never_have_negative_balance", () => {
    const account = new BankAccount(100);
    expect(() => account.withdraw(150)).toThrow();
    expect(account.balance).toBeGreaterThanOrEqual(0);
  });
});
```

</property>

</correctness_properties>

<coverage_checklist>
When reviewing test coverage, verify:

- [ ] **Happy path** — Basic valid scenario works
- [ ] **Empty/null/undefined** — Edge inputs handled
- [ ] **Boundary values** — Min, max, off-by-one checked
- [ ] **Invalid inputs** — Proper errors thrown
- [ ] **Error messages** — Errors are informative
- [ ] **State transitions** — Valid paths work, invalid blocked
- [ ] **Side effects** — External calls verified (where needed)
- [ ] **Regression** — Known bugs have tests
      </coverage_checklist>
