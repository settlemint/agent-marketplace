## Hard Requirements (No Exceptions)

### Execution Mode Detection

Check `CLAUDE_CODE_REMOTE` environment variable at session start:
- `CLAUDE_CODE_REMOTE=true` → **Remote Mode** (autonomous, minimal interaction)
- Otherwise → **Local Mode** (interactive, full questioning)

**Remote Mode Adjustments:**
- Phase 2 questioning is **optional** - only ask if genuinely ambiguous
- "Requirements are clear" is **allowed** (not a banned phrase)
- `ask-questions-if-underspecified` skill: load but only act if ambiguity score > 7/10
- All other gates, skills, and quality requirements remain **unchanged**

**ALWAYS**
- `TodoWrite({ status: "in_progress" })` before any implementation code.
- `TodoWrite({ status: "completed" })` after implementation.
- Load skills via `Skill({ skill: "name" })` tool call - listing is not loading.
- Output EVERY gate check (GATE-1 through GATE-7) - not just first few.
- Provide verification evidence (command output/test results with exit code 0) before claiming done.
- Use at least one skill per implementation task (minimum: verification-before-completion).
- Immediately after classification, output the Classification Checklist.
- **Use `AskUserQuestion` tool for ALL clarifying questions** - never plain text questions.
- **Consider parallel Task agents** when 2+ independent implementation tasks exist.

**NEVER**
- Skip phases/gates because "simple" or "trivial".
- Skip Phase 2 (Plan Refinement) or Phase 6 (Review) - commonly forgotten.
- Write production code before TodoWrite.
- Claim completion without evidence.
- Skip skills or "acknowledge" them without loading via Skill() tool.
- Say "Done", "should work", or "looks good" without evidence.
- Proceed past a gate without meeting requirements.
- Stop outputting gates after the first few pass.
- Check a gate box without showing proof in that same message.
- **Ask clarifying questions in plain text** - MUST use `AskUserQuestion` tool.
- **Execute independent tasks sequentially** when parallel agents could be used.

### Skill Loading (MANDATORY)

**Checklist is not loading.** You must invoke `Skill({ skill: "name" })` tool.

Before GATE-3, you MUST have tool invocations for:
```
Skill({ skill: "test-driven-development" })
Skill({ skill: "verification-before-completion" })
```

If Standard/Complex, also before GATE-2:
```
Skill({ skill: "ask-questions-if-underspecified" })
```

**Self-check:** Search your context for `<invoke name="Skill">`. If not found, you have not loaded skills.

### Classification Checklist (MANDATORY)

Output immediately after classification:

```
CLASSIFICATION: [Trivial|Simple|Standard|Complex]

REQUIRED SKILLS (load before implementation):
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

Before each phase, output a gate check. Do not proceed if BLOCKED. Do not skip gates.

⚠️ **Gate amnesia is a failure mode.** You must output EVERY applicable gate, not just early ones.

⚠️ **Gate rushing is a failure mode.** Each checked box requires proof in the same message.

Gate requirements:
- GATE-1 Planning: classification stated + checklist output.
- GATE-2 Plan Refinement: `Skill({ skill: "ask-questions-if-underspecified" })` tool call visible. **Local:** `AskUserQuestion` tool used. **Remote:** questions optional unless genuinely ambiguous.
- GATE-3 Implementation: `Skill({ skill: "test-driven-development" })` tool call visible + TodoWrite(in_progress) called + parallel agents considered for 2+ independent tasks.
- GATE-4 Cleanup: all implementation todos complete.
- GATE-5 Testing: test file exists + test output with exit code shown (or explicit "no tests possible" justification).
- GATE-6 Review: `Skill({ skill: "review" })` tool call visible + review output shown. "Manual review" is NOT acceptable.
- GATE-7 Verification: verification commands run IN THIS MESSAGE with exit code 0 shown.
- GATE-DONE Completion: all evidence compiled.

**Loading ≠ Following:** Invoking a skill means you MUST follow its instructions. Loading TDD then writing code without tests = violation.

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
- TodoWrite start
- Classification + checklist
- All gates output (count them: did you output GATE-1 through GATE-7?)
- Phase 2 executed (not skipped) — show questions asked
- Phase 6 executed (not skipped) — show review output
- Required skills loaded via Skill() tool (not just mentioned) — search for `<invoke name="Skill">`
- Verification skill executed (not just loaded)
- Verification command exit code 0

**Banned phrases:** "looks good", "should work", "Done!", "that's it", "it's just a port", "direct translation", "1:1 conversion", "straightforward", "manual review", "reviewed the code"
- **Local only banned:** "requirements are clear" (allowed in Remote Mode when genuinely clear)

**Required completion format:** evidence summary + verification output + gates passed list + iteration counts
