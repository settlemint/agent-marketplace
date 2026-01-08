---
description: Agent execution limits and orchestration rules
globs: "**/*"
alwaysApply: true
---

# Agent Execution Limits

These rules ensure efficient agent orchestration and prevent resource exhaustion.

## Concurrent Agent Limits

### Maximum Agents Per Batch

- **LIMIT**: Maximum 6 agents per batch
- **NEVER** launch more than 6 agents in a single message
- **WAIT** for entire batch to complete before launching more

### Why This Matters

- Prevents context window overflow
- Ensures predictable resource usage
- Allows proper result collection

## Agent Launch Pattern

### Correct: Single Message, Multiple Agents

```javascript
// Launch all agents in ONE message
Task({ subagent_type: "reviewer-1", prompt: "...", run_in_background: true });
Task({ subagent_type: "reviewer-2", prompt: "...", run_in_background: true });
Task({ subagent_type: "reviewer-3", prompt: "...", run_in_background: true });
// All launched together, collected together
```

### Wrong: Sequential Launches

```javascript
// DON'T DO THIS - launches separately
Task({ ... });  // Message 1
Task({ ... });  // Message 2 - wrong!
```

## Agent Types and Models

### Model Inheritance

- Agents inherit the parent model (opus/sonnet) by default
- Only test-runner agents should use haiku for cost efficiency

### Read-Only Agents

These agents should have `context: fork` and `hooks: false`:

- All reviewer agents (7-legs)
- Research agents (codebase-analyst, docs-researcher, etc.)
- Analysis agents

### Write-Capable Agents

These agents should keep hooks enabled (for auto-lint):

- work-orchestrator
- pr-comment-resolver
- design-iterator

## Result Collection

### Always Collect All Results

```javascript
// Wait for ALL agents before proceeding
const results = [];
for (const agent of agents) {
  results.push(TaskOutput({ task_id: agent.id, block: true }));
}
// Now process results
```

### Output Format Requirement

All agents must output in this format:

- `SUCCESS: <summary>` - Task completed successfully
- `FAILURE: <reason>` - Task failed with explanation

## Loop Mode Constraints

When in `--loop` mode:

1. Track iterations in state file
2. Default max: 10 iterations
3. Stop on `<promise>BUILD COMPLETE</promise>`
4. Create fix tasks for failures instead of infinite loops

## Emergency Stops

If agents appear stuck:

- Use `/crew:cancel-loop` to stop iterations
- Check `.claude/branches/{branch}/state.json` for loop state
- Review task files for blocking issues
