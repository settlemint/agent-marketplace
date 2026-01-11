# oRPC Schema Template

```typescript
import { z } from "zod";

export const {{ActionInput}}Schema = z.object({
  {{inputField}}: z.{{zodType}}().meta({ description: "{{fieldDescription}}" }),
});

export type {{ActionInput}} = z.infer<typeof {{ActionInput}}Schema>;

export const {{ActionOutput}}Schema = z.object({
  {{outputField}}: z.{{zodType}}().meta({ description: "{{fieldDescription}}" }),
});

export type {{ActionOutput}} = z.infer<typeof {{ActionOutput}}Schema>;
```

## Placeholders

| Placeholder            | Example                       | Description            |
| ---------------------- | ----------------------------- | ---------------------- |
| `{{ActionInput}}`      | `TransferInput`               | PascalCase input type  |
| `{{ActionOutput}}`     | `TransferOutput`              | PascalCase output type |
| `{{inputField}}`       | `to`                          | Input field name       |
| `{{outputField}}`      | `success`                     | Output field name      |
| `{{zodType}}`          | `string`, `bigint`, `boolean` | Zod validator type     |
| `{{fieldDescription}}` | `Recipient address`           | OpenAPI description    |

## Common Zod Types

```typescript
z.string(); // String value
z.number(); // Number value
z.bigint(); // BigInt value
z.boolean(); // Boolean value
z.array(z.string()); // Array of strings
z.object({}); // Nested object
z.enum(["A", "B"]); // Enum values
z.optional(); // Optional field
```
