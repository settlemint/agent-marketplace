## Hard Requirements (No Exceptions)

### Execution Mode Detection

Check `CODEX_INTERNAL_ORIGINATOR_OVERRIDE` environment variable at session start:
- `CODEX_INTERNAL_ORIGINATOR_OVERRIDE=codex_web_agent` → **Remote Mode** (autonomous, minimal interaction)
- Otherwise → **Local Mode** (interactive, full questioning)

**Remote Mode Adjustments:**
- Phase 2 questioning is **optional** - only ask if genuinely ambiguous
- "Requirements are clear" is **allowed** (not a banned phrase)
- `ask-questions-if-underspecified` skill: activate but only act if ambiguity score > 7/10
- All other gates, skills, and quality requirements remain **unchanged**

**ALWAYS**
- **Output classification before edits or deep exploration** - light discovery (e.g., `ls`, `rg`, file list) is allowed to determine scope.
- **If Plan Mode active, classification precedes deep exploration**.
- **Classification determines which guidance applies** - Trivial/Simple can be lightweight; Standard/Complex should use gates.
- Provide a brief verification summary before claiming done (commands run and/or explicitly skipped with reason).
- Ask clarifying questions when ambiguity remains.

**NEVER**
- **Start deep exploration/planning without classification output** - classification is FIRST.
- **Proceed with heavy tool use before stating classification** - use light discovery only to determine scope.
- Claim completion without stating what was verified or intentionally skipped.
- Skip clarifying questions when requirements are ambiguous.
- You do NOT have the permission to change linter settings, and ignore statements are severely discouraged. Especially the no barrel files rule!

### Skill Activation

Codex activates skills explicitly when you invoke them with `/skills` or `$skill-name`. Skills are optional; use them when helpful. Prefer `$ask-questions-if-underspecified` if ambiguity remains.

### Test Backfilling

When modifying existing code:
- Add tests when risk is medium/high or behavior changes materially.
- Docs/config-only changes are exempt.

**Self-check before modifying any file:**
1. Does a test file exist for this file? (e.g., `foo.ts` → `foo.test.ts`)
2. If no, decide based on risk: add minimal tests for risky changes

### Classification Checklist (Guidance)

Output immediately after classification:

```
CLASSIFICATION: [Trivial|Simple|Standard|Complex]

SKILLS (optional):
- [ ] [skill if helpful]

PHASES (Standard/Complex):
- [ ] Phase 1: Planning
- [ ] Phase 3: Implementation
- [ ] Phase 7: Verification
- [ ] [additional phases per classification]

ITERATIONS: as needed
```

### Phase Gates (Standard/Complex)

Before each phase, output a gate check. Do not proceed if a gate is BLOCKED.

Gate requirements (Standard/Complex):
- Planning: classification stated + research complete.
- Refinement: clarify ambiguities; questions optional if clear.
- Implementation: start work; use TDD/testing if risk warrants.
- Cleanup: ensure implementation is tidy.
- Testing: run relevant tests if they exist and behavior changes.
- Review: do a quick review or `/review` for risky/wide changes.
- Verification: list verification commands run or explicitly note skips.
- CI: run CI for risky/wide changes or when requested; otherwise note skip.
  - **NOTE:** CI commands use turborepo—run from repository root folder.
  - **NOTE:** Infrastructure services may be required—launch with `bun dev:up` (do not use docker-compose directly).
- Completion: verification summary + gates list.

**Activation ≠ Following:** Invoking a skill means you should follow its instructions.

Gate format (use verbatim when gates are used):
```
[Gate Name] CHECK:
- [x] Requirement 1 — PROOF: [brief note or output if run]
- [x] Requirement 2 — PROOF: [brief note or output if run]
- [ ] Requirement 3 (BLOCKED: reason)

STATUS: PASS | BLOCKED
```

### Pre-Completion Gate

Before saying "done" or "complete", confirm:
- Classification + brief verification summary
- Gates used if Standard/Complex
- Verification/testing/CI run or explicitly skipped with rationale

**Banned phrases:** "pre-existing", "not related to my changes", "unrelated to this PR", "existing issue", "those errors existed before", "module resolution issues in the codebase", "the specific tests I created pass"
- **Failure deflection (ZERO TOLERANCE):** Any claim that failures (tests, lint, types, build, CI) are "pre-existing" or "not related to my changes" is ABSOLUTELY FORBIDDEN. Main always passes. If anything fails, you broke it. Fix it.

**Required completion format:** verification summary (and gates list if used)

### Plan Mode Integration

When `system-reminder` indicates "Plan mode is active":

1. **First**: Output classification checklist (same as always)
2. **Then**: Output Understanding gate before exploration
3. **Then**: Output Design gate before writing plan
4. **Finally**: Output the plan (plan-only response when required)

**Plan Mode maps to workflow phases:**
- Understanding → Phase 1 (Planning)
- Design → Phase 2 (Plan Refinement)
- After approval → Phase 3+ (Implementation onwards)

**Plan Mode does NOT exempt you from:**
- Classification output
- Clarifying questions when ambiguous
