---
name: skill-builder
description: Create, audit, and maintain skills. Templates, workflows, and best practices for skill development.
triggers:
  - "create skill"
  - "new skill"
  - "audit skill"
  - "skill structure"
  - "SKILL.md"
---

<objective>

Provide tools and guidance for creating, auditing, and maintaining skills. Includes templates, workflows, and best practices for prompt-native skill development.

</objective>

<routing>

## Task Routing

| Task | Workflow |
|------|----------|
| Create new skill | `workflows/create-new-skill.md` |
| Create domain expertise skill | `workflows/create-domain-expertise-skill.md` |
| Audit existing skill | `workflows/audit-skill.md` |
| Add workflow to skill | `workflows/add-workflow.md` |
| Add reference to skill | `workflows/add-reference.md` |
| Add template to skill | `workflows/add-template.md` |
| Add script to skill | `workflows/add-script.md` |
| Upgrade to router | `workflows/upgrade-to-router.md` |
| Verify skill | `workflows/verify-skill.md` |
| Get guidance | `workflows/get-guidance.md` |

</routing>

<templates>

## Templates

| Template | Purpose |
|----------|---------|
| `simple-skill.md` | Basic skill structure |
| `router-skill.md` | Complex skill with routing |
| `skill-template.md` | Generic skill template |

</templates>

<references>

## Domain Knowledge

- `references/skill-structure.md` - SKILL.md format
- `references/recommended-structure.md` - Recommended skill structure
- `references/core-principles.md` - Skill design principles
- `references/common-patterns.md` - Reusable patterns
- `references/native-ui-components.md` - UI integration
- `references/using-templates.md` - Template usage
- `references/using-scripts.md` - Script integration
- `references/workflows-and-validation.md` - Workflow patterns
- `references/iteration-and-testing.md` - Testing skills
- `references/use-xml-tags.md` - XML tag conventions
- `references/be-clear-and-direct.md` - Writing style
- `references/executable-code.md` - Code in skills
- `references/api-security.md` - Security considerations

</references>

<scripts>

## Skill Scripts

Helper scripts are available in `crew/scripts/skills/`:

| Script | Purpose |
|--------|---------|
| `init_skill.py` | Initialize new skill structure |
| `package_skill.py` | Package skill for distribution |
| `quick_validate.py` | Validate skill structure |

</scripts>
