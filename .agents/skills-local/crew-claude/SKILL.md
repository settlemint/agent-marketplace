---
name: crew-claude
description: Complete development workflow for Claude Code
---

# Crew Claude

Development workflow: philosophy, gates, rules, and 10-phase process.

---

## 1. Philosophy

This codebase will outlive you. Every shortcut becomes someone else's burden. Every hack compounds into debt.

Fight entropy. Leave the codebase better than you found it.

**Linters are allies.** Fix everything they find. No "pre-existing." No "I didn't introduce this." If you see it, you fix it.

Would a senior engineer say this is overcomplicated? Simplify.

### Non-negotiables
- Production-grade, scalable (>1000 users); no MVP shortcuts
- Single canonical implementation; delete legacy/duplicate paths
- Direct integrations; no shims/wrappers/adapters
- Single source of truth for business rules
- Clean API invariants; validate up front, fail fast
- Latest stable libs; web search if unsure

### Code Style
- Target ≤500 LOC (hard cap 750; imports/types excluded)
- UI nesting ≤3 levels; extract when repeated/complex

### Security
- No delete/overwrite without explicit request; prefer `trash`
- No secrets in code/logs; use env/secret stores
- Validate untrusted input (injection, path traversal, SSRF)
- Enforce AuthN/AuthZ; least privilege
- Flag supply-chain/CVE risk for new deps

---

## 2. Gates

Create ALL gates immediately via TaskCreate. Full workflow, no shortcuts.

**Gate sequence:**
```
Planning → Refinement → TDD-Red → Implementation → TDD-Green →
Cleanup → Testing → Drizzle-Reset → Review → Verification →
CI → Integration → Workflow-improver
```

**Plan mode:** Planning + Refinement first; ALL rest after approval.

**Each gate requires:**
- `TaskUpdate({ status: "in_progress" })` before work
- `TaskUpdate({ status: "completed", description: "PASS: [evidence]" })` after
- `TaskList` verification before claiming done

---

## 3. Rules

### Task Management (TaskCreate/TaskUpdate/TaskList)

| Action | Tool | Required Fields |
|--------|------|-----------------|
| Create task | `TaskCreate` | `subject`, `description`, `activeForm` |
| Start work | `TaskUpdate` | `taskId`, `status: "in_progress"` |
| Complete | `TaskUpdate` | `taskId`, `status: "completed"`, `description: "PASS: [evidence]"` |
| Dependencies | `TaskUpdate` | `taskId`, `addBlockedBy: [ids]` |
| Verify all done | `TaskList` | — |

### Gate Evidence Requirements

| Gate | PASS Format | Evidence |
|------|-------------|----------|
| Planning | `Research=[tools]` | mcp tools used (octocode/context7/exa) |
| Refinement | `Questions=[N or N/A]` | AskUserQuestion used (Remote: N/A ok) |
| Implementation | `TDD=[red+green] \| Backfill=[done/N/A]` | Test output shown |
| Cleanup | `Deslop=[done] \| Simplifier=[done]` | Diff or "no changes" |
| Testing | `Tests=[N passed] \| Exit=[0]` | Test output + exit code |
| Drizzle Reset | `Migrations=[reset] \| Skip=[none touched]` | Migration diff or skip reason |
| Review | `Reviewers=[PASS] \| Fixes=[done]` | All reviewer output shown |
| Verification | `Commands=[run] \| Exit=[0]` | Command output |
| CI | `Exit=[0] \| Warnings=[0]` | `bun run ci` output |
| Integration | `Exit=[0 or N/A]` | `bun run test:integration` output |
| Session End | `Workflow-improver=[done]` | Analysis output |

### Execution Mode

Check `CLAUDE_CODE_REMOTE` env:
- `true` → Remote Mode: questions optional unless ambiguity >7/10
- Otherwise → Local Mode: AskUserQuestion required for all clarifications

### Parallel Execution

Multiple `Task()` calls in ONE message = parallel. Use for:
- Research: Explore + context7 + exa
- Cleanup: deslop + code-simplifier + knip
- Review: codex + codeql + 4 reviewers

