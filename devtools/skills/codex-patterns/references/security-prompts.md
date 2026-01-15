# Security Analysis Prompts

## OWASP Top 10 Review

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Security audit of this code for OWASP Top 10:

    [code to review]

    For each vulnerability category:
    1. Is this code vulnerable? (Yes/No/Potentially)
    2. If yes, what's the attack vector?
    3. Proof of concept (how to exploit)
    4. Recommended fix

    Categories to check:
    - A01: Broken Access Control
    - A02: Cryptographic Failures
    - A03: Injection (SQL, XSS, Command)
    - A04: Insecure Design
    - A05: Security Misconfiguration
    - A06: Vulnerable Components
    - A07: Auth Failures
    - A08: Data Integrity Failures
    - A09: Logging Failures
    - A10: SSRF`,
});
```

## Authentication Review

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Review authentication implementation:

    [auth code]

    Check for:
    1. Credential storage (password hashing algorithm?)
    2. Session management (expiration, regeneration?)
    3. Rate limiting (brute force protection?)
    4. Token validation (JWT verification complete?)
    5. Logout implementation (proper session invalidation?)

    For each issue found:
    - Severity: Critical/High/Medium/Low
    - Attack scenario
    - Fix recommendation`,
});
```

## Input Validation

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `Analyze input validation in this code:

    [code handling user input]

    For each input point:
    1. What validation exists?
    2. What's missing?
    3. Can validation be bypassed?
    4. Injection risks (SQL, XSS, command, etc.)

    Recommend fixes with code examples.`,
});
```
