# Agent Orchestration Tools

## Task — Spawn Sub-Agents

Delegates complex work to background agents.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `subagent_type` | string | Yes | Agent type to spawn |
| `prompt` | string | Yes | Detailed instructions |
| `description` | string | Yes | 3-5 word summary |
| `run_in_background` | boolean | Yes | **ALWAYS set to true** |
| `model` | string | No | Override with `haiku`, `sonnet`, `opus` |
| `resume` | string | No | Agent ID to resume from |

### Agent Types

| Type | Purpose | Tools Available |
|------|---------|-----------------|
| `Explore` | Find patterns, understand code | Glob, Grep, Read |
| `Plan` | Architecture, implementation strategy | All tools |
| `general-purpose` | Complex multi-step implementation | All tools |
| `claude-code-guide` | Claude Code documentation | Glob, Grep, Read, WebFetch, WebSearch |

### Prompt Structure (Critical)

Every prompt MUST include:

1. **Context** — The larger picture
2. **Scope** — Precisely what to accomplish
3. **Constraints** — Rules and patterns to follow
4. **Output** — What to return

```javascript
// GOOD: Complete prompt with all elements
Task({
  subagent_type: "general-purpose",
  prompt: `CONTEXT: Building a Todo app with Express and SQLite.

SCOPE: Create authentication endpoints in server/src/routes/auth.js:
- POST /signup with email validation
- POST /login with JWT token generation
- GET /me for current user

CONSTRAINTS:
- Use bcrypt for password hashing
- Pull JWT_SECRET from environment
- Follow existing route patterns in server/src/routes/

OUTPUT: Confirm files created and provide usage examples.`,
  description: "Create auth endpoints",
  run_in_background: true
})

// BAD: Vague prompt
Task({
  prompt: "Fix the auth bug",  // Missing context, scope, constraints
  ...
})
```

### Best Practices

```javascript
// GOOD: Background execution (mandatory)
Task({
  subagent_type: "Explore",
  prompt: "Find all API endpoints in src/api/",
  description: "Find API endpoints",
  run_in_background: true  // ALWAYS true
})

// GOOD: Parallel agents in single message
Task({subagent_type: "typescript-reviewer", prompt: "Review: [files]", description: "TS review", run_in_background: true})
Task({subagent_type: "security-sentinel", prompt: "Audit: [files]", description: "Security audit", run_in_background: true})
Task({subagent_type: "performance-oracle", prompt: "Analyze: [files]", description: "Perf analysis", run_in_background: true})

// GOOD: Use haiku for simple tasks
Task({
  subagent_type: "Explore",
  prompt: "Find test files matching pattern",
  description: "Find test files",
  run_in_background: true,
  model: "haiku"  // Faster, cheaper for simple work
})

// GOOD: Resume previous agent
Task({
  subagent_type: "general-purpose",
  resume: "abc123",  // Continue from previous work
  prompt: "Continue with the database migration",
  description: "Continue migration",
  run_in_background: true
})
```

### Agent Selection Guide

| Task Type | Agent | Why |
|-----------|-------|-----|
| Find files/patterns | `Explore` | Fast, focused |
| Understand codebase | `Explore` | Quick analysis |
| Design implementation | `Plan` | Thorough planning |
| Write code | `general-purpose` | Full tool access |
| Fix complex bugs | `general-purpose` | Needs all tools |
| Claude Code help | `claude-code-guide` | Documentation access |

---

## TaskOutput — Retrieve Results

Gets output from spawned agents.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `task_id` | string | Yes | Agent ID to get output from |
| `block` | boolean | No | Wait for completion (default: true) |
| `timeout` | number | No | Max wait in ms (default: 30000) |

### Usage Patterns

```javascript
// Wait for completion (default)
TaskOutput({task_id: "abc123"})

// Non-blocking check
TaskOutput({task_id: "abc123", block: false})

// Wait with timeout
TaskOutput({task_id: "abc123", timeout: 60000})
```

### Orchestration Flow

