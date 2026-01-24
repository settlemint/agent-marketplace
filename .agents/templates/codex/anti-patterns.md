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
- **Sequential when parallel possible:** executing 2+ independent tasks one-by-one -> use parallel Codex threads.
- **Thread avoidance:** "file operations are quick" to skip parallelization -> if tasks are independent, parallelize.

### Evidence Failures
- Implied evidence: "I ran the tests" without showing output -> paste actual command output.
- Exit code assumption: "command succeeded" without checking -> show exit code 0 explicitly.
- Selective evidence: showing passing tests, hiding failures -> show full output.
