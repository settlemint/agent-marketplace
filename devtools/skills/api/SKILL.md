---
name: api
description: oRPC API routes with 5-file pattern. Only for projects using oRPC.
triggers:
  - "orpc"
  - "\\.contract\\.ts"
  - "\\.router\\.ts"
  - "\\.impl\\.ts"
  - "createProcedure"
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
  reasoning: "Need current API for oRPC contracts",
});
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
**Files to create for each route:**

| File                            | Template                   | Purpose                     |
| ------------------------------- | -------------------------- | --------------------------- |
| `{domain}.{action}.contract.ts` | `templates/contract.ts.md` | API shape (OpenAPI)         |
| `{domain}.{action}.schema.ts`   | `templates/schema.ts.md`   | Zod input/output validation |
| `{domain}.{action}.router.ts`   | `templates/router.ts.md`   | Connects contract → impl    |
| `{domain}.{action}.impl.ts`     | `templates/impl.ts.md`     | Business logic handler      |
| `{domain}.{action}.spec.ts`     | `templates/spec.ts.md`     | Tests                       |

**Read the templates for scaffolding new routes.** Each template includes placeholders and documentation.
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
