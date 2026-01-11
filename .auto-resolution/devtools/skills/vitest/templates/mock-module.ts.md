# Module Mocking Template

```typescript
import { describe, expect, it, beforeEach, vi } from "vitest";
import { {{functionUnderTest}} } from "./{{module-under-test}}";

// Full module mock
vi.mock("./{{dependency-module}}", () => ({
  {{exportedFunction}}: vi.fn().mockReturnValue({{mockReturnValue}}),
}));

// Partial mock (keep some real implementations)
vi.mock("./{{partial-dependency}}", async () => {
  const actual = await vi.importActual("./{{partial-dependency}}");
  return {
    ...actual,
    {{functionToMock}}: vi.fn(),
  };
});

// Import mocked module
import { {{exportedFunction}} } from "./{{dependency-module}}";

describe("{{functionUnderTest}}", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("calls dependency with correct args", async () => {
    await {{functionUnderTest}}({{input}});

    expect({{exportedFunction}}).toHaveBeenCalledWith({{expectedArgs}});
    expect({{exportedFunction}}).toHaveBeenCalledTimes(1);
  });

  it("handles dependency failure", async () => {
    vi.mocked({{exportedFunction}}).mockRejectedValueOnce(new Error("Failed"));

    await expect({{functionUnderTest}}({{input}})).rejects.toThrow("Failed");
  });
});
```

## Mock Patterns

```typescript
// Return value
mockFn.mockReturnValue("sync value");
mockFn.mockResolvedValue("async value");
mockFn.mockRejectedValue(new Error("error"));

// Implementation
mockFn.mockImplementation((x) => x * 2);

// Sequence
mockFn
  .mockReturnValueOnce("first")
  .mockReturnValueOnce("second")
  .mockReturnValue("default");

// Assertions
expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledWith("arg");
expect(mockFn).toHaveBeenCalledTimes(2);
```
