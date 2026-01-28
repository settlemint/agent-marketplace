---
name: crew-claude
description: Complete development workflow for Claude Code
---

# Crew Claude

Complete development workflow for Claude Code. SKILL.md = orchestration (task creation + rules). Agents contain execution logic.

---

## 1. Philosophy

This codebase will outlive you. Every shortcut becomes someone else's burden. Fight entropy.

**Linters are allies.** Fix ALL issues. No "pre-existing" excuses.

### Non-negotiables

- Ship production-grade, scalable implementations
- Single canonical implementation; delete legacy/dead paths
- Single source of truth for business rules
- Clean API invariants: validate up front, fail fast
- Use latest stable libs/docs; if unsure, do a web search

### Coding Style

- Target <=500 LOC (hard cap 750; imports/types excluded)
- UI nesting <=3 levels

### Security Guards

- No delete/overwrite without explicit user request; prefer `trash` over `rm`
- Don't expose secrets; use env/secret stores
- Validate untrusted input
- Enforce AuthN/AuthZ; least privilege

---

## 2. Gate Tasks

**Philosophy:** Rather do a bit too much than too little. Every task gets the full workflow.

Immediately create ALL gate tasks via `TaskCreate`. No shortcuts, no skipping phases.

### Full Workflow — ALL tasks

