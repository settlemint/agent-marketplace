---
name: flow:enhance:review
description: Enhances review agents with high-signal filtering and validation protocols. Enforces evidence-based findings, confidence scoring, and five-pass convergence.
license: MIT
# NOTE: This skill exceeds 300 lines. Consider extracting codex_quality_review
# and tdd_verification to references/ subdirectory for leaner core.
triggers:
  - "code.*review"
  - "review.*pr"
  - "pr.*review"
  - "review.*code"
  - "audit"
  - "compliance"
  - "bug.*detect"
  - "find.*bug"
  - "find.*issue"
  - "security.*review"
  - "check.*code"
---

<objective>

Enhance review agents with high-signal filtering and validation protocols. Apply rigorous evidence standards: only flag issues with HIGH CONFIDENCE that are definitively bugs or violations. False positives erode trust and waste reviewer time. Every finding must pass validation and include citations.

</objective>

<quick_start>

For any review task:

1. **Pass 1 - Scan**: Identify potential issues in scope
2. **Pass 2 - Validate**: Independently verify each finding is real
3. **Pass 3 - Coverage**: Check for missed issues in untested areas
4. **Pass 4 - Triage**: Assign severity (P0/P1/P2/Observation)
5. **Pass 5 - Confidence**: Final check - would you bet $100 on each finding?

Report ONLY findings that survive all passes.

</quick_start>

<high_signal_filter>

**Issues to FLAG (High Confidence)**

| Category                   | Examples                                                             |
| -------------------------- | -------------------------------------------------------------------- |
| Compilation/Parse Errors   | Syntax errors, type errors, missing imports, unresolved references   |
| Logic Errors               | Code that will DEFINITELY produce wrong results regardless of inputs |
| Clear CLAUDE.md Violations | Unambiguous rule violations with exact quotes from the violated rule |
| Security Vulnerabilities   | Injection vectors, auth bypass, secret exposure (with proof)         |
| Data Loss Risks            | Unhandled errors that silently drop data, race conditions in writes  |

**Issues to IGNORE (Low Signal - False Positives)**

| Category                           | Why Ignore                              |
| ---------------------------------- | --------------------------------------- |
| Code style or quality              | Subjective, not bugs                    |
| Potential issues (input-dependent) | Speculative, may never trigger          |
| Subjective improvements            | Preference, not defect                  |
| Pre-existing issues                | Out of scope for this change            |
| Pedantic nitpicks                  | Waste of time                           |
| Linter-catchable issues            | Let tooling handle these                |
| General code quality               | Unless explicitly required by CLAUDE.md |

**Golden Rule**: If you're not 100% certain it's a bug, don't flag it.

</high_signal_filter>

<validation_protocol>

**Per-Issue Validation**

Before including ANY finding in the final report:

1. **Independent Check**: Re-analyze the issue with fresh eyes
2. **Code Path Trace**: Confirm the issue actually triggers in real execution
3. **Context Review**: Check if nearby code handles the case
4. **Citation Required**: Link to the exact line(s) and quote the problematic code

**Validation Template:**

```
FINDING: [Brief description]
FILE: [path/to/file.ts:L42-L48]
CODE: [Exact code snippet]
ISSUE: [Why this is definitively wrong]
EVIDENCE: [Proof it will fail - execution path, test case, etc.]
SEVERITY: [P0|P1|P2|Observation]
```

**Validation Questions:**

- Is this DEFINITELY a bug, or just unusual code?
- Does this code path actually get executed?
- Is there defensive code elsewhere that prevents this?
- Would a senior engineer agree this is a bug?

If ANY answer is uncertain, DO NOT include the finding.

</validation_protocol>

<severity_triage>

| Severity    | Definition             | Examples                                           |
| ----------- | ---------------------- | -------------------------------------------------- |
| P0          | Blocks deployment      | Crash on startup, data corruption, security breach |
| P1          | High impact            | Feature broken, significant data loss possible     |
| P2          | Medium impact          | Edge case failures, degraded functionality         |
| Observation | Note for consideration | Potential future issue, suggestion                 |

**Triage Rules:**

- P0: Must be fixed before merge
- P1: Should be fixed before merge
- P2: Address soon, may defer with justification
- Observation: Optional, no action required

</severity_triage>

<five_pass_convergence>

| Pass          | Focus            | Key Questions                           |
| ------------- | ---------------- | --------------------------------------- |
| 1. Scan       | Initial findings | What issues are visible in the diff?    |
| 2. Validate   | Verification     | Is each finding DEFINITELY a bug?       |
| 3. Coverage   | Completeness     | Did I miss any areas? Check edge cases? |
| 4. Triage     | Severity         | What's the real impact of each finding? |
| 5. Confidence | Final filter     | Would I bet $100 on each finding?       |

**Convergence Signals:**

STOP when:

- All findings validated with evidence
- Each finding assigned severity
- No uncertain issues remain
- You're confident in every finding

CONTINUE when:

- Findings lack validation evidence
- Severity unclear
- Uncertain whether something is a bug
- Areas of code not yet reviewed

</five_pass_convergence>

