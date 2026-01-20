---
name: review
description: Run comprehensive code review with domain checklists, quality analysis, and security audit
argument-hint: [file or directory, defaults to changed files on current branch]
---

Execute a comprehensive code review using specialized review agents.

## Current State
- Branch: !`git branch --show-current`
- Base: !`git merge-base HEAD main 2>/dev/null || echo "main"`

## Files to Review

!`if [ -n "$ARGUMENTS" ]; then echo "Target: $ARGUMENTS"; else echo "Changed files:"; git diff --name-only $(git merge-base HEAD main 2>/dev/null || echo "HEAD~1") HEAD 2>/dev/null | head -20; fi`

## Review Workflow

### Stage 1: Code Review (Domain Checklists)

Spawn the `code-reviewer` agent to apply domain-specific checklists:

```javascript
Task({
  subagent_type: "build-mode:code-reviewer",
  description: "Apply domain checklists",
  prompt: `Review the following files for code quality:

Files: ${ARGUMENTS || "changed files on current branch"}

Apply relevant domain checklists:
- Frontend (React patterns, accessibility, data fetching)
- API (input validation, error responses, auth)
- Data layer (schemas, transactions, indexes)
- Testing (behavior focus, realistic data, coverage)

Report findings with priorities (P1: must fix, P2: should fix, P3: nice to have).`
})
```

### Stage 2: Quality Review (Style/Patterns/Maintainability)

Spawn the `quality-reviewer` agent for 3-pass quality analysis:

```javascript
Task({
  subagent_type: "build-mode:quality-reviewer",
  description: "Review code quality",
  prompt: `Review code quality for:

Files: ${ARGUMENTS || "changed files on current branch"}

3-pass review:
1. Style - naming, formatting, magic numbers
2. Patterns - DRY, single responsibility, abstraction level
3. Maintainability - change impact, dependencies, testability

Only report issues with 80%+ confidence. Distinguish must-fix from nice-to-have.`
})
```

### Stage 3: Security Review (OWASP Analysis)

Spawn the `security-reviewer` agent for security audit:

```javascript
Task({
  subagent_type: "build-mode:security-reviewer",
  description: "Security audit",
  prompt: `Security review for:

Files: ${ARGUMENTS || "changed files on current branch"}

Check against OWASP Top 10:
- Injection vulnerabilities (SQL, XSS, command)
- Authentication/authorization issues
- Cryptographic failures
- Security misconfigurations
- Hardcoded secrets

Report P0 (critical), P1 (high), P2 (medium) issues.`
})
```

### Stage 4: Error Handling Review

Spawn the `silent-failure-hunter` agent to check error handling:

```javascript
Task({
  subagent_type: "build-mode:silent-failure-hunter",
  description: "Check error handling",
  prompt: `Hunt for silent failures in:

Files: ${ARGUMENTS || "changed files on current branch"}

Find:
- Empty catch blocks
- Silent returns on error
- Broad exception catching
- Missing error propagation
- Swallowed rejections

Classify: P0 (must fix), P1 (should fix), P2 (consider).`
})
```

## Aggregation

After all reviews complete, aggregate findings:

```markdown
## Review Summary

### Critical Issues (P0)
[List all P0 issues from all reviewers]

### High Priority (P1)
[List all P1 issues]

### Medium Priority (P2)
[List all P2 issues]

### Low Priority (P3)
[List all P3 issues]

### Verdict: [PASS / NEEDS FIXES]
- Pass: No P0 issues, P1 issues are minor
- Needs Fixes: Any P0 issues or multiple P1 issues
```

## Quick Options

For targeted reviews, spawn only specific agents:

- **Quality only:** Skip security and error handling
- **Security only:** Only security-reviewer
- **Quick scan:** Only code-reviewer with reduced scope

## Success Criteria

- [ ] All review stages completed
- [ ] No P0 (critical) issues
- [ ] P1 issues acknowledged and planned
- [ ] Summary report generated

## Related Skills

| Skill | Purpose | Invocation |
|-------|---------|------------|
| build | Implement with TDD and quality gates | `Skill({ skill: "build-mode:build" })` |
| fixup | Fix PR review comments and CI failures | `Skill({ skill: "build-mode:fixup" })` |
| reviewing-code | Code review patterns | `Skill({ skill: "build-mode:reviewing-code" })` |
