---
name: {{SKILL_NAME}}
description: {{What it does}} Use when {{trigger conditions}}.
---

<!--
UI Best Practices: See references/native-ui-components.md for:
- AskUserQuestion patterns for all user choices
- TodoWrite for multi-step progress tracking
- Mermaid diagrams for architecture visualization
- Consistent output styling with severity symbols
-->

<essential_principles>
## {{Core Concept}}

{{Principles that ALWAYS apply, regardless of which workflow runs}}

### 1. {{First principle}}
{{Explanation}}

### 2. {{Second principle}}
{{Explanation}}

### 3. {{Third principle}}
{{Explanation}}
</essential_principles>

<intake>
Use the **AskUserQuestion tool** to determine the task:

```
AskUserQuestion:
  header: "Task Type"
  question: "What would you like to do?"
  options:
    - label: "{{First option}}"
      description: "{{Description of first option}}"
    - label: "{{Second option}}"
      description: "{{Description of second option}}"
    - label: "{{Third option}}"
      description: "{{Description of third option}}"
  multiSelect: false
```
</intake>

<routing>
| Response | Workflow |
|----------|----------|
| 1, "{{keywords}}" | `workflows/{{first-workflow}}.md` |
| 2, "{{keywords}}" | `workflows/{{second-workflow}}.md` |
| 3, "{{keywords}}" | `workflows/{{third-workflow}}.md` |

**After reading the workflow, follow it exactly.**
</routing>

<quick_reference>
## {{Skill Name}} Quick Reference

{{Brief reference information always useful to have visible}}
</quick_reference>

<reference_index>
## Domain Knowledge

All in `references/`:
- {{reference-1.md}} - {{purpose}}
- {{reference-2.md}} - {{purpose}}
</reference_index>

<workflows_index>
## Workflows

All in `workflows/`:

| Workflow | Purpose |
|----------|---------|
| {{first-workflow}}.md | {{purpose}} |
| {{second-workflow}}.md | {{purpose}} |
| {{third-workflow}}.md | {{purpose}} |
</workflows_index>

<success_criteria>
A well-executed {{skill name}}:
- {{First criterion}}
- {{Second criterion}}
- {{Third criterion}}
</success_criteria>
