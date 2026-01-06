---
name: crew:design
description: Create validated implementation plans with research
argument-hint: "[feature description, bug report, or improvement idea]"
---

## Input

<feature_description>$ARGUMENTS</feature_description>

## Output Files

This command produces:

1. **Plan** → `.claude/plans/<feature-slug>.md` (high-level, human-readable)
2. **Task Files** → `.claude/branches/<branch>/tasks/*.md` (one file per task, ordered)

## Native Tools

### EnterPlanMode - Start Planning

Call this FIRST to enter plan mode before any research or writing:

```javascript
EnterPlanMode();
```

This signals to Claude Code that we're in planning mode. All research, plan writing, and task generation happens within plan mode. At the end, `ExitPlanMode` will present the plan for user approval.

### AskUserQuestion - Gather Input

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What would you like to design?",
      header: "Type",
      options: [
        { label: "New feature", description: "Add new functionality" },
        { label: "Bug fix", description: "Fix an existing issue" },
        { label: "Refactoring", description: "Improve code structure" },
        { label: "Infrastructure", description: "DevOps or tooling" },
      ],
      multiSelect: false,
    },
  ],
});
```

### TodoWrite - Track Progress

```javascript
TodoWrite({
  todos: [
    {
      content: "Validate input",
      status: "in_progress",
      activeForm: "Validating input",
    },
    {
      content: "Set up branch",
      status: "pending",
      activeForm: "Setting up branch",
    },
    {
      content: "Launch research (9 agents + Codex)",
      status: "pending",
      activeForm: "Researching",
    },
    {
      content: "Collect research and run spec analysis",
      status: "pending",
      activeForm: "Analyzing specs",
    },
    { content: "Write plan", status: "pending", activeForm: "Writing plan" },
    {
      content: "Generate tasks",
      status: "pending",
      activeForm: "Generating tasks",
    },
  ],
});
```

### Task - Spawn Foundational Research Agents

Launch foundational research agents in a **SINGLE message** for parallelism:

```javascript
Task({
  subagent_type: "repo-research-analyst",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Find existing patterns in codebase
CONSTRAINTS: Focus on similar implementations
OUTPUT: Pattern analysis with file references

Tools: Use Glob, Grep, Read (not bash)`,
  description: "Repo analysis",
  run_in_background: true,
});

Task({
  subagent_type: "best-practices-researcher",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Research current best practices (2026)
CONSTRAINTS: Authoritative sources, industry standards
OUTPUT: Prioritized recommendations with citations

MCP Tools (prefer over WebFetch):
- Context7 for library documentation
- OctoCode for GitHub examples`,
  description: "Best practices",
  run_in_background: true,
});

Task({
  subagent_type: "git-history-analyzer",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Analyze history of related files
CONSTRAINTS: Find past decisions, refactorings
OUTPUT: Historical context and contributor insights

Tools: Git commands via Bash
MCP: OctoCode for PR discussions`,
  description: "History analysis",
  run_in_background: true,
});
```

### Task - Spawn Spec/Flow Analysis (After Research)

Launch spec-flow-analyzer AFTER foundational research completes:

```javascript
Task({
  subagent_type: "spec-flow-analyzer",
  prompt: `CONTEXT: Designing ${feature}

FOUNDATIONAL RESEARCH:
- Repo Patterns: ${repoResearch}
- Best Practices: ${bestPractices}
- History Context: ${historyAnalysis}

SCOPE: Create prioritized user stories with acceptance criteria
CONSTRAINTS: Max 3 NEEDS CLARIFICATION markers
OUTPUT: User stories (P1/P2/P3), functional requirements (FR-XXX), success criteria (SC-XXX)

Tools: Use Glob, Grep, Read (not bash)`,
  description: "Spec analysis",
  run_in_background: false, // Wait for completion before dimension analysis
});
```

## Process

### Phase 1: Validate Input

If empty or unclear:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What would you like to design?",
      header: "Feature",
      options: [
        { label: "New feature", description: "Add new functionality" },
        { label: "Bug fix", description: "Fix an existing issue" },
        { label: "Refactoring", description: "Improve code structure" },
        { label: "Infrastructure", description: "DevOps or tooling" },
      ],
      multiSelect: false,
    },
  ],
});
```

### Phase 2: Branch Setup

**IMPORTANT:** Set up the branch early so state files are written to the correct `.claude/branches/{branch}/` directory.

```javascript
// Check current branch
const currentBranch = Bash({ command: "git branch --show-current" }).trim();
const isMainBranch = currentBranch === "main" || currentBranch === "master";

