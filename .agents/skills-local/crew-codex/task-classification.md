## Task Classification

Classify before implementation. When in doubt, classify up.

**Execution Mode:** Check `CODEX_INTERNAL_ORIGINATOR_OVERRIDE` env var. If `codex_web_agent` → Remote Mode (autonomous). See Hard Requirements for adjustments.

### Rules
1. New file => at least Simple (never Trivial).
2. Multiple files => at least Standard.
3. Security/auth/payments => Complex.
4. Uncertain => up.

**Applicability notes**
- Docs/config-only or formatting-only changes may skip TDD/testing/CI; mark gates as N/A with a short rationale.
- Behavior-changing code should follow TDD/testing guidance.

### Categories (guidance, not strict)
- **Trivial:** single-line/typo/comment only. Keep it minimal; no formal gates required.
- **Simple:** single file, clear scope; keep it lightweight and ask questions only if unclear.
- **Standard:** multi-file/behavior change. Use gates for structure; iterate as needed.
- **Complex:** architectural/cross-cutting/security-sensitive. Use gates and deeper review/testing.

### Task Management

Task tracking is optional; use it when it improves clarity or helps break up large work.

### Checklists (optional)

#### Trivial (optional template)
```
CLASSIFICATION: Trivial
SUMMARY: [what you changed] | VERIFICATION: [ran or skipped + reason]
```

#### Simple (optional template)
```
CLASSIFICATION: Simple
SUMMARY: [what you changed] | VERIFICATION: [ran or skipped + reason]
```

#### Standard
Use gates as needed; iterate until risk feels covered.

#### Complex
Use gates and deeper review/testing; choose iterations based on risk.
