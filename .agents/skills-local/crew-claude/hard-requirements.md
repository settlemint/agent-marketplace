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
- **Create gate tasks after classification** — number depends on classification (Trivial: 3, Simple: 7, Standard: 8; Plan Mode: GATE-1,2 initially, rest after approval). See Gate Task Creation section.
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

### Classification Checklist (MANDATORY)

Output immediately after classification:

```
CLASSIFICATION: [Trivial|Simple|Standard]

REQUIRED SKILLS (load before implementation):
- [ ] verification-before-completion (ALL tasks)
- [ ] [skill-2 if applicable]
- [ ] [skill-3 if applicable]

REQUIRED PHASES:
- [ ] Phase 1: Planning
- [ ] Phase 3: Implementation
- [ ] Phase 7: Verification
- [ ] [additional phases per classification]

ITERATIONS: Plan Refinement [1|5+] | Review [1|5+] | Verification [1|5+]
```

### Gate Task Creation (MANDATORY)

Immediately after classification, create gate tasks per classification:

| Classification | Gates to Create |
|---------------|-----------------|
| **Trivial** | GATE-3, GATE-7, GATE-8 (3 gates) |
| **Simple** | GATE-1,2,3,5,6,7,8 (7 gates, skip GATE-4) |
| **Standard** | All 8 gates |
| **Plan Mode** | GATE-1,2 initially; GATE-3+ after approval |

```typescript
// Standard example (all 8 gates with dependency chain):
TaskCreate({ subject: "[GATE-1] Planning", description: "Awaiting start", activeForm: "Verifying planning requirements" })
TaskCreate({ subject: "[GATE-2] Refinement", description: "Awaiting GATE-1", blockedBy: ["gate-1-id"], activeForm: "Verifying refinement requirements" })
TaskCreate({ subject: "[GATE-3] Implementation", description: "Awaiting GATE-2", blockedBy: ["gate-2-id"], activeForm: "Verifying implementation requirements" })
TaskCreate({ subject: "[GATE-4] Cleanup", description: "Awaiting GATE-3", blockedBy: ["gate-3-id"], activeForm: "Verifying cleanup requirements" })
TaskCreate({ subject: "[GATE-5] Testing", description: "Awaiting GATE-4", blockedBy: ["gate-4-id"], activeForm: "Verifying testing requirements" })
TaskCreate({ subject: "[GATE-6] Review", description: "Awaiting GATE-5", blockedBy: ["gate-5-id"], activeForm: "Verifying review requirements" })
TaskCreate({ subject: "[GATE-7] Verification", description: "Awaiting GATE-6", blockedBy: ["gate-6-id"], activeForm: "Verifying completion requirements" })
TaskCreate({ subject: "[GATE-8] CI", description: "Awaiting GATE-7", blockedBy: ["gate-7-id"], activeForm: "Verifying CI requirements" })

// Simple: skip GATE-4, adjust blockedBy (GATE-5 blockedBy GATE-3)
// Trivial: only GATE-3,7,8 (GATE-7 blockedBy GATE-3, GATE-8 blockedBy GATE-7)
// Plan Mode: create GATE-1,2 first; after approval create remaining gates
```

### Gate Task Lifecycle

```
pending → in_progress → completed
           ↓
       (if blocked, stays in_progress with "BLOCKED: reason" in description)
```

**Status mapping:**
| Gate Status | Task Status | Description Format |
|-------------|-------------|-------------------|
| Not started | pending | "Awaiting [previous gate]" |
| Checking | in_progress | "Verifying: [requirement]" |
| PASS | completed | "PASS: [key]=[evidence] \| ..." |
| BLOCKED | in_progress | "BLOCKED: [reason]" |

### Phase Gates (MANDATORY - ALL OF THEM)

Before each phase, update the corresponding gate task. Do not proceed if BLOCKED. Do not skip gates.

⚠️ **Gate task neglect is a failure mode.** You must update EVERY applicable gate task, not just early ones.

⚠️ **Gate rushing is a failure mode.** Each gate completed requires proof in the description.

**Gate requirements (update task description with proof when complete):**

- **[GATE-1] Planning**: `PASS: Classification=[type] | Research=[tools used] | Checklist=output`
  - Requirements: classification stated + checklist output + research complete (mcp__octocode__* for code, mcp__context7__* for docs, mcp__exa__* for web/company research).

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

**Loading ≠ Following:** Invoking a skill means you MUST follow its instructions. Loading TDD then writing code without tests = violation.

**Gate update pattern:**
```typescript
// When checking a gate:
TaskUpdate({ taskId: "gate-N-id", status: "in_progress" })

// When gate passes:
TaskUpdate({ taskId: "gate-N-id", status: "completed", description: "PASS: [key]=[evidence] | ..." })

// When gate blocked:
TaskUpdate({ taskId: "gate-N-id", status: "in_progress", description: "BLOCKED: [reason]" })
```

### Pre-Completion Gate

Before saying "done" or "complete", run `TaskList` and confirm:
- All gate tasks ([GATE-1] through [GATE-8]) show status: completed
- All gate descriptions show "PASS:" with proof
- All implementation tasks show status: completed
- Classification + checklist were output
- [GATE-2] description shows questions asked (Local) or "Remote: clear" (Remote)
- [GATE-6] description shows review + codex output
- **Codex review executed (Simple+)** — `codex review --uncommitted` output in [GATE-6] description, P1/P2 issues fixed
- Required skills loaded via Skill() tool (not just mentioned) — search for `<invoke name="Skill">`
- Verification skill executed (not just loaded)
- [GATE-7] and [GATE-8] descriptions show exit code 0

**Banned phrases:** "looks good", "should work", "Done!", "that's it", "it's just a port", "direct translation", "1:1 conversion", "straightforward", "manual review", "reviewed the code", "pre-existing", "not related to my changes", "unrelated to this PR", "existing issue", "those errors existed before", "module resolution issues in the codebase", "the specific tests I created pass"
- **Local only banned:** "requirements are clear" (allowed in Remote Mode when genuinely clear)
- **Failure deflection (ZERO TOLERANCE):** Any claim that failures (tests, lint, types, build, CI) are "pre-existing" or "not related to my changes" is ABSOLUTELY FORBIDDEN. Main always passes. If anything fails, you broke it. Fix it.

**Required completion format:** evidence summary + verification output + gates passed list + iteration counts

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
