---
name: thegraph
description: Use when indexing blockchain events, creating subgraphs, or querying on-chain data. Covers TheGraph schema definitions, AssemblyScript handlers, and Matchstick testing.
license: MIT
triggers:
  # Intent triggers
  - "index blockchain events"
  - "create subgraph"
  - "query on-chain data"
  - "build blockchain indexer"
  - "handle transfer events"

  # Artifact triggers
  - "the graph"
  - "subgraph"
  - "@graphprotocol"
  - "matchstick"
  - "schema\\.graphql"
  - "@entity"
  - "\\.save\\(\\)"
  - "graph codegen"
  - "AssemblyScript"
---

<objective>
Build blockchain indexers using TheGraph. Write AssemblyScript handlers to process events and store entities. AssemblyScript is NOT TypeScript - it has significant limitations.
</objective>

<mcp_first>
**CRITICAL: TheGraph has no Context7 docs. Use OctoCode to search graph-ts.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_octocode__githubSearchCode" })
```

```typescript
// graph-ts type definitions
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["BigInt", "Bytes", "Address", "store"],
  owner: "graphprotocol",
  repo: "graph-tooling",
  path: "packages/ts/common",
  mainResearchGoal: "Understand graph-ts type system",
  researchGoal: "Find BigInt, Bytes, Address type definitions",
  reasoning: "Need current API for AssemblyScript types",
});

// Entity patterns
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["Entity", "save", "load"],
  owner: "graphprotocol",
  repo: "graph-tooling",
  path: "packages/ts",
  mainResearchGoal: "Understand graph-ts entity patterns",
  researchGoal: "Find entity save/load patterns",
  reasoning: "Need current API for entity persistence",
});

// Matchstick testing
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["createMockedFunction", "newMockEvent", "assert"],
  owner: "LimeChain",
  repo: "matchstick",
  path: "packages/matchstick-as/assembly",
  mainResearchGoal: "Understand Matchstick testing",
  researchGoal: "Find mock and assertion patterns",
  reasoning: "Need current API for subgraph unit testing",
});
```

</mcp_first>

<quick_start>
**Schema (schema.graphql):**

```graphql
type Transfer @entity {
  id: Bytes!
  from: Bytes!
  to: Bytes!
  amount: BigInt!
  blockNumber: BigInt!
  timestamp: BigInt!
}
```

**Handler (mapping.ts):**

```typescript
import { Transfer as TransferEvent } from "../generated/Token/Token";
import { Transfer } from "../generated/schema";

export function handleTransfer(event: TransferEvent): void {
  let entity = new Transfer(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  );

  entity.from = event.params.from;
  entity.to = event.params.to;
  entity.amount = event.params.value;
  entity.blockNumber = event.block.number;
  entity.timestamp = event.block.timestamp;

  entity.save(); // REQUIRED!
}
```

</quick_start>

<assemblyscript_rules>
**AssemblyScript is NOT TypeScript:**

- No async/await
- No closures
- No exceptions (try/catch)
- No null (use nullable types)
- Use `Bytes` for addresses
- Use `BigInt` for numbers
- Use `BigDecimal` for decimals
- Always call `.save()` to persist

**Composite IDs:**

```typescript
// ✅ Correct
event.transaction.hash.concatI32(event.logIndex.toI32());

// ❌ Wrong - string concatenation
event.transaction.hash.toHexString() + "-" + event.logIndex.toString();
```

</assemblyscript_rules>

<constraints>
**Banned:** async/await, closures, try/catch, forget `.save()`, skip codegen, use Number (use BigInt), mutable globals

**Required:**

- All entities have `id: Bytes!` or `id: ID!`
- All handlers call `.save()` after changes
- Run `codegen` after schema/ABI changes
- Run `compile` after mapping changes
  </constraints>

<anti_patterns>

- **String ID Concatenation:** Using `hash.toHexString() + "-" + index`; use `hash.concatI32()` instead
- **Missing .save():** Entity changes without persistence; data silently lost
- **TypeScript Assumptions:** Using closures, async/await, or try/catch in AssemblyScript
- **Skipping Codegen:** Editing handlers without regenerating types after schema changes
- **Nullable Confusion:** Using `null` instead of nullable types; AssemblyScript has no null
  </anti_patterns>

<commands>
```bash
graph codegen     # Generate types (REQUIRED after schema changes)
graph build       # Compile to WASM
graph test        # Run Matchstick tests
graph deploy      # Deploy subgraph
```
</commands>

<library_ids>
Skip resolve step for these known IDs:

| Library    | Context7 ID                  |
| ---------- | ---------------------------- |
| graph-ts   | /graphprotocol/graph-tooling |
| Matchstick | /LimeChain/matchstick        |

</library_ids>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production subgraph patterns",
      researchGoal: "Search for handler and entity patterns",
      reasoning: "Need real-world examples of TheGraph usage",
      keywordsToSearch: [".save()", "handleTransfer", "@entity"],
      extension: "ts",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Handlers: `keywordsToSearch: ["export function handle", "event.params", ".save()"]`
- Entities: `keywordsToSearch: ["@entity", "id: Bytes", "BigInt"]`
- Testing: `keywordsToSearch: ["newMockEvent", "createMockedFunction", "assert"]`
- Schema: `keywordsToSearch: ["type", "@entity", "@derivedFrom"]`
  </research>

<related_skills>

**Smart contracts:** Load via `Skill({ skill: "devtools:solidity" })` when:

- Understanding contract events to index
- Decoding ABI for handler parameters

**Blockchain client:** Load via `Skill({ skill: "devtools:viem" })` when:

- Making direct RPC calls alongside subgraph queries
- Fetching data not indexed by subgraph

**Contract security (Trail of Bits):** Load when indexing contract events:

- `Skill({ skill: "trailofbits:building-secure-contracts" })` — Verify contract security before indexing
  </related_skills>

<success_criteria>

1. [ ] OctoCode searched for graph-ts patterns
2. [ ] All entities have `id` field
3. [ ] All handlers call `.save()`
4. [ ] `codegen` runs without errors
5. [ ] `compile` succeeds
6. [ ] Tests cover critical handlers
</success_criteria>

<evolution>
**Extension Points:**
- Add protocol-specific templates (DeFi, NFT, governance)
- Extend with Matchstick test patterns for complex scenarios
- Integrate with deployment workflows for hosted/decentralized networks

**Timelessness:** Blockchain indexing is essential infrastructure; TheGraph patterns apply to any event-driven data transformation.
</evolution>
