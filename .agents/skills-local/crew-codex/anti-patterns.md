## Anti-Patterns (Never)

### Workflow Bypass
- Trivial bypass: "task is simple" to skip workflow -> classify first and follow minimum steps.
- Direct implementation: code before TODO checklist -> start TODO list first.
- Classification avoidance: no classification before implementation -> state classification before first TODO.

### Skill Failures
- Skill avoidance: no skills activated -> explicitly invoke required skills via `/skills` or `$skill-name`.
- Skill mention vs activation: "I'll use TDD" without invoking `$test-driven-development` -> activate the skill explicitly.
- Conditional skip: "shell scripts don't need TDD" -> TDD applies to all code.
- Implicit knowledge: "I know TDD" without activation -> load the skill or follow its full workflow manually.
- **Activation without follow-through:** invoked a skill but ignored its instructions -> activation = commitment.
- **TDD theater:** activated TDD then wrote code without tests -> delete code, write test first.
- **Fake questions:** claimed to ask questions but skipped them -> activate skill. (Remote: asking is optional if ambiguity ≤ 7)

### Gate Failures
- Gate amnesia: output GATE-1, GATE-3, then forget the rest -> output ALL gates for your classification.
- Gate rushing: GATE-N CHECK with all boxes checked without doing the work -> gates verify work, not skip it.
- Proofless checkboxes: `[x] Requirement` without showing evidence -> add `— PROOF: [what you did]`.
- Early gate only: stop at GATE-3 because "implementation is done" -> GATE-4 through GATE-7 still required.
- False pass: marking STATUS: PASS when requirements not met -> BLOCKED until proof shown.

### Phase Skipping
- Phase 2 skip: "requirements are clear" -> Local: ask anyway. Remote: allowed if ambiguity ≤ 7 (still activate skill, document assumptions).
- Phase 6 skip: "code is simple, doesn't need review" -> run `/review` and show output.
- Implicit phases: doing phase work without outputting the gate -> gate output is mandatory.
- Single iteration: doing 1 pass when classification requires 2+ -> track and show iteration count.
- **Review substitution:** skipping `/review` without documented alternative review output -> NOT acceptable.
- **Port rationalization:** "it's just a port/translation" to skip questions -> ports have ambiguity too (error handling, idioms, edge cases).

### Iteration Failures
- Iteration shortcut: "did 1 iteration, that's enough" for Standard -> Standard requires 2+ iterations.
- Shallow iteration: repeating same check without deepening -> each iteration must add: edge cases, error handling, test strategy.
- Uncounted iterations: not tracking iteration count -> output "Iteration N of M" for each pass.

### Verification Failures
- Unverified completion: claim done without verification -> run verification commands with evidence.
- Partial verification: "syntax check passed" as full verification -> run project CI if available.
- Stale evidence: "tests passed earlier" -> run fresh verification before completion claim.
- Activation without execution: activated verification skill but never ran verification -> execute and show output.
- CI skip: claiming done without running `bun run ci` or fallback -> GATE-8 is mandatory for all classifications.

### Implementation Failures
- **Sequential when parallel possible:** executing 2+ independent tasks one-by-one -> use `spawn_agent` or parallel Codex threads.
- **Thread avoidance:** "file operations are quick" to skip parallelization -> if tasks are independent, use `spawn_agent` with role presets.

### Failure Deflection (CRITICAL)

**THIS IS THE MOST SEVERE ANTI-PATTERN. ZERO TOLERANCE.**

Applies to: CI failures, test failures, lint errors, type errors, build failures, ANY verification failure.

- **"Pre-existing issues":** claiming failures are "not related to my changes" or "pre-existing in the codebase" -> ABSOLUTELY FORBIDDEN. Main branch ALWAYS passes (otherwise PRs cannot merge). If anything fails, YOUR changes broke it.
- **"My tests pass":** claiming success because "the specific tests I created pass" while ignoring other failures -> UNACCEPTABLE. ALL tests must pass. 19 passing tests mean nothing if 1 test fails.
- **"Module resolution issues":** claiming type errors or import failures are "pre-existing module issues" -> LIES. The codebase compiles on main. You broke it.
- **Blame shifting:** any variation of "those errors existed before" or "that's a different module" -> LIES. You own the ENTIRE outcome. Fix it or revert your changes.
- **Scope limitation:** "not in scope of this PR" for ANY failure -> WRONG. If it fails, it IS in scope. Period.
- **Partial success claims:** "implementation is complete, just some unrelated issues" -> NOTHING is complete until everything passes.
- **Selective reporting:** showing only your passing tests while hiding lint/type/other failures -> DISHONEST. Show ALL output.

**The rule is absolute:** If ANY verification (tests, lint, types, build, CI) does not pass, you have NOT completed the task. There are no exceptions. There are no "pre-existing issues" in a working main branch. If it fails now, you fix it now.

### Evidence Failures
- Implied evidence: "I ran the tests" without showing output -> paste actual command output.
- Exit code assumption: "command succeeded" without checking -> show exit code 0 explicitly.
- Selective evidence: showing passing tests, hiding failures -> show full output.

### Self-Check Questions

Before each phase, ask yourself:

**Before any action**: "Did I output classification?"
**Before exploration**: "Did I output PLAN-GATE-1?" (if in plan mode)
**Before writing plan**: "Did I output PLAN-GATE-2?" (if in plan mode)
**Before Write/Edit**: "Did I output GATE-3 and start the TODO list?"
**Before claiming done**: "Did I output all required gates?"

If the answer to any question is "no", STOP and output the missing gate/classification first.

### Task Management Failures
- Orphan tasks: creating TODOs without tracking completion -> keep TODO list updated until completion.
- Missing dependencies: parallel tasks that should be sequential -> mark dependent items and avoid parallelization.
