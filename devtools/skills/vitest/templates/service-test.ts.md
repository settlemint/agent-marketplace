# Service/Unit Test Template

```typescript
import { describe, expect, it, beforeEach, vi } from "vitest";
import { {{ServiceName}} } from "./{{service-name}}";

describe("{{ServiceName}}", () => {
  let service: {{ServiceName}};

  beforeEach(() => {
    vi.clearAllMocks();
    service = new {{ServiceName}}({{dependencies}});
  });

  describe("{{methodName}}", () => {
    it("returns expected value for valid input", () => {
      const result = service.{{methodName}}({{validInput}});
      expect(result).toBe({{expectedValue}});
    });

    it("throws on invalid input", () => {
      expect(() => service.{{methodName}}({{invalidInput}})).toThrow(
        "{{expectedError}}"
      );
    });

    it("handles edge case: {{edgeCase}}", () => {
      const result = service.{{methodName}}({{edgeCaseInput}});
      expect(result).toEqual({{edgeCaseExpected}});
    });
  });
});
```

## Placeholders

| Placeholder         | Example              | Description              |
| ------------------- | -------------------- | ------------------------ |
| `{{ServiceName}}`   | `TokenService`       | PascalCase class name    |
| `{{service-name}}`  | `token-service`      | kebab-case file name     |
| `{{methodName}}`    | `transfer`           | Method being tested      |
| `{{dependencies}}`  | `mockDb, mockLogger` | Constructor dependencies |
| `{{validInput}}`    | `"0x123", 100n`      | Valid test input         |
| `{{invalidInput}}`  | `"", -1n`            | Input that should fail   |
| `{{expectedValue}}` | `true`               | Expected return          |
| `{{expectedError}}` | `Invalid amount`     | Error message            |
| `{{edgeCase}}`      | `zero amount`        | Edge case description    |

## Test Rules

- One assertion focus per test
- Descriptive names: "should X when Y"
- Clean setup with beforeEach
- No test interdependencies
