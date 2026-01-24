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
- Maintain a visible TODO checklist in the response. Mark in-progress before writing production code; mark completed after implementation.
- Activate required skills explicitly via `/skills` or `$skill-name` when a phase mandates them (or state that the skill is unavailable and follow equivalent manual steps).
- Output EVERY gate check (GATE-1 through GATE-7) - not just first few.
- Provide verification evidence (command output/test results with exit code 0) before claiming done.
- Use at least one skill per implementation task (minimum: `verification-before-completion`), or explicitly state why no skills are available in this environment.
- Immediately after classification, output the Classification Checklist.
- Ask clarifying questions in plain text during plan refinement (at least one).
- Consider parallel Codex threads when 2+ independent tasks exist; avoid parallel edits to the same files.

**NEVER**
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
- GATE-1 Planning: classification stated + checklist output.
- GATE-2 Plan Refinement: explicit `$ask-questions-if-underspecified` invocation (Standard/Complex). **Local:** at least one clarifying question asked. **Remote:** questions optional unless genuinely ambiguous.
- GATE-3 Implementation: explicit `$test-driven-development` + `$verification-before-completion` invocation + TODO list started + parallel-thread check documented.
- GATE-4 Cleanup: all implementation TODOs complete.
- GATE-5 Testing: test file exists + test output with exit code shown (or explicit "no tests possible" justification).
- GATE-6 Review: run `/review` (preferred) or provide a structured review checklist with file/line references; show output.
- GATE-7 Verification: verification commands run IN THIS MESSAGE with exit code 0 shown.
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
- All gates output (count them: did you output GATE-1 through GATE-7?)
- Phase 2 executed (not skipped) — show questions asked
- Phase 6 executed (not skipped) — show review output
- Required skills explicitly invoked (not just mentioned)
- Verification executed
- Verification command exit code 0

**Banned phrases:** "looks good", "should work", "Done!", "that's it", "it's just a port", "direct translation", "1:1 conversion", "straightforward"
- **Local only banned:** "requirements are clear" (allowed in Remote Mode when genuinely clear)

**Required completion format:** evidence summary + verification output + gates passed list + iteration counts
