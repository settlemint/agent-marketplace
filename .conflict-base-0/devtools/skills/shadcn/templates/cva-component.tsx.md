# CVA Component Template

```typescript
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const {{componentName}}Variants = cva(
  // Base styles (always applied)
  "{{baseStyles}}",
  {
    variants: {
      variant: {
        default: "{{defaultStyles}}",
        {{additionalVariant}}: "{{variantStyles}}",
      },
      size: {
        default: "{{defaultSize}}",
        sm: "{{smallSize}}",
        lg: "{{largeSize}}",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
);

interface {{ComponentName}}Props
  extends React.{{HTMLElement}}HTMLAttributes<HTML{{HTMLElement}}Element>,
    VariantProps<typeof {{componentName}}Variants> {
  asChild?: boolean;
}

function {{ComponentName}}({
  className,
  variant,
  size,
  ...props
}: {{ComponentName}}Props) {
  return (
    <{{element}}
      className={cn({{componentName}}Variants({ variant, size, className }))}
      {...props}
    />
  );
}

export { {{ComponentName}}, {{componentName}}Variants };
```

## Placeholders

| Placeholder             | Example                              | Description            |
| ----------------------- | ------------------------------------ | ---------------------- |
| `{{ComponentName}}`     | `Button`                             | PascalCase component   |
| `{{componentName}}`     | `button`                             | camelCase for variants |
| `{{element}}`           | `button`, `div`                      | HTML element           |
| `{{HTMLElement}}`       | `Button`, `Div`                      | For type attributes    |
| `{{baseStyles}}`        | `inline-flex items-center`           | Always-applied styles  |
| `{{defaultStyles}}`     | `bg-primary text-primary-foreground` | Default variant        |
| `{{additionalVariant}}` | `outline`, `ghost`                   | Variant name           |
| `{{variantStyles}}`     | `border border-input`                | Variant styles         |

## Dependencies

```bash
bun add class-variance-authority
```
