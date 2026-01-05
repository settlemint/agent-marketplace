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

```typescript
import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

Usage patterns:

```typescript
// Conditional classes
className={cn("base-class", isActive && "active-class")}

// Override with custom classes
className={cn(buttonVariants({ variant, size }), className)}

// Multiple conditions
className={cn(
  "rounded-lg border p-4",
  variant === "compact" && "p-2",
  isDisabled && "opacity-50 cursor-not-allowed"
)}
```

</cn_utility>

<cva_variants>
**Use CVA (Class Variance Authority) for component variants.**

```typescript
import { cva, type VariantProps } from "class-variance-authority";

const buttonVariants = cva(
  // Base styles (always applied)
  "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive:
          "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline:
          "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        secondary:
          "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  },
);

interface ButtonProps
  extends
    React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}
```

</cva_variants>

<compound_components>
**Build compound components with data-slot attributes.**

```typescript
function Card({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="card"
      className={cn("rounded-xl border bg-card text-card-foreground shadow", className)}
      {...props}
    />
  );
}

function CardHeader({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="card-header"
      className={cn("flex flex-col space-y-1.5 p-6", className)}
      {...props}
    />
  );
}

function CardTitle({ className, ...props }: React.ComponentProps<"h3">) {
  return (
    <h3
      data-slot="card-title"
      className={cn("text-2xl font-semibold leading-none tracking-tight", className)}
      {...props}
    />
  );
}

function CardContent({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="card-content"
      className={cn("p-6 pt-0", className)}
      {...props}
    />
  );
}

export { Card, CardHeader, CardTitle, CardContent };
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

```css
/* app.css or globals.css */
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  --card: 0 0% 100%;
  --card-foreground: 222.2 84% 4.9%;
  --primary: 222.2 47.4% 11.2%;
  --primary-foreground: 210 40% 98%;
  --secondary: 210 40% 96.1%;
  --secondary-foreground: 222.2 47.4% 11.2%;
  --muted: 210 40% 96.1%;
  --muted-foreground: 215.4 16.3% 46.9%;
  --accent: 210 40% 96.1%;
  --accent-foreground: 222.2 47.4% 11.2%;
  --destructive: 0 84.2% 60.2%;
  --destructive-foreground: 210 40% 98%;
  --border: 214.3 31.8% 91.4%;
  --input: 214.3 31.8% 91.4%;
  --ring: 222.2 84% 4.9%;
  --radius: 0.5rem;
}

.dark {
  --background: 222.2 84% 4.9%;
  --foreground: 210 40% 98%;
  /* ... dark mode values */
}
```

Reference in Tailwind:

```typescript
className = "bg-background text-foreground border-border";
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

```typescript
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

interface TextFieldProps {
  label: string;
  name: string;
  error?: string;
  required?: boolean;
}

export function TextField({ label, name, error, required, ...props }: TextFieldProps) {
  return (
    <div className="space-y-2">
      <Label htmlFor={name}>
        {label}
        {required && <span className="text-destructive ml-1">*</span>}
      </Label>
      <Input
        id={name}
        name={name}
        aria-invalid={!!error}
        aria-describedby={error ? `${name}-error` : undefined}
        className={cn(error && "border-destructive")}
        {...props}
      />
      {error && (
        <p id={`${name}-error`} className="text-sm text-destructive">
          {error}
        </p>
      )}
    </div>
  );
}
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

<success_criteria>

- [ ] shadcn MCP server used for component discovery/installation
- [ ] Components imported from `@/components/ui/[name]`
- [ ] `cn()` used for all className composition
- [ ] CVA used for variant-based components
- [ ] CSS variables used for theming (no hardcoded colors)
- [ ] Accessibility attributes included (aria-\*, focus-visible)
- [ ] Component under 150 lines
      </success_criteria>
