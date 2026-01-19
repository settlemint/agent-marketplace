# Codex Analysis Patterns

Systematic analysis techniques for trade-off evaluation, coupling analysis, and edge case discovery.

## Table of Contents

- [Core Principle](#core-principle)
- [Trade-Off Analysis](#trade-off-analysis)
- [Coupling Analysis](#coupling-analysis)
- [Pattern Fit Analysis](#pattern-fit-analysis)
- [Edge Case Discovery](#edge-case-discovery)
- [Security Analysis](#security-analysis)
- [Complexity Assessment](#complexity-assessment)
- [Research-Then-Reason Pattern](#research-then-reason-pattern)
- [Cross-Checking Patterns](#cross-checking-patterns)
  - [When to Cross-Check](#when-to-cross-check)
  - [Devil's Advocate Agent](#devils-advocate-agent)
  - [Security Analysis Prompt](#security-analysis-prompt)
  - [Architectural Critique Prompt](#architectural-critique-prompt)
- [Knowledge Version Verification](#knowledge-version-verification)
- [Anti-Patterns](#anti-patterns)

## Core Principle

Use reasoning-first analysis for multi-step problems. Provide sufficient context and ask multi-dimensional questions, not yes/no queries.

## Trade-Off Analysis

Compare options across six dimensions:

### Analysis Template

```
Compare Option A vs Option B:

1. **Complexity**
   - Implementation effort
   - Cognitive load for maintainers
   - Learning curve

2. **Performance**
   - Runtime characteristics
   - Memory usage
   - Scalability under load

3. **Scalability**
   - Horizontal scaling
   - Data volume growth
   - Team/org scaling

4. **Testability**
   - Unit test coverage feasibility
   - Integration test complexity
   - Mocking requirements

5. **Extensibility**
   - Future feature accommodation
   - API evolution support
   - Plugin/extension points

6. **Team Familiarity**
   - Existing codebase patterns
   - Team expertise
   - Documentation availability

**Weighted Recommendation:**
Based on project priorities (list weights), recommend Option [X] because [rationale].
```

### Usage in Planning

When evaluating architecture decisions:
1. Identify 2-3 viable options
2. Run trade-off analysis on each pair
3. Document decision with explicit trade-offs

## Coupling Analysis

Evaluate how components interact:

### Metrics

**Afferent Coupling (Ca):** Incoming dependencies
- How many other modules depend on this one?
- High Ca = changes here affect many places

**Efferent Coupling (Ce):** Outgoing dependencies
- How many modules does this one depend on?
- High Ce = vulnerable to changes elsewhere

**Instability (I):** Ce / (Ca + Ce)
- Range: 0 (stable) to 1 (unstable)
- Stable modules should be abstract
- Unstable modules should be concrete

### Analysis Prompts

```
For the proposed changes, analyze:

1. **Dependency Direction**
   - Do dependencies flow toward stable abstractions?
   - Are there circular dependencies?

2. **Change Impact**
   - If module X changes, what else changes?
   - Ripple effect assessment

3. **Integration Points**
   - Where does new code touch existing code?
   - API surface area

4. **God Class Detection**
   - Is any single component doing too much?
   - Responsibility diffusion

5. **Feature Envy**
   - Does code in module A mostly use module B's data?
   - Should logic move?
```

## Pattern Fit Analysis

Check new code against existing conventions:

### Checklist

```
Evaluate pattern fit:

1. **Naming Conventions**
   - File naming matches existing patterns?
   - Variable/function naming consistent?

2. **Error Handling**
   - Same error handling patterns as codebase?
   - Consistent error types/messages?

3. **Dependency Injection**
   - Follows existing DI patterns?
   - Same lifecycle management?

4. **Testing Patterns**
   - Test structure matches existing tests?
   - Same mocking approaches?

5. **Documentation**
   - Same comment style?
   - Consistent JSDoc/docstring format?
```

## Edge Case Discovery

Systematically explore boundary conditions:

### Categories

**Null/Undefined:**
- What if input is null?
- What if optional fields missing?
- What if array is empty?

**Boundary Values:**
- Zero, negative, MAX_INT
- Empty string vs whitespace
- Single element vs many

**Concurrency:**
- Simultaneous requests
- Race conditions
- Ordering assumptions

**Resource Exhaustion:**
- Memory limits
- Connection pool exhaustion
- Timeout scenarios

**Data Integrity:**
- Partial failures
- Inconsistent state
- Recovery paths

### Discovery Prompts

```
For each input/operation, identify:

1. **Boundary Conditions**
   - Minimum valid input
   - Maximum valid input
   - Just outside valid range

2. **Empty/Null States**
   - What if collection empty?
   - What if reference null?
   - What if string blank?

3. **Concurrent Access**
   - What if called twice simultaneously?
   - What if state changes mid-operation?

4. **Failure Modes**
   - Network failure
   - Database unavailable
   - Third-party API error

5. **Recovery Scenarios**
   - How to resume after failure?
   - Idempotency guarantees?
```

## Security Analysis

OWASP-informed review:

### Quick Checklist

```
Security review:

1. **Injection**
   - SQL/NoSQL injection points?
   - Command injection?
   - XSS vectors?

2. **Authentication**
   - Credential handling secure?
   - Session management correct?

3. **Authorization**
   - Access controls in place?
   - Privilege escalation paths?

4. **Data Exposure**
   - Sensitive data in logs?
   - PII protection?

5. **Configuration**
   - Secrets in code/config?
   - Debug modes disabled?
```

## Complexity Assessment

Evaluate cognitive and structural complexity:

### Metrics

**Cyclomatic Complexity:**
- Number of independent paths
- Target: < 10 per function

**Cognitive Complexity:**
- Mental effort to understand
- Nested conditionals, recursion

### Simplification Strategies

When complexity is high:
1. Extract helper functions
2. Replace conditionals with polymorphism
3. Use early returns
4. Decompose into smaller units

## Research-Then-Reason Pattern

Separate information gathering from analysis:

### Workflow

```
Phase 1: Research (gather facts)
- Search codebase for similar patterns
- Find relevant documentation
- Identify existing implementations

Phase 2: Reason (analyze and decide)
- Compare findings
- Evaluate trade-offs
- Synthesize recommendation
```

### Application to Planning

1. **Context phase:** Gather codebase facts
2. **Research phase:** Find patterns and approaches
3. **Architecture phase:** Reason through trade-offs
4. **Decomposition phase:** Apply patterns to tasks

## Cross-Checking Patterns

Use secondary analysis to verify critical work. Treat AI output as "over-confident pair programmer" requiring validation.

### When to Cross-Check

| Context | Method | Threshold |
|---------|--------|-----------|
| Security-sensitive code | Security analysis | Always |
| Architectural decisions | Architectural critique | >3 files affected |
| Complex algorithms | Devil's advocate agent | Non-obvious logic |
| External integrations | Docs + analysis | Third-party APIs |
| Bug fixes | Regression verification | All fixes |

### Devil's Advocate Agent

Spawn a review agent with explicit instructions to find problems:

```
Task({
  subagent_type: "general-purpose",
  description: "Devil's advocate review",
  prompt: `You are a devil's advocate reviewer. Your job is to find problems.

Review this implementation/plan:
[code or plan]

Your mandate:
1. Find at least 3 potential issues (or prove there are none)
2. Challenge every assumption
3. Consider what could go wrong in production
4. Identify what's missing, not just what's wrong
5. Rate findings: P0 (blocker), P1 (serious), P2 (minor)

Do NOT rubber-stamp. Do NOT say "looks good" without evidence.
If you find nothing wrong, explain WHY it's correct.`
})
```

### Security Analysis Prompt

```
Security review this implementation:

[code snippet]

Analyze for:
1. Injection vulnerabilities (SQL, command, XSS)
2. Authentication/authorization gaps
3. Data exposure risks
4. Input validation issues
5. Race conditions

For each finding: severity, location, remediation.
```

### Architectural Critique Prompt

```
Architectural review of this design:

[proposed architecture or code structure]

Evaluate:
1. Does this solve the right problem?
2. Is it over-engineered for the use case?
3. What are the coupling/cohesion concerns?
4. How will this evolve? What breaks first?
5. What would you do differently?

Be critical. Challenge assumptions.
```

### Responding to Cross-Check Results

When cross-check finds issues:

1. **Acknowledge** - Don't dismiss without investigation
2. **Verify** - Check if the issue actually exists
3. **Fix or document** - Either fix it or document why it's acceptable
4. **Re-verify** - Confirm the fix addresses root cause

```
WRONG: "Cross-check found an issue but I think it's fine"
RIGHT: "[verified] Found SQL injection risk. Checked: parameterized query
        used at db.ts:45. False positive - using $1 placeholders."

RIGHT: "[verified] Found missing input validation. Added zod schema at
        handler.ts:23. Re-verified - now passes."
```

## Knowledge Version Verification

Verify knowledge currency before implementing with frameworks/libraries.

### Check Version Awareness

Before implementing:

1. **State assumptions explicitly:**
   ```
   "I'm assuming React 19 patterns (use hooks, RSC support)"
   "Using Tailwind v4 syntax (CSS-first config)"
   ```

2. **Compare against package.json:**
   Check actual versions in project dependencies

3. **Fetch current docs when outdated:**
   Use Context7 MCP or WebFetch for current documentation

### Version-Sensitive Areas

| Library | Check For |
|---------|-----------|
| React | Server Components, use() hook, Actions |
| Next.js | App Router vs Pages, Server Actions |
| Tailwind | v4 CSS config vs v3 JS config |
| TypeScript | satisfies, const assertions, decorators |
| Node.js | fetch built-in, test runner, ESM |

### When in Doubt

Fetch current docs before implementing:

```
// Use Context7 MCP for library documentation
mcp__context7__resolve_library_id({ libraryName: "react" })
mcp__context7__query_docs({ libraryId: "/vercel/next.js", query: "app router" })
```

## Anti-Patterns

### Single-Dimension Analysis
Only considering one factor (e.g., only performance).

### Vague Prompts
"Is this good?" instead of specific multi-dimensional questions.

### No Evidence
Claims without code references or concrete examples.

### Yes/No Questions
"Does this work?" instead of "What are the failure modes?"

### Skipping Research
Jumping to conclusions without gathering context.

### Skipping Cross-Check for "Simple" Security
Security is never simple. Always cross-check.

### Ignoring Cross-Check Findings
May be right - verify before dismissing.

### Assuming Knowledge Currency
Always verify framework versions against project.
