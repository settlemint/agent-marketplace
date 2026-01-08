---
description: Testing patterns and best practices with Vitest
globs: "**/*.test.ts,**/*.test.tsx,**/*.spec.ts,**/*.spec.tsx"
alwaysApply: false
---

# Testing Standards

## Test Structure

### Arrange-Act-Assert

```typescript
it("should create user with valid data", async () => {
  // Arrange
  const userData = { name: "Alice", email: "alice@example.com" };

  // Act
  const user = await createUser(userData);

  // Assert
  expect(user.id).toBeDefined();
  expect(user.name).toBe("Alice");
});
```

### Descriptive Names

```typescript
// GOOD - describes behavior
describe("UserService", () => {
  describe("createUser", () => {
    it("should hash password before saving", async () => {});
    it("should throw ValidationError for duplicate email", async () => {});
  });
});

// AVOID - vague names
describe("UserService", () => {
  it("works", () => {});
  it("test 1", () => {});
});
```

## Assertions

### Specific Matchers

```typescript
// GOOD - specific matchers
expect(result).toHaveLength(3);
expect(user).toMatchObject({ name: "Alice" });
expect(fn).toHaveBeenCalledWith("arg");
expect(fn).toHaveBeenCalledTimes(1);

// AVOID - generic assertions
expect(result.length === 3).toBe(true);
expect(fn.mock.calls.length).toBe(1);
```

### Error Testing

```typescript
// GOOD - specific error type
await expect(createUser(invalid)).rejects.toThrow(ValidationError);

// GOOD - error message
await expect(createUser(invalid)).rejects.toThrow("Email required");
```

## Mocking

### Mock Modules

```typescript
import { vi } from "vitest";

// Mock entire module
vi.mock("./database", () => ({
  query: vi.fn(),
}));

// Mock specific export
vi.mock("./utils", async (importOriginal) => {
  const actual = await importOriginal();
  return {
    ...actual,
    fetchData: vi.fn(),
  };
});
```

### Spy on Methods

```typescript
const spy = vi.spyOn(service, "method");
spy.mockResolvedValue(mockData);

// After test
spy.mockRestore();
```

### Reset Between Tests

```typescript
beforeEach(() => {
  vi.clearAllMocks();
});

afterAll(() => {
  vi.restoreAllMocks();
});
```

## Async Testing

### Use async/await

```typescript
// GOOD
it("should fetch user", async () => {
  const user = await fetchUser("123");
  expect(user).toBeDefined();
});

// AVOID - callback style
it("should fetch user", (done) => {
  fetchUser("123").then((user) => {
    expect(user).toBeDefined();
    done();
  });
});
```

### Wait for Conditions

```typescript
import { waitFor } from "@testing-library/react";

await waitFor(() => {
  expect(screen.getByText("Loaded")).toBeInTheDocument();
});
```

## Component Testing

### Query Priority

```typescript
// Prefer accessible queries (in order)
screen.getByRole("button", { name: "Submit" });
screen.getByLabelText("Email");
screen.getByPlaceholderText("Search...");
screen.getByText("Welcome");
screen.getByTestId("custom-element"); // Last resort
```

### User Events

```typescript
import userEvent from "@testing-library/user-event";

const user = userEvent.setup();
await user.click(button);
await user.type(input, "text");
```

## Test Organization

### One Concept Per Test

```typescript
// GOOD - focused tests
it("should validate email format", () => {});
it("should reject empty password", () => {});

// AVOID - multiple assertions unrelated
it("should validate form", () => {
  expect(validateEmail("")).toBe(false);
  expect(validatePassword("")).toBe(false);
  expect(validateName("")).toBe(false);
});
```

### Setup Helpers

```typescript
// test/helpers.ts
export function createTestUser(overrides?: Partial<User>): User {
  return {
    id: "test-id",
    name: "Test User",
    email: "test@example.com",
    ...overrides,
  };
}
```

## Coverage

Target meaningful coverage, not 100%. Focus on:

- Business logic
- Edge cases
- Error paths
- Integration points
