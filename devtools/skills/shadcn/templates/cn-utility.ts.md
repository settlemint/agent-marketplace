# cn() Utility Template

Place in `src/lib/utils.ts`:

```typescript
import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

## Usage Patterns

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

// Array of classes
className={cn(["flex", "items-center"], isLoading && "animate-pulse")}
```

## Dependencies

```bash
bun add clsx tailwind-merge
```
