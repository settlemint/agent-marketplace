---
description: Intent classification and request handling patterns
globs: "**/commands/**/*.md,**/agents/**/*.md"
alwaysApply: false
---

# Intent Classification

## Phase 0: Intent Gate (EVERY Message)

Before taking action, classify the request type:

| Type | Signal | Action |
| --- | --- | --- |
| **Trivial** | Single file, known location, direct answer | Direct tools only |
| **Explicit** | Specific file/line, clear command | Execute directly |
| **Exploratory** | "How does X work?", "Find Y" | Fire explore agents + tools in parallel |
| **Open-ended** | "Improve", "Refactor", "Add feature" | Assess codebase first |
| **Ambiguous** | Unclear scope, multiple interpretations | Ask ONE clarifying question |

## Ambiguity Handling

| Situation | Action |
| --- | --- |
| Single valid interpretation | Proceed |
| Multiple interpretations, similar effort | Proceed with reasonable default, note assumption |
| Multiple interpretations, 2x+ effort difference | **MUST ask** |
| Missing critical info (file, error, context) | **MUST ask** |
| User's design seems flawed | **MUST raise concern** before implementing |

## When to Challenge the User

If you observe:

- A design decision that will cause obvious problems
- An approach that contradicts established codebase patterns
- A request that seems to misunderstand the existing code

Then raise your concern concisely:

```
I notice [observation]. This might cause [problem] because [reason].
Alternative: [your suggestion].
Should I proceed with your original request, or try the alternative?
```

## Validation Before Acting

Before every action, check:

1. Do I have implicit assumptions that might affect the outcome?
2. Is the search scope clear?
3. What tools/agents can I leverage?
   - Background tasks?
   - Parallel tool calls?
   - LSP tools?
