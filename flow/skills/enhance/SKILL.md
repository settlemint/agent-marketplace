---
name: flow:enhance
description: THE central router for all Claude work. Routes to Rule of Five, domain skills, coding rules, and agent workflows.
license: MIT
---

<objective>

THE comprehensive router for all Claude work. Loaded at session start, this skill:
- Routes to Rule of Five for quality patterns
- Routes to domain skills for technical tasks
- Routes to coding rules for standards
- Provides agent workflows for Task spawning

All routing decisions flow through this skill.

</objective>

<philosophy>

**Trust with Discovery**

This skill system is built on trust, not enforcement:

- **Knowledge, not commands** - Skills inform and guide, they don't dictate
- **Discovery, not injection** - Patterns surface contextually when relevant
- **Safety nets, not fences** - Prevent catastrophic errors, allow creative solutions
- **Quality through understanding** - Excellence comes from understanding why, not being told what

**When to deviate from patterns:**

Patterns serve quality. If following a pattern hurts quality, question it:
- Document your reasoning
- Verify with evidence
- Trust your judgment

**Freedom enables quality.** Rigid enforcement creates adversarial dynamics and burns tokens on repeated warnings. Well-informed Claude does quality work naturally.

</philosophy>

<load_first>

**REQUIRED: Load Rule of Five immediately.**

```
Skill({ skill: "devtools:rule-of-five" })
```

Rule of Five is MANDATORY for ALL work. The skill provides:
- 5-pass convergence pattern
- Evidence requirements
- Quality standards

</load_first>

<quick_start>

1. **Load Rule of Five**: `Skill({ skill: "devtools:rule-of-five" })`
2. **Identify domain** → load appropriate domain skill from routing table
3. **Read coding rules** → check relevant rules before writing code
4. **Apply 5-pass pattern** → iterate until convergence with evidence

</quick_start>

<agent_routing>

When spawning Task agents, read the appropriate workflow:

| Agent Type | Workflow | Key Pattern |
|------------|----------|-------------|
| Explore | `workflows/explore.md` | 5-angle investigation |
| Plan | `workflows/plan.md` | 5-pass planning with parallelization |
| General-purpose | `workflows/general-purpose.md` | 5-pass execution with evidence |

**Context-based routing:**

| Context | Detection | Workflow |
|---------|-----------|----------|
| Code review | "review", "audit", "find bugs" | `workflows/review.md` |
| Open PR | Working on branch with PR | `workflows/pr-awareness.md` |
| Multi-agent orchestration | Complex task, >3 files, quality-critical | `workflows/orchestration.md` |

**Orchestration guidance:**

For non-trivial implementations, consider the two-agent pattern:
1. Implementer agent completes the work
2. Reviewer agent validates independently

Read `workflows/orchestration.md` for:
- Delegation tier classification (fully delegate / checkpoint / retain ownership)
- Two-agent review pattern with examples
- Kill criteria and progress reporting
- Review bandwidth management

</agent_routing>

<plan_mode_enforcement>

## Plan Mode Enforcement (MANDATORY)

When plan mode is active, these requirements are **ENFORCED** by the `plan-quality-gate.sh` PreToolUse hook:

| Requirement | Enforcement | How to Satisfy |
|-------------|-------------|----------------|
| Codex Review | ExitPlanMode blocked without Codex invocation | `mcp__plugin_devtools_codex__codex({ prompt: "Review plan..." })` |
| Rule of Five | ExitPlanMode blocked without 3+ passes | Document passes OR spawn Review subagent |
| TDD | ExitPlanMode blocked if plan has implementation steps without test mentions | Include TDD requirements for each step |

**This is NOT optional.** The hook verifies compliance before allowing plan mode exit.

### Delegation Pattern

Main thread is **ORCHESTRATOR**, not worker:

```
Phase 1: Spawn Explore agents (research, codebase analysis, test coverage gaps)
Phase 2: Main thread synthesizes, drafts plan
Phase 3: Invoke Codex + spawn Review agent (or document passes)
Phase 4: Finalize plan, ExitPlanMode
```

### To Comply

1. **Load Codex:**
   ```javascript
   MCPSearch({ query: "select:mcp__plugin_devtools_codex__codex" })
   mcp__plugin_devtools_codex__codex({
     prompt: "Review this plan for: architecture trade-offs, security, complexity"
   })
   ```

