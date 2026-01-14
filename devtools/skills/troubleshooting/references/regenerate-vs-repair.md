# Regenerate vs Repair

When to delete and regenerate code vs trying to fix it.

## Core Principle

Generating code is easier (for AIs) than rewriting it. When agents struggle to fix broken code, regeneration is often faster and produces better results.

## The < 1 Year Rule

Plan for all code to be replaced within a year. This mindset enables:

- Faster decision-making on repair vs regenerate
- Less attachment to existing implementations
- Willingness to delete and start fresh
- Building for current needs, not imagined futures

## When to Regenerate

| Signal                    | Description                                      |
| ------------------------- | ------------------------------------------------ |
| **Mass breakage**         | Tests break en masse after refactoring           |
| **Multiple failures**     | Agent fails 2-3 times to fix the same issue      |
| **Circular fixes**        | Fixing one thing breaks another repeatedly       |
| **Architecture mismatch** | Old design doesn't fit new requirements          |
| **Cognitive overload**    | Agent context exhausted reasoning about old code |

## When to Repair

| Signal                | Description                                |
| --------------------- | ------------------------------------------ |
| **Isolated issue**    | Problem is contained to specific code path |
| **Clear fix**         | Agent identifies solution on first attempt |
| **Stable context**    | Surrounding code unchanged and working     |
| **Low blast radius**  | Fix won't cascade to other components      |
| **Knowledge encoded** | Code contains hard-won domain knowledge    |

## Test Regeneration Pattern

When tests break after refactoring:

```
TRADITIONAL APPROACH (slow):
1. Run tests → 47 failures
2. Fix test 1 → reason about old vs new behavior
3. Fix test 2 → reason about old vs new behavior
4. ... repeat 47 times
5. Struggle with edge cases and mocks

REGENERATION APPROACH (fast):
1. Run tests → 47 failures
2. Delete all failing tests
3. "Generate comprehensive tests for the new implementation"
4. Agent focuses only on new behavior
5. Better coverage, faster completion
```

## Subsystem Regeneration

When an entire subsystem is broken:

```
BEFORE:
- Logging system with 15 interdependent files
- 3 different configuration mechanisms
- Legacy compatibility hacks
- No one understands it fully

REGENERATION:
1. Document what the system should do (not how it does it)
2. Delete the entire subsystem
3. "Implement a logging system that does X, Y, Z"
4. Result: cleaner design, modern patterns, agent-friendly code
```

## Decision Framework

Ask these questions:

1. **How many times has the agent tried to fix this?**
   - 1-2 times: Keep repairing
   - 3+ times: Consider regeneration

2. **Is the agent struggling to understand the existing code?**
   - No: Repair is probably fine
   - Yes: Regeneration may be faster

3. **Does the fix require understanding historical context?**
   - No: Repair
   - Yes: Regeneration (you'll document requirements anyway)

4. **Is the code well-tested?**
   - Yes, with passing tests: Repair carefully
   - No, or tests are broken: Regeneration opportunity

5. **How much of the system is affected?**
   - < 20%: Repair
   - > 50%: Strongly consider regeneration

## Anti-Patterns

| Anti-Pattern           | Problem                                                     |
| ---------------------- | ----------------------------------------------------------- |
| **Sunk cost fallacy**  | "We already spent time on this" - irrelevant                |
| **Fear of deletion**   | "What if we need it later?" - you can recreate it           |
| **Patch accumulation** | Fixes on fixes on fixes - regenerate instead                |
| **Archaeology mode**   | Trying to understand ancient code - document and regenerate |

## Integration with Troubleshooting

When troubleshooting reveals regeneration opportunity:

1. Stop repair attempts
2. Document what the code SHOULD do
3. Document any edge cases discovered during debugging
4. Delete the problematic code
5. Regenerate from documented requirements
6. Verify edge cases are handled

## Key Insight

Agents are trained to generate, not to archaeology. Fighting against broken code burns context and produces worse results. Embrace deletion as a valid strategy.
