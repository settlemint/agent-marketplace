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
- **Output classification checklist as ABSOLUTE FIRST action** - before any tools, exploration, or planning.
- **If Plan Mode active, classification precedes exploration** - create gate tasks and update [GATE-1] after classification.
- **Classification determines which gates are required** - Trivial needs fewer, Standard needs more.
- **Task tracking before implementation:** Use `TaskCreate` to create tasks, `TaskUpdate({ status: "in_progress" })` before starting work.
- **Task completion after implementation:** Use `TaskUpdate({ status: "completed" })` after each task is done.
- **Task dependencies:** Use `TaskUpdate({ addBlockedBy: [...] })` to establish task ordering.
- **Fallback:** If Tasks tools unavailable (older Conductor), use `TodoWrite({ status: "in_progress/completed" })`.
- Load skills via `Skill({ skill: "name" })` tool call - listing is not loading.
- **Create gate tasks after classification** — number depends on classification (Trivial: 4, Simple: 8, Standard: 9; Plan Mode: GATE-1,2 initially, rest after approval). See Gate Task Creation section.
- Provide verification evidence (command output/test results with exit code 0) before claiming done.
- Use at least one skill per implementation task (minimum: verification-before-completion).
- Immediately after classification, output the Classification Checklist.
- **Use `AskUserQuestion` tool for ALL clarifying questions** - never plain text questions.
- **Use `AskUserQuestion` tool for ALL decision-seeking questions** - phrases that seek user input MUST use the tool:
  - "Would you like..." → AskUserQuestion
  - "Should we/I..." (when seeking decision) → AskUserQuestion
  - "Do you want..." → AskUserQuestion
  - "Could you clarify..." → AskUserQuestion
  - "Which option..." → AskUserQuestion
- **Consider parallel Task agents** when 2+ independent implementation tasks exist.
- **Use Task `mode` parameter** appropriately: `plan` for risky changes, `bypassPermissions` for trusted autonomous work.
- **Parallelize independent tasks** after plan approval — tasks without `blockedBy` can run in parallel via multiple `Task()` calls in one message. See `dispatching-parallel-agents` skill.

**NEVER**
- **Start exploration/planning without classification output** - classification is FIRST.
- **Proceed with tool calls before stating classification** - no exceptions.
- Skip phases/gates because "simple" or "trivial".
- Skip Phase 2 (Plan Refinement) or Phase 6 (Review) - commonly forgotten.
- Write production code before creating/updating tasks (TaskCreate or TodoWrite fallback).
- Claim completion without evidence.
- Skip task dependency setup when tasks have ordering requirements.
- Skip skills or "acknowledge" them without loading via Skill() tool.
- Say "Done", "should work", or "looks good" without evidence.
- Proceed past a gate without meeting requirements.
- Mark a gate task completed without meeting all requirements.
- Complete a gate task without proof in description.
- **Ask clarifying questions in plain text** - MUST use `AskUserQuestion` tool.
- **Ask decision questions in plain text** - if your message contains "Would you like", "Should we", "Do you want", or similar decision-seeking phrases followed by "?", you MUST use `AskUserQuestion` tool instead of inline text.
- **Execute independent tasks sequentially** when parallel agents could be used.
- You do NOT have the permission to change linter settings, and ignore statements are severely discouraged. Especially the no barrel files rule!

### Skill Loading (MANDATORY)

**Checklist is not loading.** You must invoke `Skill({ skill: "name" })` tool.

Before GATE-3, you MUST have tool invocations for:
```
Skill({ skill: "test-driven-development" })
Skill({ skill: "verification-before-completion" })
```

If Standard, also before GATE-2:
```
Skill({ skill: "ask-questions-if-underspecified" })
```

**Self-check:** Search your context for `<invoke name="Skill">`. If not found, you have not loaded skills.

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

### Classification Output (MANDATORY)

Output ONLY this single line, then create gate tasks via TodoWrite:

```
CLASSIFICATION: [Trivial|Simple|Standard]
```

No verbose checklists. The task list IS the tracking mechanism.

### Gate Task Creation (MANDATORY)

Immediately after classification, create gate tasks via TodoWrite. See task-classification.md for exact patterns per classification type.

| Classification | Gates to Create |
|---------------|-----------------|
| **Trivial** | GATE-3, GATE-7, GATE-8, GATE-9 (4 gates) |
| **Simple** | GATE-1,2,3,5,6,7,8,9 (8 gates, skip GATE-4) |
| **Standard** | All 9 gates + iteration sub-tasks for GATE-2,6,7 |
| **Plan Mode** | GATE-1,2 initially; GATE-3+ after approval |

### Gate Task Status

| Status | When | Description |
|--------|------|-------------|
| pending | Not started | — |
| in_progress | Working on it | — |
| completed | Done with proof | — |