2. **Document Rule of Five passes:**
   ```markdown
   ## Pass 1: Generation - EVIDENCE
   ## Pass 2: Tactical Review - EVIDENCE
   ## Pass 3: Quality Review - EVIDENCE
   ```
   OR spawn Review subagent:
   ```javascript
   Task({ subagent_type: "Plan", prompt: "Apply Rule of Five: 3 passes..." })
   ```

3. **Include TDD in plan steps:**
   ```markdown
   3. [serial] Implement user service
      - TDD: Write failing test FIRST
      - Evidence: Test fails -> passes -> coverage >=80%
   ```

**Emergency bypass:** Add `[PLAN-BYPASS]` to plan file (audited)

**Full workflow:** Read `workflows/plan.md`

</plan_mode_enforcement>

<domain_routing>

Load domain skills based on task context:

| Domain | Skill | Load When |
|--------|-------|-----------|
| Spec Writing | `Skill({ skill: "devtools:spec-writing" })` | Requirements, specs, project briefs, planning |
| React/UI | `Skill({ skill: "devtools:react" })` | Components, tsx, hooks, tailwind |
| Solidity | `Skill({ skill: "devtools:solidity" })` | Smart contracts, foundry, forge |
| Database | `Skill({ skill: "devtools:drizzle" })` | Schemas, migrations, queries |
| Testing | `Skill({ skill: "devtools:vitest" })` | Unit tests, mocks, coverage |
| E2E Testing | `Skill({ skill: "devtools:playwright" })` | Browser tests, page objects |
| API | `Skill({ skill: "devtools:api" })` | Endpoints, oRPC routes |
| Git | `Skill({ skill: "devtools:git" })` | Commits, branches, PRs |
| Turborepo | `Skill({ skill: "devtools:turbo" })` | Monorepo, pipelines, caching |
| Validation | `Skill({ skill: "devtools:zod" })` | Schemas, parsing, type safety |
| Auth | `Skill({ skill: "devtools:better-auth" })` | Authentication, sessions |
| Blockchain | `Skill({ skill: "devtools:viem" })` | Web3, transactions, wallets |
| Indexing | `Skill({ skill: "devtools:thegraph" })` | Subgraphs, event indexing |
| Animation | `Skill({ skill: "devtools:motion" })` | Framer Motion, transitions |
| Charts | `Skill({ skill: "devtools:recharts" })` | Data visualization |
| i18n | `Skill({ skill: "devtools:i18n" })` | Translations, localization |
| Logging | `Skill({ skill: "devtools:pino" })` | Structured logging |
| Infrastructure | `Skill({ skill: "devtools:helm" })` | Kubernetes, Helm charts |
| IaC | `Skill({ skill: "devtools:terraform" })` | Terraform, OpenTofu |
| Debugging | `Skill({ skill: "devtools:troubleshooting" })` | Errors, debugging workflow |
| TDD | `Skill({ skill: "devtools:tdd-typescript" })` | RED-GREEN-REFACTOR cycle |
| LSP | `Skill({ skill: "devtools:typescript-lsp" })` | Go to definition, references |
| Shadcn | `Skill({ skill: "devtools:shadcn" })` | UI components, primitives |
| Radix | `Skill({ skill: "devtools:radix" })` | Accessible primitives |
| Code refactor | `Skill({ skill: "devtools:ast-grep" })` | Mass rename, pattern replace |
| Durable exec | `Skill({ skill: "devtools:restate" })` | Fault-tolerant workflows |

**When to load:**
- Load domain skill BEFORE starting work in that area
- Multiple skills can be loaded for cross-cutting tasks
- Skills provide patterns, MCP guidance, and constraints
- **Load spec-writing when**: entering plan mode, writing requirements, creating project briefs, defining features

</domain_routing>

<feature_workflow>

## Feature Development (7-Phase Workflow)

