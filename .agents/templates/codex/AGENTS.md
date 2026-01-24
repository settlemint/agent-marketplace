# STOP - MANDATORY FIRST ACTION

## You Are BLOCKED Until Skill Loaded

Before ANY other action (reading files, exploring, planning, answering):

```
$crew-codex
```

Or explicitly:
```
read_file .agents/skills-local/crew-codex/SKILL.md
```

Then read ALL 6 files listed in SKILL.md and output:

```
CREW-CODEX LOADED:
- [x] philosophy.md
- [x] task-classification.md
- [x] hard-requirements.md
- [x] anti-patterns.md
- [x] workflows.md
- [x] skill-routing-table.md
```

**If you cannot check all boxes, you have NOT loaded the skill. STOP and load it.**

---

## BLOCKED Actions (until verification above is output)

You may NOT:
- Explore codebase
- Read files (except SKILL.md and the 6 workflow files)
- Start planning
- Answer questions about code
- Write any code

---

## Critical Workflow Summary (backup if skill load fails)

### Classification First - ALWAYS

Output classification BEFORE any tools/exploration:
- **Trivial**: single-line, typo, comment only
- **Simple**: single file, clear scope
- **Standard**: multi-file, behavior change
- **Complex**: architectural, security-sensitive

### 8 Mandatory Gates

Every implementation requires gates. Output gate check before each phase:
- GATE-1: Planning (classification + research complete)
- GATE-2: Plan Refinement (questions asked)
- GATE-3: Implementation (skills loaded, tasks created)
- GATE-4: Cleanup
- GATE-5: Testing (test output with exit code)
- GATE-6: Review (review skill invoked)
- GATE-7: Verification (verification skill executed)
- GATE-8: CI Validation (bun run ci with exit code 0)

### Skills Must Be INVOKED

Listing skills is NOT loading. You must call:
```
$test-driven-development
$verification-before-completion
$ask-questions-if-underspecified
```

### Banned Phrases

Never say: "looks good", "should work", "Done!", "requirements are clear" (local), "manual review", "code is simple"

### Task Tracking Required

Before code: Create task + mark in_progress
After code: Mark task completed
Before completion: List all tasks to verify done

---

## Now Load The Skill

This summary is a backup. The full workflow is in the skill files.

**Your next action MUST be:** `$crew-codex`
