# oRPC Contract Template

```typescript
import { oc } from "@orpc/contract";
import { {{ActionInput}}Schema, {{ActionOutput}}Schema } from "./{{domain}}.{{action}}.schema";

export const {{action}}Contract = oc
  .route({ method: "{{METHOD}}", path: "/{{domain}}/{{action}}" })
  .input({{ActionInput}}Schema)
  .output({{ActionOutput}}Schema);
```

## Placeholders

| Placeholder        | Example          | Description                          |
| ------------------ | ---------------- | ------------------------------------ |
| `{{domain}}`       | `token`          | Domain/resource name                 |
| `{{action}}`       | `transfer`       | Action name (verb)                   |
| `{{ActionInput}}`  | `TransferInput`  | PascalCase input type                |
| `{{ActionOutput}}` | `TransferOutput` | PascalCase output type               |
| `{{METHOD}}`       | `POST`           | HTTP method (GET, POST, PUT, DELETE) |
