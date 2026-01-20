# Sufficiency Evaluation Checklist

Detailed criteria for evaluating whether subagent results are sufficient for implementation contexts.

## General Sufficiency Questions

Always ask these questions when evaluating any subagent result:

### Completeness
- [ ] Does the result address ALL items in my initial query?
- [ ] Are there obvious gaps in the information provided?
- [ ] Did the subagent explicitly say it couldn't find something?

### Actionability
- [ ] Can I write code based on this information alone?
- [ ] Are file paths and line numbers specific?
- [ ] Do I understand the "why" not just the "what"?

### Confidence
- [ ] Would I bet this fix works on first try?
- [ ] Are there assumptions I'm making that weren't validated?
- [ ] Did the subagent show both success and failure paths?

## Implementation-Specific Checklists

### Bug Investigation

For understanding bugs before fixing:

| Criterion | Sufficient If | Insufficient If |
|-----------|---------------|-----------------|
| Root cause | Actual cause identified, not just symptoms | Only showing error message |
| Reproduction | Steps to trigger are clear | "Sometimes fails" |
| Scope | All affected code paths identified | Single file focus |
| Related code | Error handling and boundaries shown | Only the failing line |
| Test coverage | Existing tests (or lack thereof) documented | Tests not checked |

**Follow-up triggers:**
- Error shown without error handling path
- "Fails when..." without showing success case
- Async code without showing await/promise chain
- State mutation without showing all readers

### Test Failure Analysis

For understanding why tests fail:

| Criterion | Sufficient If | Insufficient If |
|-----------|---------------|-----------------|
| Assertion | Exact failing assertion with expected vs actual | Just "test failed" |
| Setup | Test fixtures and mocks documented | Setup not shown |
| Dependencies | External dependencies (DB, API) identified | Isolation unclear |
| Timing | Async behavior and waits documented | Race conditions ignored |
| Related tests | Passing similar tests identified | No comparison baseline |

**Follow-up triggers:**
- Mock mentioned without showing mock implementation
- "Timeout" without showing async code
- State assertion without showing state initialization
- Flaky test without timing analysis

### Reviewer Comment Investigation

For addressing code review feedback:

| Criterion | Sufficient If | Insufficient If |
|-----------|---------------|-----------------|
| Context | Full context around flagged code shown | Just the flagged line |
| Concern validity | Can confirm or refute the concern | Ambiguous |
| Impact | Scope of potential issue understood | Local view only |
| Precedent | Similar patterns in codebase identified | No comparison |
| Fix options | Multiple resolution approaches visible | Single path forward |

**Follow-up triggers:**
- Reviewer mentions pattern but pattern not found
- Security concern without showing data flow
- Performance concern without showing hot path
- "Potential" issue without concrete scenario

### Legacy Code Analysis

For understanding code without tests:

| Criterion | Sufficient If | Insufficient If |
|-----------|---------------|-----------------|
| Behavior | All code paths documented | Happy path only |
| Side effects | External interactions identified | Pure logic assumption |
| Invariants | What must always be true is clear | Implicit assumptions |
| History | Recent changes and their purpose known | No git history |
| Dependencies | Callers and callees mapped | Isolated view |

**Follow-up triggers:**
- Function with side effects not showing all effects
- Conditional logic without showing all branches
- External calls without showing error handling
- State changes without showing all readers

### Implementation Research

For gathering patterns before writing new code:

| Criterion | Sufficient If | Insufficient If |
|-----------|---------------|-----------------|
| Examples | Similar implementations found | No comparable code |
| Patterns | Established patterns documented | Ad-hoc approaches |
| Conventions | Naming/structure conventions clear | Inconsistent examples |
| Integration | How to wire in new code is clear | Isolated examples |
| Tests | Test patterns for similar code found | Testing approach unclear |

**Follow-up triggers:**
- Example without showing its tests
- Pattern without showing variations
- Convention mentioned without examples
- Integration point without showing protocol

## Refinement Request Templates

### Root Cause Clarification

```
Your findings show the symptom but not the cause.

DEEPER QUESTIONS:
1. WHY does [SYMPTOM] occur? What triggers it?
2. What is the code path from [TRIGGER] to [FAILURE]?
3. When does this code path succeed vs fail?

WHY NEEDED: Can't write a fix without understanding causation.
```

### Test Context Request

```
I need more context about the test environment.

MISSING PIECES:
1. What does the beforeEach/setup do?
2. What mocks are in place and what do they return?
3. Is there a passing test I can use as a reference?

WHY NEEDED: Fix may be in test setup, not production code.
```

### Error Path Request

```
You showed the happy path. I need the error path.

ERROR HANDLING QUESTIONS:
1. What happens when [OPERATION] fails?
2. Where are errors caught and transformed?
3. What does the caller see when this throws?

WHY NEEDED: Bug may be in error handling, not main logic.
```

### Concurrency Request

```
This looks like a timing issue. Need concurrency context.

TIMING QUESTIONS:
1. What other operations could be happening simultaneously?
2. Where are the await points in this flow?
3. Is there any locking or queuing mechanism?

WHY NEEDED: Race conditions need synchronization analysis.
```

## Cycle Budget Guidelines

| Investigation Type | Recommended Max Cycles |
|-------------------|----------------------|
| Simple bug fix | 1-2 cycles |
| Flaky test | 2-3 cycles |
| Security issue | 3 cycles (be thorough) |
| Legacy modification | 2-3 cycles |
| Reviewer concern | 1-2 cycles |

**When to stop early:**
- Root cause is definitively identified
- Subagent confirms no more relevant code exists
- Follow-up returns same information

**When to use all 3 cycles:**
- Async/concurrent code
- Security-sensitive paths
- Cross-module interactions
- Production incidents

## Red Flags Requiring Follow-up

Always request follow-up if you see:

1. **"Probably"** or **"likely"** - Indicates uncertainty
2. **"I didn't find"** - May have looked in wrong place
3. **Single file focus** - Bugs often span files
4. **No error handling shown** - Usually relevant
5. **"Works as expected"** - But what IS expected?
6. **Missing line numbers** - Can't verify without specifics
