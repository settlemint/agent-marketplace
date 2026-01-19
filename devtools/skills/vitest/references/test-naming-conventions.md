# Reference: Test Naming Conventions

<overview>
Consistent test naming improves readability, debugging, and maintenance. Good test names describe the expected behavior and conditions without reading the test body.
</overview>

<naming_patterns>

<pattern name="should_when">
**Primary Pattern: `should_<expected>_when_<condition>`**

Most expressive pattern. Reads as natural language specification.

```typescript
it("should_return_user_when_valid_id_provided");
it("should_throw_NotFound_when_user_does_not_exist");
it("should_return_empty_array_when_no_matches_found");
it("should_normalize_email_when_uppercase_provided");
it("should_reject_request_when_rate_limit_exceeded");
```

**Structure:**

- `should` — Sets expectation
- `<expected>` — What happens (return, throw, create, update)
- `when` — Condition separator
- `<condition>` — The scenario (valid input, missing field, timeout)
  </pattern>

<pattern name="given_when_then">
**Alternative: `given_<state>_when_<action>_then_<result>`**

Best for state machines, workflows, complex preconditions.

```typescript
it("given_pending_order_when_payment_received_then_status_confirmed");
it("given_empty_cart_when_checkout_attempted_then_error_thrown");
it("given_authenticated_user_when_accessing_profile_then_data_returned");
```

**Use when:**

- State is important context
- Testing state transitions
- Multiple preconditions exist
  </pattern>

<pattern name="returns_for">
**Concise: `returns_<result>_for_<input>`**

Good for pure functions, validators, formatters.

```typescript
it("returns_true_for_valid_email");
it("returns_false_for_empty_string");
it("returns_formatted_date_for_timestamp");
it("returns_null_for_undefined_input");
```

</pattern>

<pattern name="throws_on">
**Error cases: `throws_<error>_on_<condition>`**

Clear for error handling tests.

```typescript
it("throws_ValidationError_on_missing_required_field");
it("throws_TimeoutError_on_slow_response");
it("throws_AuthError_on_expired_token");
```

</pattern>

</naming_patterns>

<describe_block_naming>
**Describe blocks organize tests by unit under test:**

```typescript
describe("UserService", () => {
  describe("getById", () => {
    it("should_return_user_when_valid_id_provided");
    it("should_throw_NotFound_when_user_does_not_exist");
  });

  describe("create", () => {
    it("should_create_user_when_valid_data_provided");
    it("should_normalize_email_when_uppercase_provided");
  });
});
```

**Nested describe for scenarios:**

```typescript
describe("CartService", () => {
  describe("checkout", () => {
    describe("with valid cart", () => {
      it("should_create_order");
      it("should_send_confirmation_email");
    });

    describe("with empty cart", () => {
      it("should_throw_EmptyCartError");
    });
  });
});
```

</describe_block_naming>

<anti_patterns>

<anti_pattern name="vague_names">
**Vague Names**

```typescript
// BAD
it("works");
it("handles edge case");
it("test user");
it("should work correctly");

// GOOD
it("should_return_user_when_valid_id_provided");
it("should_handle_empty_string_input");
it("should_create_user_with_normalized_email");
```

</anti_pattern>

<anti_pattern name="implementation_names">
**Implementation-Focused Names**

```typescript
// BAD - describes how, not what
it("calls_validateEmail_method");
it("uses_cache_for_lookup");
it("loops_through_items");

// GOOD - describes behavior
it("should_reject_invalid_email");
it("should_return_cached_result_on_second_call");
it("should_process_all_items");
```

</anti_pattern>

<anti_pattern name="test_prefix">
**Redundant "test" Prefix**

```typescript
// BAD
it("test_user_creation");
it("test that user is created");

// GOOD
it("should_create_user_when_valid_data_provided");
```

</anti_pattern>

<anti_pattern name="assertion_names">
**Naming by Assertion**

```typescript
// BAD
it("toBe_true");
it("result_equals_expected");
it("length_is_5");

// GOOD
it("should_return_true_when_user_is_admin");
it("should_return_expected_result_for_valid_input");
it("should_contain_five_items_after_adding");
```

</anti_pattern>

</anti_patterns>

<file_naming>
**Test file naming conventions:**

```
src/
├── services/
│   └── user.service.ts
├── utils/
│   └── validator.ts
└── __tests__/           # or tests/ or alongside source
    ├── services/
    │   └── user.service.test.ts
    └── utils/
        └── validator.test.ts
```

**Patterns:**

- `*.test.ts` — Most common, explicit
- `*.spec.ts` — BDD style, also common
- `__tests__/*.ts` — Jest convention (directory-based)

**Match source structure.** Test file path should mirror source file path.
</file_naming>

<test_structure>
**AAA Structure (Arrange-Act-Assert):**

```typescript
it("should_calculate_total_with_discount", () => {
  // Arrange - Setup preconditions
  const cart = new Cart();
  cart.add({ price: 100 });
  cart.add({ price: 50 });
  cart.applyDiscount(0.1);

  // Act - Execute the behavior
  const total = cart.getTotal();

  // Assert - Verify outcome
  expect(total).toBe(135);
});
```

**One concept per test:**

```typescript
// BAD - Multiple concepts
it("should_create_user_and_send_email_and_log_event", async () => {
  // Testing too much
});

// GOOD - Single concept each
it("should_create_user_when_valid_data_provided");
it("should_send_welcome_email_after_user_created");
it("should_log_creation_event_after_user_created");
```

</test_structure>

<quick_reference>
**Pattern Quick Reference:**

| Scenario          | Pattern                 | Example                                  |
| ----------------- | ----------------------- | ---------------------------------------- |
| Standard behavior | `should_X_when_Y`       | `should_return_user_when_valid_id`       |
| State machine     | `given_X_when_Y_then_Z` | `given_pending_when_paid_then_confirmed` |
| Pure function     | `returns_X_for_Y`       | `returns_true_for_valid_email`           |
| Error case        | `throws_X_on_Y`         | `throws_NotFound_on_missing_id`          |

**Word Choice:**

- `return`, `create`, `update`, `delete` — for data operations
- `throw`, `reject` — for errors
- `call`, `invoke` — for interactions (use sparingly)
- `emit`, `send`, `notify` — for side effects
  </quick_reference>
