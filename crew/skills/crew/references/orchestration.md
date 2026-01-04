# Agent Orchestration

## Core Principle

**Agents work, you orchestrate.** Spawn agents for heavy lifting, keep main thread light for decisions.

## When to Use Agents

| Task Type | Use Agent? | Reason |
|-----------|------------|--------|
| Multi-file implementation | Yes | Agent handles complexity |
| Following a plan phase | Yes | Agent reads plan, implements |
| New feature with tests | Yes | Agent can run tests |
| Research / exploration | Yes | Agent gathers context |
| Single-line fix | No | Faster to do directly |
| Quick config change | No | Overhead not worth it |
| Decisions requiring UI | No | AskUserQuestion needs main thread |

## The Pattern

**Wrong - burns context:**
```
Main: Read files → Understand → Make edits → Report
  (2000+ tokens consumed in main context)
```

**Right - preserves context:**
```
Main: Spawn agent("implement X per plan")
  ↓
Agent: Reads files → Understands → Edits → Tests
  ↓
Main: Gets summary (~200 tokens)
```

## Parallel vs Sequential

### Parallel (Independent tasks)

Launch all at once in a single message:

```javascript
Task({ subagent_type: "repo-research-analyst", prompt: "...", run_in_background: true });
Task({ subagent_type: "best-practices-researcher", prompt: "...", run_in_background: true });
Task({ subagent_type: "framework-docs-researcher", prompt: "...", run_in_background: true });
```

### Sequential (Dependent tasks)

Wait for each before starting next:

```javascript
const research = await Task({ subagent_type: "repo-research-analyst", prompt: "..." });
// Use research results in next task
const design = await Task({ subagent_type: "Plan", prompt: `Based on ${research}...` });
```

## Agent Types for Crew

### Research Agents

| Agent | Purpose |
|-------|---------|
| `repo-research-analyst` | Analyze repository patterns |
| `best-practices-researcher` | Industry best practices |
| `framework-docs-researcher` | Framework documentation |
| `Explore` | Quick codebase exploration |

### Review Agents

| Agent | Purpose |
|-------|---------|
| `kieran-typescript-reviewer` | TypeScript quality |
| `security-sentinel` | Security audit |
| `code-simplicity-reviewer` | YAGNI, complexity |
| `architecture-strategist` | Architecture patterns |
| `solidity-security-auditor` | Smart contract security |

### Implementation Agents

| Agent | Purpose |
|-------|---------|
| `general-purpose` | Multi-step implementations |
| `Plan` | Design implementation approach |

## Handoff Between Agents

When spawning sequential agents, use handoff files:

```javascript
// Agent 1 creates handoff
Task({
  subagent_type: "general-purpose",
  prompt: `Implement Task 1. After completing:
    Skill({skill: "crew:handoff", args: "task [description]"})`
});

// Agent 2 reads previous handoff
Task({
  subagent_type: "general-purpose",
  prompt: `Implement Task 2.
    Previous handoff: .claude/branches/{branch}/handoffs/task-*.md`
});
```

## Key Insight

Agents read their own context. Don't read files in main chat just to understand what to pass to an agent - give them the task and they figure it out.