if (isMainBranch) {
  // On main - MUST create a new branch (never work directly on main)
  AskUserQuestion({
    questions: [
      {
        question: "Create a new branch for this work:",
        header: "Branch Type",
        options: [
          {
            label: "Feature branch (Recommended)",
            description: "Independent branch from main",
          },
          {
            label: "Stacked branch",
            description: "Child of existing feature branch (for stacked PRs)",
          },
        ],
        multiSelect: false,
      },
    ],
  });

  // Generate branch name from feature slug
  const branchName = `feat/${slug}`;

  // If feature branch:
  Bash({ command: `git checkout -b ${branchName}` });

  // If stacked branch:
  // 1. Show existing feature branches
  // 2. Ask which to stack on
  // 3. git checkout -b ${branchName}
  // 4. git machete add --onto <parent>
} else {
  // On a feature branch - ask whether to stay or create new
  AskUserQuestion({
    questions: [
      {
        question: `You're on '${currentBranch}'. How should we proceed?`,
        header: "Branch",
        options: [
          {
            label: "Stay on this branch (Recommended)",
            description: "Continue work here",
          },
          {
            label: "Create stacked branch",
            description: `New branch stacked on ${currentBranch}`,
          },
        ],
        multiSelect: false,
      },
    ],
  });

  // If staying: nothing to do, continue with current branch

  // If stacked:
  // git checkout -b feat/${slug}
  // git machete add --onto ${currentBranch}
}
```

**Why early branch setup:**

- State files go to `.claude/branches/{branch}/`
- Task files need the branch directory to exist
- Machete layout updated before work begins

### Phase 3: Parallel Research (9 Agents + Codex MCP)

Launch ALL research agents in a **SINGLE message** for maximum parallelism.
Then call Codex MCP directly for architectural synthesis:

```javascript
// ========== FOUNDATIONAL RESEARCH (3 agents) ==========

// Research 1: Codebase patterns
Task({
  subagent_type: "repo-research-analyst",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Analyze existing patterns in this codebase
CONSTRAINTS: Find similar implementations, conventions used
OUTPUT: Pattern analysis with specific file:line references

Tools:
- Glob for file discovery
- Grep for content search
- Read with limit for large files
- ast-grep (sg) for structural patterns
NEVER use bash find/grep/cat`,
  description: "Repo research",
  run_in_background: true,
});

// Research 2: Best practices
Task({
  subagent_type: "best-practices-researcher",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Research current best practices (2026)
CONSTRAINTS: Authoritative sources, industry standards
OUTPUT: Prioritized recommendations with citations

MCP Tools (prefer over WebFetch):
- Context7 for library documentation
- OctoCode for GitHub examples and implementations`,
  description: "Best practices",
  run_in_background: true,
});

// Research 3: Git history context
Task({
  subagent_type: "git-history-analyzer",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Analyze history of related files
CONSTRAINTS: Find past decisions, refactorings
OUTPUT: Historical context and contributor insights

Tools: Git commands via Bash
MCP: OctoCode for PR discussions`,
  description: "History analysis",
  run_in_background: true,
});

// ========== DIMENSION ANALYSIS (6 agents) ==========

// Dimension 1: API/Interface Design
Task({
  subagent_type: "api-interface-analyst",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Analyze API/interface design requirements
CONSTRAINTS: Match existing API patterns in codebase
OUTPUT:
- Endpoint specifications
- Request/response schemas
- Versioning strategy
- Error handling conventions

Tools: Glob, Grep, Read with limit (not bash)`,
  description: "API design",
  run_in_background: true,
});

