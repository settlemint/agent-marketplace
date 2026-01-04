---
name: crew:fix
description: Repair skills, resolve blockers, tune the system
argument-hint: "[skill name, issue description, or 'all' to fix pending todos]"
---

!`../scripts/workflow/fix-context.sh`

## Input

<fix_target>$ARGUMENTS</fix_target>

## Process

### Phase 1: Determine Fix Type

```javascript
AskUserQuestion({
  questions: [{
    question: "What would you like to fix?",
    header: "Target",
    options: [
      {label: "Pending todos", description: "Work through .claude/todos/ findings"},
      {label: "Skill issue", description: "Repair a broken or incorrect skill"},
      {label: "PR comments", description: "Resolve unresolved PR review comments"},
      {label: "Describe issue", description: "I'll explain what needs fixing"}
    ],
    multiSelect: false
  }]
})
```

### Phase 2: Route to Workflow

**Fix Pending Todos:**
For each pending todo:
1. Read the finding
2. Implement the fix
3. Rename: `*-pending-*` → `*-complete-*`

**Fix Skill Issue:**
1. Read the skill: `cat .claude/skills/${SKILL_NAME}/SKILL.md`
2. Research correct approach
3. Fix and validate

**Fix PR Comments:**
For each comment:
1. Understand requested change
2. Implement fix
3. Commit with reference

### Phase 3: Validate

```bash
bun run ci
```

## Success Criteria

- [ ] Issue identified and understood
- [ ] Fix implemented correctly
- [ ] Tests/CI passing
