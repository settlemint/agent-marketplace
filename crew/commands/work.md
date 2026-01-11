---
name: crew:work
description: Execute plans perfectly using orchestrated agents
argument-hint: "[plan slug]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - AskUserQuestion
  - TodoWrite
  - WebFetch
  - WebSearch
  - MCPSearch
  - Skill
skills:
  - crew:crew-patterns
  - crew:todo-tracking
  - crew:git
  - devtools:tdd-typescript
  - n-skills:orchestration
hooks:
  PostToolUse: false
  PreToolUse: false
---

<objective>

Execute a plan using orchestrated agents. Claude decides which agents to spawn based on task needs. Uses n-skills:orchestration for parallel work and agent selection.

</objective>

<tdd_enforcement>

**MANDATORY: Load `devtools:tdd-typescript` for ALL implementation.**

```javascript
Skill({ skill: "devtools:tdd-typescript" });
```

RED-GREEN-REFACTOR. Test fails first, then implement. No exceptions.

</tdd_enforcement>

<workflow>

## Step 1: Verify Not on Main

```bash
branch=$(git branch --show-current)
if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  echo "ERROR: Cannot run crew:work on main/master branch"
  exit 1
fi
```

## Step 2: Load Plan

```javascript
const slug = "$ARGUMENTS".trim() || inferFromBranch();
const planPath = `.claude/plans/${slug}.yaml`;
const plan = Read({ file_path: planPath });
```

## Step 3: Initialize TodoWrite

```javascript
// Convert plan stories to TodoWrite items
const todos = plan.stories.map((story) => ({
  content: `${story.id}: ${story.title}`,
  status: story.status === "complete" ? "completed" : "pending",
  activeForm: `Working on ${story.title}`,
}));
TodoWrite({ todos });
```

## Step 4: Execute Stories

For each story in priority order (P1 → P2 → P3):

1. **Load TDD skill**: `Skill({ skill: "devtools:tdd-typescript" })`
2. **Research if needed**: Use Task agents (Context7, OctoCode via MCP)
3. **Write failing test first** (RED)
4. **Implement minimal code** (GREEN)
5. **Refactor while green** (REFACTOR)
6. **Update TodoWrite** on completion

### Agent Selection (per n-skills:orchestration)

Let Claude decide which agents to spawn based on task complexity:

| Complexity | Agent Tier | Use Case                        |
| ---------- | ---------- | ------------------------------- |
| Simple     | Haiku      | Single file, straightforward    |
| Medium     | Sonnet     | Multi-file, some complexity     |
| Complex    | Opus       | Architecture, security-critical |

Spawn agents in parallel when tasks are independent.

## Step 5: Run CI

```javascript
Skill({ skill: "crew:work:ci", args: slug });
```

Fix any failures before proceeding.

## Step 6: Completion Check

Verify all stories are complete:

```javascript
const plan = Read({ file_path: planPath });
const incomplete = plan.stories.filter((s) => s.status !== "complete");

if (incomplete.length > 0) {
  // Continue working on incomplete stories
  // Claude decides if more agents needed
} else {
  // All done - ask about git action
}
```

## Step 7: Git Action

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Work complete. What would you like to do?",
      options: [
        "Create PR (Recommended)",
        "Commit & Push",
        "Commit only",
        "Stop",
      ],
    },
  ],
});

if (answer === "Create PR (Recommended)") {
  Skill({ skill: "crew:git:pr:create" });
} else if (answer === "Commit & Push") {
  Skill({ skill: "crew:git:commit-and-push" });
} else if (answer === "Commit only") {
  Skill({ skill: "crew:git:commit" });
}
```

</workflow>

<mcp_usage>

**Use MCP tools for research and analysis:**

```javascript
// Library documentation
MCPSearch({ query: "select:mcp__plugin_crew_context7__resolve-library-id" });
MCPSearch({ query: "select:mcp__plugin_crew_context7__query-docs" });

// GitHub code search
MCPSearch({ query: "select:mcp__plugin_crew_octocode__githubSearchCode" });

// Codex - deep reasoning for complex problems (use sparingly)
MCPSearch({ query: "select:mcp__plugin_crew_codex__codex" });
```

### When to Use Codex

Use Codex for problems requiring deep reasoning:

- Architecture decisions with trade-offs
- Security-critical code review
- Complex algorithm design
- Cross-cutting pattern analysis

```javascript
mcp__plugin_crew_codex__codex({
  prompt: `Analyze this implementation for [security|performance|correctness]:

${codeOrFindings}

Identify: root causes, systemic issues, priority escalations.`,
});
```

</mcp_usage>

<success_criteria>

- [ ] TDD followed for all implementation
- [ ] Stories executed in priority order
- [ ] CI passing
- [ ] All stories marked complete
- [ ] Git action completed per user choice

</success_criteria>
