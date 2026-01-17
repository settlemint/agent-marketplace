# Cross-Checking Patterns

Use secondary analysis (Codex MCP, devil's advocate agents) to verify critical work. Treat AI output as "over-confident pair programmer" requiring validation.

## When to Cross-Check

| Context | Cross-Check Method | Threshold |
|---------|-------------------|-----------|
| Security-sensitive code | Codex security analysis | Always |
| Architectural decisions | Codex architectural critique | >3 files affected |
| Complex algorithms | Devil's advocate agent | Non-obvious logic |
| External integrations | Context7 + Codex | Third-party APIs |
| Bug fixes | Regression verification | All fixes |

## Codex MCP for Second Opinion

Use Codex when you need deep analysis that benefits from extended reasoning.

### Security Analysis

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Security review this implementation:

[code snippet]

Analyze for:
1. Injection vulnerabilities (SQL, command, XSS)
2. Authentication/authorization gaps
3. Data exposure risks
4. Input validation issues
5. Race conditions

For each finding: severity, location, remediation.`
});
```

### Architectural Critique

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Architectural review of this design:

[proposed architecture or code structure]

Evaluate:
1. Does this solve the right problem?
2. Is it over-engineered for the use case?
3. What are the coupling/cohesion concerns?
4. How will this evolve? What breaks first?
5. What would you do differently?

Be critical. Challenge assumptions.`
});
```

### Algorithm Verification

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Verify this algorithm is correct:

[algorithm implementation]

Check:
1. Edge cases: empty input, single element, duplicates
2. Boundary conditions: off-by-one, overflow
3. Invariants: does the loop maintain correctness?
4. Termination: does it always finish?
5. Complexity: is the stated O(n) accurate?

Provide counterexamples if bugs found.`
});
```

## Devil's Advocate Agent

Spawn a review agent with explicit instructions to find problems.

```javascript
Task({
  subagent_type: "general-purpose",
  description: "Devil's advocate review",
  prompt: `You are a devil's advocate reviewer. Your job is to find problems.

REQUIRED: Load skills first.
Skill({ skill: "flow:enhance" })
Skill({ skill: "devtools:rule-of-five" })

Review this implementation:
[code or plan]

Your mandate:
1. Find at least 3 potential issues (or prove there are none)
2. Challenge every assumption
3. Consider what could go wrong in production
4. Identify what's missing, not just what's wrong
5. Rate findings: P0 (blocker), P1 (serious), P2 (minor)

Do NOT rubber-stamp. Do NOT say "looks good" without evidence.
If you find nothing wrong, explain WHY it's correct.`
});
```

## When Cross-Checking is Worth the Cost

Cross-checking uses tokens. Use it strategically:

### Always Cross-Check

- Authentication/authorization logic
- Cryptographic implementations
- Financial calculations
- Data deletion operations
- External API integrations

### Often Cross-Check

- Complex state management
- Concurrent/async operations
- Database migrations
- Public API changes
- Performance-critical paths

### Rarely Cross-Check

- Simple CRUD operations
- UI styling changes
- Documentation updates
- Test additions (unless testing complex logic)
- Straightforward refactors

## Responding to Cross-Check Results

When Codex or devil's advocate finds issues:

1. **Acknowledge the finding** - Don't dismiss without investigation
2. **Verify it's real** - Check if the issue actually exists
3. **Fix or document** - Either fix it or document why it's acceptable
4. **Update original** - If fixing, verify the fix addresses the root cause

```
WRONG: "Codex found an issue but I think it's fine"
RIGHT: "[verified] Codex flagged SQL injection risk. Checked implementation:
        parameterized query used at db.ts:45. False positive - using $1 placeholders."

RIGHT: "[verified] Codex found missing input validation. Added zod schema at
        handler.ts:23. Re-verified with Codex - now passes."
```

## Integration with Rule of Five

Cross-checking fits naturally into the 5-pass pattern:

| Pass | Standard Focus | + Cross-Check |
|------|---------------|---------------|
| 1. Generation | Create output | - |
| 2. Standard Review | Syntax, bugs | - |
| 3. Deep Review | Edge cases, errors | Codex for complex logic |
| 4. Architecture | Patterns, coupling | Codex architectural critique |
| 5. Existential | Right problem? | Devil's advocate on approach |

## Anti-Patterns

- **Skipping cross-check for "simple" security code** - Security is never simple
- **Ignoring Codex findings without verification** - May be right
- **Over-using cross-check** - 100% coverage wastes tokens
- **Single cross-check tool** - Use both Codex AND devil's advocate for critical code
- **No follow-up on findings** - Cross-check is useless without action
