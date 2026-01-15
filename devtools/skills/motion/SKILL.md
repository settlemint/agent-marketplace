---
name: motion
description: Motion (formerly Framer Motion) for React animations. Covers transitions, gestures, layout animations, and exit animations. Triggers on motion, animate, framer.
license: MIT
triggers:
  - "motion"
  - "framer"
  - "framer.?motion"
  - "animate"
  - "animation"
  - "animated"
  - "AnimatePresence"
  - "variants"
  - "transition"
  - "fade.?in"
  - "fade.?out"
  - "slide.?in"
  - "slide.?out"
  - "smooth.?transition"
  - "enter.?animation"
  - "exit.?animation"
  - "gesture"
  - "whileHover"
  - "whileTap"
  - "drag"
  - "draggable"
  - "spring.?animation"
  - "layout.?animation"
  - "stagger"
  - "orchestrat"
  - "keyframe"
  - "useAnimate"
  - "useMotionValue"
  - "useSpring"
  - "motion\\.div"
  - "motion\\.span"
---

<objective>
Create fluid animations using Motion (the successor to Framer Motion). Handle enter/exit animations, gestures, layout transitions, and complex orchestration.
</objective>

<essential_principles>

- Wrap conditional renders in `AnimatePresence` for exit animations
- Use `variants` for complex orchestration with staggerChildren
- Animate `transform` and `opacity` (GPU accelerated), avoid `width`/`height`
- Use `spring` transitions for natural feel
- Use `useMotionValue` for frequently updating values
  </essential_principles>

<constraints>
**Banned:**
- Animating `width`/`height` directly (use `scale` or `transform`)
- Missing `AnimatePresence` for exit animations
- Bouncy/spring animations in enterprise UI without design approval
- Animations that ignore `prefers-reduced-motion`

**Required:**

- Wrap conditional renders in `AnimatePresence`
- Use GPU-accelerated properties (`transform`, `opacity`)
- Respect reduced motion preferences
- Use `variants` for complex orchestration
  </constraints>

<anti_patterns>

- Forgetting `AnimatePresence` wrapper for conditional renders
- Animating layout properties (`width`, `height`, `top`, `left`) directly
- Overly long animation durations (>500ms for UI feedback)
- Not providing `key` prop for animated list items
- Using `animate` prop when `variants` would be cleaner
  </anti_patterns>

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
```

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

<reference_index>
| Reference | Content |
|-----------|---------|
| animation-patterns.md | Variants, layout animations, shared layout, spring physics, keyframes, hooks |
| verification-patterns.md | Code analysis, Vitest testing, performance heuristics, Playwright testing |
</reference_index>

<library_ids>
Skip resolve step for these known IDs:

| Library | Context7 ID            |
| ------- | ---------------------- |
| Motion  | /motiondivision/motion |

</library_ids>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production Motion animation patterns",
      researchGoal: "Search for complex animation orchestration",
      reasoning: "Need real-world examples of Motion usage",
      keywordsToSearch: ["motion/react", "AnimatePresence", "variants"],
      extension: "tsx",
      limit: 10,
    },
  ],
});
```

</research>

<related_skills>

**Design guidelines:** Load via `Skill({ skill: "devtools:vercel-design-guidelines" })` when:

- Verifying animations respect `prefers-reduced-motion`
- Checking animation timing and interruptibility

**Design system:** Load via `Skill({ skill: "devtools:design-principles" })` when:

- Establishing animation timing values (150ms micro, 200-250ms larger)
- Avoiding spring/bouncy effects in enterprise UI

</related_skills>

<success_criteria>

- [ ] Context7 docs fetched for current API
- [ ] Exit animations wrapped in AnimatePresence
- [ ] Variants used for staggered children
- [ ] Performance-friendly properties animated
- [ ] Spring transitions for natural feel
      </success_criteria>

<evolution>
**Extension Points:**
- Create reusable animation variants for common patterns
- Build gesture-based interaction libraries
- Add shared layout animations for page transitions

**Timelessness:** Declarative animation APIs are the future of web motion; Motion patterns apply to any React-based animation library.
</evolution>
