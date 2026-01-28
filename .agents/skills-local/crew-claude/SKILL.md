---
name: crew-claude
description: Complete development workflow for Claude Code
---

# Crew Claude

Development workflow for Claude Code with gates, verification, and quality enforcement.

---

## 1. Philosophy

This codebase will outlive you. Every shortcut becomes someone else's burden. Every hack compounds into debt that slows the whole team.

Fight entropy. Leave the codebase better than you found it.

Linters and formatters are allies—they find issues so you can fix them. When they report something, fix it, even if you didn't introduce it. The main branch always passes CI. If something fails now, your changes caused it. This is how codebases improve over time.

When in doubt, ask: would a senior engineer say this is overcomplicated? If yes, simplify.

### Non-negotiables

Production-grade implementations that scale beyond 1000 users. No MVP shortcuts that become permanent. Single canonical implementation in the primary codepath—delete legacy and duplicate paths as part of delivery. Direct integrations without shims, wrappers, or adapter layers. Single source of truth for business rules, validation, enums, and config. Clean API invariants that validate up front and fail fast. Latest stable libraries—web search if unsure about versions.

### Code Style

Target 500 lines or fewer per file (hard cap at 750, excluding imports and types). Keep UI nesting to 3 levels maximum—extract components when JSX repeats, responsibilities accumulate, or conditionals multiply.

### Security

Prefer `trash` over `rm` for deletions. Keep secrets out of code and logs—use environment variables or secret stores. Validate untrusted input to prevent injection, path traversal, and SSRF. Enforce authentication and authorization with least privilege. Flag supply-chain and CVE risks when adding dependencies.

---

## 2. Gates

The gate sequence ensures quality. Each gate has a purpose—skipping gates means skipping verification.

```
Planning → Refinement → TDD-Red → Implementation → TDD-Green →
Cleanup → Testing → Drizzle-Reset → Review → Verification →
CI → Integration → Workflow-improver
```

Create all gates immediately via TaskCreate when starting work. This makes progress visible and ensures nothing is forgotten.

**Plan mode workflow:** Create Planning and Refinement gates first. After the user approves your plan, create all remaining gates.

### Before starting any gate

Call `TaskUpdate` with `status: "in_progress"` so progress is tracked.

### Before completing any gate

Verify you have evidence. Each gate completion requires a description showing what was verified:
- `PASS: Research=[Explore+context7+exa]` — Planning gate, showing which tools gathered context
- `PASS: Questions=[3]` — Refinement gate, showing questions were asked via AskUserQuestion
- `PASS: TDD=[red+green]` — Implementation gate, showing tests failed then passed
- `PASS: Exit=[0]` — CI gate, showing the command succeeded

### Before claiming the task is done

Run `TaskList` and verify every gate shows completed status. If any gate is still pending or in_progress, the task is not done.

---

## 3. Working with Tasks

Use TaskCreate, TaskUpdate, and TaskList for all tracking. This ensures nothing is forgotten during long sessions.

**Creating tasks:** Provide `subject` (what), `description` (details), and `activeForm` (shown during work, like "Running tests").

**Starting work:** Call `TaskUpdate` with the task ID and `status: "in_progress"` before beginning.

**Completing work:** Call `TaskUpdate` with `status: "completed"` and update the description with evidence of completion.

**Establishing order:** Use `addBlockedBy` to specify which tasks must complete first.

**Verifying completion:** Call `TaskList` to see all tasks and their status before claiming done.

---

## 4. Evidence Requirements

Evidence matters because it proves work was done. Without evidence, there's no verification.

### Planning gate
Show which research tools you used. Did you explore the codebase with the Explore agent? Query documentation with context7? Search the web with exa? List them.

### Refinement gate
Show that you asked clarifying questions using the AskUserQuestion tool. In remote mode where questions are optional, document "N/A - requirements clear" with reasoning.

### Implementation gate
Show test output. First, tests should fail (proving the test catches the missing behavior). Then tests should pass (proving the implementation works).

### Cleanup gate
Show the diff from deslop and code-simplifier, or document "no changes needed" if the code was already clean.

### Testing gate
Show the full test output including the exit code. Partial output or summaries are not sufficient.

### Review gate
Show output from all reviewers (codex, codeql, and the four reviewer prompts). If any found issues, show the fixes and re-run results.

### CI gate
Show the complete `bun run ci` output with exit code 0. If there are warnings, fix them first—warnings become errors over time.

### Integration gate
Show `bun run test:integration` output, or document why integration tests don't apply.

---

## 5. Execution Patterns

### Parallel execution saves time

When you have independent tasks, dispatch them in a single message. Multiple `Task()` calls in one message run in parallel.