// Dimension 2: Data Models/Storage
Task({
  subagent_type: "data-model-architect",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Design data models and storage strategy
CONSTRAINTS: Match existing ORM/database patterns
OUTPUT:
- Entity-relationship model
- Schema definitions
- Migration strategy
- Data integrity constraints

Tools: Glob, Grep, Read with limit (not bash)`,
  description: "Data modeling",
  run_in_background: true,
});

// Dimension 3: UX/User Workflows
Task({
  subagent_type: "ux-workflow-analyst",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Map user workflows and interaction patterns
CONSTRAINTS: Match existing UX patterns, ensure accessibility
OUTPUT:
- User journey maps
- Interaction state diagrams
- Accessibility requirements (WCAG 2.1)

Tools: Glob, Grep, Read with limit (not bash)`,
  description: "UX workflows",
  run_in_background: true,
});

// Dimension 4: Scale/Performance
Task({
  subagent_type: "scale-performance-analyst",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Analyze scalability and performance requirements
CONSTRAINTS: Identify bottlenecks before implementation
OUTPUT:
- Load capacity estimates
- Bottleneck identification
- Caching strategy
- Performance budgets

Tools: Glob, Grep, Read with limit (not bash)`,
  description: "Scale analysis",
  run_in_background: true,
});

// Dimension 5: Security/Threat Models
Task({
  subagent_type: "security-threat-analyst",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Perform threat modeling and security analysis
CONSTRAINTS: STRIDE framework, OWASP compliance
OUTPUT:
- STRIDE threat model
- Attack surface map
- Security requirements
- Auth design

Tools: Glob, Grep, Read with limit (not bash)`,
  description: "Security analysis",
  run_in_background: true,
});

