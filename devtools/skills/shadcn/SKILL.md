---
name: shadcn
description: shadcn/ui component library with MCP server integration. Use when adding UI components, building forms, or working with shadcn primitives. Triggers on shadcn, @/components/ui, cn(), radix, cva, component variants.
triggers:
  [
    "shadcn",
    "components/ui",
    "cn(",
    "radix",
    "cva",
    "buttonVariants",
    "CardHeader",
    "DialogContent",
  ]
---

<objective>
Build and customize shadcn/ui components using the shadcn MCP server for discovery and installation. This skill provides patterns for component usage, customization with CVA variants, form integration, and theming.
</objective>

<mcp_first>
**CRITICAL: Use the shadcn MCP server for component discovery and installation.**

The shadcn MCP server enables browsing, searching, and installing components via natural language. Always use it before manually creating components.
</mcp_first>

<quick_start>
**Step 1: Use MCP for component operations**

The shadcn MCP server is auto-configured via the devtools plugin. Use natural language:

```
"Show me all available components in the shadcn registry"
"Add button, dialog and card components"
"Create a contact form using shadcn components"
"Search for a date picker component"
```

**Step 2: Import and use components**

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

</quick_start>

<cn_utility>
**Always use `cn()` for class management.**

See `templates/cn-utility.ts.md` for setup and usage patterns.

```typescript
className={cn("base-class", isActive && "active-class")}
className={cn(buttonVariants({ variant, size }), className)}
```

</cn_utility>

<cva_variants>
**Use CVA (Class Variance Authority) for component variants.**

See `templates/cva-component.tsx.md` for full pattern with placeholders.

```typescript
import { cva, type VariantProps } from "class-variance-authority";

const buttonVariants = cva("base-styles", {
  variants: {
    variant: { default: "...", outline: "..." },
    size: { default: "...", sm: "...", lg: "..." },
  },
  defaultVariants: { variant: "default", size: "default" },
});
```

</cva_variants>

<compound_components>
**Build compound components with data-slot attributes.**

See `templates/compound-component.tsx.md` for full pattern with placeholders.

```typescript
function Card({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div data-slot="card" className={cn("rounded-xl border bg-card", className)} {...props} />
  );
}
// CardHeader, CardTitle, CardContent, CardFooter follow same pattern
```

</compound_components>

<as_child_pattern>
**Support polymorphic rendering with asChild and Radix Slot.**

```typescript
import { Slot } from "@radix-ui/react-slot";

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  asChild?: boolean;
}

function Button({ className, variant, size, asChild = false, ...props }: ButtonProps) {
  const Comp = asChild ? Slot : "button";
  return (
    <Comp
      className={cn(buttonVariants({ variant, size, className }))}
      {...props}
    />
  );
}

// Usage: render as link
<Button asChild>
  <a href="/dashboard">Go to Dashboard</a>
</Button>
```

</as_child_pattern>

<common_components>
**Core components and their exports:**

| Component    | Exports                                                                                                                       |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| Button       | `Button`, `buttonVariants`                                                                                                    |
| Card         | `Card`, `CardHeader`, `CardTitle`, `CardDescription`, `CardContent`, `CardFooter`                                             |
| Dialog       | `Dialog`, `DialogTrigger`, `DialogContent`, `DialogHeader`, `DialogTitle`, `DialogDescription`, `DialogFooter`, `DialogClose` |
| Select       | `Select`, `SelectTrigger`, `SelectValue`, `SelectContent`, `SelectItem`, `SelectGroup`, `SelectLabel`                         |
| Input        | `Input`                                                                                                                       |
| Checkbox     | `Checkbox`                                                                                                                    |
| Tabs         | `Tabs`, `TabsList`, `TabsTrigger`, `TabsContent`                                                                              |
| Accordion    | `Accordion`, `AccordionItem`, `AccordionTrigger`, `AccordionContent`                                                          |
| Alert        | `Alert`, `AlertTitle`, `AlertDescription`                                                                                     |
| Badge        | `Badge`, `badgeVariants`                                                                                                      |
| Sheet        | `Sheet`, `SheetTrigger`, `SheetContent`, `SheetHeader`, `SheetTitle`, `SheetDescription`                                      |
| Command      | `Command`, `CommandInput`, `CommandList`, `CommandEmpty`, `CommandGroup`, `CommandItem`                                       |
| Popover      | `Popover`, `PopoverTrigger`, `PopoverContent`                                                                                 |
| DropdownMenu | `DropdownMenu`, `DropdownMenuTrigger`, `DropdownMenuContent`, `DropdownMenuItem`, `DropdownMenuSeparator`                     |

