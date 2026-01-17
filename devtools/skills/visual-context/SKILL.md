---
name: visual-context
description: Use when building UI, fixing visual bugs, or implementing designs. Leverage screenshots, Figma, and visual context for accurate implementation.
license: MIT
triggers:
  # Intent triggers
  - "fix visual bug"
  - "implement design"
  - "match mockup"
  - "UI looks wrong"
  - "style issue"
  - "layout broken"
  - "doesn't look right"

  # Artifact triggers
  - "screenshot"
  - "Figma"
  - "mockup"
  - "design file"
  - "pixel perfect"
  - "visual diff"
  - "browser preview"
---

<objective>
Maximize visual context when working on UI tasks. A picture is worth a thousand words — requesting and analyzing visual artifacts dramatically improves implementation accuracy and reduces iteration cycles.
</objective>

<essential_principles>

- Request screenshots before attempting visual fixes (don't guess)
- Compare expected vs actual visually, not just in code
- Use browser automation for live visual verification
- Capture visual state at multiple breakpoints for responsive issues
- Document visual requirements with concrete examples, not vague descriptions
</essential_principles>

<constraints>
**Banned:**
- Fixing visual bugs without seeing the actual render
- Implementing designs from text descriptions alone
- Guessing at spacing, colors, or layout without reference
- Marking visual work complete without visual verification

**Required:**

- Screenshot or visual reference before any UI fix
- Visual verification after changes using browser tools
- Explicit comparison of expected vs actual appearance
</constraints>

<anti_patterns>

- **Blind Fixes:** Changing CSS without seeing current vs expected state
- **Description-Only Design:** Implementing from "make it look like X" without seeing X
- **Assumption Cascade:** Assuming you know what "broken" means without visual evidence
- **Single-Viewport Testing:** Checking only desktop when issue might be responsive
- **Code-Only Verification:** Reviewing CSS changes without rendering result
</anti_patterns>

<quick_start>
**Visual context workflow:**

1. **Gather visual context** — Request screenshot, mockup, or Figma reference
2. **Capture current state** — Use Playwright MCP to screenshot current render
3. **Compare and document** — Note specific differences (spacing, color, alignment)
4. **Implement with reference** — Keep visual reference visible while coding
5. **Verify visually** — Screenshot after changes, compare to expected
</quick_start>

<requesting_visual_context>
**When to request screenshots from user:**

- "Can you share a screenshot of the current state?"
- "Do you have a mockup or Figma link for the expected design?"
- "Can you show me what it looks like on mobile/tablet?"
- "What browser/device are you seeing this issue on?"

**Information to gather:**

- Current appearance (screenshot)
- Expected appearance (mockup, reference, or description)
- Browser and viewport size
- Device type if mobile/tablet
- Dark/light mode state
</requesting_visual_context>

<browser_automation_for_visual>
**Use Playwright MCP for visual verification:**

```typescript
// Take screenshot of current state
mcp__plugin_devtools_playwright__browser_take_screenshot({
  name: "current-state",
  fullPage: true,
});

// Navigate and capture specific component
mcp__plugin_devtools_playwright__browser_navigate({
  url: "http://localhost:3000/page",
});
mcp__plugin_devtools_playwright__browser_snapshot();

// Capture at different viewports
mcp__plugin_devtools_playwright__browser_resize({
  width: 375,
  height: 812,
});
mcp__plugin_devtools_playwright__browser_take_screenshot({
  name: "mobile-view",
});
```

**Visual verification checklist:**

- Desktop viewport (1280px+)
- Tablet viewport (768px)
- Mobile viewport (375px)
- Dark mode (if applicable)
- Hover/active states (if interactive)
</browser_automation_for_visual>

<figma_integration>
**Working with Figma designs:**

When user provides Figma link:

1. Ask for specific frame/component screenshot if link is to large file
2. Note exact values: spacing (px), colors (hex), font sizes, border radius
3. Document design tokens in implementation comments

**Extracting design values:**

- Spacing: Request exact padding/margin values
- Colors: Get hex codes or design token names
- Typography: Font family, size, weight, line-height
- Effects: Shadow values, blur, opacity
- Layout: Flex/grid specifics, gap values

**If Figma inaccessible:**

- Ask user to screenshot the specific component/frame
- Request hover to reveal spacing/style values if possible
- Ask for design token values from their design system
</figma_integration>

<visual_debugging>
**Debugging visual issues systematically:**

1. **Isolate the component** — Screenshot just the problem area
2. **Check computed styles** — Use browser DevTools via Playwright
3. **Compare to working state** — Find a similar component that works
4. **Check inheritance** — Parent styles might override
5. **Test in isolation** — Render component alone to rule out context

**Common visual bugs:**

| Symptom | Likely Cause | Visual Check |
|---------|--------------|--------------|
| Overflow/cut off | Container constraints | Screenshot with dev tools overlay |
| Wrong spacing | Margin collapse, padding | Screenshot with layout grid |
| Color mismatch | Wrong token, inheritance | Screenshot with color picker |
| Font issues | Weight, family, size | Screenshot with text highlighted |
| Alignment off | Flexbox/grid issues | Screenshot with alignment guides |
</visual_debugging>

<few_shot_examples>
<example name="visual-bug-fix">
<input>The button text is cut off on mobile</input>
<output>
Before fixing, I need visual context:

1. Can you share a screenshot of the button on mobile?
2. What device/viewport size are you testing on?
3. Is there a design reference for how it should look?

[After receiving screenshot]

I can see the issue - the button has `overflow: hidden` and fixed width. The text "Submit Application" exceeds the container at 375px viewport.

Let me capture the current state and fix it:
[Uses Playwright to screenshot, then applies fix]

After the fix, here's the comparison:
- Before: Text truncated at "Submit App..."
- After: Full text visible with proper padding
</output>
<reasoning>Visual context requested before any code changes. Fix verified visually.</reasoning>
</example>

<example name="design-implementation">
<input>Implement the new card design from Figma</input>
<output>
I'll need the visual reference to implement accurately:

1. Can you share a screenshot or link to the Figma frame?
2. What design tokens should I use (spacing scale, colors)?

[After receiving Figma screenshot]

I can extract from the design:
- Card padding: 24px
- Border radius: 12px
- Shadow: 0 4px 12px rgba(0,0,0,0.08)
- Title: 18px/600 weight
- Gap between elements: 16px

Implementing now with these exact values...

[After implementation]
Let me capture the result and compare to the mockup side-by-side.
</output>
<reasoning>Exact values extracted from visual reference. Implementation verified against mockup.</reasoning>
</example>
</few_shot_examples>

<related_skills>

**Design system:** Load via `Skill({ skill: "devtools:design-principles" })` when:

- Implementing without explicit mockup (need design direction)
- Ensuring consistency with existing design system

**Component library:** Load via `Skill({ skill: "devtools:shadcn" })` when:

- Using shadcn/ui components
- Need component API and variant options

**E2E visual testing:** Load via `Skill({ skill: "devtools:playwright" })` when:

- Setting up visual regression tests
- Automating screenshot comparisons

</related_skills>

<success_criteria>

1. [ ] Visual reference obtained before starting (screenshot, mockup, or Figma)
2. [ ] Current state captured for comparison
3. [ ] Specific visual differences documented (not vague descriptions)
4. [ ] Implementation uses exact values from reference (spacing, colors)
5. [ ] Visual verification performed after changes
6. [ ] Multiple viewports tested if responsive
7. [ ] Before/after comparison documented
</success_criteria>

<evolution>
**Extension Points:**
- Add visual regression testing patterns with Playwright
- Integrate with design token extraction tools
- Add Storybook visual testing workflow

**Timelessness:** Visual verification is fundamental to UI development; the specific tools may change but the principle of "see before you fix" endures.
</evolution>
