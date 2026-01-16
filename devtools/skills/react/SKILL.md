---
name: react
description: React 19 components with Tailwind CSS v4. Use when asked to "create component", "build form", or "add data table". Covers shadcn/ui, forms, tables, routing, and data fetching.
license: MIT
triggers: [
    # File extensions and imports
    "\\.tsx$",
    "\\.jsx$",
    'from [''"]react[''"]',
    "import.*React",

    # React core concepts
    "react\\s*(19|component|hook|state|prop|context)",
    "\\b(useState|useEffect|useRef|useMemo|useCallback|useContext|useReducer)\\b",
    "\\b(use\\s+hook|custom\\s+hook|create\\s+hook)\\b",
    "\\b(jsx|tsx|functional\\s+component|class\\s+component)\\b",
    "\\b(server\\s+component|client\\s+component|rsc)\\b",
    "\\b(suspense|lazy|concurrent)\\b",

    # TanStack libraries
    "tanstack",
    "@tanstack/(router|query|form|table)",
    "\\b(useQuery|useMutation|queryClient)\\b",
    "\\b(useForm|form\\s+validation|field\\s+validation)\\b",
    "\\b(useReactTable|columnDef|data\\s+table)\\b",
    "\\b(createFileRoute|useNavigate|file.?based\\s+routing)\\b",

    # Tailwind CSS
    "tailwind(css)?",
    "\\bcn\\s*\\(",
    "class.?name.*=",
    "\\b(utility\\s+classes|responsive\\s+design)\\b",

    # Component patterns
    "\\b(build|create|make|add|write)\\s+(a\\s+)?component\\b",
    "\\b(button|card|modal|dialog|dropdown|menu|nav|header|footer|sidebar)\\s+component\\b",
    "\\b(form|input|select|checkbox|radio|textarea)\\s+(component|field)\\b",
    "\\b(list|grid|layout|container)\\s+component\\b",

    # UI/Frontend general
    "\\b(ui|frontend|front.?end|user\\s+interface)\\b",
    "\\b(render|display|show)\\s+(data|content|list|table)\\b",
    "\\b(styled?|styling|css.?in.?js)\\b",

    # Common typos
    "\\breact[0-9]*\\b",
    "\\btailwnd\\b",
    "\\btanstak\\b",
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
**Step 1: Load Context7 MCP tool**

```
MCPSearch({ query: "select:mcp__plugin_devtools_context7__query-docs" })
```

**Step 2: Fetch docs for your task (use natural language queries)**

```typescript
// React 19 patterns
mcp__context7__query_docs({
  libraryId: "/reactjs/react.dev",
  query:
    "How do I use the new use hook, server components, and actions in React 19?",
});

// Tailwind v4
mcp__context7__query_docs({
  libraryId: "/tailwindlabs/tailwindcss",
  query: "How do I configure theme colors in Tailwind v4?",
});

// TanStack Router
mcp__context7__query_docs({
  libraryId: "/tanstack/router",
  query: "How do I use createFileRoute and useNavigate?",
});

// TanStack Query
mcp__context7__query_docs({
  libraryId: "/tanstack/query",
  query: "How do I use useQuery, useMutation, and queryClient?",
});

// TanStack Form
mcp__context7__query_docs({
  libraryId: "/tanstack/form",
  query: "How do I use useForm with field validation?",
});

// TanStack Table
mcp__context7__query_docs({
  libraryId: "/tanstack/table",
  query: "How do I use useReactTable with columnDef?",
});
```

**Note:** Context7 v2 uses server-side filtering for 65% fewer tokens. Pass descriptive natural language queries for best results.

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

<anti_patterns>
**Common mistakes to avoid:**

- Using `useEffect` for derived state (compute inline or useMemo)
- Barrel file re-exports causing bundle bloat
- Components over 150 lines without decomposition
- Inline styles instead of Tailwind utility classes
- Creating new components when existing UI primitives suffice
  </anti_patterns>

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

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production React 19 patterns",
      researchGoal: "Search for server component and action patterns",
      reasoning: "Need real-world examples of React 19 features",
      keywordsToSearch: ["use server", "server component", "React 19"],
      extension: "tsx",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Server components: `keywordsToSearch: ["use client", "server component"]`
- TanStack patterns: `keywordsToSearch: ["useQuery", "queryClient"]`
- Form handling: `keywordsToSearch: ["useForm", "TanStack Form"]`
  </research>

<lsp_for_components>
**Use LSP for React codebase navigation:**

LSP tools help navigate component hierarchies and understand prop drilling:

- `lspGotoDefinition(lineHint)` - Jump to component implementations from JSX usage
- `lspFindReferences(lineHint)` - Find all places a component is rendered
- `lspCallHierarchy(lineHint)` - Trace hook usage and data flow

**Workflow:**

1. Grep for component name → get lineHint
2. `lspFindReferences` → find all render locations
3. `lspGotoDefinition` → jump to component source

**CRITICAL:** Always search first to get `lineHint` (1-indexed line number). Never call LSP tools without a lineHint from search results.

**When to use:**

- Finding where a component is used → `lspFindReferences`
- Jumping to component definition → `lspGotoDefinition`
- Understanding prop drilling → `lspCallHierarchy`

Load LSP skill for detailed patterns: `Skill({ skill: "devtools:typescript-lsp" })`
</lsp_for_components>

<related_skills>

**Performance optimization:** Load via `Skill({ skill: "devtools:react-best-practices" })` when:

- Optimizing React/Next.js bundle size
- Eliminating data fetching waterfalls
- Improving re-render performance
- Using Suspense, `React.cache()`, or transitions

**UI design audit:** Load via `Skill({ skill: "devtools:vercel-design-guidelines" })` when:

- Reviewing UI for accessibility issues
- Checking design compliance against best practices
- Auditing interactions, animations, and layout

</related_skills>

<success_criteria>

1. [ ] Context7 docs fetched before implementation
2. [ ] Component under 150 lines, max 5 props
3. [ ] Uses Tailwind (no inline styles)
4. [ ] Exports prop types
5. [ ] Uses existing UI primitives where available
</success_criteria>

<evolution>
**Extension Points:**

- Add domain-specific component patterns as project grows
- Integrate new TanStack libraries as they release
- Extend with custom hooks for project-specific logic

**Timelessness:** Component composition, state management, and data fetching patterns transcend specific React versions.
</evolution>
