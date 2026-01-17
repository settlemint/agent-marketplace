# AI-First Review Workflow

Structured "AI flags → human verifies" pipeline for code review. Treats AI as a high-speed intern that identifies potential issues, while humans provide judgment, context, and final accountability.

Based on: https://addyosmani.com/blog/code-review-ai/

## Philosophy

> "A computer can never be held accountable. That's your job as the human in the loop."

AI excels at pattern matching and finding known vulnerability types. Humans excel at understanding intent, evaluating risk, and making judgment calls. This workflow combines both.

## Quick Start

```
1. AI SCAN     → Run Codex/security tools on changes
2. TRIAGE      → Human verifies each AI finding
3. HUMAN-ONLY  → Check what AI misses (business logic, UX, architecture)
4. SIGN-OFF    → Human takes accountability
```

## Step 1: AI Scan

Load and run AI analysis tools on the code changes:

```javascript
// Load Codex for deep analysis
MCPSearch({ query: "select:mcp__plugin_devtools_codex__codex" });

// Security scan
mcp__plugin_devtools_codex__codex({
  prompt: `Security review of this code change:

    [paste diff or describe changes]

    Check for:
    1. Injection vulnerabilities (SQL, XSS, command injection)
    2. Authentication/authorization bypass
    3. Sensitive data exposure (logs, errors, responses)
    4. Race conditions in concurrent operations
    5. Cryptographic weaknesses

    For each finding, provide:
    - Severity: P0/P1/P2
    - Attack vector: How could this be exploited?
    - Evidence: Exact code location and why it's vulnerable`,
});
```

```javascript
// Logic error scan
mcp__plugin_devtools_codex__codex({
  prompt: `Find logic errors and edge cases:

    [paste code being reviewed]

    Check for:
    1. Null/undefined inputs
    2. Empty collections
    3. Boundary conditions (min/max values)
    4. Error propagation
    5. Concurrent access issues

    For each finding, provide:
    - Severity: P0/P1/P2
    - Trigger condition: When does this fail?
    - Evidence: Exact code path that causes the issue`,
});
```

**AI Scan Output Format:**

```
## AI Findings

| # | Type | Severity | Location | Description |
|---|------|----------|----------|-------------|
| 1 | Security | P1 | auth.ts:45 | Missing input validation |
| 2 | Logic | P2 | utils.ts:22 | Null check missing |
| 3 | Edge case | P2 | api.ts:88 | Empty array not handled |
```

## Step 2: Human Triage

For EACH AI finding, human reviewer must verify:

```markdown
### Finding #1: [Description]
Location: [file:line]

**Verification checklist:**
- [ ] Is this actually a bug? (not just unusual code)
- [ ] Does nearby code handle this case?
- [ ] Can this code path actually execute?
- [ ] What's the real severity?

**Triage decision:**
- [ ] CONFIRM: Real issue, fix needed
- [ ] DEFER: Real issue, acceptable risk (document why)
- [ ] DISMISS: False positive (explain why)

**Notes:** [Why this decision]
```

**Triage Guidelines:**

| AI Says | Human Checks | Common False Positives |
|---------|--------------|------------------------|
| "Possible SQL injection" | Is input actually used in query? | ORM-managed queries, parameterized statements |
| "Missing null check" | Does caller guarantee non-null? | TypeScript strict mode, validated inputs |
| "Potential race condition" | Is this actually concurrent? | Single-threaded handlers, idempotent operations |
| "Hardcoded secret" | Is it actually a secret? | Public API URLs, development-only values |

## Step 3: Human-Only Checks

AI systematically misses these — humans must check manually:

### Business Logic Alignment

```markdown
- [ ] Does this change match the intended behavior?
- [ ] Are edge cases handled according to product requirements?
- [ ] Will users understand this behavior?
- [ ] Are error messages helpful?
```

### Architectural Fit

```markdown
- [ ] Does this follow existing patterns in the codebase?
- [ ] Are dependencies appropriate?
- [ ] Is the abstraction level correct?
- [ ] Will this be maintainable?
```

### Performance Implications

```markdown
- [ ] Are there N+1 query patterns?
- [ ] Could this cause memory issues at scale?
- [ ] Are expensive operations cached appropriately?
- [ ] Is this blocking when it should be async?
```

### User Experience Impact

```markdown
- [ ] Is loading state handled?
- [ ] Are error states recoverable?
- [ ] Is feedback timely and clear?
- [ ] Does this work on slow connections?
```

## Step 4: Human Sign-Off

Before approving, human reviewer confirms:

```markdown
## Review Sign-Off

**AI Findings Triaged:**
- Total findings: X
- Confirmed & fixed: X
- Deferred (with justification): X
- Dismissed (false positives): X

**Human-Only Checks:**
- [ ] Business logic verified
- [ ] Architecture reviewed
- [ ] Performance considered
- [ ] UX implications checked

**Final Assessment:**
I have reviewed this code and take accountability for its correctness.
The code is ready to merge.

Signed: [Reviewer]
```

## Anti-Patterns

**DON'T:**

- Auto-approve because AI found no issues
- Skip human-only checks because AI "already reviewed"
- Trust AI severity ratings without verification
- Merge without understanding what the code does

**DO:**

- Treat AI findings as leads to investigate, not verdicts
- Document why you disagree with AI findings
- Verify AI findings with actual code traces
- Take accountability for every merge decision

## Integration with Rule of Five

This workflow fits into Rule of Five passes:

| Pass | Who | Focus |
|------|-----|-------|
| Pass 1: Standard | AI + Human | AI scans, human triages findings |
| Pass 2: Deep | Human | Human-only checks (business, UX) |
| Pass 3: Architecture | Human | Architectural fit, maintainability |
| Pass 4: Security | AI + Human | Security tools + human threat model |
| Pass 5: Convergence | Human | Final sign-off, accountability |

## When to Use This Workflow

**Use AI-First Review for:**

- New features with significant code changes
- Security-sensitive code (auth, payments, user data)
- Code touching system boundaries (APIs, databases)
- Refactors affecting multiple files

**Skip AI-First Review for:**

- Typo fixes and documentation
- Config changes with no logic
- Dependency updates (use security advisories instead)
- Reverts of known-good states

## Success Criteria

- [ ] AI scan completed with findings documented
- [ ] Every AI finding triaged with human decision
- [ ] Human-only checks completed
- [ ] Sign-off recorded with accountability statement
- [ ] No unverified AI findings merged
