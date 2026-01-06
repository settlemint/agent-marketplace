---
name: vitest
description: Vitest unit testing patterns for TypeScript. Covers test structure, mocking, assertions, and coverage. Triggers on vitest, describe, it, expect, mock.
triggers:
  [
    "vitest",
    "describe",
    "\\bit\\(",
    "expect",
    "mock",
    "\\.test\\.ts",
    "\\.spec\\.ts",
  ]
---

<objective>
Write effective unit tests using Vitest. Vitest is a fast, Vite-native test runner with Jest-compatible API and excellent TypeScript support.
</objective>

<mcp_first>
**CRITICAL: Always fetch Vitest documentation for current API.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_context7__query-docs" })
```

```typescript
// Test patterns
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/vitest-dev/vitest",
  topic: "describe it expect beforeEach",
});

// Mocking
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/vitest-dev/vitest",
  topic: "vi.mock vi.fn vi.spyOn",
});

// Async testing
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/vitest-dev/vitest",
  topic: "async await rejects resolves",
});
```

</mcp_first>

<quick_start>
**Templates for common test patterns:**

| Pattern            | Template                       | Use When                     |
| ------------------ | ------------------------------ | ---------------------------- |
| Service/Unit tests | `templates/service-test.ts.md` | Testing classes/functions    |
| Module mocking     | `templates/mock-module.ts.md`  | Mocking dependencies         |
| Timer mocking      | `templates/mock-timers.ts.md`  | Testing setTimeout/intervals |

**Read the templates for scaffolding new tests.** Each includes placeholders and examples.
</quick_start>

<mocking>
**Mock functions:**

```typescript
const mockFn = vi.fn();
mockFn.mockReturnValue("mocked");
mockFn.mockResolvedValue("async mocked");
mockFn.mockImplementation((x) => x * 2);

expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledWith("arg");
expect(mockFn).toHaveBeenCalledTimes(1);
```

**Mock modules:**

```typescript
vi.mock("./myModule", () => ({
  myFunction: vi.fn().mockReturnValue("mocked"),
}));

// Partial mock (keep some real implementations)
vi.mock("./myModule", async () => {
  const actual = await vi.importActual("./myModule");
  return {
    ...actual,
    specificFunction: vi.fn(),
  };
});
```

**Spy on methods:**

```typescript
const spy = vi.spyOn(object, "method");
spy.mockReturnValue("mocked");

// Restore original
spy.mockRestore();
```

**Mock timers:**

```typescript
beforeEach(() => {
  vi.useFakeTimers();
});

afterEach(() => {
  vi.useRealTimers();
});

it("handles timeouts", async () => {
  const callback = vi.fn();
  setTimeout(callback, 1000);

  vi.advanceTimersByTime(1000);
  expect(callback).toHaveBeenCalled();
});

it("handles dates", () => {
  vi.setSystemTime(new Date("2024-01-15"));
  expect(new Date().toISOString()).toContain("2024-01-15");
});
```

**Mock environment variables:**

```typescript
beforeEach(() => {
  vi.stubEnv("API_KEY", "test-key");
});

afterEach(() => {
  vi.unstubAllEnvs();
});
```

</mocking>

<advanced_mocking>
**Conditional mock behavior:**

```typescript
const mockDb = {
  query: vi.fn(),
};

// Different responses for different inputs
mockDb.query.mockImplementation((sql: string) => {
  if (sql.includes("SELECT")) return Promise.resolve([{ id: 1 }]);
  if (sql.includes("INSERT")) return Promise.resolve({ insertId: 1 });
  return Promise.reject(new Error("Unknown query"));
});
```

**Mock sequences:**

```typescript
const mockFetch = vi
  .fn()
  .mockResolvedValueOnce({ status: 500 }) // First call fails
  .mockResolvedValueOnce({ status: 200 }); // Retry succeeds

await expect(fetchWithRetry()).resolves.toEqual({ status: 200 });
expect(mockFetch).toHaveBeenCalledTimes(2);
```

**Mock classes:**

```typescript
vi.mock("./EmailService", () => ({
  EmailService: vi.fn().mockImplementation(() => ({
    send: vi.fn().mockResolvedValue({ sent: true }),
    verify: vi.fn().mockResolvedValue(true),
  })),
}));
```

**Verify call order:**

```typescript
const mockA = vi.fn();
const mockB = vi.fn();

await service.process(); // Should call A then B

const callOrder = [
  ...mockA.mock.invocationCallOrder,
  ...mockB.mock.invocationCallOrder,
];
expect(callOrder).toEqual([1, 2]); // A called first, then B
```

</advanced_mocking>

<assertions>
**Common assertions:**

```typescript
expect(value).toBe(exact); // ===
expect(value).toEqual(deep); // Deep equality
expect(value).toBeDefined();
expect(value).toBeNull();
expect(value).toBeTruthy();
expect(value).toContain(item);
expect(value).toHaveLength(n);
expect(value).toMatch(/regex/);

// Objects
expect(obj).toHaveProperty("key");
expect(obj).toMatchObject({ partial: true });

// Async
await expect(promise).resolves.toBe(value);
await expect(promise).rejects.toThrow("error");
```

</assertions>

<constraints>
**Required:**
- One concept per test (single assertion focus)
- Descriptive test names ("should X when Y")
- Clean setup with beforeEach
- No test interdependencies
- Mock external services

**Naming:** Test files=`*.test.ts` or `*.spec.ts`
</constraints>

<commands>
```bash
vitest                  # Run in watch mode
vitest run              # Run once
vitest run --coverage   # With coverage
vitest run -t "pattern" # Filter by name
```
</commands>

<success_criteria>

- [ ] Context7 docs fetched for current API
- [ ] Tests are isolated (no dependencies)
- [ ] Mocks used for external services
- [ ] Descriptive test names
- [ ] Coverage for edge cases
      </success_criteria>
