# Reference: Test Data Strategies

<overview>
Test data is the foundation of reliable tests. Choose the right strategy based on what you're testing. Factories generate dynamic data, fixtures provide static scenarios, and mocks replace external dependencies.
</overview>

<strategy_selection>
| Strategy | Use When | Characteristics |
|----------|----------|-----------------|
| **Factories** | Data variability needed, many instances, randomized properties | Dynamic, generated, supports overrides |
| **Fixtures** | Exact reproduction needed, edge cases, snapshot testing | Static, deterministic, version-controlled |
| **Mocks** | External dependencies, side effects, isolation required | Controlled behavior, verifiable interactions |

**Decision rule:** Default to factories. Use fixtures for regression/edge cases. Use mocks only for external boundaries.
</strategy_selection>

<factories>
**Factories generate test data dynamically with sensible defaults and override support.**

<pattern name="basic_factory">
```typescript
import { faker } from "@faker-js/faker";

// Factory function with defaults
function createUser(overrides: Partial<User> = {}): User {
return {
id: faker.string.uuid(),
email: faker.internet.email(),
name: faker.person.fullName(),
createdAt: faker.date.past(),
...overrides,
};
}

// Usage
const user = createUser(); // Random user
const admin = createUser({ role: "admin" }); // Random admin
const specific = createUser({ email: "test@x.com" }); // Specific email

````
</pattern>

<pattern name="builder_factory">
```typescript
// Builder pattern for complex objects
class UserBuilder {
  private user: Partial<User> = {};

  withEmail(email: string) {
    this.user.email = email;
    return this;
  }

  withRole(role: Role) {
    this.user.role = role;
    return this;
  }

  asAdmin() {
    this.user.role = "admin";
    this.user.permissions = ["read", "write", "delete"];
    return this;
  }

  build(): User {
    return createUser(this.user);
  }
}

// Usage
const admin = new UserBuilder().asAdmin().withEmail("admin@x.com").build();
````

</pattern>

<pattern name="bulk_factory">
```typescript
// Generate multiple instances
function createUsers(count: number, overrides: Partial<User> = {}): User[] {
  return Array.from({ length: count }, () => createUser(overrides));
}

// Sequence factories for unique values
let userCounter = 0;
function createSequentialUser(): User {
return createUser({
email: `user${++userCounter}@test.com`,
name: `User ${userCounter}`,
});
}

````
</pattern>

<best_practices>
**Factory best practices:**
- Use faker for realistic random data
- Provide sensible defaults for all required fields
- Support partial overrides via spread operator
- Create domain-specific builders for complex scenarios
- Reset sequences/counters in beforeEach
</best_practices>
</factories>

<fixtures>
**Fixtures provide static, deterministic test data for exact reproduction.**

<pattern name="json_fixtures">
```typescript
// fixtures/users.json
{
  "validUser": {
    "id": "usr_123",
    "email": "valid@example.com",
    "name": "Valid User"
  },
  "maxLengthUser": {
    "id": "usr_456",
    "email": "a@b.com",
    "name": "A".repeat(255)
  },
  "unicodeUser": {
    "id": "usr_789",
    "email": "日本語@example.com",
    "name": "名前"
  }
}

// Usage
import fixtures from "./fixtures/users.json";

it("should_handle_max_length_name", () => {
  const result = validateUser(fixtures.maxLengthUser);
  expect(result.valid).toBe(true);
});
````

</pattern>

<pattern name="typescript_fixtures">
```typescript
// fixtures/users.ts - Type-safe fixtures
export const fixtures = {
  validUser: {
    id: "usr_123",
    email: "valid@example.com",
    name: "Valid User",
    createdAt: new Date("2024-01-15T10:00:00Z"),
  },

edgeCases: {
emptyName: { id: "usr_001", email: "a@b.com", name: "" },
maxLength: { id: "usr_002", email: "a@b.com", name: "A".repeat(255) },
unicode: { id: "usr_003", email: "日本語@example.com", name: "名前" },
specialChars: { id: "usr_004", email: "a@b.com", name: "O'Brien-Smith" },
},

errorCases: {
missingEmail: { id: "usr_005", name: "No Email" },
invalidEmail: { id: "usr_006", email: "not-an-email", name: "Bad Email" },
},
} as const;

````
</pattern>

<pattern name="regression_fixtures">
```typescript
// fixtures/regression.ts - Bug reproduction data
export const regressionFixtures = {
  // Issue #1234: Empty roles array caused crash
  issue1234: {
    user: { id: "1", roles: [] },
    expectedBehavior: "should not crash, return false for permissions",
  },

  // Issue #2345: Unicode in email broke validation
  issue2345: {
    email: "münchen@example.de",
    expectedBehavior: "should accept international characters",
  },
};
````

</pattern>

<best_practices>
**Fixture best practices:**

- Name fixtures by scenario, not content
- Include edge cases and boundary values
- Document regression fixtures with issue numbers
- Keep fixtures immutable (use `as const`)
- Organize by domain (users, orders, products)
  </best_practices>
  </fixtures>

<mocks>
**Mocks replace external dependencies with controlled implementations.**

