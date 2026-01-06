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

Create, audit, and maintain skills. Includes templates, workflows, and best practices for prompt-native skill development.

</objective>

<routing>

| Task                | Workflow                                     |
| ------------------- | -------------------------------------------- |
| Create new skill    | `workflows/create-new-skill.md`              |
| Create domain skill | `workflows/create-domain-expertise-skill.md` |
| Audit skill         | `workflows/audit-skill.md`                   |
| Add workflow        | `workflows/add-workflow.md`                  |
| Add reference       | `workflows/add-reference.md`                 |
| Add template        | `workflows/add-template.md`                  |
| Add script          | `workflows/add-script.md`                    |
| Upgrade to router   | `workflows/upgrade-to-router.md`             |
| Verify skill        | `workflows/verify-skill.md`                  |

</routing>

<templates>

| Template            | Purpose              |
| ------------------- | -------------------- |
| `simple-skill.md`   | Basic structure      |
| `router-skill.md`   | Complex with routing |
| `skill-template.md` | Generic template     |

</templates>

<references>

- `skill-structure.md` - SKILL.md format
- `core-principles.md` - Design principles
- `use-xml-tags.md` - XML conventions
- `be-clear-and-direct.md` - Writing style
- `common-patterns.md` - Reusable patterns
- `native-ui-components.md` - UI integration
- `using-templates.md` - Template usage
- `using-scripts.md` - Script integration
- `workflows-and-validation.md` - Workflow patterns

</references>

<scripts>

| Script              | Purpose                  |
| ------------------- | ------------------------ |
| `init_skill.py`     | Initialize structure     |
| `package_skill.py`  | Package for distribution |
| `quick_validate.py` | Validate structure       |

</scripts>

<success_criteria>

- Valid YAML frontmatter (name matches directory)
- Required tags: `<objective>`, `<quick_start>`, `<success_criteria>`
- All XML tags closed, no markdown headings in body
- Passes `quick_validate.py`

</success_criteria>
