---
name: crew:design
description: Create validated implementation plans with research
argument-hint: "[feature description, bug report, or improvement idea]"
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
---

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>

<phantom_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/phantom-context.sh`
</phantom_context>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<prerequisite>

**Load patterns skill first:**

```javascript
Skill({ skill: "crew:crew-patterns" });
```

This provides: `<pattern name="research-agents"/>`, `<pattern name="task-file"/>`.

</prerequisite>

<input>
<feature_description>$ARGUMENTS</feature_description>
</input>

<output_files>

1. **Plan** → `.claude/plans/<feature-slug>.md`
2. **Task files** → `.claude/branches/<slugified-branch>/tasks/*.md`

</output_files>

<notes>
- **NEVER CODE** - This command researches and writes plans only
- Branch early for state directory, agents per @rules/agent-limits.md
- spec-flow-analyzer runs after all research collected
</notes>

<process>

<phase name="memory-recall">
**Query claude-mem for past learnings before expensive research:**

```javascript
// Search for relevant past decisions, discoveries, gotchas
mcp__claude_mem__search({
  query: "<feature keywords>",
  type: "decision,discovery,bugfix",
  limit: 10,
});

// If relevant results found (~50 tokens per result), evaluate ROI
// Fetch full details only for high-relevance matches
mcp__claude_mem__get_observations({
  ids: [relevant_ids], // ~500 tokens per observation
});
```

**Why:** Prevents re-discovering known gotchas and respects past architectural decisions. Costs ~1000 tokens vs re-researching from scratch.

**CRITICAL - Memory vs Current Request:**

- Memory INFORMS, never OVERRIDES the user's explicit request
- User's current ask ALWAYS takes priority over past observations
- If memory suggests approach X but user asks for approach Y → follow user's request
- If memory conflicts with current request, use AskUserQuestion:

```javascript
AskUserQuestion({
  questions: [
    {
      question:
        "I found a past observation that suggests [X], but your current request implies [Y]. Which approach should I follow?",
      options: [
        "Follow my current request (Y)",
        "Use the past approach (X)",
        "Explain both so I can decide",
      ],
    },
  ],
});
```

**Skip if:** No claude-mem MCP available or empty results.
</phase>

<phase name="validate-input">
If empty or unclear:
```javascript
AskUserQuestion({
  questions: [{
    question: "What would you like to design?",
    header: "Type",
    options: [
      { label: "New feature", description: "Add new functionality" },
      { label: "Bug fix", description: "Fix an existing issue" },
      { label: "Refactoring", description: "Improve code structure" },
      { label: "Infrastructure", description: "DevOps or tooling" }
    ],
    multiSelect: false
  }]
});
```
</phase>

<phase name="isolation-setup">
**CRITICAL: Ask isolation question FIRST before any file creation.**

If on main/master, ask how to isolate this feature:

```javascript
const branch = Bash({ command: "git branch --show-current" }).trim();
if (branch === "main" || branch === "master") {
  AskUserQuestion({
    questions: [
      {
        question: "How should this feature be isolated?",
        header: "Isolation",
        options: [
          {
            label: "New worktree (Recommended)",
            description: "Isolated phantom worktree for independent work",
          },
          {
            label: "Stacked branch",
            description: "Add to machete stack for dependent changes",
          },
          {
            label: "Simple branch",
            description: "Regular branch in current checkout",
          },
        ],
        multiSelect: false,
      },
    ],
  });
}
```

**Handle isolation choice:**

```javascript
if (isolationChoice === "New worktree") {
  // Delegate to worktree skill (handles username prefix, name confirmation, phantom create)
  Skill({ skill: "crew:git:worktree" });

  // CRITICAL: Worktree requires manual switch - EXIT with clear instructions
  // The worktree skill will show instructions and open editor
  // DO NOT continue to research phase - user must switch sessions
  return; // Exit design command
}

if (isolationChoice === "Stacked branch") {
  // Create branch with username prefix (from current)
  Skill({ skill: "crew:git:branch:new", args: "--base current" });

  // Add to machete stack
  Skill({ skill: "crew:git:stacked:add" });
  // Continue to research phase in same session
}

if (isolationChoice === "Simple branch") {
  // Create branch with username prefix (from main)
  Skill({ skill: "crew:git:branch:new", args: "--base main" });
  // Continue to research phase in same session
}
```

**IMPORTANT: Worktree isolation requires session switch.**

When "New worktree" is chosen:
1. Worktree is created via `phantom create`
2. Editor opens via `phantom edit`
3. Clear instructions shown for how to switch
4. **Command EXITS** - user must start new Claude session in worktree
5. User runs `/crew:design <feature>` again in the new worktree session

**If already in a worktree or feature branch:** Skip isolation question, proceed with current branch.
</phase>

<phase name="interview">
**Clarify ambiguous requirements BEFORE research:**

Analyze the feature description and ask 2-4 contextual questions if needed:

```javascript
// Determine if interview is needed based on description clarity
const needsInterview =
  featureDescription.length < 100 || // Too short
  !featureDescription.includes("should") || // No clear requirements
  featureDescription.includes("?") || // Contains questions
  featureDescription.split(" ").length < 20; // Very brief

if (needsInterview) {
  // Build questions dynamically based on what's missing
  const questions = [];

  // Question 1: Scope boundaries (always useful)
  questions.push({
    question: "What should be explicitly OUT of scope for this feature?",
    header: "Scope",
    options: [
      {
        label: "Keep it minimal",
        description: "Only the core functionality described",
      },
      {
        label: "Include related improvements",
        description: "Fix adjacent issues while we're there",
      },
      {
        label: "Full solution",
        description: "End-to-end implementation with edge cases",
      },
    ],
    multiSelect: false,
  });

  // Question 2: Technical constraints (if technical details unclear)
  if (!featureDescription.match(/use|with|via|using/i)) {
    questions.push({
      question: "Are there technical constraints I should know about?",
      header: "Constraints",
      options: [
        { label: "No constraints", description: "Free to choose best approach" },
        {
          label: "Must integrate with existing",
          description: "Follow current patterns and APIs",
        },
        {
          label: "Backward compatible",
          description: "Can't break existing functionality",
        },
      ],
      multiSelect: false,
    });
  }

  // Question 3: Success metrics (if outcome unclear)
  if (!featureDescription.match(/goal|metric|measure|success/i)) {
    questions.push({
      question: "How will we know this is successful?",
      header: "Success",
      options: [
        { label: "It works", description: "Feature functions as described" },
        { label: "Tests pass", description: "Automated tests verify behavior" },
        { label: "User validates", description: "You'll manually verify the outcome" },
        { label: "Performance target", description: "Must meet specific benchmarks" },
      ],
      multiSelect: false,
    });
  }

  // Question 4: Priority/urgency (helps with planning)
  questions.push({
    question: "What's the priority for this work?",
    header: "Priority",
    options: [
      { label: "Critical", description: "Blocking other work, needs immediate attention" },
      { label: "High", description: "Important feature, should be done soon" },
      { label: "Normal", description: "Standard priority, fit into regular workflow" },
      { label: "Low", description: "Nice to have, can wait" },
    ],
    multiSelect: false,
  });

  // Ask max 4 questions (AskUserQuestion limit)
  AskUserQuestion({ questions: questions.slice(0, 4) });

  // Store answers to inform research phase
  // interviewAnswers = { scope, constraints, success, priority }
}
```

**Skip interview if:**

- Feature description is >200 words with clear requirements
- User explicitly says "skip interview" or "just build it"
- Description contains acceptance criteria or user stories

**Interview answers inform research:**

- Scope → Focus codebase-analyst on specific areas
- Constraints → Tell docs-researcher what patterns to look for
- Success → Guide quality-analyst on what to verify
- Priority → Determines P1/P2/P3 task distribution
</phase>

<phase name="parallel-research">
Launch ALL 4 agents in SINGLE message using `<pattern name="research-agents"/>`:

- `codebase-analyst` - Repository structure, patterns, conventions, git history
- `docs-researcher` - External best practices via Context7/OctoCode MCP
- `architecture-analyst` - API design, data models, external integrations
- `quality-analyst` - Performance, security (STRIDE), UX, accessibility

**Plus Codex MCP** (direct call, not Task):

```javascript
MCPSearch({ query: "select:mcp__plugin_crew_codex__codex" });
mcp__plugin_crew_codex__codex({
  question: `Architecture design for: ${feature}. Key decisions, trade-offs, risks?`,
});
```

</phase>

<phase name="collect-research">
```javascript
// Collect ALL 4 agent results
const results = {};
for (const agent of agents) {
  results[agent.type] = TaskOutput({ task_id: agent.id, block: true });
}
```
</phase>

<phase name="spec-analysis">
Launch spec-flow-analyzer with ALL research context:
```javascript
Task({
  subagent_type: "spec-flow-analyzer",
  prompt: `CONTEXT: ${feature}\nRESEARCH: ${JSON.stringify(results)}\nOUTPUT: User stories (P1/P2/P3), FR-XXX requirements, SC-XXX success criteria, gaps`,
  run_in_background: false
});
```
</phase>

<phase name="write-plan">
Write to `.claude/plans/<feature-slug>.md` using the plan template:

```javascript
// Read template and populate with research findings
Read({
  file_path: `${CLAUDE_PLUGIN_ROOT}/skills/todo-tracking/templates/plan-template.md`,
});

// Fill in template with:
// - Problem Statement: From spec analysis
// - User Stories: From spec-flow-analyzer (P1/P2/P3 priorities)
// - Functional Requirements: FR-XXX requirements
// - Technical Approach: From Codex synthesis
// - Codebase Context: From codebase-analyst
// - External Research: From docs-researcher
// - Architecture: From architecture-analyst (API, Data, Integrations)
// - Quality: From quality-analyst (Performance, Security, UX)
// - Success Criteria: SC-XXX criteria
// - Open Questions: Max 3 NEEDS CLARIFICATION items
```

</phase>

<phase name="triage">
**Let user select which stories to implement:**

After the plan is written, extract user stories and let the user choose:

```javascript
// Extract user stories from the plan
const planContent = Read({ file_path: `.claude/plans/${slug}.md` });

// Parse user stories (format: ### US-X: Title [P1/P2/P3])
const storyPattern = /### (US-\d+): (.+) \[(P[123])\]/g;
const stories = [...planContent.matchAll(storyPattern)].map((m) => ({
  id: m[1],
  title: m[2],
  priority: m[3],
}));

// Group by priority for display
const p1Stories = stories.filter((s) => s.priority === "P1");
const p2Stories = stories.filter((s) => s.priority === "P2");
const p3Stories = stories.filter((s) => s.priority === "P3");

// Build options (max 4 due to AskUserQuestion limit)
// Option 1: P1 only (critical path)
// Option 2: P1 + P2 (recommended)
// Option 3: All stories
// Option 4: Custom selection (opens follow-up question)

AskUserQuestion({
  questions: [
    {
      question: `Which user stories should be implemented?\n\nP1 (${p1Stories.length}): ${p1Stories.map((s) => s.title).join(", ")}\nP2 (${p2Stories.length}): ${p2Stories.map((s) => s.title).join(", ")}\nP3 (${p3Stories.length}): ${p3Stories.map((s) => s.title).join(", ")}`,
      header: "Stories",
      options: [
        {
          label: "P1 only (critical)",
          description: `${p1Stories.length} stories - core functionality`,
        },
        {
          label: "P1 + P2 (Recommended)",
          description: `${p1Stories.length + p2Stories.length} stories - full feature`,
        },
        {
          label: "All stories",
          description: `${stories.length} stories - complete implementation`,
        },
        {
          label: "Let me pick",
          description: "Select individual stories",
        },
      ],
      multiSelect: false,
    },
  ],
});

// If "Let me pick" selected, show individual story selection
if (triageChoice === "Let me pick" && stories.length <= 4) {
  AskUserQuestion({
    questions: [
      {
        question: "Select the stories you want to implement:",
        header: "Selection",
        options: stories.map((s) => ({
          label: `${s.id} [${s.priority}]`,
          description: s.title,
        })),
        multiSelect: true,
      },
    ],
  });
}

// Store selected stories for task generation
// selectedStories = stories based on triage choice
```

**Triage results inform task generation:**

- Only generate task files for selected stories
- Update plan file to mark deselected stories as "DEFERRED"
- Set story labels in task filenames based on selection
</phase>

<phase name="generate-tasks">
Create task files using `<pattern name="task-file"/>`:

```javascript
const slugBranch = branch.replace(/\//g, "-");
Bash({ command: `mkdir -p .claude/branches/${slugBranch}/tasks` });

// Naming: {order}-{status}-{priority}-{story}-{slug}.md
// 001-009: setup tasks
// 010-019: us1 tasks
// 020-029: us2 tasks
// 090-099: polish tasks
```

Story labels: `setup`, `found`, `us1`, `us2`, `us3`, `polish`
</phase>

<phase name="present-plan">
**Print the full plan content:**

```javascript
// Read and output the entire plan file
const planContent = Read({ file_path: `.claude/plans/${slug}.md` });
// Output the plan content directly to the user (not a summary)
```

Output the complete plan content followed by:

```
Files created:
- Plan: .claude/plans/<slug>.md
- Tasks: .claude/branches/<branch>/tasks/*.md (X tasks)
```

**Then ask user to continue:**

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Ready to start building this plan?",
      header: "Next step",
      options: [
        {
          label: "Start building",
          description: "Run /crew:build to implement the plan",
        },
        {
          label: "Interview first",
          description: "Flesh out details with /crew:interview before building",
        },
        {
          label: "Edit plan first",
          description: "Make manual changes before building",
        },
        { label: "Just save", description: "Save the plan for later" },
      ],
      multiSelect: false,
    },
    {
      question: "Enable iteration loop during build?",
      header: "Loop mode",
      options: [
        {
          label: "With loop",
          description: "Iterate until all tasks pass CI checks (Recommended)",
        },
        {
          label: "Single pass",
          description: "Run build once without automatic iteration",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

**Based on responses:**

Next step:

- "Start building" + "With loop" → `Skill({ skill: "crew:build", args: "<slug> --loop" });`
- "Start building" + "Single pass" → `Skill({ skill: "crew:build", args: "<slug>" });`
- "Interview first" → `SlashCommand({ command: "/crew:interview .claude/plans/<slug>.md" });`
- "Edit plan first" → Tell user to edit `.claude/plans/<slug>.md` and run `/crew:build` when ready
- "Just save" → Confirm plan saved, no further action

</phase>

</process>

<success_criteria>

- [ ] Isolation question asked FIRST if on main/master
- [ ] Worktree: created with phantom, editor opened, clear instructions shown, command EXITS
- [ ] Stacked/Simple branch: created and switched, continues to research
- [ ] Interview questions asked for ambiguous descriptions
- [ ] Interview skipped for detailed specs (>200 words with criteria)
- [ ] claude-mem queried for past learnings (if available)
- [ ] All 4 research agents launched in single message
- [ ] Codex MCP called directly for synthesis
- [ ] spec-flow-analyzer runs after all research collected
- [ ] Plan contains user stories with P1/P2/P3 priorities
- [ ] Triage question asked to select stories
- [ ] Only selected stories generate task files
- [ ] Plan contains FR-XXX requirements and SC-XXX criteria
- [ ] Plan contains architecture and quality analyses
- [ ] Task files follow naming convention
- [ ] Each task has acceptance criteria
- [ ] Full plan content printed to user (not just summary)
- [ ] AskUserQuestion used to offer building option

</success_criteria>
