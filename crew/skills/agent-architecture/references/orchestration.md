<overview>

Agent orchestration patterns for crew workflows. **Agents work, you orchestrate.** Spawn agents for heavy lifting, keep main thread light for decisions.

</overview>

<critical_limitation>

**AskUserQuestion does NOT work from sub-agents.** It returns as plain text to parent - user never sees native UI.

**Solutions:**

- Return findings to parent, let IT call AskUserQuestion
- Proceed with reasonable defaults when straightforward

</critical_limitation>

<when_to_use_agents>

| Task                      | Agent? | Reason                            |
| ------------------------- | ------ | --------------------------------- |
| Multi-file implementation | Yes    | Agent handles complexity          |
| Following a plan phase    | Yes    | Agent reads plan, implements      |
| Research / exploration    | Yes    | Agent gathers context             |
| Single-line fix           | No     | Faster directly                   |
| Decisions requiring UI    | No     | AskUserQuestion needs main thread |

</when_to_use_agents>

<parallel_vs_sequential>

**Parallel (independent tasks):** Launch ALL in single message

```javascript
Task({ subagent_type: "X", prompt: "...", run_in_background: true });
Task({ subagent_type: "Y", prompt: "...", run_in_background: true });
```

**Sequential (dependent):** Wait for each

```javascript
const research = await Task({ subagent_type: "analyst", prompt: "..." });
const design = await Task({
  subagent_type: "Plan",
  prompt: `Based on ${research}...`,
});
```

</parallel_vs_sequential>

<agent_types>

| Type                        | Purpose                               |
| --------------------------- | ------------------------------------- |
| `Explore`                   | Quick codebase exploration            |
| `Plan`                      | Architecture, implementation strategy |
| `general-purpose`           | Complex multi-step implementation     |
| `repo-research-analyst`     | Repository pattern analysis           |
| `best-practices-researcher` | Industry best practices               |
| `*-reviewer`                | Seven-leg review agents               |

</agent_types>

<todowrite_rules>

- Mark `in_progress` BEFORE starting task
- Mark `completed` IMMEDIATELY after finishing
- **Never batch status updates**
- Only ONE task `in_progress` at a time

See `<pattern name="todo-progress"/>` in crew-patterns skill.

</todowrite_rules>

<orchestrator_workflow>

1. **Setup**: TodoWrite with all phases, determine target, AskUserQuestion for scope
2. **Parallel execution**: Launch ALL agents in ONE message, collect with TaskOutput
3. **Synthesis**: Categorize, prioritize, deduplicate
4. **Report**: AskUserQuestion for format, create artifacts, mark complete

</orchestrator_workflow>

<handoffs>

For sequential agents:

```javascript
// Agent 1 creates handoff
Task({
  prompt: `... After completing: Skill({skill: "crew:handoff", args: "task [description]"})`,
});

// Agent 2 reads previous
Task({
  prompt: `... Previous handoff: .claude/branches/{branch}/handoffs/task-*.md`,
});
```

</handoffs>

<anti_patterns>

- **AskUserQuestion in sub-agents** - Returns plain text, UI never shows
- **Sequential when parallel possible** - Always launch together
- **Batch TodoWrite updates** - Update immediately
- **Vague prompts** - Must include CONTEXT, SCOPE, CONSTRAINTS, OUTPUT

</anti_patterns>
