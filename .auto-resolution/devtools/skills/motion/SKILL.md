---
name: motion
description: Motion (formerly Framer Motion) for React animations. Covers transitions, gestures, layout animations, and exit animations. Triggers on motion, animate, framer.
triggers:
  ["motion", "animate", "framer", "transition", "variants", "AnimatePresence"]
---

<objective>
Create fluid animations using Motion (the successor to Framer Motion). Handle enter/exit animations, gestures, layout transitions, and complex orchestration.
</objective>

<mcp_first>
**CRITICAL: Fetch Motion documentation before implementing.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_context7__query-docs" })
```

```typescript
// Motion component patterns
mcp__context7__query_docs({
  libraryId: "/motiondivision/motion",
  query: "How do I use motion.div with animate, initial, and exit props?",
});

// Variants and orchestration
mcp__context7__query_docs({
  libraryId: "/motiondivision/motion",
  query: "How do I use variants and staggerChildren for orchestration?",
});

// Layout animations
mcp__context7__query_docs({
  libraryId: "/motiondivision/motion",
  query: "How do I use layout and layoutId for shared layout animations?",
});

// Gestures
mcp__context7__query_docs({
  libraryId: "/motiondivision/motion",
  query: "How do I use whileHover, whileTap, and drag gestures?",
});
```

**Note:** Context7 v2 uses server-side filtering. Use descriptive natural language queries.
</mcp_first>

<quick_start>
**Basic animation:**

```tsx
import { motion } from "motion/react";

function FadeIn() {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3 }}
    >
      Hello!
    </motion.div>
  );
}
```

**Exit animations:**

```tsx
import { motion, AnimatePresence } from "motion/react";

function Modal({ isOpen, onClose }) {
  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 0.9 }}
        >
          <button onClick={onClose}>Close</button>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
```

**Gestures:**

```tsx
<motion.button whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }}>
  Click me
</motion.button>
```

</quick_start>

<patterns>
**Variants (reusable animations):**

```tsx
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
};

function List({ items }) {
  return (
    <motion.ul variants={containerVariants} initial="hidden" animate="visible">
      {items.map((item) => (
        <motion.li key={item.id} variants={itemVariants}>
          {item.name}
        </motion.li>
      ))}
    </motion.ul>
  );
}
```

**Layout animations:**

```tsx
<motion.div layout>
  {/* Content changes trigger smooth layout animation */}
</motion.div>
```

**Shared layout (magic move):**

```tsx
<motion.div layoutId="card">
  {/* Same layoutId creates shared transition */}
</motion.div>
```

**Spring physics:**

```tsx
<motion.div
  animate={{ x: 100 }}
  transition={{
    type: "spring",
    stiffness: 300,
    damping: 20,
  }}
/>
```

**Keyframes:**

```tsx
<motion.div
  animate={{
    scale: [1, 1.2, 1],
    rotate: [0, 180, 360],
  }}
  transition={{ duration: 2 }}
/>
```

</patterns>

<hooks>
```typescript
import { useAnimate, useMotionValue, useTransform, useSpring } from "motion/react";

// Imperative animations
const [scope, animate] = useAnimate();
animate(scope.current, { opacity: 1 });

// Motion values for performance
const x = useMotionValue(0);
const opacity = useTransform(x, [0, 100], [1, 0]);

// Spring-based values
const smoothX = useSpring(x, { stiffness: 300 });

````
</hooks>

<constraints>
**Best practices:**
- Use `layoutId` for shared element transitions
- Wrap conditional renders in `AnimatePresence`
- Use `variants` for complex orchestration
- Prefer `spring` transitions for natural feel
- Use `useMotionValue` for frequently updating values

**Performance:**
- Animate `transform` and `opacity` (GPU accelerated)
- Avoid animating `width`, `height` (use `scale`)
- Use `layout` prop sparingly (can be expensive)
</constraints>

<agent_verification>
**Programmatic validation for animation implementations:**

Animation quality typically requires visual verification, but agents can validate correctness through code analysis and testing:

**Code analysis checks:**
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
````

**Animation state testing with Vitest:**

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

**Performance heuristics (without visual inspection):**

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

**Lighthouse CI for performance validation:**

```bash
# Run Lighthouse in CI mode
npx lighthouse http://localhost:3000 --output=json --output-path=./lighthouse.json

# Parse animation-related metrics
cat lighthouse.json | jq '.audits["cumulative-layout-shift"].score'
cat lighthouse.json | jq '.audits["total-blocking-time"].score'
```

**Playwright for animation behavior testing:**

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
</agent_verification>

<success_criteria>

- [ ] Context7 docs fetched for current API
- [ ] Exit animations wrapped in AnimatePresence
- [ ] Variants used for staggered children
- [ ] Performance-friendly properties animated
- [ ] Spring transitions for natural feel
      </success_criteria>

```

```
