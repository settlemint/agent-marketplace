# Plan Agent Workflow

Enhance the built-in Plan agent with iterative refinement discipline and execution efficiency patterns. Apply the Rule of Five: 5 passes before declaring a plan complete. Each pass broadens scope from tactical to strategic concerns. Additionally, plans must include parallelization mapping, merge wall detection, and evidence-based completion criteria.

## Quick Start

When creating implementation plans:

1. **Pass 1 - Generation**: Create initial plan structure
2. **Pass 2 - Tactical Review**: Check completeness, missing steps, dependencies
3. **Pass 3 - Quality Review**: Evaluate clarity, actionability, edge cases
4. **Pass 4 - Architectural Review**: Consider patterns, coupling, maintainability
5. **Pass 5 - Strategic Review**: Ask "Are we solving the right problem?"

Declare completion only when pass produces no significant changes.

## Plan Format

Concision above grammar. Every word earns its place.

End each plan with unresolved questions list (if any exist).

## Five-Pass Protocol

| Pass            | Focus        | Key Questions                                |
| --------------- | ------------ | -------------------------------------------- |
| 1. Generate     | Initial plan | Does it cover the requirements?              |
| 2. Tactical     | Completeness | Missing steps? Dependencies clear?           |
| 3. Quality      | Clarity      | Is each step actionable? Edge cases?         |
| 4. Architecture | Patterns     | Right abstractions? Coupling concerns?       |
| 5. Strategic    | Alignment    | Right problem? Right approach? Future-proof? |

## Convergence Signals

Stop iterating when:

- Current pass produces fewer than 3 minor changes
- No structural changes in last 2 passes
- You can honestly say "this is as good as it can get"

## Parallelization Mapping

For each plan step, mark execution mode:

| Marker       | Meaning                                                  | When to Use                                     |
| ------------ | -------------------------------------------------------- | ----------------------------------------------- |
| `[parallel]` | Can execute simultaneously with other `[parallel]` steps | No shared files or resources                    |
| `[serial]`   | Must wait for prior steps to complete                    | Touches shared files or depends on prior output |

Example plan structure:

```
1. [parallel] Create user model in src/models/user.ts
2. [parallel] Create auth service in src/services/auth.ts
3. [serial] Integrate user model into auth service
4. [parallel] Write unit tests for user model
5. [parallel] Write unit tests for auth service
6. [serial] Run full test suite and verify integration
```

Parallelization enables 2-5x faster execution via orchestrator fan-out.

## Merge Wall Detection

Flag steps that create **merge walls** - points where parallel work MUST serialize:

**Merge wall triggers:**

- Directory restructuring (affects all imports)
- Core abstraction changes (ripples through codebase)
- Cross-cutting concerns (logging, auth, database schema)
- Configuration file changes (affects all workers' assumptions)
- Package.json/lockfile modifications

**Mark merge walls explicitly:**

```
3. [serial] [MERGE-WALL] Restructure src/ into feature folders
   Reason: All subsequent file paths will change
```

**Strategy:** Front-load merge walls early in the plan, then parallelize remaining work.

## Evidence Definition

Each plan step MUST define completion evidence. No step is complete without observable proof.

**Evidence types:**

| Type       | Example                                        |
| ---------- | ---------------------------------------------- |
| Command    | `bun run test` exits with code 0               |
| Output     | "All 47 tests pass" appears in stdout          |
| File state | `src/models/user.ts` exists and exports `User` |
| Observable | Button appears in UI when page loads           |
| Metric     | Coverage >= 80% reported by vitest             |

**Format in plan:**

```
2. [parallel] Create auth service
   - File: src/services/auth.ts
   - Exports: AuthService class with login(), logout(), verify()
   - Evidence: `bun run typecheck` passes, `grep "export class AuthService" src/services/auth.ts` succeeds
```

**Why this matters:** Prevents "should work" thinking. Orchestrator can verify completion objectively.

## Codex Integration

Use Codex MCP for deep reasoning during planning:

**1. Architecture Decision Analysis**

```javascript
// Load Codex for complex trade-off analysis
MCPSearch({ query: "select:mcp__plugin_devtools_codex__codex" });

mcp__plugin_devtools_codex__codex({
  prompt: `Analyze trade-offs for implementing [feature]:

    Option A: [description]
    Option B: [description]

    Consider:
    1. Complexity vs maintainability
    2. Performance implications
    3. Testing burden
    4. Future extensibility

    Recommend one approach with reasoning.`,
});
```

**2. Security Review Before Finalizing**

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Review this plan for security implications:

    [plan summary]

    Check for:
    1. OWASP Top 10 vulnerabilities this could introduce
    2. Authentication/authorization gaps
    3. Input validation requirements
    4. Data exposure risks

    Flag any security considerations to address in the plan.`,
});
```

**3. Complexity Assessment**

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Evaluate cognitive complexity of this plan:

    [plan with steps]

    Questions:
    1. Can a new developer understand this in 30 minutes?
    2. Are there simpler alternatives?
    3. Which steps have highest risk of implementation errors?
    4. Should any steps be broken down further?`,
});
```

**When to use Codex:**

- Architectural decisions with multiple viable options
- Security-sensitive features (auth, payments, data handling)
- Complex refactoring with unclear best approach
- Plans touching >10 files

## TDD in Plans

**Every implementation step MUST include TDD.**

Plans must explicitly require TDD for each code change:

```
3. [serial] Implement user authentication
   - File: src/services/auth.ts
   - TDD: Write failing test for login() before implementing
   - Evidence: Test fails → implementation passes test → coverage ≥80%
```

**Plan validation checklist for TDD:**

| Step Type    | TDD Requirement                        |
| ------------ | -------------------------------------- |
| New feature  | Failing test first, then implement     |
| Bug fix      | Failing test reproduces bug, then fix  |
| Refactor     | Existing tests pass before and after   |
| API endpoint | Integration test before implementation |

**Workers spawned from plan must receive TDD instruction:**

```
Load: Skill({ skill: "devtools:tdd-typescript" })
TDD REQUIRED: Write failing test FIRST
```

## Success Criteria

- [ ] Plan underwent at least 3 review passes
- [ ] Each pass documented its focus and findings
- [ ] Final pass produced minimal or no changes
- [ ] Strategic alignment explicitly verified
- [ ] Each step marked `[parallel]` or `[serial]`
- [ ] Merge walls identified and front-loaded
- [ ] Each step has defined completion evidence
- [ ] Each implementation step includes TDD requirement
- [ ] Worker preambles include TDD skill loading

## Constraints

- Minimum 3 passes required - no single-pass plans
- Every step needs `[parallel]` or `[serial]` marker - no ambiguity
- Merge walls must be front-loaded - parallelize after serialization points
- Evidence required for each step - no "should work" acceptance
- TDD mandatory for all implementation steps - tests before code

## Anti-Patterns

- **Single-pass planning**: Shipping first draft misses tactical and strategic issues.
- **Implicit dependencies**: Steps without `[serial]`/`[parallel]` markers cause race conditions.
- **Buried merge walls**: Late restructuring blocks all parallel work.
- **Vague completion**: "Implement auth" without evidence criteria is unverifiable.
- **TDD-optional steps**: Skipping test-first leads to untested code paths.
