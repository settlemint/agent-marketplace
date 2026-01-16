---
name: vercel-design-guidelines
description: Use when reviewing UI, checking accessibility, or auditing design against best practices. Covers Vercel's guidelines for interactions, animations, forms, and a11y.
license: MIT
triggers:
  # Intent triggers
  - "review my UI"
  - "check accessibility"
  - "audit design"
  - "review UX"
  - "check against best practices"
  - "improve UI"

  # Artifact triggers
  - "vercel design"
  - "vercel guidelines"
  - "a11y audit"
  - "wcag"
  - "keyboard navigation"
  - "focus management"
  - "hit target"
  - "color contrast"
  - "reduced motion"
---

<objective>
Review web interfaces against Vercel's comprehensive design guidelines and propose fixes. Analyze code for interactions, animations, layout, content, forms, performance, design, and copywriting compliance.
</objective>

<quick_start>

1. Fetch fresh guidelines from `https://vercel.com/design/guidelines`
2. Read user's source files (components, styles, HTML)
3. Check against each applicable guideline category
4. Report violations with specific line references
5. Propose concrete fixes with code examples
   </quick_start>

<constraints>
<banned>
- Never skip accessibility checks
- Never approve designs without verifying keyboard navigation
- Never ignore `prefers-reduced-motion` requirements
- Never use `transition: all` in recommendations
- Never recommend disabled zoom
- Never skip form label associations
</banned>
<required>
- Always fetch fresh guidelines before auditing
- Always report issues with file:line references
- Always categorize findings by severity (Critical/Warning/Suggestion)
- Always provide concrete code fixes
- Always check APCA color contrast standards
- Always verify hit targets meet minimum sizes
</required>
</constraints>

<audit_categories>
<category name="Interactions">
Keyboard accessibility, focus management, hit targets, loading states, URL persistence
</category>
<category name="Animations">
Reduced motion, GPU acceleration, easing, interruptibility
</category>
<category name="Layout">
Optical adjustment, alignment, responsive testing, safe areas
</category>
<category name="Content">
Inline help, skeletons, empty states, typography, accessibility
</category>
<category name="Forms">
Labels, validation, autocomplete, error handling, submit behavior
</category>
<category name="Performance">
Re-renders, layout thrashing, virtualization, preloading
</category>
<category name="Design">
Shadows, borders, radii, contrast, color accessibility
</category>
<category name="Copywriting">
Active voice, title case, clarity, error messaging
</category>
</audit_categories>

<workflow>
<step name="fetch_guidelines">
Fetch the live guidelines from `https://vercel.com/design/guidelines` to ensure checking against latest standards.
</step>
<step name="read_source">
Read the relevant source files (components, styles, HTML) from the user's codebase.
</step>
<step name="analyze">
Analyze the code against each applicable guideline category.
</step>
<step name="report">
Report findings grouped by category with severity levels:
- **Critical**: Accessibility violations, broken functionality
- **Warning**: UX issues, performance concerns
- **Suggestion**: Polish, best practices
</step>
<step name="propose_fixes">
Provide concrete code fixes for each violation found.
</step>
</workflow>

<output_format>
Present findings as:

````
## {Category} Issues

### {Severity}: {Guideline Name}
**File:** `path/to/file.tsx:42`
**Issue:** {Description of the violation}
**Guideline:** {Brief guideline reference}
**Fix:**
```{language}
{Proposed code fix}
````

```

Final summary format:

```

# Design Guidelines Audit

Reviewed {N} files against Vercel design guidelines.

## Summary

- Critical: {N} issues
- Warning: {N} issues
- Suggestions: {N} items

{Detailed findings by category}

## Recommended Priority

1. {First critical fix}
2. {Second critical fix}
   ...

````
</output_format>

<examples>
<example name="interactions_critical">
## Interactions Issues

### Critical: Keyboard Accessibility
**File:** `components/Modal.tsx:28`
**Issue:** Modal lacks focus trap - keyboard users can tab outside
**Guideline:** Implement focus traps per WAI-ARIA patterns
**Fix:**
```tsx
// Add focus trap using @radix-ui/react-focus-guards or similar
import { FocusScope } from "@radix-ui/react-focus-scope";

<FocusScope trapped>
  <ModalContent>{children}</ModalContent>
</FocusScope>;
````

</example>

