---
name: design-principles
description: Enforce a precise, minimal design system inspired by Linear, Notion, and Stripe. Use when building dashboards, admin interfaces, or any UI that needs Jony Ive-level precision - clean, modern, minimalist with taste. Every pixel matters.
triggers:
  [
    "dashboard",
    "admin",
    "ui design",
    "design system",
    "spacing",
    "typography",
    "elevation",
    "shadow",
    "card",
    "layout",
  ]
---

<objective>
Enforce precise, crafted design for enterprise software, SaaS dashboards, admin interfaces, and web applications. The philosophy is Jony Ive-level precision with intentional personality — every interface is polished, and each is designed for its specific context.
</objective>

<quick_start>
**Before writing any code, commit to a design direction.** Don't default. Think about what this specific product needs to feel like.

Ask these questions:

- **What does this product do?** A finance tool needs different energy than a creative tool.
- **Who uses it?** Power users want density. Occasional users want guidance.
- **What's the emotional job?** Trust? Efficiency? Delight? Focus?
- **What would make this memorable?** Every product has a chance to feel distinctive.
  </quick_start>

<design_directions>
Enterprise/SaaS UI has more range than you think. Consider these directions:

**Precision & Density** — Tight spacing, monochrome, information-forward. For power users who live in the tool. Think Linear, Raycast, terminal aesthetics.

**Warmth & Approachability** — Generous spacing, soft shadows, friendly colors. For products that want to feel human. Think Notion, Coda, collaborative tools.

**Sophistication & Trust** — Cool tones, layered depth, financial gravitas. For products handling money or sensitive data. Think Stripe, Mercury, enterprise B2B.

**Boldness & Clarity** — High contrast, dramatic negative space, confident typography. For products that want to feel modern and decisive. Think Vercel, minimal dashboards.

**Utility & Function** — Muted palette, functional density, clear hierarchy. For products where the work matters more than the chrome. Think GitHub, developer tools.

**Data & Analysis** — Chart-optimized, technical but accessible, numbers as first-class citizens. For analytics, metrics, business intelligence.

Pick one. Or blend two. But commit to a direction that fits the product.
</design_directions>

<color_foundation>
**Don't default to warm neutrals.** Consider the product:

- **Warm foundations** (creams, warm grays) — approachable, comfortable, human
- **Cool foundations** (slate, blue-gray) — professional, trustworthy, serious
- **Pure neutrals** (true grays, black/white) — minimal, bold, technical
- **Tinted foundations** (slight color cast) — distinctive, memorable, branded

**Light or dark?** Dark modes aren't just light modes inverted. Dark feels technical, focused, premium. Light feels open, approachable, clean. Choose based on context.

**Accent color** — Pick ONE that means something. Blue for trust. Green for growth. Orange for energy. Violet for creativity. Don't just reach for the same accent every time.
</color_foundation>

<layout_approach>
The content should drive the layout:

- **Dense grids** for information-heavy interfaces where users scan and compare
- **Generous spacing** for focused tasks where users need to concentrate
- **Sidebar navigation** for multi-section apps with many destinations
- **Top navigation** for simpler tools with fewer sections
- **Split panels** for list-detail patterns where context matters
  </layout_approach>

<typography_choices>
Typography sets tone. Don't always default:

- **System fonts** — fast, native, invisible (good for utility-focused products)
- **Geometric sans** (Geist, Inter) — modern, clean, technical
- **Humanist sans** (SF Pro, Satoshi) — warmer, more approachable
- **Monospace influence** — technical, developer-focused, data-heavy
  </typography_choices>

<core_craft_principles>
These apply regardless of design direction. This is the quality floor.

<the_4px_grid>
All spacing uses a 4px base grid:

- `4px` - micro spacing (icon gaps)
- `8px` - tight spacing (within components)
- `12px` - standard spacing (between related elements)
- `16px` - comfortable spacing (section padding)
- `24px` - generous spacing (between sections)
- `32px` - major separation
  </the_4px_grid>

