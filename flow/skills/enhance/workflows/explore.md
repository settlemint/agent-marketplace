# Explore Agent Workflow

Enhance the built-in Explore agent with multi-angle investigation discipline and token-efficient exploration patterns. Apply the Rule of Five: explore from 5 different angles before concluding. Use progressive disclosure (10x token savings) and MCP tools for external code. Cross-reference findings and verify from multiple sources.

## Quick Start

When exploring codebases:

1. **Angle 1 - Structure**: Directory layout, file organization, naming conventions
2. **Angle 2 - Entry Points**: Main files, exports, public APIs
3. **Angle 3 - Patterns**: Recurring patterns, architectural decisions, conventions
4. **Angle 4 - Dependencies**: External deps, internal coupling, data flow
5. **Angle 5 - Edge Cases**: Error handling, edge cases, unusual code paths

Cross-reference findings across angles before concluding.

## Five-Angle Protocol

| Angle           | Focus          | Tools                                 |
| --------------- | -------------- | ------------------------------------- |
| 1. Structure    | Organization   | Glob, LS, tree patterns               |
| 2. Entry Points | Public surface | Grep for exports, main files          |
| 3. Patterns     | Conventions    | Grep for recurring patterns           |
| 4. Dependencies | Relationships  | Package.json, imports, coupling       |
| 5. Edge Cases   | Robustness     | Error handlers, try/catch, edge paths |

## Verification Protocol

Before concluding exploration:

- Cross-reference findings from at least 3 angles
- If findings conflict, investigate deeper
- Cite specific file:line for all claims
- Distinguish between facts and inferences

## Progressive Disclosure

Explore in 3 layers for 10x token efficiency:

| Layer   | Content                         | Tokens/Item | When to Use                   |
| ------- | ------------------------------- | ----------- | ----------------------------- |
| Index   | File names, export lists only   | ~50         | Initial survey, breadth-first |
| Summary | Key observations with file:line | ~150        | Focused investigation         |
| Detail  | Full content, implementation    | ~500+       | Critical findings only        |

**Protocol:**

1. Start at Layer 1 (Index) - broad survey of structure
2. Identify interesting areas, advance to Layer 2 (Summary)
3. Only drill to Layer 3 (Detail) for findings that directly answer the question

**Example progression:**

```
Layer 1: Glob("src/services/*.ts") → [auth.ts, user.ts, api.ts]
Layer 2: Grep exports in auth.ts → "AuthService with login(), logout(), verify()"
Layer 3: Read full auth.ts ONLY IF implementation details needed
```

**Why this matters:** Large codebases can't fit in context. Progressive disclosure enables unlimited exploration without context overflow.

## MCP Tool Selection

Choose tools based on code location:

| Code Location     | Primary Tools                                          |
| ----------------- | ------------------------------------------------------ |
| Local codebase    | Glob, Grep, Read                                       |
| External packages | Context7 (`mcp__plugin_devtools_context7__query_docs`) |
| GitHub repos      | OctoCode (`mcp__plugin_devtools_octocode__*`)          |
| Unknown libraries | Context7 resolve-library-id first, then query-docs     |

**Context7 for library docs:**

```javascript
// First resolve the library ID
mcp__plugin_devtools_context7__resolve_library_id({
  libraryName: "tanstack-query",
});

// Then query documentation
mcp__plugin_devtools_context7__query_docs({
  libraryId: "/tanstack/query",
  query: "How does useQuery handle suspense?",
});
```

**OctoCode for GitHub exploration:**

```javascript
// Search code in specific repo
mcp__plugin_devtools_octocode__githubSearchCode({
  keywordsToSearch: ["useQuery", "suspense"],
  owner: "tanstack",
  repo: "query",
});
```

**Why this matters:** Training data is stale. MCP tools provide up-to-date library documentation and real-world code patterns.

## Confidence Scoring

Rate each finding by certainty level:

| Level      | Marker         | Meaning                                    |
| ---------- | -------------- | ------------------------------------------ |
| Verified   | `[verified]`   | Observed directly in code, cited file:line |
| Likely     | `[likely]`     | Multiple indicators, high confidence       |
| Inferred   | `[inferred]`   | Logical conclusion from evidence           |
| Speculated | `[speculated]` | Hypothesis, needs verification             |

**Usage:**

```
[verified] AuthService.login() calls UserRepository.findByEmail() (auth.ts:45)
[likely] All API routes require authentication (12/12 checked use AuthMiddleware)
[inferred] Rate limiting exists (import from @upstash/ratelimit in api.ts)
[speculated] May use Redis for sessions (no direct evidence, but common pattern)
```

**Why this matters:** Parent agent can prioritize follow-up. Verified findings are actionable; speculated findings need confirmation.

## Parallel Exploration

For broad codebase exploration, spawn up to 3 Explore agents in parallel:

**When to parallelize exploration:**

- Scope is uncertain
- Multiple areas of codebase involved
- Need to understand patterns before planning

**Pattern: Parallel angle exploration**

```javascript
// Spawn exploration agents in a SINGLE message (parallel)
Task({
  subagent_type: "Explore",
  description: "Explore auth patterns",
  prompt: `Search for authentication patterns:
- How is auth implemented?
- What middleware is used?
- Where are permissions checked?

Cite specific file:line for all findings.
Rate findings by confidence level.`,
  run_in_background: true,
});

Task({
  subagent_type: "Explore",
  description: "Explore data layer",
  prompt: `Search for data access patterns:
- How are database queries structured?
- What ORM/query builder is used?
- Where is data validation done?

Cite specific file:line for all findings.`,
  run_in_background: true,
});
```

**Guidelines:**

- Maximum 3 parallel explore agents
- Each agent gets a specific search focus
- Use 1 agent for isolated/known file locations
- Use 2-3 agents when scope is uncertain

## Codex for Deep Analysis

Use Codex when exploration reveals complex patterns:

```javascript
// After initial exploration finds complex code
mcp__plugin_devtools_codex__codex({
  prompt: `Analyze this architectural pattern found in the codebase:

    [code snippet from exploration]

    Questions:
    1. What design pattern is this implementing?
    2. What are the key abstractions?
    3. How should new code integrate with this?
    4. What are the extension points?`,
});
```

**When to use Codex in exploration:**

- Complex architecture discovered
- Unfamiliar design patterns
- Need to understand intent behind code
- Evaluating technical debt

## Success Criteria

- [ ] Explored from at least 3 distinct angles
- [ ] Findings cross-referenced across angles
- [ ] All claims cite specific evidence (file:line)
- [ ] Conflicts investigated and resolved
- [ ] Used progressive disclosure (Index → Summary → Detail)
- [ ] External libraries queried via MCP tools (Context7/OctoCode)
- [ ] Each finding rated by confidence level

## Constraints

- Never skip angles - all 5 angles required before concluding
- Always cite file:line for claims - no unsourced assertions
- Stay at Index layer until pattern emerges - avoid premature Detail drilling
- Maximum 3 parallel Explore agents - prevent context fragmentation
- MCP tools required for external code - training data is stale

## Anti-Patterns

- **Depth-first diving**: Going straight to Detail layer wastes tokens. Start broad.
- **Single-angle conclusions**: Drawing conclusions from one perspective misses context.
- **Uncited claims**: "The app uses React" without file:line is unverifiable.
- **Skipping MCP for libraries**: Relying on training data for npm packages yields outdated info.
- **Over-parallelization**: More than 3 agents fragments findings and wastes context.