</common_components>

<theming>
**shadcn uses CSS variables for theming.**

See `templates/theme-variables.css.md` for complete light/dark theme setup.

```typescript
// Reference in Tailwind
className = "bg-background text-foreground";
className = "bg-primary text-primary-foreground";
className = "bg-muted text-muted-foreground";
```

</theming>

<accessibility>
**Built-in accessibility patterns:**

```typescript
// Focus rings
className =
  "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2";

// Invalid state
className = "aria-invalid:border-destructive aria-invalid:ring-destructive/20";

// Disabled state
className = "disabled:pointer-events-none disabled:opacity-50";

// Screen reader only
className = "sr-only";

// Focus within group
className = "group-focus-within:ring-2";
```

ARIA attributes:

```typescript
<Input aria-invalid={!!errors} aria-describedby={`${id}-error`} />
<div role="alert" id={`${id}-error`}>{error}</div>
```

</accessibility>

<icons>
**Use lucide-react for icons.**

```typescript
import { ChevronDown, Check, X, Search, Settings } from "lucide-react";

// In components
<Button>
  <Settings className="mr-2 h-4 w-4" />
  Settings
</Button>

// Icon sizing pattern in shadcn components
className="[&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0"
```

</icons>

<form_integration>
**Wrap shadcn components for form fields.**

See `templates/form-field.tsx.md` for text/select field wrappers with accessibility.

```typescript
<TextField label="Email" name="email" error={errors.email} required />
```

</form_integration>

<directory_structure>
**Standard component organization:**

```
src/components/
├── ui/                    # shadcn primitives (47+ components)
│   ├── button.tsx
│   ├── card.tsx
│   ├── dialog.tsx
│   ├── input.tsx
│   ├── select.tsx
│   └── ...
├── form/                  # Form field wrappers
│   ├── text-field.tsx
│   ├── select-field.tsx
│   └── checkbox-field.tsx
└── [feature]/             # Feature-specific compositions
```

</directory_structure>

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
<pitfall name="wrong_imports">

```typescript
// Wrong - barrel imports
import { Button, Card } from "@/components/ui";

// Correct - direct imports
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
```

</pitfall>

<pitfall name="missing_cn">
```typescript
// Wrong - string concatenation
className={`base-class ${isActive ? "active" : ""}`}

// Correct - cn utility
className={cn("base-class", isActive && "active")}

````
</pitfall>

<pitfall name="native_form_elements">
```typescript
// Wrong - native select (can't be styled)
<select>{options}</select>

// Correct - shadcn Select
<Select>
  <SelectTrigger>
    <SelectValue />
  </SelectTrigger>
  <SelectContent>
    {options.map(opt => <SelectItem key={opt} value={opt}>{opt}</SelectItem>)}
  </SelectContent>
</Select>
````

</pitfall>
</anti_patterns>

<related_skills>

**Design guidelines:** Load via `Skill({ skill: "devtools:vercel-design-guidelines" })` when:

- Auditing UI for accessibility compliance
- Checking interactions, animations, and form design
- Reviewing copywriting and content patterns

**Design system:** Load via `Skill({ skill: "devtools:design-principles" })` when:

- Setting up design direction and color foundations
- Establishing spacing, typography, and depth strategies
- Building consistent card layouts and navigation

</related_skills>

<success_criteria>

- [ ] shadcn MCP server used for component discovery/installation
- [ ] Components imported from `@/components/ui/[name]`
- [ ] `cn()` used for all className composition
- [ ] CVA used for variant-based components
- [ ] CSS variables used for theming (no hardcoded colors)
- [ ] Accessibility attributes included (aria-\*, focus-visible)
- [ ] Component under 150 lines
      </success_criteria>
