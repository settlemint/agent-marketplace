---
name: stack-review
description: Code review guidance for full-stack blockchain platform (React, TanStack, Drizzle, Viem, Hardhat, TheGraph, Restate). Routes to specialized skills and provides curated review patterns.
license: MIT
triggers:
  # Intent triggers
  - "review code"
  - "code review"
  - "review PR"
  - "check code quality"
  - "review changes"
  - "review this"

  # Domain triggers
  - "review contract"
  - "review frontend"
  - "review subgraph"
  - "review api"
  - "review workflow"

  # Artifact triggers - monorepo paths
  - "kit/contracts"
  - "kit/dapp"
  - "kit/subgraph"
  - "packages/services"
  - "packages/core"
---

<objective>
Provide comprehensive code review guidance for the full-stack blockchain platform. Routes to specialized skills based on change type, applies domain-specific checklists, and surfaces curated review patterns from top open-source projects.
</objective>

<quick_start>

**Three-phase review workflow:**

1. **Categorize** - Identify which domains the changes touch
2. **Load Skills** - Activate relevant specialized skills for deep review
3. **Apply Checklist** - Run through domain-specific review items

**Quick categorization:**

```bash
# See what changed
git diff --stat HEAD~1

# Categorize by file extension/path
git diff --name-only HEAD~1 | grep -E '\.(sol|tsx|ts)$' | head -20
```

</quick_start>

<routing>

**Route to specialized skills based on change type:**

| Change Pattern | Skill to Load | When |
|----------------|---------------|------|
| `*.sol` files | `Skill({ skill: "devtools:solidity" })` | Smart contract changes |
| `kit/dapp/**/*.tsx` | `Skill({ skill: "devtools:react" })` | UI component changes |
| TanStack routes | `Skill({ skill: "devtools:tanstack-start" })` | Route files, loaders |
| `kit/subgraph/**` | `Skill({ skill: "devtools:thegraph" })` | Subgraph handlers, schema |
| `**/schema.ts` | `Skill({ skill: "devtools:drizzle" })` | Database schema changes |
| `**/*.test.ts` | `Skill({ skill: "devtools:vitest" })` | Unit test changes |
| `kit/e2e/**` | `Skill({ skill: "devtools:playwright" })` | E2E test changes |
| Restate handlers | `Skill({ skill: "devtools:restate" })` | Durable workflow changes |
| Auth patterns | `Skill({ skill: "devtools:better-auth" })` | Authentication changes |
| shadcn components | `Skill({ skill: "devtools:shadcn" })` | UI primitive changes |
| Zod schemas | `Skill({ skill: "devtools:zod" })` | Validation schemas |
| ORPC routes | `Skill({ skill: "devtools:api" })` | API endpoint changes |

**Multi-domain changes:** Load multiple skills when changes span domains.

</routing>

<domain_checklists>

### Smart Contract Review

- [ ] CEI pattern followed (Checks-Effects-Interactions)
- [ ] Access control on state-changing functions (`onlyOwner`, `onlyRole`)
- [ ] Events emitted for all state changes
- [ ] No floating pragma (use `pragma solidity 0.8.28;` not `^0.8.0`)
- [ ] NatSpec documentation complete (`@notice`, `@param`, `@return`)
- [ ] ReentrancyGuard on external call functions
- [ ] Gas optimization reviewed (storage vs memory, batch operations)
- [ ] Upgrade safety verified (storage layout, initializers)

### Frontend Review

- [ ] Components < 150 lines (split if larger)
- [ ] Data fetching via TanStack loader (no `useEffect` fetch)
- [ ] Tailwind classes only (no inline styles, no CSS modules)
- [ ] Accessibility attributes present (`aria-*`, semantic HTML)
- [ ] Error boundaries around async operations
- [ ] Loading states handled (skeleton, spinner)
- [ ] Form validation with Zod schemas
- [ ] No hardcoded strings (use i18n keys)

### Subgraph Review

- [ ] All handlers call `.save()` on entities
- [ ] No TypeScript assumptions (AssemblyScript limits apply)
- [ ] Composite IDs use `concatI32` not string concatenation
- [ ] Codegen run after schema changes (`bun run codegen`)
- [ ] Event handlers match contract events exactly
- [ ] BigInt/BigDecimal handled correctly
- [ ] Derived fields use `@derivedFrom` annotation
- [ ] Entity relationships defined with `@entity`

### Data Layer Review

