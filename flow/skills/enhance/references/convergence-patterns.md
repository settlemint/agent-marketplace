# Convergence Patterns Reference

Shared patterns for Rule of Five agent enhancement skills.

## Core Philosophy

Generating is easy; reviewing deeply is hard. First outputs are drafts, not finals. Apply 4-5 iterative passes before declaring work complete.

## Self-Assessment Questions

Before declaring completion, ask:

- "Would I be proud to show this to a senior engineer?"
- "Are there obvious improvements I'm skipping?"
- "Is this truly as good as it can get, or am I rushing?"

## Convergence Signals

**STOP refining when:**

- Current pass finds no issues
- Changes are purely cosmetic
- Same issue oscillating back and forth (force a decision)
- You can honestly declare "this is as good as it can get"

**CONTINUE refining when:**

- New P1/P2 severity issues discovered
- Untested dimensions remain (correctness, integration, edge cases)
- Conflicting changes detected
- Self-assessment questions answered "no"

## Evidence Requirements

Every task completion MUST include observable evidence.

**Evidence format:**

```
EVIDENCE:
- Command: <what was run>
- Output: <what was observed>
- Observed: <interpretation>
```

**NO EVIDENCE = NOT COMPLETE**

If you cannot obtain evidence (e.g., no tests, no way to run):

1. State explicitly: "Cannot verify - no test infrastructure"
2. Suggest verification steps for the user
3. Mark confidence as `[unverified]`

## Confidence Scoring

Rate each finding by certainty level:

| Level      | Marker         | Meaning                                    |
| ---------- | -------------- | ------------------------------------------ |
| Verified   | `[verified]`   | Observed directly in code, cited file:line |
| Likely     | `[likely]`     | Multiple indicators, high confidence       |
| Inferred   | `[inferred]`   | Logical conclusion from evidence           |
| Speculated | `[speculated]` | Hypothesis, needs verification             |

## Phrases to Avoid vs Use

**Avoid (indicate insufficient verification):**

- "This should work now"
- "I've fixed the issue" (especially 2nd+ time)
- "Try it now" (without trying yourself)
- "The logic is correct so..."

**Use (demonstrate verification):**

- "I ran `bun run test` and all 47 tests pass"
- "I clicked the button and saw the modal appear"
- "The API returns 200 with the expected payload"
- "Build completes with exit code 0"
