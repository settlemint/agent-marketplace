# oRPC Implementation Template

```typescript
import type { {{ActionInput}} } from "./{{domain}}.{{action}}.schema";

export const {{action}}Handler = async ({
  input,
  context
}: {
  input: {{ActionInput}};
  context: {{ContextType}};
}) => {
  const { {{inputFields}} } = input;
  const { {{contextFields}} } = context;

  // Business logic here
  {{businessLogic}}

  return { {{outputFields}} };
};
```

## Placeholders

| Placeholder         | Example                            | Description                 |
| ------------------- | ---------------------------------- | --------------------------- |
| `{{domain}}`        | `token`                            | Domain/resource name        |
| `{{action}}`        | `transfer`                         | Action name                 |
| `{{ActionInput}}`   | `TransferInput`                    | Input type from schema      |
| `{{ContextType}}`   | `OnboardedContext`                 | Context type from router    |
| `{{inputFields}}`   | `to, amount`                       | Destructured input fields   |
| `{{contextFields}}` | `wallet`                           | Destructured context fields |
| `{{businessLogic}}` | `await tokenService.transfer(...)` | Core logic                  |
| `{{outputFields}}`  | `success: true`                    | Return value                |

## Handler Rules

- Max 50 lines
- No raw SQL (use services)
- Destructure input and context
- Return typed output matching schema