<symmetrical_padding>
**TLBR must match.** If top padding is 16px, left/bottom/right must also be 16px. Exception: when content naturally creates visual balance.

```css
/* Good */
padding: 16px;
padding: 12px 16px; /* Only when horizontal needs more room */

/* Bad */
padding: 24px 16px 12px 16px;
```

</symmetrical_padding>

<border_radius>
Stick to the 4px grid. Sharper corners feel technical, rounder corners feel friendly. Pick a system and commit:

- Sharp: 4px, 6px, 8px
- Soft: 8px, 12px
- Minimal: 2px, 4px, 6px

Don't mix systems. Consistency creates coherence.
</border_radius>

<depth_strategy>
**Match your depth approach to your design direction.** Depth is a tool, not a requirement.

**Borders-only (flat)** — Clean, technical, dense. Works for utility-focused tools where information density matters more than visual lift. Linear, Raycast, and many developer tools use almost no shadows — just subtle borders to define regions. This isn't lazy; it's intentional restraint.

**Subtle single shadows** — Soft lift without complexity. A simple `0 1px 3px rgba(0,0,0,0.08)` can be enough. Works for approachable products that want gentle depth without the weight of layered shadows.

**Layered shadows** — Rich, premium, dimensional. Multiple shadow layers create realistic depth for products that want to feel substantial. Stripe and Mercury use this approach. Best for cards that need to feel like physical objects.

**Surface color shifts** — Background tints establish hierarchy without any shadows. A card at `#fff` on a `#f8fafc` background already feels elevated. Shadows can reinforce this, but color does the heavy lifting.

Choose ONE approach and commit. Mixing flat borders on some cards with heavy shadows on others creates visual inconsistency.

```css
/* Borders-only approach */
--border: rgba(0, 0, 0, 0.08);
--border-subtle: rgba(0, 0, 0, 0.05);
border: 0.5px solid var(--border);

/* Single shadow approach */
--shadow: 0 1px 3px rgba(0, 0, 0, 0.08);

/* Layered shadow approach (when appropriate) */
--shadow-layered:
  0 0 0 0.5px rgba(0, 0, 0, 0.05), 0 1px 2px rgba(0, 0, 0, 0.04),
  0 2px 4px rgba(0, 0, 0, 0.03), 0 4px 8px rgba(0, 0, 0, 0.02);
```

**The craft is in the choice, not the complexity.** A flat interface with perfect spacing and typography is more polished than a shadow-heavy interface with sloppy details.
</depth_strategy>

<card_layouts>
Monotonous card layouts are lazy design. A metric card doesn't have to look like a plan card doesn't have to look like a settings card. One might have a sparkline, another an avatar stack, another a progress ring, another a two-column split.

Design each card's internal structure for its specific content — but keep the surface treatment consistent: same border weight, shadow depth, corner radius, padding scale, typography. Cohesion comes from the container chrome, not from forcing every card into the same layout template.
</card_layouts>

<isolated_controls>
UI controls deserve container treatment. Date pickers, filters, dropdowns — these should feel like crafted objects sitting on the page, not plain text with click handlers.

**Never use native form elements for styled UI.** Native `<select>`, `<input type="date">`, and similar elements render OS-native dropdowns and pickers that cannot be styled. Build custom components instead:

- Custom select: trigger button + positioned dropdown menu
- Custom date picker: input + calendar popover
- Custom checkbox/radio: styled div with state management

**Custom select triggers must use `display: inline-flex` with `white-space: nowrap`** to keep text and chevron icons on the same row. Without this, flex children can wrap to new lines.
</isolated_controls>

<typography_hierarchy>

- Headlines: 600 weight, tight letter-spacing (-0.02em)
- Body: 400-500 weight, standard tracking
- Labels: 500 weight, slight positive tracking for uppercase
- Scale: 11px, 12px, 13px, 14px (base), 16px, 18px, 24px, 32px
  </typography_hierarchy>

