---
name: react-best-practices
description: React and Next.js performance optimization guidelines from Vercel Engineering. This skill should be used when writing, reviewing, or refactoring React/Next.js code to ensure optimal performance patterns. Triggers on tasks involving React components, Next.js pages, data fetching, bundle optimization, or performance improvements.
license: MIT
triggers: [
    # Performance keywords
    "(?i)\\b(performance|perf|optimize|optimization|optimise)\\b",
    "(?i)\\b(slow|fast|speed|latency|lag)\\b",
    "(?i)\\b(improve|reduce|minimize|boost)\\s+(performance|speed|load\\s+time)\\b",

    # Bundle and loading
    "(?i)\\b(bundle|chunk|split|tree.?shak)\\b",
    "(?i)\\b(lazy\\s+load|code\\s+split|dynamic\\s+import)\\b",
    "(?i)\\b(bundle\\s+size|import\\s+cost|barrel\\s+file)\\b",
    "(?i)\\bnext/dynamic\\b",

    # Data fetching patterns
    "(?i)\\b(waterfall|parallel|sequential)\\s+(fetch|request|load)\\b",
    "(?i)\\b(data\\s+fetch|fetching\\s+pattern|fetch\\s+strategy)\\b",
    "(?i)\\bPromise\\.all\\b",
    "(?i)\\b(swr|react.?query|cache|dedup)\\b",

    # Re-render optimization
    "(?i)\\b(re.?render|rerender|render\\s+cycle)\\b",
    "(?i)\\b(memo|useMemo|useCallback|React\\.memo)\\b",
    "(?i)\\b(unnecessary\\s+render|wasted\\s+render|render\\s+optimization)\\b",

    # React/Next.js specific
    "(?i)\\b(react|next\\.?js|nextjs)\\s+(best\\s+practice|pattern|guideline)\\b",
    "(?i)\\b(server\\s+component|client\\s+component|rsc|ssr|ssg|isr)\\b",
    "(?i)\\b(suspense|streaming|transition|startTransition)\\b",
    "(?i)\\bReact\\.cache\\b",

    # Code review context
    "(?i)\\b(review|audit|check)\\s+(performance|code|component)\\b",
    "(?i)\\b(refactor|improve|clean\\s*up)\\s+(react|component|code)\\b",

    # Vercel/Next.js ecosystem
    "(?i)\\bvercel\\s+(guideline|pattern|engineering)\\b",
    "(?i)\\b(app\\s+router|pages\\s+router|middleware)\\b",

    # Common performance issues
    "(?i)\\b(memory\\s+leak|infinite\\s+loop|blocking)\\b",
    "(?i)\\b(hydration|mismatch|flash)\\b",
    "(?i)\\b(core\\s+web\\s+vitals|lcp|fid|cls|inp)\\b",

    # Intent-based
    "(?i)why\\s+is\\s+(my|the|this)\\s+(app|page|component)\\s+slow",
    "(?i)how\\s+to\\s+(speed\\s+up|optimize|improve)\\s+(react|next|my\\s+app)",
  ]
---

<objective>
Apply Vercel Engineering's React and Next.js performance optimization patterns to eliminate waterfalls, reduce bundle size, optimize rendering, and improve Core Web Vitals. Use priority-ordered guidelines to maximize performance gains when writing, reviewing, or refactoring React/Next.js code.
</objective>

<quick_start>

1. **Identify performance bottleneck** - Waterfall? Bundle size? Re-renders?
2. **Apply critical patterns first** - Eliminate waterfalls with `Promise.all()`, reduce bundle with direct imports
3. **Use server patterns** - `React.cache()` for deduplication, parallelize data fetching
4. **Optimize client** - SWR for caching, `startTransition` for non-urgent updates
5. **Verify with metrics** - Check Core Web Vitals (LCP, FID, CLS, INP)
   </quick_start>

<constraints>
<banned>
- Barrel file imports (`import { Button } from '@/components'`) - Import directly from source
- Sequential awaits for independent fetches - Use `Promise.all()` instead
- Large synchronous imports for non-critical UI - Use `next/dynamic`
- Premature memoization without profiling evidence
- Inline object/function props without memoization in hot paths
- Client components when server components suffice
</banned>

<required>
- `Promise.all()` for independent async operations
- Direct imports from source files, not barrel files
- `React.cache()` for server-side per-request deduplication
- Suspense boundaries for streaming heavy content
- `startTransition` for non-urgent state updates
- LRU cache for cross-request server caching
</required>
</constraints>

<when_to_apply>
Reference these guidelines when:

- Writing new React components or Next.js pages
- Implementing data fetching (client or server-side)
- Reviewing code for performance issues
- Refactoring existing React/Next.js code
- Optimizing bundle size or load times
  </when_to_apply>

<priority_guidelines>
Rules are prioritized by impact:

| Priority | Category                  | Impact      |
| -------- | ------------------------- | ----------- |
| 1        | Eliminating Waterfalls    | CRITICAL    |
| 2        | Bundle Size Optimization  | CRITICAL    |
| 3        | Server-Side Performance   | HIGH        |
| 4        | Client-Side Data Fetching | MEDIUM-HIGH |
| 5        | Re-render Optimization    | MEDIUM      |
| 6        | Rendering Performance     | MEDIUM      |
| 7        | JavaScript Performance    | LOW-MEDIUM  |
| 8        | Advanced Patterns         | LOW         |

