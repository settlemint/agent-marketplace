---
name: shadcn
description: Use when adding UI components, building forms, or working with shadcn primitives. Covers shadcn/ui installation, cn() utility, CVA variants, and theming.
license: MIT
triggers:
  # Intent triggers
  - "add shadcn component"
  - "install shadcn"
  - "build form with shadcn"
  - "create button variant"
  - "add ui component"

  # Artifact triggers
  - "shadcn"
  - "@/components/ui"
  - "cn\\("
  - "cva"
  - "VariantProps"
  - "lucide"
  - "npx shadcn"
  - "data-slot"
---

<objective>
Build and customize shadcn/ui components using the shadcn MCP server for discovery and installation. This skill provides patterns for component usage, customization with CVA variants, form integration, and theming.
</objective>

<essential_principles>

- Use shadcn MCP server for component discovery and installation
- Import from `@/components/ui/[component]` (not barrel imports)
- Use `cn()` for all className composition
- Use CVA for variant-based components
- Use CSS variables for theming (no hardcoded colors)
  </essential_principles>

<mcp_first>
**CRITICAL: Use the shadcn MCP server for component discovery and installation.**

The shadcn MCP server is auto-configured via the devtools plugin. Use natural language:

```
"Show me all available components in the shadcn registry"
"Add button, dialog and card components"
"Create a contact form using shadcn components"
```

</mcp_first>

<quick_start>
**Step 1: Import and use components**

```typescript
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { cn } from "@/lib/utils";

export function MyComponent() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Title</CardTitle>
      </CardHeader>
      <CardContent>
        <Button variant="outline">Click me</Button>
      </CardContent>
    </Card>
  );
}
```

**Step 2: Use cn() for conditional classes**

```typescript
className={cn("base-class", isActive && "active-class")}
className={cn(buttonVariants({ variant, size }), className)}
```

</quick_start>

<reference_index>
| Reference | Content |
|-----------|---------|
| component-exports.md | All component exports (Button, Card, Dialog, Select, etc.) |
| accessibility-patterns.md | Focus states, ARIA attributes, keyboard navigation, icons |
| anti-patterns.md | Wrong imports, missing cn(), native elements, hardcoded colors |
</reference_index>

<template_index>
| Template | Purpose |
|----------|---------|
| cn-utility.ts.md | Setup and usage patterns for cn() |
| cva-component.tsx.md | CVA variant component pattern |
| compound-component.tsx.md | Compound component with data-slot |
| form-field.tsx.md | Form field wrapper with accessibility |
| theme-variables.css.md | Light/dark theme CSS variables |
</template_index>

<theming>
**shadcn uses CSS variables for theming.**

```typescript
// Reference in Tailwind
className = "bg-background text-foreground";
className = "bg-primary text-primary-foreground";
className = "bg-muted text-muted-foreground";
```

See `templates/theme-variables.css.md` for complete light/dark theme setup.
</theming>

<icons>
**Use lucide-react for icons.**

```typescript
import { ChevronDown, Check, X, Search, Settings } from "lucide-react";

<Button>
  <Settings className="mr-2 h-4 w-4" />
  Settings
</Button>
```

</icons>

<constraints>
**Required:**

- Import from `@/components/ui/[component]`
- Use `cn()` for all className composition
- Export prop types for custom components
- Support className override in all components

**Banned:**

- Inline styles (use Tailwind)
- Native form elements in styled UI (use custom components)
- Hardcoded colors (use CSS variables)
- Components > 150 lines
  </constraints>

<anti_patterns>
**Common mistakes to avoid:**

- Importing from barrel files instead of `@/components/ui/[name]`
- String concatenation for classes instead of `cn()`
- Native `<button>` and `<input>` instead of shadcn components
- Hardcoded hex colors instead of CSS variables
- Missing `className` prop forwarding in wrapper components
  </anti_patterns>

<library_ids>
Skip resolve step for these known IDs:

| Library   | Context7 ID               |
| --------- | ------------------------- |
| shadcn/ui | /shadcn/ui                |
| Radix UI  | /radix-ui/primitives      |
| Tailwind  | /tailwindlabs/tailwindcss |
| CVA       | /joe-bell/cva             |

</library_ids>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production shadcn/ui patterns",
      researchGoal: "Search for component composition patterns",
      reasoning: "Need real-world examples of shadcn customization",
      keywordsToSearch: ["shadcn", "components/ui", "cva"],
      extension: "tsx",
      limit: 10,
    },
  ],
});
```

</research>

<related_skills>

**Design guidelines:** Load via `Skill({ skill: "devtools:vercel-design-guidelines" })` when:

- Auditing UI for accessibility compliance
- Checking interactions, animations, and form design

**Design system:** Load via `Skill({ skill: "devtools:design-principles" })` when:

- Setting up design direction and color foundations
- Establishing spacing, typography, and depth strategies

</related_skills>

<success_criteria>

1. [ ] shadcn MCP server used for component discovery/installation
2. [ ] Components imported from `@/components/ui/[name]`
3. [ ] `cn()` used for all className composition
4. [ ] CVA used for variant-based components
5. [ ] CSS variables used for theming (no hardcoded colors)
6. [ ] Accessibility attributes included (aria-*, focus-visible)
</success_criteria>

<evolution>
**Extension Points:**

- Add custom component variants via CVA for project needs
- Create domain-specific compound components
- Extend theming with additional CSS variables

**Timelessness:** Copy-paste component libraries with utility-first styling represent the modern approach to design systems.
</evolution>
