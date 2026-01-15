---
name: api
description: oRPC API routes with 5-file pattern. Use when asked to "create API route", "add API endpoint", or "build type-safe API". Only for projects using oRPC.
license: MIT
triggers:
  # Library name and typos
  - "\\borpc\\b"
  - "\\bo-rpc\\b"
  - "\\bunnoq/orpc\\b"
  # File patterns
  - "\\.contract\\.ts"
  - "\\.router\\.ts"
  - "\\.impl\\.ts"
  - "\\.schema\\.ts"
  # API patterns
  - "createProcedure"
  - "oc\\.route"
  - "oc\\.input"
  - "oc\\.output"
  - "publicRouter"
  - "authRouter"
  - "onboardedRouter"
  - "tokenRouter"
  # User intent - creating APIs
  - "(?i)create.*api.*route"
  - "(?i)add.*api.*endpoint"
  - "(?i)build.*api"
  - "(?i)new.*route"
  - "(?i)type.*safe.*api"
  - "(?i)rpc.*endpoint"
  - "(?i)api.*handler"
  - "(?i)5.*file.*pattern"
  - "(?i)five.*file.*pattern"
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

<anti_patterns>

- Mixing business logic in router files (keep routers thin)
- Creating generic CRUD endpoints instead of domain-specific actions
- Skipping schema validation for "simple" endpoints
- Hardcoding error messages instead of using typed error codes
- Returning raw database entities without transformation
  </anti_patterns>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production oRPC patterns",
      researchGoal: "Search for API route and contract patterns",
      reasoning: "Need real-world examples of oRPC usage",
      keywordsToSearch: ["oc.route", "oc.input", "createProcedure"],
      extension: "ts",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Contracts: `keywordsToSearch: ["oc.route", "oc.input", "oc.output"]`
- Routers: `keywordsToSearch: ["publicRouter", "authRouter", "onboardedRouter"]`
- Testing: `keywordsToSearch: ["orpc", "spec.ts", "test"]`
  </research>

<related_skills>

**Schema validation:** Load via `Skill({ skill: "devtools:zod" })` when:

- Defining input/output schemas
- Using `.meta()` for OpenAPI descriptions

**Testing:** Load via `Skill({ skill: "devtools:vitest" })` when:

- Writing route spec tests
- Mocking dependencies

**API security (Trail of Bits):** Load these for security hardening:

- `Skill({ skill: "trailofbits:semgrep-rule-creator" })` — Create API security rules
- `Skill({ skill: "trailofbits:static-analysis" })` — CodeQL, Semgrep for API security
  </related_skills>

<success_criteria>

1. [ ] All 5 files created (contract, schema, router, impl, spec)
2. [ ] Correct router layer chosen
3. [ ] Route registered in `routes.ts`
4. [ ] Schema uses `.meta({ description })`
5. [ ] Spec has success and error test cases
</success_criteria>

<evolution>
**Extension Points:**
- Add new router layers by extending the router hierarchy
- Create domain-specific error types in shared error module
- Add middleware via oRPC plugin system

**Timelessness:** Type-safe RPC with explicit contracts is a proven pattern that scales from startups to enterprise.
</evolution>
