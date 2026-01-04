# Codex MCP Reference

Delegate complex tasks to OpenAI's Codex model for deep reasoning.

## Constraints

- **Context isolation:** Codex cannot access your conversation history or Claude's tools
- **Working directory:** Always specify `cwd` for file operations
- **Latency:** Deep reasoning takes time; don't use for quick answers
- **Project conventions:** Validate output against local patterns

## Tools

### Start New Session

```
mcp__codex__codex({
  prompt: "Analyze this algorithm and suggest optimizations",
  cwd: "/path/to/project",
  sandbox: "workspace-write"
})
```

### Continue Conversation

```
mcp__codex__codex-reply({
  conversationId: "from-previous",
  prompt: "How would this handle edge cases?"
})
```

## Parameters

| Parameter         | Required | Description                                            |
| ----------------- | -------- | ------------------------------------------------------ |
| `prompt`          | Yes      | Task or question                                       |
| `cwd`             | No       | Working directory for file access                      |
| `sandbox`         | No       | `read-only` / `workspace-write` / `danger-full-access` |
| `model`           | No       | Override default (gpt-5.2-codex)                       |
| `approval-policy` | No       | `untrusted` / `on-failure` / `on-request` / `never`    |

## Common Patterns

### One-Shot Analysis

```
mcp__codex__codex({
  prompt: "Review this code for security issues: [paste code]",
  cwd: "/project"
})
```

### Multi-Turn Investigation

```
result = mcp__codex__codex({ prompt: "Analyze auth flow", cwd: "/project" })
mcp__codex__codex-reply({ conversationId: result.id, prompt: "What vulnerabilities exist?" })
```

### Second Opinion

```
mcp__codex__codex({
  prompt: "Critique my approach: [your analysis]. Suggest alternatives."
})
```

### Architecture Analysis

```
mcp__codex__codex({
  prompt: "Design a scalable event-driven architecture for real-time notifications"
})
```

## Sandbox Modes

| Mode                 | Access              | Network | Use Case                      |
| -------------------- | ------------------- | ------- | ----------------------------- |
| `read-only`          | Read files only     | No      | Safe exploration, code review |
| `workspace-write`    | Read + write in cwd | No      | File edits, refactoring       |
| `danger-full-access` | Full disk access    | Yes     | Container isolation only      |

## Code Review Guidelines

When using Codex for code review:

**Bug Validity Criteria:**
1. Meaningfully impacts accuracy, performance, security, or maintainability
2. Discrete and actionable (not general issues)
3. Bug was introduced in this change (not pre-existing)
4. Author would likely fix if made aware

**Priority Levels:**
- **P0** – Blocking release/operations
- **P1** – Urgent, address next cycle
- **P2** – Normal, fix eventually
- **P3** – Nice to have

**Output Format:** Include `confidence_score` (0.0-1.0) and `priority` (0-3) for each finding.

## When to Use

**Good use cases:**
- Complex algorithmic problems requiring deep reasoning
- Code review for security or performance concerns
- Architecture decisions with multiple trade-offs
- Getting a second opinion on your approach

**When NOT to use:**
- Simple tasks Claude can handle quickly
- Tasks requiring extensive local project context
- When you need immediate results