<example name="loading_state_warning">
### Warning: Loading State Duration
**File:** `components/Button.tsx:15`
**Issue:** No minimum loading duration - causes flicker on fast responses
**Guideline:** Add 150-300ms delay and 300-500ms minimum visibility
**Fix:**
```tsx
const [isLoading, setIsLoading] = useState(false);
const minimumLoadingTime = 300;

async function handleClick() {
setIsLoading(true);
const start = Date.now();
await action();
const elapsed = Date.now() - start;
if (elapsed < minimumLoadingTime) {
await new Promise((r) => setTimeout(r, minimumLoadingTime - elapsed));
}
setIsLoading(false);
}

````
</example>
</examples>

<quick_checklist>
For rapid reviews, check these high-impact items first:

- [ ] All interactive elements keyboard accessible
- [ ] Visible focus rings on focusable elements
- [ ] Hit targets >= 24px (44px on mobile)
- [ ] Form inputs have associated labels
- [ ] Loading states don't flicker
- [ ] `prefers-reduced-motion` respected
- [ ] No `transition: all`
- [ ] Errors show how to fix, not just what's wrong
- [ ] Color contrast meets APCA standards
- [ ] No zoom disabled
</quick_checklist>

<anti_patterns>
<anti_pattern name="missing_focus_trap">
Modals and dialogs without focus trapping allow keyboard users to navigate outside, breaking accessibility.
</anti_pattern>
<anti_pattern name="transition_all">
Using `transition: all` causes performance issues and unexpected animations on unintended properties.
</anti_pattern>
<anti_pattern name="disabled_zoom">
Setting `user-scalable=no` or `maximum-scale=1` prevents users with low vision from zooming.
</anti_pattern>
<anti_pattern name="unlabeled_inputs">
Form inputs without associated `<label>` elements fail screen reader accessibility requirements.
</anti_pattern>
<anti_pattern name="flicker_loading">
Loading states that appear and disappear too quickly cause jarring visual flicker.
</anti_pattern>
<anti_pattern name="ignore_reduced_motion">
Animations that don't respect `prefers-reduced-motion` can cause vestibular issues for users.
</anti_pattern>
<anti_pattern name="small_hit_targets">
Interactive elements smaller than 24px (44px on mobile) are difficult for users to tap accurately.
</anti_pattern>
</anti_patterns>

<research>
Find accessibility and design patterns on GitHub when stuck:

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find accessibility and UX patterns",
      researchGoal: "Search for focus management and ARIA patterns",
      reasoning: "Need real-world examples of accessible UI",
      keywordsToSearch: ["FocusScope", "aria-", "focus-trap"],
      extension: "tsx",
      limit: 10,
    },
  ],
});
````

Common searches:

- Focus management: `keywordsToSearch: ["FocusScope", "focus-trap", "tabIndex"]`
- Animations: `keywordsToSearch: ["prefers-reduced-motion", "motion-safe"]`
- Loading states: `keywordsToSearch: ["Skeleton", "loading", "suspense"]`
- Forms: `keywordsToSearch: ["aria-invalid", "aria-describedby", "form"]`
  </research>

<related_skills>
<skill name="devtools:design-principles">
Load when building components following design system patterns or making color, spacing, and typography decisions.
</skill>
<skill name="devtools:react-best-practices">
Load when optimizing component rendering or implementing data fetching patterns.
</skill>
<skill name="devtools:radix">
Load when building accessible UI primitives or implementing compound components.
</skill>
</related_skills>

<success_criteria>

- [ ] Fresh guidelines fetched before audit
- [ ] All audit categories checked against code
- [ ] Findings include file:line references
- [ ] Each violation has severity classification
- [ ] Concrete code fixes provided for all issues
- [ ] Summary includes issue counts by severity
- [ ] Priority recommendations given for critical fixes
- [ ] Accessibility violations marked as Critical
- [ ] User can act on findings without further research
      </success_criteria>

<evolution>
<extension_point name="custom_categories">
Add project-specific guideline categories by extending audit_categories with team standards.
</extension_point>
<extension_point name="severity_rules">
Customize severity classification based on project requirements (e.g., all a11y issues as Critical).
</extension_point>
<extension_point name="output_formats">
Extend output_format to support different reporting styles (JSON, GitHub issues, Jira tickets).
</extension_point>
<extension_point name="automation">
Integrate with CI/CD to run design audits on pull requests automatically.
</extension_point>
</evolution>
