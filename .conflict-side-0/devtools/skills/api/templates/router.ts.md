# oRPC Router Template

```typescript
import { {{routerBase}} } from "../../procedures/{{routerBase}}.router";
import { {{action}}Contract } from "./{{domain}}.{{action}}.contract";
import { {{action}}Handler } from "./{{domain}}.{{action}}.impl";

export const {{action}}Router = {{routerBase}}
  .contract({{action}}Contract)
  .handler({{action}}Handler);
```

## Placeholders

| Placeholder      | Example           | Description                   |
| ---------------- | ----------------- | ----------------------------- |
| `{{routerBase}}` | `onboardedRouter` | Base router providing context |
| `{{domain}}`     | `token`           | Domain/resource name          |
| `{{action}}`     | `transfer`        | Action name                   |

## Router Layers

| Router            | Use When            | Context Provided         |
| ----------------- | ------------------- | ------------------------ |
| `publicRouter`    | Health, public data | `requestId`              |
| `authRouter`      | User operations     | `session`, `user`        |
| `onboardedRouter` | Org operations      | `organization`, `wallet` |
| `tokenRouter`     | Token management    | `token`, admin check     |
