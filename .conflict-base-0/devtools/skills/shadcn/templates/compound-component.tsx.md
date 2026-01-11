# Compound Component Template

```typescript
import { cn } from "@/lib/utils";

function {{ComponentName}}({ className, ...props }: React.ComponentProps<"{{rootElement}}">) {
  return (
    <{{rootElement}}
      data-slot="{{slot-name}}"
      className={cn("{{rootStyles}}", className)}
      {...props}
    />
  );
}

function {{ComponentName}}Header({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="{{slot-name}}-header"
      className={cn("{{headerStyles}}", className)}
      {...props}
    />
  );
}

function {{ComponentName}}Title({ className, ...props }: React.ComponentProps<"h3">) {
  return (
    <h3
      data-slot="{{slot-name}}-title"
      className={cn("{{titleStyles}}", className)}
      {...props}
    />
  );
}

function {{ComponentName}}Content({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="{{slot-name}}-content"
      className={cn("{{contentStyles}}", className)}
      {...props}
    />
  );
}

function {{ComponentName}}Footer({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      data-slot="{{slot-name}}-footer"
      className={cn("{{footerStyles}}", className)}
      {...props}
    />
  );
}

export {
  {{ComponentName}},
  {{ComponentName}}Header,
  {{ComponentName}}Title,
  {{ComponentName}}Content,
  {{ComponentName}}Footer,
};
```

## Placeholders

| Placeholder         | Example                         | Description              |
| ------------------- | ------------------------------- | ------------------------ |
| `{{ComponentName}}` | `Card`                          | PascalCase component     |
| `{{slot-name}}`     | `card`                          | kebab-case for data-slot |
| `{{rootElement}}`   | `div`, `section`                | Root HTML element        |
| `{{rootStyles}}`    | `rounded-xl border bg-card`     | Container styles         |
| `{{headerStyles}}`  | `flex flex-col space-y-1.5 p-6` | Header styles            |
| `{{titleStyles}}`   | `text-2xl font-semibold`        | Title styles             |
| `{{contentStyles}}` | `p-6 pt-0`                      | Content styles           |
| `{{footerStyles}}`  | `flex items-center p-6 pt-0`    | Footer styles            |

## Usage

```tsx
<Card>
  <CardHeader>
    <CardTitle>Title</CardTitle>
  </CardHeader>
  <CardContent>Content here</CardContent>
  <CardFooter>Footer actions</CardFooter>
</Card>
```
