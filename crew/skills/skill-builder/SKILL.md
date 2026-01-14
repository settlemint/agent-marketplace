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

| Task                | Workflow                                     | ~Tokens | Load When           |
| ------------------- | -------------------------------------------- | ------- | ------------------- |
| Create new skill    | `workflows/create-new-skill.md`              | ~400    | Building skill      |
| Create domain skill | `workflows/create-domain-expertise-skill.md` | ~350    | Library/framework   |
| Audit skill         | `workflows/audit-skill.md`                   | ~300    | Quality check       |
| Add workflow        | `workflows/add-workflow.md`                  | ~200    | Adding step-by-step |
| Add reference       | `workflows/add-reference.md`                 | ~150    | Adding knowledge    |
| Add template        | `workflows/add-template.md`                  | ~150    | Adding doc template |
| Add script          | `workflows/add-script.md`                    | ~200    | Adding automation   |
| Upgrade to router   | `workflows/upgrade-to-router.md`             | ~250    | Simple → complex    |
| Verify skill        | `workflows/verify-skill.md`                  | ~200    | Final validation    |

</routing>

<templates>

| Template            | Purpose              |
| ------------------- | -------------------- |
| `simple-skill.md`   | Basic structure      |
| `router-skill.md`   | Complex with routing |
| `skill-template.md` | Generic template     |

</templates>

<references>

| Reference                     | Purpose              | ~Tokens | Load When                 |
| ----------------------------- | -------------------- | ------- | ------------------------- |
| `skill-structure.md`          | SKILL.md format      | ~400    | First time                |
| `core-principles.md`          | Design principles    | ~300    | Design decisions          |
| `use-xml-tags.md`             | XML conventions      | ~200    | Structuring content       |
| `be-clear-and-direct.md`      | Writing style        | ~150    | Writing instructions      |
| `common-patterns.md`          | Reusable patterns    | ~350    | Pattern discovery         |
| `native-ui-components.md`     | UI integration       | ~250    | Adding UI elements        |
| `using-templates.md`          | Template usage       | ~200    | Template questions        |
| `using-scripts.md`            | Script integration   | ~200    | Automation questions      |
| `workflows-and-validation.md` | Workflow patterns    | ~300    | Adding workflows          |
| `agent-ux-design.md`          | Agent-friendly tools | ~350    | Building tools for agents |

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
