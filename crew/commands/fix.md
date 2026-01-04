---
name: crew:fix
description: Repair skills, resolve blockers, tune the system
argument-hint: "[skill name, issue description, or 'all' to fix pending todos]"
aliases:
  - fix
---

<objective>

Fix issues in the agent system, resolve blockers, and tune skills.

</objective>

<input>

<fix_target>$ARGUMENTS</fix_target>

</input>

<process>

**IMPORTANT:** Execute directly in main thread for native UI access.

## Phase 1: Determine Fix Type

Parse input to determine what to fix:

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

## Phase 2: Route to Appropriate Workflow

### Fix Pending Todos

```bash
# List pending todos
ls -la .claude/todos/*-pending-*.md 2>/dev/null
```

For each pending todo:
1. Read the finding
2. Implement the fix
3. Mark as complete by renaming: `*-pending-*` → `*-complete-*`
4. Create handoff

### Fix Skill Issue

1. **Read the skill** to understand current state:

```bash
cat .claude/skills/${SKILL_NAME}/SKILL.md
```

2. **Identify the problem** - Check for:
   - Outdated API references
   - Incorrect patterns
   - Missing workflows
   - Broken scripts

3. **Research correct approach**:

```javascript
Task({
  subagent_type: "framework-docs-researcher",
  prompt: "Research current best practices for: [skill domain]",
  run_in_background: true
});
```

4. **Fix the skill** with proper validation

5. **Test the fix**:

```bash
# If skill has scripts
shellcheck .claude/skills/${SKILL_NAME}/scripts/*.sh
```

### Fix PR Comments

```bash
# Get unresolved comments
gh pr view --json comments --jq '.comments[] | select(.state == "PENDING")'
```

For each comment:
1. Understand the requested change
2. Implement the fix
3. Commit with reference to comment
4. Mark as resolved

### Fix Described Issue

1. Research the problem
2. Create a mini-plan
3. Implement fixes
4. Verify with tests

## Phase 3: Validate Fixes

```bash
# Run CI to verify
bun run ci
```

## Phase 4: Create Handoff

```javascript
Skill({
  skill: "crew:handoff",
  args: "task Fixed: [summary of what was fixed]"
})
```

## Phase 5: Compound Learnings

If fixes revealed patterns worth preserving:

```javascript
Skill({ skill: "crew:compound" })
```

</process>

<skill_healing_patterns>

## Common Skill Issues

| Issue | Solution |
|-------|----------|
| Outdated API | Research current docs, update references |
| Wrong patterns | Check framework-docs-researcher, update |
| Missing workflow | Create workflow in workflows/ |
| Broken script | Fix script, test with shellcheck |
| Wrong triggers | Update frontmatter triggers |

## Skill Validation Checklist

- [ ] Valid YAML frontmatter
- [ ] Pure XML structure (no markdown # headings)
- [ ] Scripts pass shellcheck
- [ ] References exist and are current
- [ ] Workflows follow patterns

</skill_healing_patterns>

<success_criteria>

- [ ] Issue identified and understood
- [ ] Fix implemented correctly
- [ ] Tests/CI passing
- [ ] Handoff created
- [ ] Learnings compounded (if applicable)

</success_criteria>