```typescript
// === PLANNING PHASE ===
TaskCreate({ subject: "Planning", description: "Research and planning phase. Use mcp__octocode__* for code, mcp__context7__* for docs, mcp__exa__* for web.", activeForm: "Planning" })

TaskCreate({ subject: "Dispatch initial refinement", description: `Parallel dispatch in ONE message:
Task({ subagent_type: "general-purpose", description: "Ask clarifying questions", prompt: "Load Skill({ skill: 'ask-questions-if-underspecified' }). If Local mode: use AskUserQuestion. If Remote: only ask if ambiguity > 7/10. Output: Questions and answers or 'N/A - requirements clear'." })
Task({ subagent_type: "systems-architect", description: "Initial plan review", prompt: "Review plan at [PLAN_FILE_PATH]. Check task granularity, gate coverage, logical ordering. If issues: fix plan directly. Output: Plan Review Summary." })`, activeForm: "Dispatching initial refinement" })

TaskCreate({ subject: "Architect review: granularity", description: `Task({ subagent_type: "systems-architect", description: "Granularity review", prompt: "Focus: granularity. Plan file: [PLAN_FILE_PATH]. Apply GRANULARITY MODE checklist. If VERDICT != PASS: split oversized tasks. Output: VERDICT: PASS | NEEDS_SPLITTING" })`, activeForm: "Reviewing granularity" })

TaskCreate({ subject: "Architect review: completeness", description: `Task({ subagent_type: "systems-architect", description: "Completeness review", prompt: "Focus: completeness. Plan file: [PLAN_FILE_PATH]. Original request: [QUOTE]. Apply COMPLETENESS MODE checklist. If VERDICT != PASS: add missing tasks. Output: VERDICT: PASS | INCOMPLETE | OVERBUILT" })`, activeForm: "Reviewing completeness" })

TaskCreate({ subject: "Architect review: dependencies", description: `Task({ subagent_type: "systems-architect", description: "Dependencies review", prompt: "Focus: dependencies. Plan file: [PLAN_FILE_PATH]. Apply DEPENDENCIES MODE checklist. If VERDICT != PASS: correct ordering. Output: VERDICT: PASS | NEEDS_REORDERING" })`, activeForm: "Reviewing dependencies" })

TaskCreate({ subject: "Architect review: risk", description: `Task({ subagent_type: "systems-architect", description: "Risk review", prompt: "Focus: risk. Plan file: [PLAN_FILE_PATH]. Apply RISK MODE checklist. If VERDICT != PASS: add mitigation tasks. Output: VERDICT: PASS | NEEDS_MITIGATION" })`, activeForm: "Reviewing risk" })

TaskCreate({ subject: "Architect review: feasibility", description: `Task({ subagent_type: "systems-architect", description: "Feasibility review", prompt: "Focus: feasibility. Plan file: [PLAN_FILE_PATH]. Apply FEASIBILITY MODE checklist. If VERDICT != PASS: add validation/spike tasks. Output: VERDICT: PASS | NEEDS_VALIDATION | INFEASIBLE" })`, activeForm: "Reviewing feasibility" })

TaskCreate({ subject: "Codex plan review", description: `Task({ subagent_type: "Bash", description: "Codex plan review", prompt: "Run: codex review [PLAN_FILE_PATH] --config model_reasoning_effort=xhigh. Output: Full codex output - concerns or 'no concerns'." })`, activeForm: "Running codex on plan" })

TaskCreate({ subject: "Refinement", description: "Plan refinement complete - all iterations passed. Completion: All 5 architect reviews VERDICT=PASS + codex no concerns.", activeForm: "Completing refinement" })

// === IMPLEMENTATION PHASE ===
TaskCreate({ subject: "Write failing tests (TDD red)", description: `Task({ subagent_type: "test-engineer", description: "TDD red phase + backfill", prompt: "Focus: TDD Red Phase with Backfill. Files to modify: [LIST]. Feature: [DESCRIBE].
1. BACKFILL: Ensure touched files have test coverage. Run existing tests for baseline. Write characterization tests for untested paths.
2. RED PHASE: Write failing tests for NEW feature. Run tests - MUST fail.
Output: Backfill Summary (files, tests added, baseline) + Red Phase Summary (tests written, failure output) + VERDICT: RED_CONFIRMED | ALREADY_PASSING | BACKFILL_FAILED" })`, activeForm: "Writing failing tests" })

TaskCreate({ subject: "Implementation", description: `From the approved plan, create individual TaskCreate calls for each 2-5 minute task. Mark tasks with [P] if parallelizable (different files, no dependencies).
For [P] tasks: dispatch parallel Task agents in ONE message.
For sequential tasks: complete one before starting next.
Each sub-task: TaskUpdate in_progress before work, completed with evidence after.
Implementation gate complete when ALL plan tasks show completed.`, activeForm: "Implementing" })

TaskCreate({ subject: "Make tests pass (TDD green + CI)", description: `Task({ subagent_type: "test-engineer", description: "TDD green phase + CI", prompt: "Focus: TDD Green Phase + CI. Run bun run ci (tests + lint + types). Verify: 1) Previously failing tests PASS 2) All lint/type checks PASS 3) Exit code 0. Output: Full CI output with exit code + VERDICT: GREEN_CONFIRMED | CI_FAILING" })`, activeForm: "Making tests pass" })

// === CLEANUP PHASE ===
TaskCreate({ subject: "Dispatch parallel cleanup", description: `Parallel dispatch in ONE message:
Task({ subagent_type: "general-purpose", description: "Run deslop", prompt: "Load Skill({ skill: 'deslop' }). Execute on changed files. Remove: AI slop, unnecessary comments, defensive checks. Output: Diff or 'no slop found'." })
Task({ subagent_type: "general-purpose", description: "Run code-simplifier", prompt: "Load Skill({ skill: 'code-simplifier' }). Execute on changed files. Simplify complex code, reduce nesting. Output: Diff or 'no simplifications needed'." })
Task({ subagent_type: "general-purpose", description: "Run knip", prompt: "Load Skill({ skill: 'knip' }). Find unused files, dependencies, exports. Output: List or 'no dead code found'." })`, activeForm: "Dispatching cleanup" })

TaskCreate({ subject: "Cleanup", description: "Cleanup complete - deslop, code-simplifier, knip, drizzle migration reset (if touched). All tools run with evidence.", activeForm: "Cleaning up" })

// === REVIEW PHASE ===
TaskCreate({ subject: "Dispatch parallel reviewers", description: `ALL SIX in ONE message:
Task({ subagent_type: "Bash", description: "Run codex review", prompt: "Stage untracked: git ls-files --others --exclude-standard -z | while IFS= read -r -d '' f; do git add -- \"$f\"; done. Run: codex review --uncommitted --config model_reasoning_effort=xhigh. Output: Full output with issue counts." })
Task({ subagent_type: "general-purpose", description: "Run codeql scan", prompt: "Load Skill({ skill: 'codeql' }). Execute codeql analysis on changed files. Output: Scan results with security findings." })
Task({ subagent_type: "reviewer", description: "Simplicity review", prompt: "Focus: simplicity. Files: [CHANGED_FILES]. Apply SIMPLICITY MODE checklist. Output: VERDICT: PASS | NEEDS_SIMPLIFICATION" })
Task({ subagent_type: "reviewer", description: "Completeness review", prompt: "Focus: completeness. Files: [CHANGED_FILES]. Original request: [QUOTE]. Apply COMPLETENESS MODE checklist. Output: VERDICT: PASS | INCOMPLETE | OVERBUILT" })
Task({ subagent_type: "reviewer", description: "Quality review", prompt: "Focus: quality. Files: [CHANGED_FILES]. Apply QUALITY MODE checklist. Output: VERDICT: PASS | NEEDS_FIXES" })
Task({ subagent_type: "reviewer", description: "Test coverage review", prompt: "Focus: test-coverage. Files: [CHANGED_FILES]. Apply TEST COVERAGE MODE checklist. Output: VERDICT: PASS | NEEDS_TESTS | TESTS_FAILING" })`, activeForm: "Dispatching reviewers" })

TaskCreate({ subject: "Dispatch parallel fixes", description: `ALL in ONE message - paste actual outputs from reviewers:
Task({ subagent_type: "general-purpose", description: "Fix codex issues", prompt: "Codex output: [PASTE]. Fix all P1/P2/P3 issues. Output: Issues fixed or 'no issues'." })
Task({ subagent_type: "general-purpose", description: "Fix codeql findings", prompt: "CodeQL results: [PASTE]. Fix all findings. Output: Findings fixed or 'no findings'." })
Task({ subagent_type: "general-purpose", description: "Fix reviewer findings", prompt: "Verdicts: [PASTE ALL]. For any NEEDS_* verdict, apply fixes. Output: Fixes applied or 'all passed'." })`, activeForm: "Dispatching fixes" })

TaskCreate({ subject: "Re-run failed reviewers", description: "Re-run ONLY checks that had issues, ALL in ONE message. Repeat fix→re-run until ALL pass.", activeForm: "Re-running reviewers" })

TaskCreate({ subject: "Review", description: "All reviewers PASS. Completion: codex no issues + codeql no findings + all 4 reviewers VERDICT=PASS.", activeForm: "Reviewing" })

// === VERIFICATION PHASE ===
TaskCreate({ subject: "Run verification commands", description: `Load Skill({ skill: "verification-before-completion" }). Execute verification commands from skill. Show exit code 0.`, activeForm: "Running verification" })

TaskCreate({ subject: "Verification", description: "Verification complete with exit code 0.", activeForm: "Verifying" })

TaskCreate({ subject: "Integration", description: "Run bun run test:integration. Exit code 0 or N/A with justification.", activeForm: "Running integration tests" })

TaskCreate({ subject: "Run workflow-improver", description: `Load Skill({ skill: "workflow-improver" }). Analyze session, identify improvements. Show analysis output.`, activeForm: "Running workflow analysis" })

// === DEPENDENCIES ===
TaskUpdate({ taskId: "2", addBlockedBy: ["1"] })
TaskUpdate({ taskId: "3", addBlockedBy: ["2"] })
TaskUpdate({ taskId: "4", addBlockedBy: ["3"] })
TaskUpdate({ taskId: "5", addBlockedBy: ["4"] })
TaskUpdate({ taskId: "6", addBlockedBy: ["5"] })
TaskUpdate({ taskId: "7", addBlockedBy: ["6"] })
TaskUpdate({ taskId: "8", addBlockedBy: ["7"] })
TaskUpdate({ taskId: "9", addBlockedBy: ["8"] })
TaskUpdate({ taskId: "10", addBlockedBy: ["9"] })
TaskUpdate({ taskId: "11", addBlockedBy: ["10"] })
TaskUpdate({ taskId: "12", addBlockedBy: ["11"] })
TaskUpdate({ taskId: "13", addBlockedBy: ["12"] })
TaskUpdate({ taskId: "14", addBlockedBy: ["13"] })
TaskUpdate({ taskId: "15", addBlockedBy: ["14"] })
TaskUpdate({ taskId: "16", addBlockedBy: ["15"] })
TaskUpdate({ taskId: "17", addBlockedBy: ["16"] })
TaskUpdate({ taskId: "18", addBlockedBy: ["17"] })
TaskUpdate({ taskId: "19", addBlockedBy: ["18"] })
TaskUpdate({ taskId: "20", addBlockedBy: ["19"] })
TaskUpdate({ taskId: "21", addBlockedBy: ["20"] })
TaskUpdate({ taskId: "22", addBlockedBy: ["21"] })
```

**Execution tasks require evidence:** Each task must show command output, diff, or scan results before marking complete.

### Plan Mode — Create planning tasks first, rest after approval

```typescript
// Create tasks 1-9 (Planning through Refinement)
// After plan approval, create tasks 10-25 (Implementation through workflow-improver)
```

---

## 3. Rules

### Execution Mode Detection

Check `CLAUDE_CODE_REMOTE` at session start:

- `true` → Remote Mode (autonomous, minimal interaction)
- Otherwise → Local Mode (interactive, full questioning)

Remote Mode: Phase 2 questioning optional (only if ambiguity > 7/10).

### ALWAYS

- **Create ALL gate tasks immediately** - every task gets the full workflow
- **Task tracking:** `TaskCreate` → `TaskUpdate({ status: "in_progress" })` before work → `TaskUpdate({ status: "completed" })` after
- **Task dependencies:** `TaskUpdate({ addBlockedBy: [...] })` for ordering
- **Use `AskUserQuestion`** for ALL clarifying/decision questions - never plain text
- **Parallelize** independent tasks via multiple `Task()` calls in one message
- **Provide evidence** before claiming done

### NEVER

- Skip phases because task "seems simple" - full workflow always
- Skip Phase 2 (Refinement) or Phase 6 (Review)
- Write code before task tracking
- Claim completion without evidence
- Ask questions in plain text (use `AskUserQuestion`)
- Say "Done", "looks good", "should work" without evidence
- Change linter settings or add ignore statements

### Gate Requirements

Each gate requires proof: `PASS: [key]=[evidence]`

| Gate | Requirement |
|------|-------------|
| Planning | Research complete |
| Refinement | All 7 iterations PASS |
| Implementation | TDD red + green (green runs `bun run ci`) |
| Cleanup | Deslop + simplifier + knip + drizzle reset (if touched) |
| Review | All reviewers PASS |
| Verification | Commands run, exit 0 |
| Integration | `bun run test:integration` exit 0 or N/A |

### Anti-Patterns (ZERO TOLERANCE)

- **Shortcut claims** ("task is simple") → full workflow always
- **Text checklists** → use `TaskCreate` instead
- **Skill mention without invocation** → must call `Skill()` tool
- **Gate without evidence** → blocked
- **Failure deflection** ("pre-existing", "not my changes") → fix ALL issues you see
- **Sequential when parallel possible** → use parallel Task agents

### Banned Phrases

"looks good", "should work", "Done!", "it's just a port", "manual review", "pre-existing", "not related to my changes", "I didn't introduce", "just warnings"

---

## 4. Supplementary Files

- `routing.md` - Skill routing table (what skill for what trigger)
- Agent files contain specialized mode checklists and verdicts
