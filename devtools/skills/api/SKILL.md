---
name: api
description: oRPC API routes with the 5-file pattern (contract, schema, router, impl, spec). Triggers on orpc, api, endpoint, router keywords.
triggers: ["orpc", "api", "endpoint", "router", "\\.contract\\.ts", "\\.router\\.ts", "\\.impl\\.ts"]
---

<objective>
Build type-safe APIs using oRPC with the 5-file pattern. Every route needs: contract (OpenAPI shape), schema (Zod validation), router (connection), impl (business logic), and spec (tests).
</objective>

<mcp_first>
**CRITICAL: oRPC has no Context7 docs. Use OctoCode to search the source.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_octocode__githubSearchCode" })
MCPSearch({ query: "select:mcp__plugin_devtools_octocode__githubGetFileContent" })
```

```typescript
// Search oRPC patterns
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["oc.route", "oc.input", "oc.output"],
  owner: "unnoq",
  repo: "orpc",
  path: "packages/contract/src",
  mainResearchGoal: "Understand oRPC contract definition",
  researchGoal: "Find route contract patterns",
  reasoning: "Need current API for oRPC contracts"
})
```
</mcp_first>

<quick_start>
**The 5-File Pattern:**

```
routes/token/
├── token.transfer.contract.ts   # API shape (OpenAPI)
├── token.transfer.schema.ts     # Zod input/output
├── token.transfer.router.ts     # Connects contract → impl
├── token.transfer.impl.ts       # Business logic
└── token.transfer.spec.ts       # Tests
```
</quick_start>

<five_file_pattern>
**1. Contract (`.contract.ts`)**

```typescript
import { oc } from "@orpc/contract";
import { TransferInputSchema, TransferOutputSchema } from "./token.transfer.schema";

export const transferContract = oc
  .route({ method: "POST", path: "/token/transfer" })
  .input(TransferInputSchema)
  .output(TransferOutputSchema);
```

**2. Schema (`.schema.ts`)**

```typescript
import { z } from "zod";

export const TransferInputSchema = z.object({
  to: z.string().meta({ description: "Recipient address" }),
  amount: z.bigint().meta({ description: "Amount to transfer" }),
});

export type TransferInput = z.infer<typeof TransferInputSchema>;
```

**3. Router (`.router.ts`)**

```typescript
import { onboardedRouter } from "../../procedures/onboarded.router";
import { transferContract } from "./token.transfer.contract";
import { transferHandler } from "./token.transfer.impl";

export const transferRouter = onboardedRouter
  .contract(transferContract)
  .handler(transferHandler);
```

**4. Implementation (`.impl.ts`)**

```typescript
export const transferHandler = async ({ input, context }) => {
  const { to, amount } = input;
  const { wallet } = context;

  await tokenService.transfer(wallet, to, amount);
  return { success: true };
};
```

**5. Spec (`.spec.ts`)**

```typescript
import { describe, expect, it, beforeAll } from "vitest";
import { getOrpcClient } from "@test/fixtures/orpc-client";

describe("Token transfer", () => {
  let client: ReturnType<typeof getOrpcClient>;

  beforeAll(async () => {
    client = getOrpcClient(await getAuthHeaders());
  });

  it("returns expected response", async () => {
    const result = await client.token.transfer({ to: "0x...", amount: 100n });
    expect(result.success).toBe(true);
  });
});
```
</five_file_pattern>

<router_layers>
| Router | Use When | Context Provided |
|--------|----------|------------------|
| `publicRouter` | Health, public data | `requestId` |
| `authRouter` | User operations | `session`, `user` |
| `onboardedRouter` | Org operations | `organization`, `wallet` |
| `tokenRouter` | Token management | `token`, admin check |
</router_layers>

<constraints>
**Banned:**
- Handler >50 lines
- Raw SQL in handlers (use services)
- Skipping 5-file pattern
- Re-exports via barrel files (import from canonical source)
- Test utilities in production (`NODE_ENV !== "production"` guard)
- Trusting localhost origins in production
- Abstractions for one-time operations
- Migration/backwards-compatibility shims

**Required:**
- Every route uses 5-file pattern
- Choose correct router layer
- Register route in domain's `routes.ts`
- Every route has `.spec.ts` with tests
- Import directly from source files, not index barrels
- Gate dev-only utilities with `NODE_ENV` checks
- Prefer simplest implementation
- Delete unused code completely

**Naming:** Files=`<domain>.<action>.<type>.ts`, Handlers=`<domain><Action>Handler`
</constraints>

<success_criteria>
- [ ] All 5 files created (contract, schema, router, impl, spec)
- [ ] Correct router layer chosen
- [ ] Route registered in `routes.ts`
- [ ] Schema uses `.meta({ description })`
- [ ] Spec has success and error test cases
</success_criteria>
