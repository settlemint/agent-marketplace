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
- **Output classification checklist as ABSOLUTE FIRST action** - before any tools, exploration, or planning.
- **If Plan Mode active, classification precedes exploration** - output PLAN-GATE-1 after classification.
- **Classification determines which gates are required** - Trivial needs fewer, Complex needs more.
- Maintain a visible TODO checklist in the response. Mark in-progress before writing production code; mark completed after implementation.
- Activate required skills explicitly via `/skills` or `$skill-name` when a phase mandates them (or state that the skill is unavailable and follow equivalent manual steps).
- Output EVERY gate check (GATE-1 through GATE-8) - not just first few.
- Provide verification evidence (command output/test results with exit code 0) before claiming done.
- Use at least one skill per implementation task (minimum: `verification-before-completion`), or explicitly state why no skills are available in this environment.
- Immediately after classification, output the Classification Checklist.
- Ask clarifying questions in plain text during plan refinement (at least one).
- **Parallelize independent tasks** — use `spawn_agent` (with role presets) for subagent dispatch, or `/new`/`/fork` for separate threads. Avoid parallel edits to the same files.

**NEVER**
- **Start exploration/planning without classification output** - classification is FIRST.
- **Proceed with tool calls before stating classification** - no exceptions.
- Skip phases/gates because "simple" or "trivial".
- Skip Phase 2 (Plan Refinement) or Phase 6 (Review) - commonly forgotten.
- Write production code before a failing test.
- Claim completion without evidence.
- Say "Done", "should work", or "looks good" without evidence.
- Proceed past a gate without meeting requirements.
- Stop outputting gates after the first few pass.
- Check a gate box without showing proof in that same message.
- Skip clarifying questions.
- Execute independent tasks sequentially when parallel threads could be used.
- You do NOT have the permission to change linter settings, and ignore statements are severely discouraged. Especially the no barrel files rule!

### Skill Activation (MANDATORY)

Codex activates skills explicitly when you invoke them with `/skills` or `$skill-name`, and it can also invoke them implicitly when the task matches the skill description. If a skill is required by a gate, you MUST explicitly invoke it (or explicitly state that the skill is unavailable and follow its equivalent workflow manually).

Before GATE-3, you MUST have explicit invocations for:
```
$test-driven-development
$verification-before-completion
```

If Standard/Complex, also before GATE-2:
```
$ask-questions-if-underspecified
```

**Self-check:** Confirm you explicitly invoked required skills (or documented unavailability) in the transcript.

### Test Backfilling (MANDATORY)

When modifying existing code:
- **If file has no tests → add tests BEFORE modifying**
- This is not optional: "Existing code has no tests → You're improving it. Add tests."
- Applies to: bug fixes, refactors, behavior changes, any file touch
- **Minimum coverage:** Test the behavior you're changing/touching

**Self-check before modifying any file:**
1. Does a test file exist for this file? (e.g., `foo.ts` → `foo.test.ts`)
2. If no → create test file, add tests for existing behavior first
3. If yes → verify tests cover the code you're about to change
4. Only then proceed with TDD for new changes

### Classification Checklist (MANDATORY)

Output immediately after classification:

```
CLASSIFICATION: [Trivial|Simple|Standard|Complex]

REQUIRED SKILLS (activate before implementation):
- [ ] verification-before-completion (ALL tasks)
- [ ] [skill-2 if applicable]
- [ ] [skill-3 if applicable]

REQUIRED PHASES:
- [ ] Phase 1: Planning
- [ ] Phase 3: Implementation
- [ ] Phase 7: Verification
- [ ] [additional phases per classification]

ITERATIONS: Plan Refinement [1|2|5+] | Review [1|2|5+] | Verification [1|2|5+]
```

### Phase Gates (MANDATORY - ALL OF THEM)

Before each phase, output a gate check. Do not proceed if a gate is BLOCKED. Do not skip gates.

