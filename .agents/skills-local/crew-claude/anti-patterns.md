## Anti-Patterns (Never)

### Workflow Bypass
- Trivial bypass: "task is simple" to skip workflow -> classify first and follow minimum steps.
- Direct implementation: code before task tracking -> call `TaskCreate` + `TaskUpdate({ status: "in_progress" })` first (or `TodoWrite` fallback).
- Classification avoidance: no classification before implementation -> state classification before first task creation.
- Task dependency skip: ignoring task ordering -> use `TaskUpdate({ addBlockedBy: [...] })` for dependent tasks.
- Task status neglect: not updating task status -> always set in_progress before work, completed after.

### Skill Failures
- Skill avoidance: no skills loaded -> load at least verification-before-completion.
- Skill mention vs load: "I'll use TDD" without `Skill({ skill: "..." })` call -> actually invoke the tool.
- Checklist theater: listing skills in checklist without invoking Skill() tool -> checklist is not loading.
- Conditional skip: "shell scripts don't need TDD" -> TDD applies to all code, load the skill.
- Implicit knowledge: "I know TDD" without loading -> skill provides specific instructions, load it.
- **Load without follow:** invoked Skill() but ignored its instructions -> loading = commitment to follow.
- **TDD theater:** loaded TDD skill then wrote code without tests -> delete code, write test first.
- **Fake ask-questions:** checked box without invoking skill, said "requirements clear" -> MUST invoke tool. (Remote: asking is optional if ambiguity ≤ 7)
- **Plain text questions:** loaded ask-questions skill but asked in markdown instead of `AskUserQuestion` tool -> FORBIDDEN, always use the tool when asking.

### Decision Question Patterns (MUST use AskUserQuestion)

These phrases in assistant messages = VIOLATION if not using the tool:
- `Would you like me to...?` → Use AskUserQuestion with options
- `Should we...?` / `Should I...?` → Use AskUserQuestion with yes/no or options
- `Do you want...?` → Use AskUserQuestion with options
- `Which would you prefer...?` → Use AskUserQuestion with the options listed
- `Could you clarify...?` → Use AskUserQuestion
- `What should I...?` → Use AskUserQuestion with options

**ALLOWED without tool** (rhetorical/explanatory):
- Questions analyzing the problem: "The question is whether X works with Y..."
- Questions in code comments or documentation
- Questions quoting the user back to them

### Gate Failures
- Gate amnesia: output GATE-1, GATE-3, then forget the rest -> output ALL gates for your classification.
- Gate rushing: GATE-N CHECK with all boxes checked without doing the work -> gates verify work, not skip it.
- Proofless checkboxes: `[x] Requirement` without showing evidence -> add `— PROOF: [what you did]`.
- Early gate only: stop at GATE-3 because "implementation is done" -> GATE-4 through GATE-7 still required.
- False pass: marking STATUS: PASS when requirements not met -> BLOCKED until proof shown.

### Phase Skipping
- Phase 2 skip: "requirements are clear" -> Local: ask anyway. Remote: allowed if ambiguity ≤ 7 (still invoke skill, document assumptions).
- Phase 6 skip: "code is simple, doesn't need review" -> run `/review` AND `codex review` regardless.
- **Codex skip:** "my review skill passed" without running `codex review --uncommitted` -> BLOCKED. Both review skill AND codex are required (Simple+).
- Implicit phases: doing phase work without outputting the gate -> gate output is mandatory.
- Single iteration: doing 1 pass when classification requires 5+ -> track and show iteration count.
- **Manual review substitution:** "reviewed manually" or "reviewed the code" instead of `Skill({ skill: "review" })` -> tool invocation required.
- **Port rationalization:** "it's just a port/translation" to skip questions -> ports have ambiguity too (error handling, idioms, edge cases).

### Iteration Failures
- Iteration shortcut: "did 1 iteration, that's enough" for Standard -> Standard requires 5+ iterations.
- Shallow iteration: repeating same check without deepening -> each iteration must add: edge cases, error handling, test strategy.
- Uncounted iterations: not tracking iteration count -> output "Iteration N of M" for each pass.

### Verification Failures
- Unverified completion: claim done without verification -> run `Skill({ skill: "verification-before-completion" })` with evidence.
- Partial verification: "syntax check passed" as full verification -> run project CI if available.
- Stale evidence: "tests passed earlier" -> run fresh verification before completion claim.
- Load without execute: loaded verification skill but never ran it -> execute and show output.
- CI skip: claiming done without running `bun run ci` or fallback -> GATE-8 is mandatory for all classifications.

### Implementation Failures
- **Sequential when parallel possible:** executing 2+ independent tasks one-by-one with Bash -> use parallel Task agents.
- **Bash familiarity bias:** defaulting to sequential bash "because it's simpler" -> check skill routing table for `dispatching-parallel-agents`.
- **Agent avoidance:** "file operations are quick" to skip parallel agents -> if tasks are independent, parallelize.
- **Unnamed agents:** spawning agents without `name` parameter -> use names for tracking (e.g., `name: "test-runner"`).
- **Overly permissive mode:** using `mode: "bypassPermissions"` for risky/security tasks -> use `mode: "plan"` for changes requiring review.
- **Mode omission:** not specifying mode when context requires it -> explicitly set `mode` based on task risk level.

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
**Before Write/Edit**: "Did I output GATE-3 and create/update tasks?"
**Before claiming done**: "Did I output all required gates and run TaskList?"

If the answer to any question is "no", STOP and output the missing gate/classification first.

### Task Management Failures
- Orphan tasks: creating tasks without tracking completion -> run `TaskList` before claiming done.
- Stale task list: not checking TaskList after subagent work -> always verify task status after delegation.
- Missing dependencies: parallel tasks that should be sequential -> define blockedBy relationships.
- Tool confusion: mixing Tasks and TodoWrite in same session -> use one system consistently per session.
