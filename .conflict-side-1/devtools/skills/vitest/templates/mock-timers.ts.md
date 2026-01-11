# Timer Mocking Template

```typescript
import { describe, expect, it, beforeEach, afterEach, vi } from "vitest";
import { {{functionWithTimers}} } from "./{{module}}";

describe("{{functionWithTimers}}", () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it("executes callback after timeout", async () => {
    const callback = vi.fn();
    {{functionWithTimers}}(callback, {{timeoutMs}});

    expect(callback).not.toHaveBeenCalled();

    vi.advanceTimersByTime({{timeoutMs}});

    expect(callback).toHaveBeenCalledTimes(1);
  });

  it("handles interval correctly", async () => {
    const callback = vi.fn();
    {{startInterval}}(callback, {{intervalMs}});

    vi.advanceTimersByTime({{intervalMs}} * 3);

    expect(callback).toHaveBeenCalledTimes(3);
  });

  it("uses mocked date", () => {
    vi.setSystemTime(new Date("{{mockDate}}"));

    const result = {{functionUsingDate}}();

    expect(result).toContain("{{expectedDatePart}}");
  });

  it("runs all pending timers", async () => {
    const callbacks = [vi.fn(), vi.fn()];
    setTimeout(callbacks[0], 100);
    setTimeout(callbacks[1], 200);

    vi.runAllTimers();

    expect(callbacks[0]).toHaveBeenCalled();
    expect(callbacks[1]).toHaveBeenCalled();
  });
});
```

## Timer Control Methods

```typescript
// Time control
vi.advanceTimersByTime(1000); // Advance by milliseconds
vi.advanceTimersToNextTimer(); // Run next timer only
vi.runAllTimers(); // Run all pending timers
vi.runOnlyPendingTimers(); // Run pending, not new ones

// Date mocking
vi.setSystemTime(new Date("2024-01-15"));
vi.setSystemTime(Date.now());

// Cleanup
vi.useRealTimers(); // Restore real timers
vi.clearAllTimers(); // Clear without running
```