⚠️ **Gate amnesia is a failure mode.** You must output EVERY applicable gate, not just early ones.

⚠️ **Gate rushing is a failure mode.** Each checked box requires proof in the same message.

Gate requirements:
- GATE-1 Planning: classification stated + checklist output + research complete (mcp__octocode__* for code, mcp__context7__* for docs, mcp__exa__* for web/company research).
- GATE-2 Plan Refinement: explicit `$ask-questions-if-underspecified` invocation (Standard/Complex). **Local:** at least one clarifying question asked. **Remote:** questions optional unless genuinely ambiguous.
- GATE-3 Implementation: explicit `$test-driven-development` + `$verification-before-completion` invocation + **backfill check done (if modifying existing file without tests → tests added first)** + TODO list started + parallel-thread check documented.
- GATE-4 Cleanup: all implementation TODOs complete.
- GATE-5 Testing: test file exists + test output with exit code shown (or explicit "no tests possible" justification).
- GATE-6 Review: run `/review` (preferred) or provide a structured review checklist with file/line references; show output. Manual review is NOT acceptable.
- GATE-7 Verification: verification commands run IN THIS MESSAGE with exit code 0 shown.
- GATE-8 CI Validation: `bun run ci` (or `npm/pnpm run ci`, or fallback: lint+test+build) executed IN THIS MESSAGE with exit code 0 shown.
  - **NOTE:** CI commands use turborepo—run from repository root folder.
  - **NOTE:** Infrastructure services may be required—launch with `bun dev:up` (do not use docker-compose directly).
- GATE-DONE Completion: all evidence compiled.

**Activation ≠ Following:** Invoking a skill means you MUST follow its instructions. Activating TDD then writing code without tests = violation.

Gate format (use verbatim):
```
GATE-[N] CHECK:
- [x] Requirement 1 — PROOF: [what you did]
- [x] Requirement 2 — PROOF: [what you did]
- [ ] Requirement 3 (BLOCKED: reason)

STATUS: PASS | BLOCKED
```

### Pre-Completion Gate

Before saying "done" or "complete", confirm evidence for:
- TODO checklist started and completed
- Classification + checklist
- All gates output (count them: did you output GATE-1 through GATE-8?)
- Phase 2 executed (not skipped) — show questions asked
- Phase 6 executed (not skipped) — show review output
- Required skills explicitly invoked (not just mentioned)
- Verification executed
- Verification command exit code 0
- CI phase executed (GATE-8) with exit code 0

**Banned phrases:** "looks good", "should work", "Done!", "that's it", "it's just a port", "direct translation", "1:1 conversion", "straightforward", "manual review", "reviewed the code", "pre-existing", "not related to my changes", "unrelated to this PR", "existing issue", "those errors existed before", "module resolution issues in the codebase", "the specific tests I created pass"
- **Local only banned:** "requirements are clear" (allowed in Remote Mode when genuinely clear)
- **Failure deflection (ZERO TOLERANCE):** Any claim that failures (tests, lint, types, build, CI) are "pre-existing" or "not related to my changes" is ABSOLUTELY FORBIDDEN. Main always passes. If anything fails, you broke it. Fix it.

**Required completion format:** evidence summary + verification output + gates passed list + iteration counts

### Plan Mode Integration

When `system-reminder` indicates "Plan mode is active":

1. **First**: Output classification checklist (same as always)
2. **Then**: Output PLAN-GATE-1 before exploration
3. **Then**: Output PLAN-GATE-2 before writing plan
4. **Finally**: Output the plan (plan-only response when required)

**Plan Mode maps to workflow phases:**
- PLAN-GATE-1 → Phase 1 (Planning)
- PLAN-GATE-2 → Phase 2 (Plan Refinement)
- After approval → Phase 3+ (Implementation onwards)

**Plan Mode does NOT exempt you from:**
- Classification output (still FIRST)
- Skill activation (ask-questions-if-underspecified before PLAN-GATE-2)
- Clarifying questions (plain text when required)