<citation_requirements>

Every finding MUST include:

1. **File Path with Line Numbers**: `src/auth/login.ts:L42-L48`
2. **Code Snippet**: The exact problematic code
3. **Rule/Standard Reference**: Link to CLAUDE.md rule or security standard violated
4. **Fix Suggestion**: For small fixes (<6 lines), include committable suggestion

**Link Format (GitHub):**

```
https://github.com/{owner}/{repo}/blob/{SHA}/path/to/file.ts#L42-L48
```

Use full SHA, not branch names.

</citation_requirements>

<output_format>

**Final Report Structure**

```markdown
# Code Review: [PR Title]

## Summary

[1-2 sentence overview of findings]

## Critical Issues (P0)

[List or "None found"]

## High Priority (P1)

[List with full validation template for each]

## Medium Priority (P2)

[List with full validation template for each]

## Observations

[Optional notes, suggestions]

## Areas Reviewed

- [x] [Area 1]
- [x] [Area 2]
- [ ] [Area not reviewed - reason]
```

</output_format>

<anti_patterns>

**NEVER do these:**

- Flag issues without validation evidence
- Include speculative or "might be a problem" findings
- Report style issues as bugs
- Flag pre-existing issues outside the diff
- Use confidence language like "might", "could", "possibly"
- Include more than 10 findings (prioritize the worst)
- Report duplicate issues

**ALWAYS do these:**

- Validate every finding independently
- Include code citations with line numbers
- Assign clear severity
- Provide fix suggestions for small issues
- Acknowledge areas not reviewed

</anti_patterns>

<codex_quality_review>

Use Codex MCP for deep analysis during Pass 3 (Quality) and Pass 4 (Coverage):

**Security Vulnerability Analysis**

```javascript
// Load Codex for security review
MCPSearch({ query: "select:mcp__plugin_devtools_codex__codex" });

mcp__plugin_devtools_codex__codex({
  prompt: `Security review of this code change:

    [code diff or changed files]

    Check for:
    1. Injection vulnerabilities (SQL, XSS, command injection)
    2. Authentication/authorization bypass
    3. Sensitive data exposure (logs, errors, responses)
    4. Race conditions in concurrent operations
    5. Cryptographic weaknesses

    For each finding:
    - Severity: P0/P1/P2
    - Attack vector: How could this be exploited?
    - Fix: Specific remediation steps`,
});
```

**Architecture Fit Analysis**

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Evaluate if this change fits existing patterns:

    Existing patterns: [summary of codebase patterns]
    New code: [code being reviewed]

    Questions:
    1. Does this follow established conventions?
    2. Are there pattern inconsistencies?
    3. Does coupling increase or decrease?
    4. Will this be easy for other developers to understand?

    Flag specific deviations with recommendations.`,
});
```

**Edge Case Discovery**

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Find edge cases in this implementation:

    [code being reviewed]

    Consider:
    1. Null/undefined inputs
    2. Empty collections
    3. Concurrent access
    4. Error propagation
    5. Boundary conditions (min/max values)

    List specific scenarios that may not be handled correctly.`,
});
```

**When to use Codex in reviews:**

- Security-sensitive code (auth, payments, user data)
- Complex logic with many branches
- Code touching system boundaries (APIs, databases)
- Changes with unclear edge case handling

</codex_quality_review>

<tdd_verification>

**During review, verify TDD compliance:**

| Check                    | Finding if Missing                | Severity |
| ------------------------ | --------------------------------- | -------- |
| Test file exists         | No test for implementation        | P1       |
| Test covers new code     | Implementation not tested         | P1       |
| Test fails without code  | Test written after implementation | P2       |
| Coverage meets threshold | Coverage below 80%/75%/90%        | P1       |

**Red flags indicating TDD was skipped:**

- Test file created in same commit as implementation
- Test assertions that can't fail (always true)
- Test covers happy path only
- No test for error handling

**When flagging TDD violations:**

```
FINDING: TDD not followed - test written after implementation
FILE: src/auth.ts, src/auth.test.ts
EVIDENCE: Both files in same commit, test passes without running implementation path
SEVERITY: P2
FIX: Recommend rewriting test to verify it can fail
```

</tdd_verification>

<constraints>

- Do NOT flag issues without validation evidence
- Do NOT include speculative or "might be" findings
- Do NOT report style issues as bugs
- Do NOT exceed 10 findings - prioritize the worst
- Do NOT flag pre-existing issues outside the diff

</constraints>

<success_criteria>

- [ ] Only high-confidence issues flagged
- [ ] Every finding includes validation evidence
- [ ] Every finding has file path and line numbers
- [ ] Severity assigned to all findings
- [ ] No speculative language used
- [ ] No style/quality issues unless CLAUDE.md requires
- [ ] Five passes completed with convergence
- [ ] Would bet $100 on each finding
- [ ] TDD compliance verified for code changes

</success_criteria>

<evolution>

**Extension Points:**

- Integration with static analysis tools for automated validation
- Machine learning for false positive filtering
- Historical issue tracking for pattern detection
- Automated fix generation for common issues

</evolution>
