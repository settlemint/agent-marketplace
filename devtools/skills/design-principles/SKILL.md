---
name: design-principles
description: Use when building dashboards, admin interfaces, or polished UI. Covers Linear/Notion/Stripe-inspired design with 4px grid, typography, and depth strategies.
license: MIT
triggers:
  # Intent triggers
  - "build dashboard"
  - "create admin interface"
  - "design system"
  - "make UI polished"
  - "pixel perfect design"
  - "clean modern UI"

  # Artifact triggers
  - "4px grid"
  - "design direction"
  - "Linear style"
  - "Notion style"
  - "Stripe style"
  - "typography hierarchy"
  - "border radius"
  - "dark mode"
  - "elevation"
---

<objective>
Enforce precise, crafted design for enterprise software, SaaS dashboards, admin interfaces, and web applications. The philosophy is Jony Ive-level precision with intentional personality — every interface is polished, and each is designed for its specific context.
</objective>

<essential_principles>

- 4px grid for all spacing (4, 8, 12, 16, 24, 32px)
- Symmetrical padding (TLBR must match)
- Single depth strategy (borders-only OR single shadow OR layered — pick one)
- Four-level contrast hierarchy (foreground → secondary → muted → faint)
- Color for meaning only (gray builds structure)
  </essential_principles>

<constraints>
**Banned:**
- Asymmetrical padding (TLBR must match)
- Multiple depth strategies in same interface
- Spacing values not on 4px grid
- Color used decoratively without meaning
- Bouncy/playful animations in enterprise UI

**Required:**

- Commit to ONE depth strategy per interface
- All spacing on 4px grid (4, 8, 12, 16, 24, 32px)
- Explicit design direction chosen before coding
- Four-level contrast hierarchy maintained
  </constraints>

<anti_patterns>

- Defaulting to a design direction instead of choosing intentionally
- Mixing borders AND shadows AND layered backgrounds
- Using color for decoration rather than meaning
- Padding that differs on opposing sides
- Typography without clear hierarchy (more than 4 levels)
  </anti_patterns>

<quick_start>
**Before writing any code, commit to a design direction.** Don't default. Think about what this specific product needs to feel like.

1. Choose direction (see `references/design-directions.md`): Precision, Warmth, Sophistication, Boldness, Utility, or Data
2. Pick color foundation: warm (approachable), cool (professional), or pure (minimal)
3. Pick ONE depth strategy and commit
4. Apply craft principles from `references/craft-principles.md`
5. Verify with `references/verification-scripts.md`
   </quick_start>

<reference_index>
| Reference | Content |
|-----------|---------|
| craft-principles.md | 4px grid, symmetrical padding, depth strategy, border radius, typography, animation, dark mode |
| design-directions.md | Precision, Warmth, Sophistication, Boldness, Utility, Data — when to use each |
| verification-scripts.md | Bash scripts for validating spacing, shadows, border-radius, typography, anti-patterns |
| anti-patterns.md | Never-do list, always-question checklist, common mistakes |
</reference_index>

<navigation_context>
Screens need grounding. A data table floating in space feels like a component demo, not a product. Consider including:

- **Navigation** — sidebar or top nav showing where you are in the app
- **Location indicator** — breadcrumbs, page title, or active nav state
- **User context** — who's logged in, what workspace/org

When building sidebars, consider using the same background as the main content area. Tools like Supabase, Linear, and Vercel rely on a subtle border for separation rather than different background colors. This reduces visual weight and feels more unified.
</navigation_context>

<research>
**Find design patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production design system patterns",
      researchGoal: "Search for component styling and theming patterns",
      reasoning: "Need real-world examples of design systems",
      keywordsToSearch: ["design-system", "tokens", "theme"],
      extension: "ts",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Tokens: `keywordsToSearch: ["--spacing", "--color", "design-tokens"]`
- Components: `keywordsToSearch: ["Card", "Button", "shadcn"]`
- Tailwind: `keywordsToSearch: ["tailwind.config", "theme.extend"]`
- Linear/Notion style: Search `owner: "linear"` or `owner: "makenotion"`
  </research>

<related_skills>

**Comprehensive UI audit:** Load via `Skill({ skill: "devtools:vercel-design-guidelines" })` when:

- Auditing against Vercel's official design guidelines
- Checking accessibility (keyboard, focus, hit targets)
- Reviewing animations and reduced motion support

**Component library:** Load via `Skill({ skill: "devtools:shadcn" })` when:

- Adding UI components from shadcn registry
- Customizing component variants

</related_skills>

<success_criteria>
Every interface should look designed by a team that obsesses over 1-pixel differences.

1. [ ] Design direction explicitly chosen (not defaulted)
2. [ ] All spacing on 4px grid (verify with `references/verification-scripts.md`)
3. [ ] Symmetrical padding applied
4. [ ] Single depth strategy used consistently
5. [ ] Typography hierarchy established
6. [ ] Color used for meaning only
</success_criteria>

<evolution>
**Extension Points:**
- Add new design directions for specific product types
- Create verification scripts for additional anti-patterns
- Extend reference files with component-specific guidelines

**Timelessness:** Precision and intentionality in design transcend trends; these principles apply whether using Tailwind, CSS-in-JS, or future frameworks.
</evolution>