Good opportunities for parallelism:
- Research phase: Explore codebase + query docs + web search
- Cleanup phase: deslop + code-simplifier + knip
- Review phase: codex + codeql + four reviewer prompts

Use `model: "haiku"` for simpler subtasks like cleanup and knip—it's faster and sufficient for straightforward work.

Use `run_in_background: true` for long-running tasks like codex review on large changesets.

### Remote vs local mode

Check the `CLAUDE_CODE_REMOTE` environment variable. When true, you're running autonomously and questions are optional unless genuinely ambiguous (ambiguity score above 7/10). Otherwise, use AskUserQuestion for all clarifications—plain text questions get lost in conversation flow.

### Pre-action verification

Before writing code, verify TaskCreate was called. The task list is the source of truth.

Before completing a gate, verify you have evidence to show. Re-read the evidence requirements above.

Before claiming done, run TaskList and verify all gates show completed.

---

## 6. Fixing What You Find

When a linter, formatter, or CI check reports an issue, fix it. This applies even to issues you didn't introduce.

The reasoning: main branch always passes. If it fails now, something in your changes triggered it—maybe a transitive dependency, maybe a file you touched, maybe a config change. Regardless of root cause, the fix is your responsibility.

This also applies to warnings. Warnings are future errors. Fix them now while context is fresh.

Phrases that indicate deflection (and should trigger self-correction):
- "pre-existing issue" — fix it anyway
- "not related to my changes" — it's failing now, so it is related
- "I didn't introduce this" — irrelevant, fix it
- "just a warning" — warnings matter, fix it

The goal is leaving the codebase better than you found it. Every session should reduce technical debt, not add to it.

---

## 7. Workflows

### Phase 1: Planning

Mark the Planning gate in_progress. Dispatch parallel research:
- Explore agent to understand codebase structure and patterns
- context7 queries for library documentation
- exa searches for current best practices

After research completes, mark Planning completed with evidence of tools used.

### Phase 2: Refinement

Mark Refinement in_progress. In parallel:
- Load ask-questions-if-underspecified skill and ask clarifying questions
- Run codex review on the plan if one exists

Address any concerns raised, then mark Refinement completed.

### Phase 3: Implementation

Follow TDD: write a failing test first (red), then implement until tests pass (green). Show test output at each stage.

When modifying existing code that lacks tests, add tests before making changes. This ensures your changes don't break existing behavior.

### Phase 4: Cleanup

Dispatch cleanup tasks in parallel using haiku model:
- deslop to remove AI-generated cruft
- code-simplifier to reduce complexity
- knip to find unused exports and dependencies

### Phase 5: Testing

Run `bun run ci` from the repository root. Show the complete output with exit code.

### Phase 5.5: Drizzle Migration Reset

Check if migrations were touched: `git diff --name-only main...HEAD | grep -E 'drizzle.*\.(sql|json)$'`

If migrations were touched, reset to main and regenerate:
```bash
FOLDER=$(git diff --name-only main...HEAD | grep -oE '.*/drizzle/' | head -1)
git checkout main -- "$FOLDER"
bun run db:generate
```

This ensures clean, consolidated migrations instead of accumulated incremental changes.

### Phase 6: Review

**Step 1:** Dispatch all reviewers in parallel (one message, six tasks):
- codex review (use run_in_background for large changesets)
- codeql scan
- simplicity-reviewer.md
- completeness-reviewer.md
- quality-reviewer.md
- comprehensive-test-reviewer.md

**Step 2:** After all complete, dispatch fixes in parallel for any findings.

**Step 3:** Re-run any reviewers that had findings. Repeat until all pass.

### Phase 7: Verification

Load the verification-before-completion skill and execute its commands. Show output with exit code 0.

### Phase 8: CI

Run `bun run ci` and show complete output. Exit code must be 0 with zero warnings.

### Phase 9: Integration

Run `bun run test:integration` if available. Show output or document why it doesn't apply.

### Phase 10: Session End

Load workflow-improver skill and show the analysis. This identifies patterns for future improvement.

---

## 8. Reviewer Files

The `iterations/` folder contains reviewer prompts:
- `simplicity-reviewer.md` — YAGNI violations, LOC reduction opportunities
- `completeness-reviewer.md` — spec compliance verification
- `quality-reviewer.md` — patterns, security, performance issues
- `comprehensive-test-reviewer.md` — test coverage gaps, green phase verification

Each reviewer is read by a parallel Task agent during the review phase.

---

## 9. Bash Guidelines

Avoid piping through `head`, `tail`, `less`, or `more`—these cause output buffering issues that can hang commands.

Use command-specific flags instead: `git log -n 10` rather than `git log | head -10`.

Let commands complete fully before processing output.