<monospace_for_data>
Numbers, IDs, codes, timestamps belong in monospace. Use `tabular-nums` for columnar alignment. Mono signals "this is data."
</monospace_for_data>

<iconography>
Use **Phosphor Icons** (`@phosphor-icons/react`). Icons clarify, not decorate — if removing an icon loses no meaning, remove it.

Give standalone icons presence with subtle background containers.
</iconography>

<animation>
- 150ms for micro-interactions, 200-250ms for larger transitions
- Easing: `cubic-bezier(0.25, 1, 0.5, 1)`
- No spring/bouncy effects in enterprise UI
</animation>

<contrast_hierarchy>
Build a four-level system: foreground (primary) → secondary → muted → faint. Use all four consistently.
</contrast_hierarchy>

<color_for_meaning>
Gray builds structure. Color only appears when it communicates: status, action, error, success. Decorative color is noise.

When building data-heavy interfaces, ask whether each use of color is earning its place. Score bars don't need to be color-coded by performance — a single muted color works. Grade badges don't need traffic-light colors — typography can do the hierarchy work. Look at how GitHub renders tables and lists: almost entirely monochrome, with color reserved for status indicators and actionable elements.
</color_for_meaning>
</core_craft_principles>

<navigation_context>
Screens need grounding. A data table floating in space feels like a component demo, not a product. Consider including:

- **Navigation** — sidebar or top nav showing where you are in the app
- **Location indicator** — breadcrumbs, page title, or active nav state
- **User context** — who's logged in, what workspace/org

When building sidebars, consider using the same background as the main content area. Tools like Supabase, Linear, and Vercel rely on a subtle border for separation rather than different background colors. This reduces visual weight and feels more unified.
</navigation_context>

<dark_mode>
Dark interfaces have different needs:

**Borders over shadows** — Shadows are less visible on dark backgrounds. Lean more on borders for definition. A border at 10-15% white opacity might look nearly invisible but it's doing its job — resist the urge to make it more prominent.

**Adjust semantic colors** — Status colors (success, warning, error) often need to be slightly desaturated or adjusted for dark backgrounds to avoid feeling harsh.

**Same structure, different values** — The hierarchy system (foreground → secondary → muted → faint) still applies, just with inverted values.
</dark_mode>

<anti_patterns>
<never_do>

- Dramatic drop shadows (`box-shadow: 0 25px 50px...`)
- Large border radius (16px+) on small elements
- Asymmetric padding without clear reason
- Pure white cards on colored backgrounds
- Thick borders (2px+) for decoration
- Excessive spacing (margins > 48px between sections)
- Spring/bouncy animations
- Gradients for decoration
- Multiple accent colors in one interface
  </never_do>

<always_question>

- "Did I think about what this product needs, or did I default?"
- "Does this direction fit the context and users?"
- "Does this element feel crafted?"
- "Is my depth strategy consistent and intentional?"
- "Are all elements on the grid?"
  </always_question>
  </anti_patterns>

<agent_verification>
**Programmatic validation for agents:**

Design principles can be verified through code inspection without visual tools:

**Spacing validation (4px grid):**

```bash
# Find non-grid spacing values in CSS/Tailwind
grep -rE "(padding|margin|gap):\s*[0-9]+(px|rem)" --include="*.css" --include="*.tsx" | \
  grep -vE "(4|8|12|16|20|24|28|32|36|40|48|64)px"

# Tailwind: Check for arbitrary values not on grid
grep -rE "\[(padding|margin|gap|space)-\[" --include="*.tsx" | grep -vE "\[[0-9]+(px)?\]"
```

**Symmetrical padding check:**

```bash
# Find asymmetric padding patterns
grep -rE "padding:\s*[0-9]+px\s+[0-9]+px\s+[0-9]+px\s+[0-9]+px" --include="*.css" --include="*.tsx"
```

