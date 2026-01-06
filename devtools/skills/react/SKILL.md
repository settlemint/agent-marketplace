---
name: react
description: React 19 components with Tailwind CSS v4, shadcn/ui, forms, tables, routing, data fetching, and i18n. Triggers on .tsx files, component, tailwind, tanstack, form, table, router.
triggers:
  [
    "\\.tsx",
    "component",
    "tailwind",
    "tanstack",
    "form",
    "table",
    "router",
    "react",
    "shadcn",
  ]
---

<objective>
Build React 19 components with Tailwind CSS v4, TanStack libraries (Router, Query, Form, Table), and shadcn/ui primitives. This skill consolidates all frontend development patterns.
</objective>

<mcp_first>
**CRITICAL: Always fetch documentation before implementing.**

This skill depends heavily on Context7 MCP for up-to-date API documentation. React 19 and Tailwind v4 have significant API changes from previous versions.
</mcp_first>

<quick_start>
**Step 1: Load Context7 MCP tools**

```
MCPSearch({ query: "select:mcp__plugin_devtools_context7__resolve-library-id" })
MCPSearch({ query: "select:mcp__plugin_devtools_context7__query-docs" })
```

**Step 2: Fetch docs for your task**

```typescript
// React 19 patterns
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/reactjs/react.dev",
  topic: "use hook server components actions",
});

// Tailwind v4
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/tailwindlabs/tailwindcss",
  topic: "v4 theme colors",
});

// TanStack Router
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/tanstack/router",
  topic: "createFileRoute useNavigate",
});

// TanStack Query
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/tanstack/query",
  topic: "useQuery useMutation queryClient",
});

// TanStack Form
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/tanstack/form",
  topic: "useForm field validation",
});

// TanStack Table
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/tanstack/table",
  topic: "useReactTable columnDef",
});
```

**Step 3: Implement with verified patterns**

**Component template:** See `templates/component.tsx.md` for scaffolding.
</quick_start>

<library_ids>
Skip resolve step for these known IDs:

| Library         | Context7 ID               |
| --------------- | ------------------------- |
| React           | /reactjs/react.dev        |
| Tailwind CSS    | /tailwindlabs/tailwindcss |
| TanStack Router | /tanstack/router          |
| TanStack Query  | /tanstack/query           |
| TanStack Form   | /tanstack/form            |
| TanStack Table  | /tanstack/table           |
| Radix UI        | /radix-ui/primitives      |

</library_ids>

<constraints>
**Banned:**
- Components >150 lines, >5 props
- Inline styles (use Tailwind)
- `useEffect` for derived state
- `any` type
- CSS class selectors
- Re-exports via barrel files (import from canonical source)
- `import { X } from "@pkg"` (wrong - use `import { X } from "@pkg/module"`)
- Abstractions for one-time operations
- Helpers for code used once
- Backwards-compatibility shims

**Required:**

- Check existing components before creating new ones
- Use Tailwind for all styling (no inline styles)
- Export prop types for all components
- Use `cn()` utility for conditional classes
- Import directly from source files, not index barrels
- Prefer simplest change possible
- Delete unused code completely (no `_unused` prefixes)

**Naming:** Components=`PascalCase`, files=`kebab-case.tsx`, props=`<Component>Props`
</constraints>

<routing>
| Task | Action |
|------|--------|
| Create component | Fetch React + Tailwind docs first |
| Build form | Fetch TanStack Form docs |
| Build table | Fetch TanStack Table docs |
| Add routing | Fetch TanStack Router docs |
| Data fetching | Fetch TanStack Query docs |
| i18n | Check existing translation patterns |
</routing>

<component_pattern>

```typescript
import { type ComponentProps } from "react";
import { cn } from "@/lib/utils";

interface MyComponentProps {
  title: string;
  children: React.ReactNode;
  variant?: "default" | "compact";
}

export function MyComponent({
  title,
  children,
  variant = "default"
}: MyComponentProps) {
  return (
    <div className={cn(
      "rounded-lg border p-4",
      variant === "compact" && "p-2"
    )}>
      <h3 className="text-lg font-semibold">{title}</h3>
      {children}
    </div>
  );
}
```

</component_pattern>

<success_criteria>

- [ ] Context7 docs fetched before implementation
- [ ] Component under 150 lines, max 5 props
- [ ] Uses Tailwind (no inline styles)
- [ ] Exports prop types
- [ ] Uses existing UI primitives where available
      </success_criteria>