```javascript
// 1. Launch parallel agents
const reviewers = [
  Task({subagent_type: "typescript-reviewer", prompt: "...", description: "TS review", run_in_background: true}),
  Task({subagent_type: "security-sentinel", prompt: "...", description: "Security", run_in_background: true}),
  Task({subagent_type: "performance-oracle", prompt: "...", description: "Perf", run_in_background: true})
]

// 2. Continue other work while agents run...

// 3. Collect results
TaskOutput({task_id: "reviewer-1"})
TaskOutput({task_id: "reviewer-2"})
TaskOutput({task_id: "reviewer-3"})

// 4. Synthesize findings
```

---

## Complete Orchestration Example

### Multi-Agent Code Review

```javascript
// Phase 1: Gather context
const changedFiles = Glob({pattern: "**/*.ts"})
const diff = Bash({command: "git diff main...HEAD"})

// Phase 2: Launch parallel reviewers (SINGLE MESSAGE)
Task({
  subagent_type: "typescript-reviewer",
  prompt: `CONTEXT: PR review for feature branch
SCOPE: Review TypeScript quality in: ${changedFiles}
CONSTRAINTS: Focus on type safety, modern patterns, testability
OUTPUT: Findings with file:line, severity, recommendation`,
  description: "TypeScript review",
  run_in_background: true
})

Task({
  subagent_type: "security-sentinel",
  prompt: `CONTEXT: Security audit for PR
SCOPE: Analyze for vulnerabilities in: ${changedFiles}
CONSTRAINTS: Check OWASP Top 10, injection, auth issues
OUTPUT: Security findings with severity and remediation`,
  description: "Security audit",
  run_in_background: true
})

Task({
  subagent_type: "architecture-strategist",
  prompt: `CONTEXT: Architecture review for PR
SCOPE: Check design patterns in: ${changedFiles}
CONSTRAINTS: Verify layer boundaries, SOLID principles
OUTPUT: Architectural concerns with recommendations`,
  description: "Architecture review",
  run_in_background: true
})

// Phase 3: Collect and synthesize
// (Wait for all agents to complete)
const tsFindings = TaskOutput({task_id: "ts-review-id"})
const secFindings = TaskOutput({task_id: "sec-review-id"})
const archFindings = TaskOutput({task_id: "arch-review-id"})

// Phase 4: Triage and prioritize
// Deduplicate, categorize as P1/P2/P3
```

---

## Anti-Patterns

```javascript
// BAD: Foreground execution
Task({
  run_in_background: false  // NEVER do this
})

// BAD: Sequential when parallel possible
Task({...})
TaskOutput({...})  // Waiting
Task({...})        // Then launching next
TaskOutput({...})  // Waiting again

// GOOD: Parallel launch
Task({...run_in_background: true})
Task({...run_in_background: true})
Task({...run_in_background: true})
// Continue work, then collect

// BAD: Vague prompt
Task({prompt: "Review the code"})

// GOOD: Detailed prompt
Task({prompt: `CONTEXT: ...
SCOPE: ...
CONSTRAINTS: ...
OUTPUT: ...`})

// BAD: Using agent for simple search
Task({prompt: "Find all .ts files"})

// GOOD: Use native tool directly
Glob({pattern: "**/*.ts"})
```

---

## Agent Capabilities Matrix

### What Agents CAN Do

| Agent Type | Glob | Grep | Read | Edit | Write | Bash | WebFetch |
|------------|------|------|------|------|-------|------|----------|
| Explore | Yes | Yes | Yes | No | No | No | No |
| Plan | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| general-purpose | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| claude-code-guide | Yes | Yes | Yes | No | No | No | Yes |

### Custom Agents (Plugin Agents)

Plugin-defined agents (like `typescript-reviewer`, `security-sentinel`) receive:
- Full conversation context
- All tools available to the parent
- Their agent definition as system context

They do NOT receive:
- Skills from the parent (skills don't inherit)
- Automatic MCP tool access (must be in their prompt)
