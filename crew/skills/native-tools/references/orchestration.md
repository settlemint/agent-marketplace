<overview>

Task and TaskOutput tools for agent orchestration.

</overview>

<task_tool>

Spawns sub-agents for complex work.

| Parameter           | Required | Description                                                    |
| ------------------- | -------- | -------------------------------------------------------------- |
| `subagent_type`     | Yes      | Agent type (Explore, Plan, general-purpose, etc.)              |
| `prompt`            | Yes      | Detailed instructions with CONTEXT, SCOPE, CONSTRAINTS, OUTPUT |
| `description`       | Yes      | 3-5 word summary                                               |
| `run_in_background` | Yes      | **ALWAYS true**                                                |
| `model`             | No       | Override: `haiku`, `sonnet`, `opus`                            |
| `resume`            | No       | Agent ID to continue from                                      |

</task_tool>

<prompt_structure>

Every prompt MUST include:

```
CONTEXT: The larger picture
SCOPE: Precisely what to accomplish
CONSTRAINTS: Rules and patterns
OUTPUT: What to return
```

</prompt_structure>

<task_output_tool>

Retrieves results from spawned agents.

| Parameter | Required | Default | Description         |
| --------- | -------- | ------- | ------------------- |
| `task_id` | Yes      | -       | Agent ID            |
| `block`   | No       | true    | Wait for completion |
| `timeout` | No       | 30000   | Max wait (ms)       |

</task_output_tool>

<agent_types>

| Type                | Purpose        | Tools                      |
| ------------------- | -------------- | -------------------------- |
| `Explore`           | Quick search   | Glob, Grep, Read           |
| `Plan`              | Architecture   | All                        |
| `general-purpose`   | Implementation | All                        |
| `claude-code-guide` | Documentation  | Glob, Grep, Read, WebFetch |

</agent_types>

<usage>

```javascript
// Parallel launch (SINGLE message)
Task({
  subagent_type: "X",
  prompt: "...",
  description: "X task",
  run_in_background: true,
});
Task({
  subagent_type: "Y",
  prompt: "...",
  description: "Y task",
  run_in_background: true,
});

// Collect results
TaskOutput({ task_id: "x-id", block: true });
TaskOutput({ task_id: "y-id", block: true });
```

</usage>

<anti_patterns>

- `run_in_background: false` - Always use true
- Sequential when parallel possible - Launch all together
- Vague prompts - Must include CONTEXT/SCOPE/CONSTRAINTS/OUTPUT
- Agent for simple search - Use Glob directly instead

</anti_patterns>
