# React Component Template

```typescript
import { type ComponentProps } from "react";
import { cn } from "@/lib/utils";

interface {{ComponentName}}Props {
  {{propName}}: {{propType}};
  children?: React.ReactNode;
  className?: string;
}

export function {{ComponentName}}({
  {{propName}},
  children,
  className,
}: {{ComponentName}}Props) {
  return (
    <div className={cn("{{baseStyles}}", className)}>
      {{content}}
      {children}
    </div>
  );
}
```

## Placeholders

| Placeholder         | Example                 | Description          |
| ------------------- | ----------------------- | -------------------- |
| `{{ComponentName}}` | `UserCard`              | PascalCase component |
| `{{propName}}`      | `title`, `user`         | Prop name            |
| `{{propType}}`      | `string`, `User`        | Prop TypeScript type |
| `{{baseStyles}}`    | `rounded-lg border p-4` | Tailwind classes     |
| `{{content}}`       | `<h3>{title}</h3>`      | JSX content          |

## With Variants

```typescript
interface {{ComponentName}}Props {
  variant?: "default" | "compact";
  // ...
}

export function {{ComponentName}}({
  variant = "default",
  className,
  ...props
}: {{ComponentName}}Props) {
  return (
    <div
      className={cn(
        "base-styles",
        variant === "compact" && "compact-styles",
        className
      )}
      {...props}
    />
  );
}
```

## Rules

- Max 150 lines, max 5 props
- Use Tailwind (no inline styles)
- Export prop types
- Use `cn()` for class composition