**Border radius consistency:**

```bash
# List all border-radius values to check for consistency
grep -rhoE "border-radius:\s*[0-9]+px" --include="*.css" | sort | uniq -c | sort -rn

# Tailwind: Check rounded-* usage
grep -rhoE "rounded-[a-z0-9]+" --include="*.tsx" | sort | uniq -c | sort -rn
```

**Shadow/depth strategy validation:**

```bash
# List all shadow values to verify single strategy
grep -rhoE "box-shadow:[^;]+" --include="*.css" | sort | uniq -c

# Tailwind: Check shadow-* usage
grep -rhoE "shadow-[a-z0-9]+" --include="*.tsx" | sort | uniq -c | sort -rn
```

**Typography hierarchy check:**

```bash
# List font sizes to verify scale adherence
grep -rhoE "font-size:\s*[0-9]+px" --include="*.css" | sort | uniq -c | sort -rn

# Tailwind: Check text-* usage
grep -rhoE "text-(xs|sm|base|lg|xl|[0-9]xl)" --include="*.tsx" | sort | uniq -c | sort -rn
```

**Anti-pattern detection:**

```bash
# Large shadows (anti-pattern)
grep -rE "box-shadow:.*25px" --include="*.css" --include="*.tsx"

# Large border-radius on small elements
grep -rE "border-radius:\s*(16|20|24|32)px" --include="*.css"

# Multiple accent colors
grep -rhoE "(bg|text|border)-(blue|green|red|orange|purple|pink)-[0-9]+" --include="*.tsx" | \
  sed 's/-[0-9]*//' | sort -u | wc -l  # Should be 1-2
```

**Design tokens validation:**

```bash
# Verify CSS variables are defined and used consistently
grep -rhE "--[a-z-]+:" --include="*.css" | sort | uniq  # List all tokens
grep -rhE "var\(--" --include="*.tsx" --include="*.css" | sort | uniq -c  # Usage counts
```

**Automated checklist:**

```bash
# Run all checks and report violations
echo "=== Design Validation ==="
echo "Non-grid spacing:" && grep -rE "(padding|margin|gap):\s*[0-9]+(px)" --include="*.css" -c 2>/dev/null || echo "0"
echo "Shadow variations:" && grep -rhoE "box-shadow:[^;]+" --include="*.css" | sort -u | wc -l
echo "Border-radius variations:" && grep -rhoE "border-radius:\s*[0-9]+px" --include="*.css" | sort -u | wc -l
```

**Note:** These checks validate implementation consistency. The initial design direction choice (warm vs cool, dense vs generous) requires understanding product context - agents should use AskUserQuestion to clarify with the user before implementing.
</agent_verification>

<related_skills>

**Comprehensive UI audit:** Load via `Skill({ skill: "devtools:vercel-design-guidelines" })` when:

- Auditing against Vercel's official design guidelines
- Checking accessibility (keyboard, focus, hit targets)
- Reviewing animations and reduced motion support
- Validating form design and error handling
- Checking copywriting and content patterns

**React performance:** Load via `Skill({ skill: "devtools:react-best-practices" })` when:

- Implementing components following performance best practices
- Optimizing bundle size and loading performance
- Implementing data fetching patterns

</related_skills>

<success*criteria>
Every interface should look designed by a team that obsesses over 1-pixel differences. Not stripped — \_crafted*. And designed for its specific context.

- [ ] Design direction explicitly chosen (not defaulted)
- [ ] Color foundation matches product context
- [ ] All spacing on 4px grid (verify with grep)
- [ ] Symmetrical padding applied (verify with grep)
- [ ] Single depth strategy used consistently (verify shadow count)
- [ ] Typography hierarchy established (verify scale adherence)
- [ ] No anti-patterns present (run detection scripts)
- [ ] Color used for meaning only
      </success_criteria>