- [ ] `$inferInsert`/`$inferSelect` types exported from schemas
- [ ] Foreign keys have explicit `onDelete` action
- [ ] Timestamps use `withTimezone: true`
- [ ] ORPC validators use Zod schemas (not manual checks)
- [ ] Transactions wrap related operations
- [ ] Indexes on frequently queried columns
- [ ] Migrations tested both up and down
- [ ] No raw SQL (use Drizzle query builder)

### Durable Workflow Review

- [ ] External calls wrapped in `ctx.run()` for durability
- [ ] Using `ctx.sleep()` not `setTimeout`
- [ ] Handlers are idempotent (safe to replay)
- [ ] State accessed via Virtual Objects (not local variables)
- [ ] Service registered with Restate server
- [ ] Error handling with compensating transactions
- [ ] Awakeables used for external signals

### Authentication Review

- [ ] Session tokens have appropriate expiry
- [ ] Sensitive routes protected with auth middleware
- [ ] CSRF protection enabled on form submissions
- [ ] Password hashing uses secure algorithm
- [ ] Rate limiting on auth endpoints
- [ ] Passkey/WebAuthn configured correctly
- [ ] OAuth redirects validated

### Testing Review

- [ ] Unit tests cover business logic
- [ ] E2E tests cover critical user flows
- [ ] Mocks don't hide real behavior
- [ ] Test data is realistic (not `test123`)
- [ ] Assertions verify behavior, not implementation
- [ ] No `.skip` or `.only` in committed tests
- [ ] Coverage meets thresholds (80% line, 75% branch)

</domain_checklists>

<blockchain_patterns>

**Viem Transaction Patterns:**

```typescript
// Always simulate before write
const { request } = await publicClient.simulateContract({
  address: contractAddress,
  abi: contractABI,
  functionName: "transfer",
  args: [to, amount],
  account,
});

// Execute with simulated request
const hash = await walletClient.writeContract(request);

// Wait for confirmation
const receipt = await publicClient.waitForTransactionReceipt({
  hash,
  confirmations: 1,
});

// Check receipt status
if (receipt.status === "reverted") {
  throw new Error("Transaction reverted");
}
```

**Hardhat Deployment Review:**

- Network configs in `hardhat.config.ts` with chain IDs
- Verification scripts for each supported network
- Gas reporter configuration for optimization insights
- Coverage thresholds enforced in CI
- Deployment scripts use Ignition modules (not raw scripts)
- Constructor arguments validated before deployment

**OpenZeppelin Upgrade Patterns:**

```solidity
// UUPS proxy - implementation disables initializers
constructor() {
    _disableInitializers();
}

// Storage gaps for upgrade safety (50 slots standard)
uint256[50] private __gap;

// Version tracking
function version() public pure returns (string memory) {
    return "2.0.0";
}
```

**Contract ABI Regeneration:**

After any contract change, always regenerate ABIs:

```bash
bun run artifacts
```

This updates TypeScript types used by Viem in the frontend.

</blockchain_patterns>

<anti_patterns>

**Common mistakes to flag during review:**

| Anti-Pattern | Why It's Bad | Fix |
|--------------|--------------|-----|
| Data fetching in `useEffect` | Bypasses TanStack caching, causes waterfalls | Use route loader |
| Missing `.save()` in subgraph | Entity changes won't persist | Add `.save()` call |
| Contract changes without `bun run artifacts` | Frontend uses stale ABIs | Regenerate artifacts |
| Raw SQL in Drizzle | SQL injection risk, loses type safety | Use query builder |
| `console.log` in production | Leaks info, pollutes logs | Use structured logger |
| Hardcoded chain IDs | Breaks multi-network support | Use config/env |
| `setTimeout` in Restate handlers | Doesn't survive restarts | Use `ctx.sleep()` |
| Direct state mutation in React | Breaks reactivity | Use setState/signals |
| Floating Solidity pragma | Non-deterministic compilation | Pin exact version |

</anti_patterns>

<commands>

**Verification commands (run before approving PR):**

```bash
# Full quality gate - MUST pass
bun run ci

# Individual checks
bun run build          # Build all packages
bun run test           # Unit tests
bun run lint           # Biome linting
bun run typecheck      # TypeScript checks

# Contract-specific
bun run artifacts      # Regenerate ABIs
bun run test:contracts # Contract tests

# E2E (requires Docker)
bun run dev:up         # Start services
bun run test:e2e       # Playwright tests

# Localization
bun verify-translations # Check i18n keys match
```

</commands>

<awesome_reviewers>

**353 code review patterns** organized in `references/reviewers/` directory.

