---
name: vitest
description: Vitest unit testing patterns for TypeScript. Use when asked to "write unit tests", "mock dependencies", or "add test coverage". Covers test structure, mocking, assertions, and coverage.
license: MIT
triggers:
  - "vitest"
  - "vite.*test"
  - "describe\\("
  - "\\bit\\("
  - "\\btest\\("
  - "expect\\("
  - "\\bmock"
  - "vi\\.fn"
  - "vi\\.mock"
  - "vi\\.spyOn"
  - "vi\\.stub"
  - "\\.test\\.ts"
  - "\\.spec\\.ts"
  - "unit.*test"
  - "test.*unit"
  - "write.*test"
  - "add.*test"
  - "create.*test"
  - "test.*file"
  - "test.*coverage"
  - "coverage.*report"
  - "beforeEach"
  - "afterEach"
  - "beforeAll"
  - "afterAll"
  - "toBe\\("
  - "toEqual\\("
  - "toHaveBeenCalled"
  - "toThrow"
  - "mockReturnValue"
  - "mockResolvedValue"
  - "mockImplementation"
  - "bun.*test"
  - "run.*test"
  - "test.*pass"
  - "test.*fail"
  - "assert"
  - "spy"
  - "fake.*timer"
  - "useFakeTimers"
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
  libraryId: "/vitest-dev/vitest",
  query: "How do I use describe, it, expect, and beforeEach?",
});

// Mocking
mcp__context7__query_docs({
  libraryId: "/vitest-dev/vitest",
  query: "How do I use vi.mock, vi.fn, and vi.spyOn for mocking?",
});

// Async testing
mcp__context7__query_docs({
  libraryId: "/vitest-dev/vitest",
  query: "How do I test async code with rejects and resolves?",
});
```

**Note:** Context7 v2 uses server-side filtering. Use descriptive natural language queries.
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
**Banned:**
- Test interdependencies (tests must run in any order)
- Shared mutable state between tests
- Testing implementation details (test behavior, not internals)
- `.only` or `.skip` committed to main branch

**Required:**

- One concept per test (single assertion focus)
- Descriptive test names ("should X when Y")
- Clean setup with beforeEach
- No test interdependencies
- Mock external services

**Naming:** Test files=`*.test.ts` or `*.spec.ts`
</constraints>

<anti_patterns>

- **Test Interdependence:** Tests that rely on other tests running first; breaks isolation
- **Implementation Testing:** Testing private methods or internal state; breaks on refactoring
- **Mock Leakage:** Mocks persisting between tests; use `vi.resetAllMocks()` in afterEach
- **Assertion-Free Tests:** Tests without expect statements; false positives
- **Overmocking:** Mocking so much that tests don't verify real behavior
  </anti_patterns>

<commands>
```bash
vitest                  # Run in watch mode
vitest run              # Run once
vitest run --coverage   # With coverage
vitest run -t "pattern" # Filter by name
```
</commands>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production Vitest testing patterns",
      researchGoal: "Search for mocking and test organization patterns",
      reasoning: "Need real-world examples of Vitest usage",
      keywordsToSearch: ["vi.mock", "describe", "vitest"],
      extension: "ts",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Mocking: `keywordsToSearch: ["vi.mock", "vi.spyOn", "mockImplementation"]`
- Async testing: `keywordsToSearch: ["resolves", "rejects", "toThrow"]`
- Coverage: `keywordsToSearch: ["vitest", "coverage", "c8"]`
  </research>

<related_skills>

**TDD workflow:** Load via `Skill({ skill: "devtools:tdd-typescript" })` when:

- Following RED-GREEN-REFACTOR cycle
- Writing tests before implementation
- Enforcing coverage requirements

**E2E testing:** Load via `Skill({ skill: "devtools:playwright" })` when:

- Testing user flows end-to-end
- Browser automation testing
- Integration testing with real browser

**Advanced testing (Trail of Bits):** Load these for enhanced test quality:

- `Skill({ skill: "trailofbits:property-based-testing" })` — Property-based testing guidance
- `Skill({ skill: "trailofbits:testing-handbook-skills" })` — Fuzzers, sanitizers, coverage
  </related_skills>

<success_criteria>

1. [ ] Context7 docs fetched for current API
2. [ ] Tests are isolated (no dependencies)
3. [ ] Mocks used for external services
4. [ ] Descriptive test names
5. [ ] Coverage for edge cases
</success_criteria>

<evolution>
**Extension Points:**
- Add domain-specific test templates (API testing, React components)
- Extend with snapshot testing patterns for UI components
- Integrate with CI/CD for automated test reporting

**Timelessness:** Unit testing principles are fundamental to software quality; Vitest's Jest-compatible API means patterns transfer across testing frameworks.
</evolution>