// Dimension 6: Integration/Dependencies
Task({
  subagent_type: "integration-dependency-analyst",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Analyze integrations and dependencies
CONSTRAINTS: Minimize new dependencies, plan for failures
OUTPUT:
- External service dependency map
- Package requirements
- Failure modes and fallbacks

Tools: Glob, Grep, Read with limit (not bash)`,
  description: "Integration analysis",
  run_in_background: true,
});

// ========== CODEX SYNTHESIS (direct MCP call) ==========

// Use Codex MCP directly for deep architectural reasoning
// NOTE: Not a Task - call MCPSearch then the Codex tool directly
MCPSearch({ query: "select:mcp__plugin_crew_codex__codex" });

// Then call Codex with architectural question
mcp__plugin_crew_codex__codex({
  question: `Architecture design for: ${feature}

CONTEXT:
- Feature: ${feature}
- Codebase patterns being analyzed by other agents

QUESTION:
What are the key architectural decisions, trade-offs, and risks for this feature?
Consider:
- Cross-cutting concerns
- Implementation priorities
- Integration points
- Potential bottlenecks`,
});
```

### Phase 4: Collect All Research

```javascript
// Collect ALL research results (9 background agents)
const repoResearch = TaskOutput({ task_id: "repo-id", block: true });
const bestPractices = TaskOutput({ task_id: "bp-id", block: true });
const historyAnalysis = TaskOutput({ task_id: "hist-id", block: true });
const apiDesign = TaskOutput({ task_id: "api-id", block: true });
const dataModel = TaskOutput({ task_id: "data-id", block: true });
const uxWorkflows = TaskOutput({ task_id: "ux-id", block: true });
const scaleAnalysis = TaskOutput({ task_id: "scale-id", block: true });
const securityAnalysis = TaskOutput({ task_id: "security-id", block: true });
const integrationAnalysis = TaskOutput({
  task_id: "integration-id",
  block: true,
});
// Note: Codex synthesis was called directly via MCP, result available immediately

// Update progress
TodoWrite({
  todos: [
    { content: "Validate input", status: "completed", activeForm: "Validated" },
    {
      content: "Set up branch",
      status: "completed",
      activeForm: "Set up branch",
    },
    {
      content: "Launch research (9 agents + Codex)",
      status: "completed",
      activeForm: "Researched",
    },
    {
      content: "Create user stories",
      status: "in_progress",
      activeForm: "Creating stories",
    },
    { content: "Write plan", status: "pending", activeForm: "Writing plan" },
    {
      content: "Generate tasks",
      status: "pending",
      activeForm: "Generating tasks",
    },
  ],
});
```

### Phase 5: Spec/Flow Analysis (Uses Research Context)

Launch spec-flow-analyzer with ALL research context to create prioritized user stories:

```javascript
Task({
  subagent_type: "spec-flow-analyzer",
  prompt: `CONTEXT: Designing ${feature}

RESEARCH CONTEXT:
- Repo Patterns: ${repoResearch}
- Best Practices: ${bestPractices}
- History: ${historyAnalysis}
- API Design: ${apiDesign}
- Data Model: ${dataModel}
- UX Workflows: ${uxWorkflows}
- Scale Analysis: ${scaleAnalysis}
- Security: ${securityAnalysis}
- Integrations: ${integrationAnalysis}
- Architecture: ${codexSynthesis}

SCOPE: Create comprehensive user story analysis using ALL research
CONSTRAINTS:
- Prioritize stories (P1=MVP, P2=Important, P3=Nice-to-have)
- Given-When-Then acceptance scenarios
- Max 3 NEEDS CLARIFICATION markers
- Define success criteria (SC-XXX)
- Extract functional requirements (FR-XXX)
OUTPUT:
- User Stories with priorities
- Functional Requirements (FR-XXX)
- Success Criteria (SC-XXX)
- Key Entities
- Gaps with NEEDS CLARIFICATION

Tools: Glob, Grep, Read with limit (not bash)`,
  description: "Spec analysis",
  run_in_background: false, // Wait for completion
});
```

### Phase 6: Write Plan

Write plan to `.claude/plans/<feature-slug>.md` using template structure:

```markdown
# Plan: [Feature Name]

**Branch**: `feature/<feature-slug>`
**Created**: [DATE]
**Status**: Draft
**Tasks**: `.claude/branches/feature/<feature-slug>/tasks.md`

## Problem Statement

[From spec analysis - what we're solving]

## User Stories

[From spec-flow-analyzer - P1/P2/P3 with acceptance criteria]

### User Story 1 - [Title] (Priority: P1) 🎯 MVP

[Description]

**Why P1**: [Rationale]
**Independent Test**: [How to verify]

**Acceptance Scenarios**:

1. **Given** [state], **When** [action], **Then** [outcome]

---

[More stories...]

## Functional Requirements

[FR-XXX from spec analysis]

## Key Entities

[From spec analysis]

## Technical Approach

[From codex-architect synthesis]

## Dimension Analyses

### API Design

[From api-interface-analyst - endpoints, schemas, versioning]

### Data Model

[From data-model-architect - entities, schemas, migrations]

### UX Workflows

[From ux-workflow-analyst - journeys, states, accessibility]

### Scale & Performance

[From scale-performance-analyst - capacity, bottlenecks, caching]

### Security

[From security-threat-analyst - STRIDE model, controls]

### Integrations

[From integration-dependency-analyst - dependencies, failure modes]

## Success Criteria

[SC-XXX from spec analysis]

## Risks & Mitigations

[From dimension analyses and synthesis]

## Open Questions

[Any remaining NEEDS CLARIFICATION - max 3]
```

### Phase 7: Generate Task Files

Create individual task files in `.claude/branches/<slugified-branch>/tasks/`:

```javascript
// CRITICAL: Slugify branch name (replace / with -)
// Branch: feat/custom-indexer → Folder: feat-custom-indexer
const branchSlug = `feature-${slug}`; // Already slugified since we use the slug

// Ensure directory exists
Bash({ command: `mkdir -p .claude/branches/${branchSlug}/tasks` });

// Write individual task files - ONE file per task
// Naming: {order}-{status}-{priority}-{story}-{slug}.md

// Setup tasks (001-009)
Write({
  file_path: `.claude/branches/${branchSlug}/tasks/001-pending-p1-setup-create-structure.md`,
  content: `---
status: pending
priority: p1
story: setup
parallel: true
file_path: ""
depends_on: []
---

# T001: Create project structure

## Description
Initialize project structure per implementation plan.

## Acceptance Criteria
- [ ] Directory structure matches plan
- [ ] Configuration files in place

## Work Log
### ${date} - Created
**By:** /crew:design`,
});

// User Story 1 tasks (010-019)
Write({
  file_path: `.claude/branches/${branchSlug}/tasks/010-pending-p1-us1-create-user-model.md`,
  content: `---
status: pending
priority: p1
story: us1
parallel: true
file_path: src/models/user.ts
depends_on: []
---

# T010: Create User model

## Description
[From user story acceptance criteria]

## Acceptance Criteria
- [ ] **Given** [state], **When** [action], **Then** [outcome]

## File Path
\`src/models/user.ts\`

## Implementation Notes
[Context from plan]

## Work Log
### ${date} - Created
**By:** /crew:design`,
});

