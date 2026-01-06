# oRPC Spec/Test Template

```typescript
import { describe, expect, it, beforeAll } from "vitest";
import { getOrpcClient } from "@test/fixtures/orpc-client";

describe("{{Domain}} {{action}}", () => {
  let client: ReturnType<typeof getOrpcClient>;

  beforeAll(async () => {
    client = getOrpcClient(await getAuthHeaders());
  });

  it("returns expected response for valid input", async () => {
    const result = await client.{{domain}}.{{action}}({
      {{validInput}}
    });

    expect(result.{{expectedField}}).toBe({{expectedValue}});
  });

  it("throws on invalid input", async () => {
    await expect(
      client.{{domain}}.{{action}}({
        {{invalidInput}}
      })
    ).rejects.toThrow("{{expectedError}}");
  });

  it("handles edge case: {{edgeCaseDescription}}", async () => {
    {{edgeCaseTest}}
  });
});
```

## Placeholders

| Placeholder               | Example                     | Description              |
| ------------------------- | --------------------------- | ------------------------ |
| `{{Domain}}`              | `Token`                     | PascalCase domain        |
| `{{domain}}`              | `token`                     | camelCase domain         |
| `{{action}}`              | `transfer`                  | Action name              |
| `{{validInput}}`          | `to: "0x...", amount: 100n` | Valid test input         |
| `{{invalidInput}}`        | `to: "", amount: -1n`       | Invalid test input       |
| `{{expectedField}}`       | `success`                   | Field to assert          |
| `{{expectedValue}}`       | `true`                      | Expected value           |
| `{{expectedError}}`       | `Invalid amount`            | Error message            |
| `{{edgeCaseDescription}}` | `zero amount`               | Edge case name           |
| `{{edgeCaseTest}}`        | Full test code              | Edge case implementation |

## Test Rules

- One concept per test
- Test success AND error cases
- Test edge cases (null, empty, boundary values)
- Use descriptive test names