<pattern name="dependency_mock">
```typescript
// Mock external services
const mockEmailService = {
  send: vi.fn().mockResolvedValue({ success: true }),
  verify: vi.fn().mockResolvedValue(true),
};

const mockDatabase = {
query: vi.fn(),
transaction: vi.fn((fn) => fn()),
};

// Inject mocks
const userService = new UserService(mockEmailService, mockDatabase);

````
</pattern>

<pattern name="behavior_scenarios">
```typescript
// Success scenario
mockDatabase.query.mockResolvedValue([{ id: "1", name: "User" }]);

// Error scenario
mockDatabase.query.mockRejectedValue(new Error("Connection failed"));

// Empty result
mockDatabase.query.mockResolvedValue([]);

// Conditional behavior
mockDatabase.query.mockImplementation((sql) => {
  if (sql.includes("WHERE id =")) {
    return Promise.resolve([{ id: "1" }]);
  }
  return Promise.resolve([]);
});
````

</pattern>

<pattern name="verification">
```typescript
it("should_call_email_service_on_signup", async () => {
  await userService.signup({ email: "new@example.com" });

expect(mockEmailService.send).toHaveBeenCalledTimes(1);
expect(mockEmailService.send).toHaveBeenCalledWith({
to: "new@example.com",
template: "welcome",
});
});

it("should_not_send_email_on_failure", async () => {
mockDatabase.query.mockRejectedValue(new Error("DB error"));

await expect(userService.signup({ email: "x@y.com" })).rejects.toThrow();
expect(mockEmailService.send).not.toHaveBeenCalled();
});

````
</pattern>

<boundary_rule>
**Mock at boundaries only:**
- External APIs (HTTP clients, third-party services)
- Databases and file systems
- Time and randomness (for determinism)
- Expensive operations (for speed)

**Do NOT mock:**
- Internal collaborators (test them together)
- Pure functions (no side effects to control)
- Data structures (use factories instead)
</boundary_rule>
</mocks>

<determinism>
**Eliminate non-determinism for reliable tests.**

<pattern name="time_injection">
```typescript
// Inject time dependency
class ExpirationChecker {
  constructor(private now: () => Date = () => new Date()) {}

  isExpired(date: Date): boolean {
    return date < this.now();
  }
}

// Test with controlled time
it("should_detect_expired_date", () => {
  const fixedNow = new Date("2024-06-01");
  const checker = new ExpirationChecker(() => fixedNow);

  expect(checker.isExpired(new Date("2024-05-01"))).toBe(true);
  expect(checker.isExpired(new Date("2024-07-01"))).toBe(false);
});
````

</pattern>

<pattern name="randomness_injection">
```typescript
// Inject random seed
class IdGenerator {
  constructor(private seed?: number) {}

generate(): string {
if (this.seed !== undefined) {
return `id_${this.seed}`;
}
return `id_${Math.random().toString(36).slice(2)}`;
}
}

// Test with deterministic seed
it("should_generate_predictable_id_with_seed", () => {
const generator = new IdGenerator(42);
expect(generator.generate()).toBe("id_42");
});

````
</pattern>

<pattern name="faker_seed">
```typescript
import { faker } from "@faker-js/faker";

beforeEach(() => {
  // Reset faker seed for reproducible tests
  faker.seed(12345);
});

it("should_process_user_data", () => {
  const user = createUser(); // Same user every time with seed
  // Assertions...
});
````

</pattern>
</determinism>

<integration_pattern>
**Combining strategies:**

```typescript
describe("OrderService", () => {
  // Mocks for external dependencies
  const mockPaymentGateway = { charge: vi.fn() };
  const mockInventory = { reserve: vi.fn(), release: vi.fn() };

  // Factory for dynamic order data
  const createOrder = (overrides = {}) => ({
    id: faker.string.uuid(),
    items: [{ sku: "SKU001", quantity: 1, price: 100 }],
    ...overrides,
  });

  // Fixtures for edge cases
  const fixtures = {
    emptyOrder: { id: "ord_001", items: [] },
    maxItems: {
      id: "ord_002",
      items: Array(100).fill({ sku: "SKU", quantity: 1, price: 1 }),
    },
  };

  let service: OrderService;

  beforeEach(() => {
    vi.clearAllMocks();
    service = new OrderService(mockPaymentGateway, mockInventory);
  });

  it("should_process_valid_order", async () => {
    const order = createOrder(); // Factory
    mockPaymentGateway.charge.mockResolvedValue({ success: true });
    mockInventory.reserve.mockResolvedValue(true);

    const result = await service.process(order);

    expect(result.status).toBe("completed");
    expect(mockPaymentGateway.charge).toHaveBeenCalled();
  });

  it("should_reject_empty_order", async () => {
    await expect(service.process(fixtures.emptyOrder)).rejects.toThrow(
      "Empty order",
    );
  });
});
```

</integration_pattern>

<checklist>
**Test data checklist:**

- [ ] **Factories** — Used for dynamic, variable data
- [ ] **Overrides** — Factories support partial customization
- [ ] **Fixtures** — Used for exact reproduction scenarios
- [ ] **Edge cases** — Boundary values in fixtures
- [ ] **Mocks** — Only at external boundaries
- [ ] **Verification** — Mock calls verified where side effects matter
- [ ] **Determinism** — Time/randomness injected for reproducibility
- [ ] **Reset** — Mocks cleared in beforeEach
      </checklist>
