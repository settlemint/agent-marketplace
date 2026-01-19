# Verification Patterns Reference

## Table of Contents

- [The 5-Step Gate Function](#the-5-step-gate-function)
- [Evidence Requirements by Work Type](#evidence-requirements-by-work-type)
- [Reviewer Agent Prompts](#reviewer-agent-prompts)
- [Confidence Scoring](#confidence-scoring)
- [Completion Checklist](#completion-checklist)
- [Anti-Patterns](#anti-patterns)

## The 5-Step Gate Function

Before claiming ANY completion, execute these steps in order:

### Step 1: IDENTIFY

Determine the verification command that proves the claim:

| Claim | Verification Command |
|-------|---------------------|
| "Tests pass" | `bun run test` |
| "Build succeeds" | `bun run build` |
| "Lint clean" | `bun run lint` |
| "CI passes" | `bun run ci` |
| "Feature works" | Specific user flow |

### Step 2: RUN

Execute the command fresh. Not from cache. Not from memory.

```bash
# Run NOW, not "I ran it earlier"
bun run test
```

### Step 3: READ

Read the COMPLETE output. Every line.

```
✓ auth.test.ts (5 tests)
✓ user.test.ts (3 tests)
✓ api.test.ts (12 tests)

Test Files  3 passed (3)
Tests      20 passed (20)
Duration   2.34s
```

### Step 4: VERIFY

Confirm output supports the claim:

- Exit code 0? ✓
- "20 passed" means all passed? ✓
- No warnings or skipped tests? ✓

### Step 5: CLAIM

Only NOW make the claim, with evidence:

```
Tests pass: 20/20 tests passing (bun run test, exit 0)
```

**Skipping ANY step = misrepresentation**

## Evidence Requirements by Work Type

### Unit/Integration Tests

**Claim:** "Tests pass"

**Evidence required:**
```
Test Files  X passed (X)
Tests      Y passed (Y)
Duration   Z.XXs
Exit code: 0
```

**Insufficient:**
- "I ran tests earlier"
- "Tests should pass"
- Screenshots without command output

### Linting

**Claim:** "Lint clean"

**Evidence required:**
```
$ bun run lint
✔ No ESLint warnings or errors
Exit code: 0
```

**Insufficient:**
- "I fixed the lint errors"
- Partial output

### Build

**Claim:** "Build succeeds"

**Evidence required:**
```
$ bun run build
Build completed in X.XXs
Exit code: 0
```

**Insufficient:**
- "It compiled"
- IDE showing no errors

### Bug Fixes

**Claim:** "Bug is fixed"

**Evidence required:**
1. Original symptom description
2. Reproduction steps
3. Test that failed before fix
4. Same test passing after fix
5. No regressions

**Insufficient:**
- "I changed the code"
- "It works now"

### Features

**Claim:** "Feature complete"

**Evidence required:**
1. All acceptance criteria met with demos
2. Tests covering the feature
3. CI passing
4. Visual verification (if UI)

**Insufficient:**
- "I implemented it"
- Code changes without verification

## Reviewer Agent Prompts

### Spec Compliance Reviewer

```markdown
You are a SPEC COMPLIANCE REVIEWER. Apply 3-pass review.

CRITICAL: DO NOT trust the implementer's report. Read actual code.

TASK REQUIREMENTS:
[Paste original requirements]

IMPLEMENTER REPORT:
[Paste implementer's completion report]

PASS 1 - LITERAL CHECK:
- Does code do exactly what spec says?
- Are ALL requirements addressed?
- Any requirements partially implemented?

PASS 2 - INTENT CHECK:
- Does implementation solve the actual problem?
- Any requirement misinterpretation?
- Does it integrate correctly with existing code?

PASS 3 - EDGE CASE CHECK:
- Boundary conditions handled?
- Error cases covered?
- Null/undefined scenarios?

OUTPUT FORMAT:
## Spec Compliance Review

### Pass 1: Literal - [PASS/FAIL]
- Findings: [specific issues or "No issues"]
- Evidence: [file:line references]

### Pass 2: Intent - [PASS/FAIL]
- Findings: [specific issues or "No issues"]
- Evidence: [file:line references]

### Pass 3: Edge Cases - [PASS/FAIL]
- Findings: [specific issues or "No issues"]
- Evidence: [file:line references]

### Verdict: [APPROVED / NEEDS FIXES]

If NEEDS FIXES, list specific changes required.
```

### Quality Reviewer

```markdown
You are a CODE QUALITY REVIEWER. Apply 3-pass review.

CONTEXT: Implementation passed spec compliance.
Your job is QUALITY, not correctness.

FILES TO REVIEW:
[List modified files]

PASS 1 - STYLE:
- Clear, descriptive names?
- Consistent with codebase conventions?
- No magic numbers/strings?
- Comments where needed (not excessive)?

PASS 2 - PATTERNS:
- Right level of abstraction?
- Follows existing codebase patterns?
- No unnecessary complexity?
- DRY (Don't Repeat Yourself)?

PASS 3 - MAINTAINABILITY:
- Easy to modify later?
- Clear error messages?
- Testable design?
- No hidden dependencies?

OUTPUT FORMAT:
## Code Quality Review

### Pass 1: Style - [PASS/CONCERNS]
- Findings: [issues or "No issues"]
- Evidence: [file:line references]

### Pass 2: Patterns - [PASS/CONCERNS]
- Findings: [issues or "No issues"]
- Evidence: [file:line references]

### Pass 3: Maintainability - [PASS/CONCERNS]
- Findings: [issues or "No issues"]
- Evidence: [file:line references]

### Verdict: [APPROVED / SUGGESTIONS]

If SUGGESTIONS, prioritize:
- P1: Must fix before merge
- P2: Should fix, not blocking
- P3: Nice to have
```

### Silent Failure Hunter

```markdown
You are a SILENT FAILURE HUNTER. Find error handling gaps.

FILES TO REVIEW:
[List modified files]

HUNT FOR:

1. Empty catch blocks (CRITICAL)
2. Catch blocks that only log (warn about)
3. Optional chaining that silently swallows errors
4. Return null/undefined without logging
5. Missing error handling on async operations
6. Overly broad exception catching
7. Error messages lacking context/actionability

QUESTIONS TO ANSWER:
- Is every error logged with appropriate severity?
- Does the user receive clear feedback on failures?
- Could this catch block accidentally suppress unrelated errors?
- Is fallback behavior masking underlying problems?
- Should this error propagate instead of being caught?

OUTPUT FORMAT:
## Silent Failure Analysis

### Critical Issues (must fix)
[List with file:line and explanation]

### Warnings (should fix)
[List with file:line and explanation]

### Verdict: [CLEAR / ISSUES FOUND]
```

## Confidence Scoring

For review findings, score confidence 0-100:

### Score Interpretation

| Score | Meaning | Action |
|-------|---------|--------|
| 0-25 | Likely false positive | Don't report |
| 26-50 | Might be real but minor | Don't report |
| 51-79 | Probably real, uncertain impact | Don't report |
| 80-100 | Definitely real and important | **Report** |

### What Qualifies for 80+

- Explicitly violates project guidelines
- Directly impacts functionality
- Introduces security vulnerability
- Breaks existing behavior
- Creates silent failure
- Causes data loss potential

### What Scores Below 80

- Pre-existing issues (not in current changes)
- Style preferences not in guidelines
- Pedantic nitpicks
- General "best practices" without project context
- Issues that linter/compiler catches
- Subjective improvements

## Completion Checklist

### Before Claiming Task Complete

- [ ] TDD cycle completed (RED → GREEN → REFACTOR)
- [ ] Test output captured as evidence
- [ ] Spec review passed (3 passes)
- [ ] Quality review passed (3 passes)
- [ ] Silent failure hunter found no critical issues
- [ ] Visual verification done (if UI)
- [ ] TodoWrite updated to completed

### Before Claiming Plan Complete

- [ ] All tasks marked completed
- [ ] `bun run ci` exits 0 (fresh run)
- [ ] CI output captured as evidence
- [ ] No TODO comments left in code
- [ ] No placeholder implementations
- [ ] All acceptance criteria demonstrated

### Evidence Documentation Format

```markdown
## Completion Evidence

### Tests
Command: `bun run test`
Result: 45/45 passed
Exit code: 0

### Lint
Command: `bun run lint`
Result: No warnings or errors
Exit code: 0

### Build
Command: `bun run build`
Result: Build completed in 2.3s
Exit code: 0

### CI
Command: `bun run ci`
Result: All checks passed
Exit code: 0

### Visual Verification
- Screenshot: [attached/linked]
- Interaction demo: [gif/video]
```

## Anti-Patterns

### Premature Completion

Claiming done before verification:

```
WRONG: "I finished the feature"
RIGHT: "Feature complete: tests pass (20/20), lint clean, build succeeds"
```

### Stale Evidence

Using old verification results:

```
WRONG: "Tests passed when I ran them yesterday"
RIGHT: "Tests pass: just ran `bun run test`, 20/20 passing"
```

### Partial Verification

Verifying only some aspects:

```
WRONG: "Tests pass" (didn't check lint or build)
RIGHT: "Tests pass AND lint clean AND build succeeds AND CI green"
```

### Trust Without Verify

Accepting agent reports as final:

```
WRONG: "The implementer says it's done"
RIGHT: "Ran spec review independently: verified implementation matches requirements"
```

### Assumption-Based Claims

Using confidence instead of verification:

```
WRONG: "This should work"
RIGHT: "This works: demonstrated via [specific evidence]"
```