Use `model: "haiku"` for simple tasks (cleanup, knip). Use `run_in_background: true` for long codex reviews.

### Banned Patterns

| Pattern | Why Banned |
|---------|------------|
| "looks good", "should work", "Done!" | No evidence |
| "pre-existing", "not my changes", "I didn't introduce" | Fix what you see |
| "just warnings" | Warnings ARE errors |
| "manual review" | Evidence required |
| Plain text questions | Use AskUserQuestion tool |
| Code before TaskCreate | Track first |
| Sequential when parallel possible | Efficiency |

### Failure Deflection (ZERO TOLERANCE)

If linter/CI/test finds it, you fix it. All of it.
- Ran linter? Fix every warning.
- Touched file? Own every issue in it.
- Test fails? Your problem.
- "Pre-existing"? BANNED. Fix it anyway.

---

## 4. Workflows

All phases use Task tool for parallelism. ONE message = parallel execution.

### Phase 1: Planning

```
TaskUpdate({ taskId: "planning", status: "in_progress" })
```

Parallel research dispatch:
- `Task({ subagent_type: "Explore", description: "Explore codebase" })`
- `Task({ subagent_type: "general-purpose", prompt: "context7 docs for [LIB]" })`
- `Task({ subagent_type: "general-purpose", prompt: "exa search for [TOPIC]" })`

```
TaskUpdate({ taskId: "planning", status: "completed", description: "PASS: Research=[Explore+context7+exa]" })
```

### Phase 2: Refinement

Parallel:
- `Task({ description: "Ask questions", prompt: "Load ask-questions-if-underspecified skill..." })`
- `Task({ description: "Codex plan review", prompt: "codex review [PLAN_FILE]" })`

Address concerns, then: `TaskUpdate({ status: "completed", description: "PASS: Questions=[N]" })`

### Phase 3: Implementation

1. TDD Red: Write failing test, show failure output
2. Implementation: Write code
3. TDD Green: Run tests, show pass output

### Phase 4: Cleanup

Parallel (use `model: "haiku"`):
- `Task({ description: "deslop", model: "haiku", prompt: "Load deslop skill..." })`
- `Task({ description: "code-simplifier", model: "haiku", prompt: "Load code-simplifier..." })`
- `Task({ description: "knip", model: "haiku", prompt: "Load knip skill..." })`

### Phase 5: Testing

```bash
bun run ci  # from repo root
```

Show full output with exit code.

### Phase 5.5: Drizzle Migration Reset

**Trigger:** `git diff --name-only main...HEAD | grep -E 'drizzle.*\.(sql|json)$'`

If matches:
```bash
FOLDER=$(git diff --name-only main...HEAD | grep -oE '.*/drizzle/' | head -1)
git checkout main -- "$FOLDER"
bun run db:generate
```

If no matches: `Skip: no migrations touched`

### Phase 6: Review

**Step 1: Parallel reviewers** (ONE message, 6 Tasks):
- codex review (`run_in_background: true` if large)
- codeql scan
- simplicity-reviewer.md
- completeness-reviewer.md
- quality-reviewer.md
- comprehensive-test-reviewer.md

**Step 2: Parallel fixes** (ONE message):
- Fix codex issues
- Fix codeql findings
- Fix reviewer findings

**Step 3: Re-run** any that had findings until all PASS.

### Phase 7: Verification

Load `verification-before-completion` skill, execute commands, show exit code 0.

### Phase 8: CI

```bash
bun run ci  # exit 0, zero warnings
```

Fix ALL warnings. No "pre-existing" excuses.

### Phase 9: Integration

```bash
bun run test:integration  # if available
```

### Phase 10: Session End

Load `workflow-improver` skill, show analysis.

---

## 5. Reviewer Files

Located in `iterations/`:
- `simplicity-reviewer.md` - YAGNI, LOC reduction
- `completeness-reviewer.md` - spec compliance
- `quality-reviewer.md` - patterns, security, performance
- `comprehensive-test-reviewer.md` - coverage, green phase

---

## 6. Bash Guidelines

- NO piping through `head`/`tail`/`less` — causes buffering
- Use command flags: `git log -n 10` not `git log | head -10`
- Let commands complete fully
