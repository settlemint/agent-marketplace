# Form Field Wrapper Template

```typescript
import { cn } from "@/lib/utils";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

interface {{FieldName}}Props extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
  name: string;
  error?: string;
  required?: boolean;
  description?: string;
}

export function {{FieldName}}({
  label,
  name,
  error,
  required,
  description,
  className,
  ...props
}: {{FieldName}}Props) {
  return (
    <div className={cn("space-y-2", className)}>
      <Label htmlFor={name}>
        {label}
        {required && <span className="text-destructive ml-1">*</span>}
      </Label>
      {description && (
        <p className="text-sm text-muted-foreground">{description}</p>
      )}
      <Input
        id={name}
        name={name}
        aria-invalid={!!error}
        aria-describedby={error ? `${name}-error` : undefined}
        className={cn(error && "border-destructive focus-visible:ring-destructive")}
        {...props}
      />
      {error && (
        <p id={`${name}-error`} role="alert" className="text-sm text-destructive">
          {error}
        </p>
      )}
    </div>
  );
}
```

## Placeholders

| Placeholder     | Example                   | Description          |
| --------------- | ------------------------- | -------------------- |
| `{{FieldName}}` | `TextField`, `EmailField` | Field component name |

## Accessibility

- `aria-invalid` signals error state to screen readers
- `aria-describedby` links input to error message
- `role="alert"` announces error immediately
- `htmlFor` associates label with input

## Variants

For select fields, replace `Input` with `Select`:

```typescript
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";

<Select name={name} value={value} onValueChange={onChange}>
  <SelectTrigger aria-invalid={!!error}>
    <SelectValue placeholder={placeholder} />
  </SelectTrigger>
  <SelectContent>
    {options.map((opt) => (
      <SelectItem key={opt.value} value={opt.value}>
        {opt.label}
      </SelectItem>
    ))}
  </SelectContent>
</Select>
```