</priority_guidelines>

<quick_reference>
<critical_patterns>
**Eliminate Waterfalls:**

- Use `Promise.all()` for independent async operations
- Start promises early, await late
- Use `better-all` for partial dependencies
- Use Suspense boundaries to stream content

**Reduce Bundle Size:**

- Avoid barrel file imports (import directly from source)
- Use `next/dynamic` for heavy components
- Defer non-critical third-party libraries
- Preload based on user intent
  </critical_patterns>

<high_impact_server_patterns>

- Use `React.cache()` for per-request deduplication
- Use LRU cache for cross-request caching
- Minimize serialization at RSC boundaries
- Parallelize data fetching with component composition
  </high_impact_server_patterns>

<medium_impact_client_patterns>

- Use SWR for automatic request deduplication
- Defer state reads to usage point
- Use derived state subscriptions
- Apply `startTransition` for non-urgent updates
  </medium_impact_client_patterns>
  </quick_reference>

<anti_patterns>
<pattern name="barrel-file-imports">

```tsx
// BAD: Pulls entire component library into bundle
import { Button, Card, Modal } from "@/components";

// GOOD: Tree-shakeable direct imports
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
```

</pattern>

<pattern name="sequential-await-waterfall">
```tsx
// BAD: Sequential waterfall - 300ms total
const user = await fetchUser(id);      // 100ms
const posts = await fetchPosts(id);    // 100ms
const comments = await fetchComments(id); // 100ms

// GOOD: Parallel fetch - 100ms total
const [user, posts, comments] = await Promise.all([
fetchUser(id),
fetchPosts(id),
fetchComments(id),
]);

````
</pattern>

<pattern name="premature-memoization">
```tsx
// BAD: Memoizing without evidence of performance issue
const MemoizedButton = React.memo(({ onClick }) => (
  <button onClick={onClick}>Click</button>
));

// GOOD: Profile first, memoize hot paths with evidence
// Use React DevTools Profiler to identify actual bottlenecks
````

</pattern>

<pattern name="client-component-overuse">
```tsx
// BAD: Entire page as client component
'use client';
export default function ProductPage({ id }) { ... }

// GOOD: Server component with client islands
export default async function ProductPage({ id }) {
const product = await getProduct(id);
return (

<div>
<ProductDetails product={product} />
<AddToCartButton productId={id} /> {/_ Only this is 'use client' _/}
</div>
);
}

```
</pattern>
</anti_patterns>

<references_section>
Full documentation with code examples is available in:
- `references/react-performance-guidelines.md` - Complete guide with all patterns
- `references/rules/` - Individual rule files organized by category

To look up a specific pattern, grep the rules directory:
```

grep -l "suspense" references/rules/
grep -l "barrel" references/rules/
grep -l "swr" references/rules/

````

<rule_categories>
- `async-*` - Waterfall elimination patterns
- `bundle-*` - Bundle size optimization
- `server-*` - Server-side performance
- `client-*` - Client-side data fetching
- `rerender-*` - Re-render optimization
- `rendering-*` - DOM rendering performance
- `js-*` - JavaScript micro-optimizations
- `advanced-*` - Advanced patterns
</rule_categories>
</references_section>

<research>
**Find React performance patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find React performance patterns",
      researchGoal: "Search for optimization and caching patterns",
      reasoning: "Need real-world examples of React performance",
      keywordsToSearch: ["useMemo", "useCallback", "React.memo"],
      extension: "tsx",
      limit: 10,
    },
  ],
});
````

**Common searches:**

- Memoization: `keywordsToSearch: ["useMemo", "useCallback", "memo"]`
- Data fetching: `keywordsToSearch: ["useSWR", "useQuery", "Suspense"]`
- Bundle: `keywordsToSearch: ["next/dynamic", "lazy", "import()"]`
- Server components: `keywordsToSearch: ["use server", "React.cache"]`
  </research>

<related_skills>
**React components:** Load via `Skill({ skill: "devtools:react" })` when:

- Building React components with Tailwind CSS
- Implementing forms and routing

**Testing:** Load via `Skill({ skill: "devtools:vitest" })` when:

- Writing unit tests for optimized components
- Testing memoization behavior

**Design system:** Load via `Skill({ skill: "devtools:design-principles" })` when:

- Building performant UI with proper design patterns
- Implementing animations and transitions
  </related_skills>

<success_criteria>

- [ ] No barrel file imports in new/modified code
- [ ] Independent async operations use `Promise.all()`
- [ ] Heavy components use `next/dynamic` with loading states
- [ ] Server components used where client interactivity not needed
- [ ] `React.cache()` applied for server-side deduplication
- [ ] No sequential await waterfall patterns
- [ ] Memoization applied only with profiling evidence
- [ ] Core Web Vitals within acceptable thresholds (LCP < 2.5s, FID < 100ms, CLS < 0.1)
      </success_criteria>

<evolution>
<extension_points>
- **New optimization patterns**: Add rules to `references/rules/` with appropriate prefix
- **Framework updates**: Update for React 19+ features (use, Actions, etc.)
- **Build tool patterns**: Add Turbopack-specific optimizations
- **Testing patterns**: Add performance testing utilities and benchmarks
</extension_points>

<version_history>

- v1.0: Initial Vercel Engineering guidelines
- v1.1: Added anti-patterns section and success criteria
  </version_history>
  </evolution>