// Continue for each task...
// User Story 2 tasks (020-029)
// User Story 3 tasks (030-039)
// Polish tasks (090-099)
```

**Task File Naming:**

```text
{order}-{status}-{priority}-{story}-{slug}.md

001-pending-p1-setup-create-structure.md
002-pending-p1-setup-install-deps.md
010-pending-p1-us1-create-user-model.md
011-pending-p1-us1-implement-auth.md
020-pending-p2-us2-add-profile.md
099-pending-p3-polish-update-docs.md
```

**Story Labels:**

| Label    | Phase                  |
| -------- | ---------------------- |
| `setup`  | Phase 1: Project setup |
| `found`  | Phase 2: Foundational  |
| `us1`    | User Story 1 (P1/MVP)  |
| `us2`    | User Story 2 (P2)      |
| `us3`    | User Story 3 (P3)      |
| `polish` | Final: Cleanup         |

### Phase 8: Exit Plan Mode

Exit plan mode to present the plan for user approval:

```javascript
ExitPlanMode();
```

After user approves the plan, output:

```
Plan approved. To start building, run: /crew:build

Files created:
- Plan: .claude/plans/<slug>.md
- Tasks: .claude/branches/<branch>/tasks/*.md (X tasks)
```

## Context Management

**Prevention of context exhaustion (200K token limit):**

1. **Research agents run in background** - Results summarized when collected
2. **Use `limit` parameter for large files**:
   ```javascript
   Read({ file_path: "large-file.ts", limit: 200 }); // First 200 lines
   ```
3. **Manual `/compact` if session feels heavy** - Before launching dimension analysis
4. **Agents use focused file reads** - Max 2-3 files per agent prompt

**Recovery if context exhausted:**

- Session auto-compacts and resumes with summary
- Plan file and task files persist in `.claude/` directory
- Continue from where you left off

## Constraints

**NEVER CODE!** This command researches and writes plans only.

## Success Criteria

- [ ] **EnterPlanMode called at start (before any research)**
- [ ] AskUserQuestion used for type clarification
- [ ] TodoWrite tracks progress throughout
- [ ] **Branch created early (Phase 2) before research so state writes to correct directory**
- [ ] **All 9 research agents launched in parallel (single message):**
  - [ ] 3 foundational: repo-research-analyst, best-practices-researcher, git-history-analyzer
  - [ ] 6 dimension: api-interface-analyst, data-model-architect, ux-workflow-analyst, scale-performance-analyst, security-threat-analyst, integration-dependency-analyst
- [ ] **Codex MCP called directly for architectural synthesis**
- [ ] **spec-flow-analyzer runs AFTER all research collected**
- [ ] spec-flow-analyzer receives ALL research context and produces user stories with P1/P2/P3
- [ ] MCP tools used for docs (Context7, OctoCode, Codex) instead of WebFetch
- [ ] Plan written to `.claude/plans/<feature-slug>.md`
- [ ] Plan contains user stories with acceptance criteria
- [ ] Plan contains functional requirements (FR-XXX)
- [ ] Plan contains success criteria (SC-XXX)
- [ ] **Plan contains Dimension Analyses section with all 6 dimensions**
- [ ] Individual task files written to `.claude/branches/<slugified-branch>/tasks/`
- [ ] Task files follow naming: `{order}-{status}-{priority}-{story}-{slug}.md`
- [ ] Each task file has acceptance criteria
- [ ] Parallel tasks marked with `parallel: true`
- [ ] Branch created (only if on main/master)
- [ ] Stacked branch option offered (with machete integration)
- [ ] **ExitPlanMode called at end (presents plan for user approval)**
