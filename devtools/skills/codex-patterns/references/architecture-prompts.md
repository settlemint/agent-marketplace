# Architecture Review Prompts

## Trade-off Analysis

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Analyze architectural trade-offs:

    Option A: [description]
    Option B: [description]

    Evaluate on:
    1. Complexity (implementation + maintenance)
    2. Performance (latency, throughput, memory)
    3. Scalability (horizontal, vertical)
    4. Testability (unit, integration, e2e)
    5. Extensibility (adding features)
    6. Team familiarity (learning curve)

    Provide weighted recommendation with reasoning.`,
});
```

## Pattern Fit Analysis

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Evaluate if this code fits existing patterns:

    Existing codebase patterns:
    [summary of conventions]

    New code:
    [code to evaluate]

    Check for:
    1. Naming consistency
    2. Error handling patterns
    3. Dependency injection style
    4. Testing approach
    5. Documentation standards

    Flag deviations with severity and recommendation.`,
});
```

## Coupling Analysis

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Analyze coupling in this module:

    [module code with imports]

    Evaluate:
    1. Afferent coupling (who depends on this?)
    2. Efferent coupling (what does this depend on?)
    3. Instability metric (Ce / (Ca + Ce))
    4. Abstractness (interfaces vs implementations)

    Identify:
    - Circular dependencies
    - God classes
    - Feature envy
    - Inappropriate intimacy

    Suggest refactoring if coupling is problematic.`,
});
```