### Phase Gates (MANDATORY - ALL OF THEM)

Before each phase, update the corresponding gate task. Do not proceed if BLOCKED. Do not skip gates.

⚠️ **Gate task neglect is a failure mode.** You must update EVERY applicable gate task, not just early ones.

⚠️ **Gate rushing is a failure mode.** Each gate completed requires proof in the description.

**Gate requirements (update task description with proof when complete):**

- **[GATE-1] Planning**: `PASS: Classification=[type] | Request=understood | Research=[tools used] | Docs=checked | Web=[done/N/A]`
  - Requirements: classification stated + user request understood + research complete (mcp__octocode__* for code, mcp__context7__* for docs, mcp__exa__* for web/company research).

- **[GATE-2] Refinement**: `PASS: AskQuestions=[invoked] | Questions=[count or N/A if Remote]`
  - Requirements: `Skill({ skill: "ask-questions-if-underspecified" })` tool call visible. **Local:** `AskUserQuestion` tool used. **Remote:** questions optional unless genuinely ambiguous.

- **[GATE-3] Implementation**: `PASS: TDD=[loaded] | Tasks=[IDs created] | Backfill=[done/N/A]`
  - Requirements: `Skill({ skill: "test-driven-development" })` tool call visible + **backfill check done (if modifying existing file without tests → tests added first)** + Tasks created (or TodoWrite fallback) + task status set to in_progress + parallel agents considered for 2+ independent tasks.

- **[GATE-4] Cleanup**: `PASS: Tasks=[all complete] | Cleanup=[skills run]`
  - Requirements: all implementation tasks complete (TaskList shows no pending tasks for current work).

- **[GATE-5] Testing**: `PASS: Tests=[N passed, N failed] | Exit=[code]`
  - Requirements: test file exists + test output with exit code shown (or explicit "no tests possible" justification).

- **[GATE-6] Review**: `PASS: Review=[invoked] | Codex=[P1:N, P2:N fixed]`
  - Requirements: `Skill({ skill: "review" })` tool call visible + review output shown + `codex review --uncommitted` executed (Simple+) with P1/P2 issues fixed. Standard tasks also require `differential-review` and security review. "Manual review" is NOT acceptable.

- **[GATE-7] Verification**: `PASS: Commands=[run] | Exit=[0] | Tasks=[all completed]`
  - Requirements: verification commands run IN THIS MESSAGE with exit code 0 shown + all tasks marked completed.

- **[GATE-8] CI**: `PASS: CI=[command] | Exit=[0]`
  - Requirements: `bun run ci` (or `npm/pnpm run ci`, or fallback: lint+test+build) executed IN THIS MESSAGE with exit code 0 shown.
  - **NOTE:** CI commands use turborepo—run from repository root folder.
  - **NOTE:** Infrastructure services may be required—launch with `bun dev:up` (do not use docker-compose directly).

- **[GATE-9] Integration**: `PASS: Integration=[Exit 0 or N/A]`
  - Requirements: Run `bun run test:integration` if script exists in package.json. Include result (`Exit 0`) or note `N/A` if unavailable.
  - **Prerequisite:** GATE-8 must pass first—do not attempt integration tests if CI fails.
  - **NOTE:** Infrastructure services may be required—launch with `bun dev:up` before running.

**Loading ≠ Following:** Invoking a skill means you MUST follow its instructions. Loading TDD then writing code without tests = violation.

### Pre-Completion Gate

Before claiming done, the task list must show all gate tasks as completed. No exceptions.

**Banned phrases:** "looks good", "should work", "Done!", "it's just a port", "manual review", "pre-existing", "not related to my changes"

**Failure deflection (ZERO TOLERANCE):** Any claim that failures are "pre-existing" or "not related to my changes" is FORBIDDEN. Main always passes. If anything fails, you broke it.

### Plan Mode Integration

When `system-reminder` indicates "Plan mode is active":

1. **First**: Output classification checklist (same as always)
2. **Then**: Create gate tasks and update [GATE-1] to in_progress, then completed when research done
3. **Then**: Update [GATE-2] to in_progress, then completed when plan written
4. **Finally**: Call ExitPlanMode when plan is complete

**Plan Mode maps to workflow phases:**
- [GATE-1] → Phase 1 (Planning)
- [GATE-2] → Phase 2 (Plan Refinement)
- After approval → Phase 3+ (Implementation onwards, create remaining gate tasks)

**Plan Mode does NOT exempt you from:**
- Classification output (still FIRST)
- Gate task creation (create [GATE-1] and [GATE-2] minimum, rest after approval)
- Skill loading (ask-questions-if-underspecified before [GATE-2] completion)
- AskUserQuestion tool usage (never plain text questions)