For new features, follow this systematic workflow (based on Anthropic's feature-dev plugin):

| Phase | Focus | Agents |
|-------|-------|--------|
| 1. Discovery | Clarify requirements | User questions |
| 2. Exploration | Trace similar features, architecture | 2-3 Explore agents (parallel) |
| 3. Questions | Resolve all ambiguities | User clarification |
| 4. Design | Architecture blueprints | 2-3 Plan agents with different focuses |
| 5. Implementation | Build feature | TDD + incremental |
| 6. Review | Quality validation | 3 code-reviewer agents |
| 7. Summary | Document and next steps | Main thread |

**Phase 2 Pattern - Parallel Exploration:**
```javascript
// Launch simultaneously with different focuses
Task({ subagent_type: "Explore", prompt: "Trace execution path for similar feature X..." })
Task({ subagent_type: "Explore", prompt: "Map architecture layers touched by feature..." })
Task({ subagent_type: "Explore", prompt: "Find integration patterns in similar code..." })
```

**Phase 4 Pattern - Architecture Options:**
```javascript
// Different trade-off focuses
Task({ subagent_type: "Plan", prompt: "Design minimal approach - fewest changes..." })
Task({ subagent_type: "Plan", prompt: "Design clean architecture approach - best patterns..." })
Task({ subagent_type: "Plan", prompt: "Design pragmatic approach - fastest to ship..." })
```

**Phase 6 Pattern - Parallel Review:**
```javascript
// Different quality lenses
Task({ subagent_type: "general-purpose", prompt: "Review for simplicity and DRY..." })
Task({ subagent_type: "general-purpose", prompt: "Review for bugs and correctness..." })
Task({ subagent_type: "general-purpose", prompt: "Review for conventions and CLAUDE.md..." })
```

**Key Principle:** Each phase returns "essential files to read" → main thread reads all before proceeding.

</feature_workflow>

<pr_review_agents>

## PR Review Agents (6 Specialized Reviewers)

For comprehensive PR review, use aspect-based agent selection (based on Anthropic's pr-review-toolkit):

| Agent | Focus | When to Use |
|-------|-------|-------------|
| **code-reviewer** | CLAUDE.md compliance, bugs | Always |
| **comment-analyzer** | Comment accuracy vs code | Comments added/changed |
| **pr-test-analyzer** | Behavioral test coverage | Test files changed |
| **silent-failure-hunter** | Error handling, logging | Any code changes |
| **type-design-analyzer** | Type encapsulation, invariants | Type definitions changed |
| **code-simplifier** | Post-implementation refinement | After implementation |

**Agent Selection Logic:**
```javascript
// Determine agents based on file types changed
const changedFiles = await getGitDiff();
const agents = ['code-reviewer']; // Always include

if (changedFiles.some(f => f.includes('.test.'))) agents.push('pr-test-analyzer');
if (hasCommentsAdded(changedFiles)) agents.push('comment-analyzer');
if (hasTypeChanges(changedFiles)) agents.push('type-design-analyzer');
agents.push('silent-failure-hunter'); // Always check error handling
```

**Confidence Scoring (0-100):**
- Only report issues with confidence ≥ 80
- Filters false positives, focuses on actionable feedback
- See `<confidence_scoring>` section

**Silent Failure Hunter Rules:**
- Zero tolerance for errors without logging
- Every catch block must log or re-throw
- Error boundaries must report

**Type Design Analyzer Dimensions:**
| Dimension | Question |
|-----------|----------|
| Encapsulation | Are implementation details hidden? |
| Invariant Expression | Does the type enforce constraints? |
| Usefulness | Is the type practical to use? |
| Enforcement | Are invariants enforced at boundaries? |

</pr_review_agents>

<confidence_scoring>

## Confidence Scoring Pattern (0-100)

For review findings, apply confidence scoring to filter false positives:

**Scale:**
| Score | Meaning | Action |
|-------|---------|--------|
| 0-25 | Low confidence - likely false positive | Don't report |
| 26-50 | Moderate - might be real but minor | Don't report |
| 51-79 | High confidence but uncertain | Don't report |
| 80-100 | Very high - definitely real and important | **Report** |

**Threshold: Only report issues scoring ≥ 80**

**What qualifies for 80+:**
- Explicitly violates CLAUDE.md or project guidelines
- Directly impacts functionality
- Introduces security vulnerability
- Breaks existing behavior

**What scores below 80:**
- Pre-existing issues not introduced by current changes
- Style preferences not in guidelines
- Pedantic nitpicks
- General "best practices" not project-specific
- Issues that linter/compiler will catch

**Implementation Pattern:**
```javascript
// For each finding, score independently
for (const issue of issues) {
  const confidence = await scoreConfidence(issue, {
    isInChanges: true,
    isInGuidelines: checkClaudeMd(issue),
    impactsFunctionality: assessImpact(issue),
    isPreExisting: checkGitBlame(issue)
  });

  if (confidence >= 80) {
    reportIssue(issue, confidence);
  }
}
```

**Multi-Agent Scoring:**
For highest accuracy, score each issue with independent agent (Haiku for speed):
```javascript
// Parallel confidence scoring
const scores = await Promise.all(
  issues.map(issue =>
    Task({ model: "haiku", prompt: `Score confidence 0-100 for: ${issue}` })
  )
);
```

</confidence_scoring>

<knowledge_verification>

**Verify knowledge currency before implementing with frameworks/libraries.**

AI knowledge has cutoff dates. Before implementing:

1. **Check version awareness:**
   - "Which version of [React/Next.js/Tailwind/etc.] are you familiar with?"
   - Compare against project's package.json versions

2. **Fetch current docs when outdated:**
   ```javascript
   // Use Context7 MCP for up-to-date documentation
   MCPSearch({ query: "select:mcp__plugin_devtools_context7__resolve_library_id" });
   mcp__plugin_devtools_context7__resolve_library_id({ libraryName: "react" });
   mcp__plugin_devtools_context7__query_docs({ libraryId: "/vercel/next.js", query: "app router" });
   ```

3. **State assumptions explicitly:**
   - "I'm assuming React 19 patterns (use hooks, RSC support)"
   - "Using Tailwind v4 syntax (CSS-first config)"
   - User can correct before implementation begins

**Common version-sensitive areas:**
| Library | Check For |
|---------|-----------|
| React | Server Components, use() hook, Actions |
| Next.js | App Router vs Pages, Server Actions |
| Tailwind | v4 CSS config vs v3 JS config |
| TypeScript | satisfies, const assertions, decorators |
| Node.js | fetch built-in, test runner, ESM |

**When in doubt, fetch docs.** Context7 provides current documentation for major libraries.

</knowledge_verification>

<coding_rules>

Read relevant rules BEFORE writing code:

| Rule | Summary | Path |
|------|---------|------|
| spec-writing | Six Core Areas, Boundaries, Goal Framing | `devtools/rules/spec-writing.md` |
| architecture | Functional Core, Imperative Shell | `devtools/rules/architecture.md` |
| srp | Single Responsibility Principle | `devtools/rules/srp.md` |
| testing | TDD, coverage requirements | `devtools/rules/testing.md` |
| typescript | TypeScript standards | `devtools/rules/typescript.md` |
| error-handling | Error patterns, Result types | `devtools/rules/error-handling.md` |
| react | Component guidelines | `devtools/rules/react.md` |
| module-design | Module/package design | `devtools/rules/module-design.md` |
| imports | NO RE-EXPORTS EVER | `devtools/rules/imports.md` |
| simplicity | KISS, avoid over-engineering | `devtools/rules/simplicity.md` |
| truthfulness | Verify claims, prevent hallucination | `devtools/rules/truthfulness.md` |
| fix-documentation | Document bug fixes with explanatory comments | `devtools/rules/fix-documentation.md` |

**When to read:**
- `spec-writing` - Plan mode, requirements, specs, project briefs
- `architecture` + `srp` - System design, new features
- `testing` - Any code changes (TDD required)
- `typescript` + `imports` - All TypeScript work
- `react` - Any React/UI work
- `simplicity` - Before adding abstractions
- `truthfulness` - Always (auto-applied)
- `fix-documentation` - When fixing bugs

</coding_rules>

<sub_agent_setup>

**When spawning Task agents, ALWAYS include:**

```
REQUIRED: Load skills first.
Skill({ skill: "flow:enhance" })
Skill({ skill: "devtools:rule-of-five" })

You are a [Explore|Plan|General-purpose] agent.
Read your workflow from workflows/[type].md

MANDATORY:
- Apply Rule of Five (5 passes minimum)
- Evidence required for completion
- No "should work" - only verified facts
- TDD for code changes: failing test FIRST
```

**Example - spawning Explore agent:**

```javascript
Task({
  subagent_type: "Explore",
  prompt: `REQUIRED: Load skills first.
Skill({ skill: "flow:enhance" })
Skill({ skill: "devtools:rule-of-five" })

You are an Explore agent. Read workflows/explore.md

TASK: Find where authentication is handled in this codebase.

Apply 5-angle investigation. Cite file:line for findings.`
})
```

</sub_agent_setup>

<quick_reference>

**Starting any task:**
1. Load enhance (already loaded at session start)
2. Load Rule of Five: `Skill({ skill: "devtools:rule-of-five" })`
3. Identify domain → load domain skill
4. Identify rules → read relevant rules
5. Apply Rule of Five throughout

**Spawning agents:**
1. Include enhance + rule-of-five load instructions
2. Specify agent type
3. Reference appropriate workflow
4. Require evidence

**Before completing:**
- [ ] 5 passes done (or converged earlier)
- [ ] Evidence provided (command output, results)
- [ ] Would bet $100 this is correct
- [ ] No "should work" language used

**Before committing code changes (ENFORCED):**
- [ ] Minimum 3 review passes documented (Pass 1, Pass 2, Pass 3)
- [ ] Findings section present (even if empty: "No findings")
- [ ] Convergence status stated
- [ ] Commits will be BLOCKED without documented passes

</quick_reference>

<enforcement_hooks>

## Rule of Five Enforcement (AUTOMATED)

These hooks automatically enforce Rule of Five during implementation:

| Hook | When | Action |
|------|------|--------|
| `edit-review-checkpoint.sh` | Every 10 Edit/Write calls | BLOCK until review pass documented |
| `review-enforcer.sh` | Stop (session end) | BLOCK if <3 passes for code changes |
| `auto-review-spawner.sh` | Stop (session end) | Auto-spawn reviewer agents if no review |
| `commit-review-gate.sh` | git commit | BLOCK without documented passes |

**Checkpoint behavior:**
- After 10 code file edits, you must document a review pass before more edits
- Pass format: `## Pass N: Review - EVIDENCE`
- Threshold configurable via `CLAUDE_REVIEW_CHECKPOINT` env var

**Auto-spawn behavior:**
- If >5 code edits AND no passes documented, spawns these agents:
  - `pr-review-toolkit:code-reviewer` (always)
  - `pr-review-toolkit:silent-failure-hunter` (always)
  - `pr-review-toolkit:pr-test-analyzer` (if test files changed)
  - `pr-review-toolkit:type-design-analyzer` (if type definitions changed)

**Override markers (audited to /tmp/claude-audit/):**
- `[SKIP-CHECKPOINT]` - Bypass edit checkpoint
- `[REVIEW-BYPASS]` - Bypass review enforcer at Stop

</enforcement_hooks>

<workflow_files>

Detailed patterns for each agent type:

| Workflow | File | Key Focus |
|----------|------|-----------|
| Explore | `workflows/explore.md` | 5-angle investigation, confidence scoring |
| Plan | `workflows/plan.md` | Parallelization mapping, merge walls |
| General-purpose | `workflows/general-purpose.md` | 30-second reality check, TDD |
| Review | `workflows/review.md` | High-signal filtering, $100 bet test |
| PR Awareness | `workflows/pr-awareness.md` | Thread tracking, opportunistic resolution |
| Agent Orchestration | `workflows/agent-orchestration.md` | Git worktrees, parallel agents, dependency mapping |
| Orchestration | `workflows/orchestration.md` | Two-agent review, delegation tiers, kill criteria |

</workflow_files>

<guidelines>

**Quality foundations (why these matter):**

- **Rule of Five** - Multiple passes catch issues single-pass misses
- **Evidence** - "Should work" is the enemy of "does work"
- **TDD for code** - Tests prevent regressions and document behavior
- **Domain skills first** - Patterns prevent reinventing wheels
- **Sub-agent skill loading** - Agents need context to do quality work

These aren't arbitrary rules - they're patterns that consistently produce better outcomes. Apply judgment; deviate when you have good reason.

**TDD Reminder (recommended, not enforced):**

When writing implementation code, consider test-driven development:
- **RED**: Write a failing test first that defines expected behavior
- **GREEN**: Write minimal code to make the test pass
- **REFACTOR**: Improve code while keeping tests green

TDD helps catch bugs early and documents intent. Load `devtools:tdd-typescript` for detailed patterns.

</guidelines>

<success_criteria>

- [ ] Rule of Five applied (minimum 5 passes, or converged earlier with evidence)
- [ ] Correct domain skills loaded
- [ ] Relevant coding rules read
- [ ] Sub-agents properly configured
- [ ] Evidence provided for all claims
- [ ] No "should work" language

</success_criteria>
