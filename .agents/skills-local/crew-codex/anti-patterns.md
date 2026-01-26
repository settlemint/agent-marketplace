## Anti-Patterns (Never)

### Workflow Bypass
- Classification avoidance: no classification before implementation -> state classification before first TODO (light discovery allowed).

### Skill Failures
- Skill avoidance when needed: use a skill if it materially reduces risk or ambiguity.
- Skill mention vs activation: "I'll use TDD" without invoking `$test-driven-development` -> activate the skill explicitly.
- Conditional skip: "shell scripts don't need TDD" -> TDD applies to behavior-changing code (docs/config-only exempt).
- Implicit knowledge: "I know TDD" without activation -> load the skill or follow its full workflow manually.
- **Activation without follow-through:** invoked a skill but ignored its instructions -> activation = commitment.
- **TDD theater:** activated TDD then wrote code without tests -> delete code, write test first.
- **Fake questions:** claimed to ask questions but skipped them -> activate skill. (Remote: asking is optional if ambiguity ≤ 7)

### Gate Failures
- Gate rushing: gate CHECK with all boxes checked without doing the work -> gates verify work, not skip it.
- Proofless checkboxes: `[x] Requirement` without a brief note -> add `— PROOF: [what you did]`.

### Phase Skipping
- Phase 2 skip: skipping questions when requirements are ambiguous -> clarify or document assumptions.
- Phase 6 skip: skipping review for Standard/Complex code changes without noting a rationale.
- Implicit phases: doing phase work without outputting the gate -> gate output is mandatory.
- Single iteration: doing 1 pass when classification requires 2+ -> track and show iteration count.
- **Review substitution:** skipping any review for Standard/Complex code changes without a brief manual checklist.
- **Port rationalization:** "it's just a port/translation" to skip questions -> ports have ambiguity too (error handling, idioms, edge cases).

### Iteration Failures
- Shallow iteration: repeating the same check without deeper risk analysis.

### Verification Failures
- Unverified completion: claim done without stating what was verified or intentionally skipped.
- Partial verification: "syntax check passed" as full verification -> be explicit about what ran vs skipped.
- Stale evidence: "tests passed earlier" -> run fresh verification before completion claim for code changes.
- Activation without execution: activated verification skill but never ran verification -> execute relevant checks or document skip.
- CI skip: skipping CI for Standard/Complex code changes without a rationale.

### Implementation Failures
- Ignoring obvious time-saving decomposition for large work.

### Failure Deflection (CRITICAL)

**THIS IS THE MOST SEVERE ANTI-PATTERN. ZERO TOLERANCE.**

Applies to: CI failures, test failures, lint errors, type errors, build failures, ANY verification failure.

- **"Pre-existing issues":** claiming failures are "not related to my changes" or "pre-existing in the codebase" -> ABSOLUTELY FORBIDDEN. Main branch ALWAYS passes (otherwise PRs cannot merge). If anything fails, YOUR changes broke it.
- **"My tests pass":** claiming success because "the specific tests I created pass" while ignoring other failures -> UNACCEPTABLE. ALL tests must pass. 19 passing tests mean nothing if 1 test fails.
- **"Module resolution issues":** claiming type errors or import failures are "pre-existing module issues" -> LIES. The codebase compiles on main. You broke it.
- **Blame shifting:** any variation of "those errors existed before" or "that's a different module" -> LIES. You own the ENTIRE outcome. Fix it or revert your changes.
- **Scope limitation:** "not in scope of this PR" for ANY failure -> WRONG. If it fails, it IS in scope. Period.
- **Partial success claims:** "implementation is complete, just some unrelated issues" -> NOTHING is complete until everything passes.
- **Selective reporting:** hiding lint/type/other failures while claiming success -> DISHONEST. Disclose failures; share output if requested.

**The rule is absolute:** If ANY verification (tests, lint, types, build, CI) does not pass, you have NOT completed the task. There are no exceptions. There are no "pre-existing issues" in a working main branch. If it fails now, you fix it now.

### Evidence Failures
- Claiming tests ran when they did not.
- Hiding failures if verification was executed.
- Refusing to share output when explicitly requested.

### Self-Check Questions

Before edits or deep exploration: "Did I output classification?"
Before claiming done: "Did I summarize what ran or was skipped?"
