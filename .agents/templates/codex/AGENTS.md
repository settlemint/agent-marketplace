# Codex Workflow (Lightweight)

## Recommended First Action

For Standard/Complex or multi-file code changes, load the crew-codex skill before deeper work:

```
$crew-codex
```

Or explicitly:
```
read_file .agents/skills-local/crew-codex/SKILL.md
```

If you read all 6 files listed in SKILL.md, output:

```
CREW-CODEX LOADED:
- [x] philosophy.md
- [x] task-classification.md
- [x] hard-requirements.md
- [x] anti-patterns.md
- [x] workflows.md
- [x] skill-routing-table.md
```

For Trivial/Simple or docs/config-only tasks, you may proceed after classification and load the skill only if unsure.

---

## Critical Workflow Summary (backup if skill load fails)

### Classification First - ALWAYS

Output classification before edits or deep exploration. Light discovery (e.g., `ls`, `rg`, file list) is allowed to determine scope:
- **Trivial**: single-line, typo, comment only
- **Simple**: single file, clear scope
- **Standard**: multi-file, behavior change
- **Complex**: architectural, security-sensitive

### Gates (lightweight)

Use gates only for Standard/Complex changes. For Trivial/Simple or docs/config-only, provide a short summary of what ran or was skipped:
- GATE-1: Planning (classification + research complete)
- GATE-2: Plan Refinement (questions asked)
- GATE-3: Implementation (skills loaded, tasks created)
- GATE-4: Cleanup
- GATE-5: Testing (if applicable; summarize results)
- GATE-6: Review (required for Standard/Complex code changes; method noted)
- GATE-7: Verification (summarize what ran or skipped)
- GATE-8: CI Validation (required for Standard/Complex code changes; optional for docs/low-risk)

### Skills

Invoke skills when helpful; no mandatory skill list. Prefer `$ask-questions-if-underspecified` only when requirements are unclear.

### Reporting

Be honest about what ran or was skipped; do not hide failures.

### Task Tracking

Task tracking is optional; use when it helps clarity or multi-step work.

---

## Now Load The Skill

This summary is a backup. The full workflow is in the skill files.

**Your next action MUST be:** `$crew-codex`
