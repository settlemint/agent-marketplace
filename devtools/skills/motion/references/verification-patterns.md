# Animation Verification Patterns

Animation quality typically requires visual verification, but agents can validate correctness through code analysis and testing.

## Code Analysis Checks

```bash
# Verify AnimatePresence wraps conditional renders with exit
grep -rB5 "exit=" --include="*.tsx" | grep -v "AnimatePresence" && echo "WARNING: exit without AnimatePresence"

# Check for layout prop overuse (performance concern)
layout_count=$(grep -rh "layout" --include="*.tsx" | grep -c "motion\.")
[ "$layout_count" -gt 5 ] && echo "WARNING: $layout_count layout props - consider optimization"

# Verify spring transitions are used (natural feel)
grep -rE "transition=\{" --include="*.tsx" | grep -v "spring" | head -5

# Check for non-GPU-accelerated properties
grep -rE "animate=.*\{[^}]*(width|height|left|top|right|bottom)" --include="*.tsx"
```

## Animation State Testing with Vitest

```tsx
import { render, screen } from "@testing-library/react";
import { act } from "react";

describe("Animation component", () => {
  it("renders with initial state", () => {
    const { container } = render(<AnimatedComponent />);
    // Motion elements have data-motion attributes
    expect(container.querySelector("[data-motion]")).toBeInTheDocument();
  });

  it("applies exit animation when removed", async () => {
    const { rerender, container } = render(<Modal isOpen={true} />);
    // AnimatePresence should keep element during exit
    rerender(<Modal isOpen={false} />);
    // Element should still exist briefly during exit animation
    expect(container.querySelector("[data-motion]")).toBeInTheDocument();
  });
});
```

## Performance Heuristics

```bash
# Count motion components per file (complexity indicator)
for file in $(find src -name "*.tsx"); do
  count=$(grep -c "motion\." "$file" 2>/dev/null || echo 0)
  [ "$count" -gt 10 ] && echo "HIGH: $file has $count motion elements"
done

# Check bundle impact
bun run build
du -h dist/*.js | grep -E "motion|framer"
```

## Lighthouse CI for Performance

```bash
# Run Lighthouse in CI mode
npx lighthouse http://localhost:3000 --output=json --output-path=./lighthouse.json

# Parse animation-related metrics
cat lighthouse.json | jq '.audits["cumulative-layout-shift"].score'
cat lighthouse.json | jq '.audits["total-blocking-time"].score'
```

## Playwright for Animation Behavior Testing

```typescript
import { test, expect } from "@playwright/test";

test("modal animation completes", async ({ page }) => {
  await page.goto("/");

  // Trigger modal open
  await page.click('[data-testid="open-modal"]');

  // Wait for animation to complete (motion adds data attributes)
  await page.waitForSelector(
    '[data-testid="modal"][data-motion-state="animate"]',
  );

  // Verify modal is visible
  await expect(page.locator('[data-testid="modal"]')).toBeVisible();

  // Close and verify exit animation
  await page.click('[data-testid="close-modal"]');

  // AnimatePresence keeps element during exit - wait for removal
  await expect(page.locator('[data-testid="modal"]')).not.toBeVisible({
    timeout: 1000,
  });
});
```

**Key principle:** Validate animation correctness through code patterns, state testing, and performance metrics. Reserve "natural feel" judgment for human review, but ensure the implementation is technically sound.
