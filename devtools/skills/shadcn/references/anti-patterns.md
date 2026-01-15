# Anti-Patterns

## Wrong Imports

```typescript
// Wrong - barrel imports (bad for tree shaking)
import { Button, Card } from "@/components/ui";

// Correct - direct imports
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
```

## Missing cn()

```typescript
// Wrong - string concatenation (loses Tailwind conflict resolution)
className={`base-class ${isActive ? "active" : ""}`}

// Correct - cn utility (handles conflicts, falsy values)
className={cn("base-class", isActive && "active")}
```

## Native Form Elements

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
```

## Hardcoded Colors

```typescript
// Wrong - hardcoded colors (breaks theming)
className = "bg-gray-100 text-gray-900";

// Correct - CSS variables
className = "bg-background text-foreground";
className = "bg-muted text-muted-foreground";
```

## Missing Variant Types

```typescript
// Wrong - no type safety for variants
function Button({ variant }) { ... }

// Correct - VariantProps from CVA
interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}
```

## Inline Styles

```typescript
// Wrong - inline styles
<div style={{ padding: "16px", marginTop: "8px" }}>

// Correct - Tailwind classes
<div className="p-4 mt-2">
```

## Props Not Spread

```typescript
// Wrong - props lost
function Button({ children, variant }) {
  return <button className={cn(buttonVariants({ variant }))}>{children}</button>;
}

// Correct - spread remaining props
function Button({ className, variant, ...props }: ButtonProps) {
  return (
    <button
      className={cn(buttonVariants({ variant }), className)}
      {...props}
    />
  );
}
```
