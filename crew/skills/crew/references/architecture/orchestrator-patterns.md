# Orchestrator Agent Patterns

## Critical Limitation

```markdown
<critical_limitation>
**WARNING: AskUserQuestion does NOT work from sub-agents**

When you call AskUserQuestion from within a Task/sub-agent, it returns as plain text
to the parent - the user never sees the native UI components.

**If you need user input:** Return your findings/options to the parent thread and let
IT call AskUserQuestion.
**Alternative:** Proceed with reasonable defaults when decisions are straightforward.
</critical_limitation>
```

**All orchestrator agents MUST include this warning.**

## TodoWrite Progress Pattern

Create todo list at the start showing all phases:

```javascript
TodoWrite([
  {
    content: "Phase 1: Setup",
    status: "in_progress",
    activeForm: "Setting up",
  },
  { content: "Phase 2: Execute", status: "pending", activeForm: "Executing" },
  {
    content: "Phase 3: Synthesize",
    status: "pending",
    activeForm: "Synthesizing",
  },
  { content: "Phase 4: Report", status: "pending", activeForm: "Reporting" },
]);
```

**Update rules:**

- Mark `in_progress` BEFORE starting a task
- Mark `completed` IMMEDIATELY after finishing
- Never batch status updates
- Include granular sub-tasks for long phases

## Parallel Agent Execution

**Launch agents in a SINGLE message:**

```javascript
// Send ONE message with multiple Task calls:
Task({
  subagent_type: "agent-type-1",
  prompt: "...",
  run_in_background: true,
});
Task({
  subagent_type: "agent-type-2",
  prompt: "...",
  run_in_background: true,
});
Task({
  subagent_type: "agent-type-3",
  prompt: "...",
  run_in_background: true,
});
```

**Collect results:**

```javascript
// Wait for completion (blocking)
TaskOutput({ task_id: "agent1_id", block: true });
TaskOutput({ task_id: "agent2_id", block: true });
```

**Update TodoWrite** after each agent completes to show progress (X/N complete).

## AskUserQuestion Checkpoints

**Pattern 1: Scope selection (at start):**

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What scope should I use?",
      header: "Scope",
      options: [
        { label: "Full (Recommended)", description: "Complete analysis" },
        { label: "Quick", description: "Core checks only" },
        { label: "Focused", description: "Specific area only" },
      ],
      multiSelect: false,
    },
  ],
});
```

**Pattern 2: Critical findings:**

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Found critical issues. How should I proceed?",
      header: "Critical",
      options: [
        { label: "Continue", description: "Complete all phases first" },
        { label: "Stop and fix", description: "Address immediately" },
        { label: "Show details", description: "Display issues now" },
      ],
      multiSelect: false,
    },
  ],
});
```

**Pattern 3: Final approval:**

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Ready to complete?",
      header: "Confirm",
      options: [
        { label: "Proceed", description: "Finalize and report" },
        { label: "Review first", description: "Show detailed changes" },
        { label: "Run more checks", description: "Additional validation" },
      ],
      multiSelect: false,
    },
  ],
});
```

## GitHub CLI Scripts Integration

Scripts in `.claude/skills/crew/scripts/git/`:

```bash
# Repository info
.claude/skills/crew/scripts/git/gh-repo-info.sh
# → NAME_WITH_OWNER, OWNER, REPO, DEFAULT_BRANCH, REPO_URL

# PR metadata
.claude/skills/crew/scripts/git/gh-pr-info.sh [PR_NUMBER]
# → PR_NUMBER, PR_URL, PR_TITLE, PR_STATE, HEAD_BRANCH

# Unresolved threads
.claude/skills/crew/scripts/git/gh-pr-threads.sh [PR_NUMBER]
# → List of unresolved comments with file:line
```

## Orchestrator Workflow Template

```markdown
## Phase 1: Setup & Scope

1. Create TodoWrite with all phases
2. Determine target from arguments
3. Use gh CLI scripts for context
4. AskUserQuestion for scope selection
5. Mark setup complete

## Phase 2: Parallel Execution

1. Update TodoWrite - mark phase in_progress
2. Launch ALL agents in ONE message
3. Use TaskOutput to collect results
4. Update TodoWrite after each completes

## Phase 3: Synthesis

1. Collect all findings
2. Categorize and prioritize
3. Remove duplicates
4. Prepare report structure

## Phase 4: Report & Handoff

1. AskUserQuestion for output format
2. Present comprehensive summary
3. Create any artifacts (todos, files)
4. Mark all tasks complete
```

## Orchestrator Agent Frontmatter

```yaml
---
name: <purpose>-orchestrator
description: <Purpose description>. NOTE - AskUserQuestion does NOT work from sub-agents.
skills: monorepo, file-todos, <domain-skills>
model: inherit
---
```

## Existing Orchestrators

| Orchestrator            | Purpose                  | Key Agents Used          |
| ----------------------- | ------------------------ | ------------------------ |
| `review-orchestrator`   | Multi-agent code review  | 9+ review agents + Codex |
| `work-orchestrator`     | Execute work plans       | Quality review agents    |
| `fix-pr-orchestrator`   | Resolve PR comments      | `pr-comment-resolver`    |
| `/workflows:compound`   | Document solved problems | Runs in main thread      |
| `triage-orchestrator`   | Categorize findings      | Analysis agents          |

## Anti-Patterns

**Never do these in orchestrators:**

1. **AskUserQuestion in sub-agents** - returns plain text, UI never shows
2. **Sequential agent launches** - always launch in parallel
3. **Batch TodoWrite updates** - update immediately after each task
4. **Skip gh CLI scripts** - use them for PR context
5. **Forget critical_limitation** - always include the warning
