# STOP - MANDATORY FIRST ACTION

## You Are BLOCKED Until Skill Loaded

Before ANY other action (reading files, exploring, planning, answering):

```
Skill({ skill: "crew-claude" })
```

The skill content loads inline. Output:

```
CREW-CLAUDE LOADED: ✓
```

---

## BLOCKED Actions (until verification above is output)

You may NOT:
- Explore codebase
- Read files (except SKILL.md)
- Use Task/Explore agents
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

### 9 Mandatory Gates

Every implementation requires gates. Output gate check before each phase:
- Planning (classification + research complete)
- Refinement (questions asked via AskUserQuestion)
- Implementation (skills loaded, tasks created)
- Cleanup
- Testing (test output with exit code)
- Review (Skill({ skill: "review" }) invoked)
- Verification (verification skill executed)
- CI (bun run ci with exit code 0)
- Integration (bun run test:integration with exit code 0)

### Skills Must Be INVOKED

Listing skills is NOT loading. You must call:
```
Skill({ skill: "test-driven-development" })
Skill({ skill: "verification-before-completion" })
Skill({ skill: "ask-questions-if-underspecified" })
```

### Banned Phrases

Never say: "looks good", "should work", "Done!", "requirements are clear" (local), "manual review", "code is simple"

### Task Tracking Required

Before code: `TaskCreate` + `TaskUpdate({ status: "in_progress" })`
After code: `TaskUpdate({ status: "completed" })`
Before completion: `TaskList` to verify all done

---

## Now Load The Skill

This summary is a backup. The full workflow loads inline with the skill.

**Your next action MUST be:** `Skill({ skill: "crew-claude" })`
