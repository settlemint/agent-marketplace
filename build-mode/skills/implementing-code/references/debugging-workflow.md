# Systematic Debugging Workflow

## Table of Contents

- [Core Principle](#core-principle)
- [Phase 1: Root Cause Investigation](#phase-1-root-cause-investigation)
- [Phase 2: Pattern Analysis](#phase-2-pattern-analysis)
- [Phase 3: Hypothesis Testing](#phase-3-hypothesis-testing)
- [Phase 4: Implementation](#phase-4-implementation)
- [Debugging Decision Tree](#debugging-decision-tree)
- [Red Flags](#red-flags)
- [Anti-Patterns](#anti-patterns)

## Core Principle

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

Systematic debugging proves faster than guess-and-check, even under time pressure. The process prevents thrashing and achieves first-time fix rates around 95%.

## Phase 1: Root Cause Investigation

### Step 1: Read Error Messages Completely

Don't skim. Read every line:

```
Error: Cannot read property 'user' of undefined
    at AuthService.validateToken (src/auth.ts:45:23)
    at RequestHandler.handle (src/handler.ts:78:12)
    at processRequest (src/server.ts:23:5)
```

**Extract:**
- Error type: `TypeError` (property access on undefined)
- Location: `src/auth.ts:45:23`
- Call stack: server → handler → auth
- The property: `user`
- The undefined thing: something at line 45

### Step 2: Reproduce Consistently

Before investigating, ensure you can trigger the bug reliably:

```bash
# Document exact reproduction steps
1. Start server: bun run dev
2. Make request: curl http://localhost:3000/api/protected
3. Observe: 500 error with "Cannot read property 'user'"
```

**If not reproducible:** Add logging to capture state when it occurs.

### Step 3: Review Recent Changes

```bash
git log --oneline -10
git diff HEAD~5 -- src/auth.ts
```

**Questions:**
- What changed near the error location?
- Did tests pass before the change?
- What was the intent of recent changes?

### Step 4: Trace Data Flow

Map how data moves through the system to the failure point:

```
Request arrives
    ↓
RequestHandler receives (has headers? ✓)
    ↓
Extracts token from header (token present? ?)
    ↓
Passes to AuthService.validateToken
    ↓
validateToken accesses token.user ← FAILS HERE
```

**Finding:** Token is undefined when it reaches validateToken.

### Step 5: Gather Evidence

Add targeted logging or debugging:

```typescript
// Temporary diagnostic
console.log('Token before validate:', JSON.stringify(token));
console.log('Token type:', typeof token);
console.log('Header value:', req.headers.authorization);
```

## Phase 2: Pattern Analysis

### Find Working Examples

Search codebase for similar patterns that work:

```bash
# Find other places that validate tokens
grep -r "validateToken" src/
grep -r "authorization" src/
```

### Compare Thoroughly

**Working code:**
```typescript
// src/other-handler.ts
const token = extractToken(req.headers.authorization);
if (!token) throw new UnauthorizedError();
const result = authService.validateToken(token);
```

**Broken code:**
```typescript
// src/handler.ts
const result = authService.validateToken(req.token); // Missing extraction!
```

### Document Differences

| Aspect | Working | Broken |
|--------|---------|--------|
| Token extraction | `extractToken(headers.auth)` | Direct `req.token` |
| Null check | Present | Missing |
| Error handling | Throws `UnauthorizedError` | None |

### Read Reference Implementations

If using external libraries, read their docs and examples. Don't skim.

## Phase 3: Hypothesis Testing

### Form Single Hypothesis

Based on evidence, state ONE specific hypothesis:

**Good hypothesis:**
> "The handler accesses `req.token` which doesn't exist. It should extract token from `req.headers.authorization` like other handlers do."

**Bad hypothesis:**
> "Something is wrong with authentication."

### Test Minimally

Change ONE thing to test the hypothesis:

```typescript
// Test: Add extraction
const token = extractToken(req.headers.authorization);
const result = authService.validateToken(token);
```

### Verify

1. Run reproduction steps
2. Bug still occurs? Hypothesis was wrong. Form new one.
3. Bug fixed? Proceed to Phase 4.

**Critical:** If hypothesis fails, DO NOT layer another fix on top. Revert and try different hypothesis.

## Phase 4: Implementation

### Write Failing Test First

Create a test that reproduces the bug:

```typescript
test('validateToken handles missing authorization header', async () => {
  const req = { headers: {} }; // No authorization

  await expect(handleRequest(req))
    .rejects
    .toThrow('Unauthorized');
});
```

**Verify:** Test fails with current code.

### Implement Fix

Apply the single fix identified in Phase 3:

```typescript
async function handleRequest(req: Request) {
  const token = extractToken(req.headers.authorization);
  if (!token) {
    throw new UnauthorizedError('Missing authorization');
  }
  return authService.validateToken(token);
}
```

### Verify Fix

1. New test passes
2. All existing tests pass
3. Manual reproduction steps no longer trigger bug

### Three-Strike Rule

If three fix attempts fail:

**STOP.** This indicates an architectural problem, not a simple bug.

Actions:
1. Step away from the code
2. Draw the system diagram
3. Identify the design flaw
4. Plan a refactor, not a patch

## Debugging Decision Tree

```
Bug reported
    ↓
Can reproduce? ─── No ──→ Add monitoring/logging
    ↓ Yes                   until it happens again
Read error completely
    ↓
Understand the error? ─── No ──→ Research error type
    ↓ Yes                         Document learnings
Trace data flow
    ↓
Found anomaly? ─── No ──→ Expand tracing scope
    ↓ Yes                  Add more logging
Find working pattern
    ↓
Pattern exists? ─── No ──→ Research correct approach
    ↓ Yes                   Check docs/examples
Compare to broken code
    ↓
Difference found? ─── No ──→ Deeper investigation
    ↓ Yes                     Maybe design issue
Form hypothesis
    ↓
Test hypothesis
    ↓
Fixed? ─── No ──→ New hypothesis (max 3 attempts)
    ↓ Yes           then → Architectural review
Write regression test
    ↓
Deploy fix
```

## Red Flags

These thought patterns indicate debugging failure. Return to Phase 1:

### "Just try X and see if it works"

**Problem:** Guess-and-check. No understanding.

**Action:** Stop. Trace data flow. Understand before changing.

### "I don't fully understand but this might work"

**Problem:** Hope is not a strategy.

**Action:** Stop. Invest time in understanding. It pays off.

### "One more fix attempt"

**Problem:** After 2 failures, you're likely patching symptoms.

**Action:** Step back. Is this an architectural issue?

### Proposing solutions before data flow analysis

**Problem:** Jumping to conclusions without evidence.

**Action:** Complete Phase 1 before any fix attempt.

### "It works on my machine"

**Problem:** Environment difference, not understanding.

**Action:** Compare environments systematically.

## Anti-Patterns

### Shotgun Debugging

Making multiple changes hoping one works:

```typescript
// WRONG: Multiple changes at once
token = extractToken(req.headers.authorization);
token = token || req.token;
token = token || '';
if (!token) token = getDefaultToken();
```

**Problem:** If it works, you don't know which change fixed it. If it doesn't, you've made things worse.

### Debugging by Deletion

Removing code until error disappears:

**Problem:** You've likely removed necessary functionality.

### Print Statement Overload

```typescript
console.log('here 1');
console.log('here 2');
console.log('token', token);
console.log('here 3');
```

**Better:** Strategic logging with context:

```typescript
console.log('[Auth] Validating token:', {
  hasToken: !!token,
  tokenLength: token?.length,
  source: 'handleRequest'
});
```

### Blaming Dependencies

"Must be a bug in the library."

**Truth:** 99% of the time, it's your code. Verify your usage first.

### Time Pressure Shortcuts

"We don't have time for proper debugging."

**Truth:** Quick fixes create more bugs. Systematic debugging is faster in total.