**Browse by technology via `references/reviewers-index.md`:**

| Technology | Count | Examples |
|------------|-------|----------|
| GraphQL | 40 | API design, response transformation, polling optimization |
| TanStack Router | 38 | File routing, loaders, backward compatibility |
| Bun | 37 | Async/await, error handling, memory management |
| Node.js | 32 | Stream handling, event loop, buffer safety |
| Playwright | 31 | Test organization, security boundaries, flaky tests |
| Tailwind/Vite | 30 | Build config, hot reload, CSS optimization |
| Prettier | 28 | Formatting rules, parser consistency |
| React | 24 | Component APIs, hooks, testing patterns |
| TypeScript | 20 | Type safety, inference, configuration |
| Better Auth | 15 | Session context, API consistency, config handling |
| Vitest | 13 | Test patterns, mocking, coverage |
| Drizzle | 8 | Schema design, migrations, type consistency |

**Usage:** Read the index to find relevant reviewers, then load specific files:
```
Read references/reviewers-index.md      # Find relevant patterns
Read references/reviewers/{name}.md     # Load specific reviewer
```

Generated from [awesome-reviewers](https://github.com/baz-scm/awesome-reviewers) catalog.

</awesome_reviewers>

<rule_of_five_integration>

**This skill provides domain checklists for the Rule of Five review pattern.**

When using `Skill({ skill: "devtools:rule-of-five" })`:

| Pass | This Skill Adds |
|------|-----------------|
| 1. Standard | Domain checklists (contracts, frontend, subgraph, data layer) |
| 2. Deep | Technology-specific reviewers from `references/reviewers/` |
| 3. Architecture | Routing to specialized skills (solidity, react, drizzle) |
| 4. Strategic | Anti-patterns table, blockchain patterns |
| 5. Existential | Stack architecture context |

**Usage:**
1. Load rule-of-five: `Skill({ skill: "devtools:rule-of-five" })`
2. Load stack-review: `Skill({ skill: "devtools:stack-review" })`
3. Run 5-pass review using domain checklists at each level
4. Consult `references/reviewers-index.md` for technology-specific patterns

</rule_of_five_integration>

<related_skills>

**Iterative review:** Load via `Skill({ skill: "devtools:rule-of-five" })` when:

- Running multi-pass reviews (this skill provides the checklists)
- Need convergence pattern for quality assurance

**Security auditing (Trail of Bits):**

- `Skill({ skill: "entry-point-analyzer:entry-point-analyzer" })` — Find attack surface in contracts
- `Skill({ skill: "sharp-edges:sharp-edges" })` — Error-prone APIs and dangerous configs
- `Skill({ skill: "property-based-testing:property-based-testing" })` — Invariant testing

**Code quality:**

- `Skill({ skill: "devtools:code-health" })` — Dead code, YAGNI, tech debt
- `Skill({ skill: "devtools:tdd-typescript" })` — TDD workflow for new code

**Design:**

- `Skill({ skill: "devtools:design-principles" })` — UI/UX patterns
- `Skill({ skill: "devtools:vercel-design-guidelines" })` — Accessibility, interactions

</related_skills>

<constraints>

**Banned:**

- Approving PRs without `bun run ci` passing
- Skipping security review on contract changes
- Merging `.skip` or `.only` in test files
- Hardcoded secrets or API keys in code

**Required:**

- Load specialized skill for each domain touched by changes
- Apply relevant domain checklist
- Verify commands pass before approval
- Check for anti-patterns listed above

</constraints>

<success_criteria>

- [ ] All changed domains have checklist applied
- [ ] Relevant specialized skills loaded and consulted
- [ ] No P1 issues (blocking, security)
- [ ] `bun run ci` passes
- [ ] Tests cover new/changed code
- [ ] No anti-patterns introduced

</success_criteria>

<reference_index>

| Reference | Content |
|-----------|---------|
| `reviewers-index.md` | Index of 353 reviewers organized by technology |
| `reviewers/*.md` | Individual reviewer files (~1-3KB each) |
| `smart-contract-checklist.md` | Blockchain patterns (Viem, Hardhat, OpenZeppelin) |
| `stack-architecture.md` | Monorepo structure and conventions |

</reference_index>

<evolution>

**Extension Points:**

- Add project-specific checklists via references
- Extend anti-patterns based on team learnings
- Integrate with CI for automated review comments

**Timelessness:** Code review practices and checklists are fundamental software engineering disciplines that persist across framework versions.

</evolution>
