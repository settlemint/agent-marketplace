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
      content: "Launch foundational research agents",
      status: "pending",
      activeForm: "Researching",
    },
    {
      content: "Run spec/flow analysis",
      status: "pending",
      activeForm: "Analyzing spec/flows",
    },
    {
      content: "Launch dimension analysis",
      status: "pending",
      activeForm: "Analyzing dimensions",
    },
    {
      content: "Synthesize findings",
      status: "pending",
      activeForm: "Synthesizing",
    },
    { content: "Write plan", status: "pending", activeForm: "Writing plan" },
    {
      content: "Generate tasks",
      status: "pending",
      activeForm: "Generating tasks",
    },
    {
      content: "Set up branch (if needed)",
      status: "pending",
      activeForm: "Setting up branch",
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

### Phase 2: Foundational Research

Launch foundational research agents in a **SINGLE message**:

```javascript
// Research agent 1: Codebase patterns
Task({
  subagent_type: "repo-research-analyst",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Analyze existing patterns in this codebase
CONSTRAINTS: Find similar implementations, conventions used
OUTPUT: Pattern analysis with specific file:line references

Tools:
- Glob for file discovery
- Grep for content search
- Read for file examination
- ast-grep (sg) for structural patterns
NEVER use bash find/grep/cat`,
  description: "Repo research",
  run_in_background: true,
});

// Research agent 2: Best practices
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

// Research agent 3: Git history context
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

### Phase 3: Collect Foundational Research

```javascript
// Collect foundational research results
const repoResearch = TaskOutput({ task_id: "repo-id", block: true });
const bestPractices = TaskOutput({ task_id: "bp-id", block: true });
const historyAnalysis = TaskOutput({ task_id: "hist-id", block: true });

// Update progress
TodoWrite({
  todos: [
    {
      content: "Validate input",
      status: "completed",
      activeForm: "Validating input",
    },
    {
      content: "Launch research agents",
      status: "completed",
      activeForm: "Researching",
    },
    {
      content: "Analyze user flows",
      status: "in_progress",
      activeForm: "Analyzing flows",
    },
    // ...
  ],
});
```

### Phase 4: Spec/Flow Analysis (Depends on Research)

Launch spec-flow-analyzer AFTER foundational research completes, so it can incorporate findings:

```javascript
// Spec/Flow Analysis - runs AFTER foundational research
Task({
  subagent_type: "spec-flow-analyzer",
  prompt: `CONTEXT: Designing ${feature}

FOUNDATIONAL RESEARCH:
- Repo Patterns: ${repoResearch}
- Best Practices: ${bestPractices}
- History Context: ${historyAnalysis}

SCOPE: Create comprehensive user story analysis incorporating research findings
CONSTRAINTS:
- Prioritize stories (P1=MVP, P2=Important, P3=Nice-to-have)
- Given-When-Then acceptance scenarios
- Max 3 NEEDS CLARIFICATION markers
- Define measurable success criteria (SC-XXX)
- Extract functional requirements (FR-XXX)
- Reference existing patterns found in research
OUTPUT:
- User Stories with priorities and acceptance criteria
- Functional Requirements (FR-XXX)
- Success Criteria (SC-XXX)
- Key Entities
- Edge Cases
- Gaps with NEEDS CLARIFICATION

Tools: Glob, Grep, Read (not bash)`,
  description: "Spec analysis",
  run_in_background: false, // Wait for this to complete before dimension analysis
});
```

### Phase 5: Collect Spec Analysis

```javascript
// Spec analysis already collected (run_in_background: false)
// Now we have all research context for dimension analysis

// Update progress
TodoWrite({
  todos: [
    {
      content: "Validate input",
      status: "completed",
      activeForm: "Validating input",
    },
    {
      content: "Launch research agents",
      status: "completed",
      activeForm: "Researching",
    },
    {
      content: "Analyze user flows",
      status: "completed",
      activeForm: "Analyzing flows",
    },
    {
      content: "Launch dimension analysis",
      status: "in_progress",
      activeForm: "Analyzing dimensions",
    },
    // ...
  ],
});
```

### Phase 6: Parallel Dimension Analysis (6-Leg)

Launch ALL dimension analysis agents in a **SINGLE message** for parallelism.
Each produces a dedicated analysis document covering one dimension of the design:

```javascript
// Dimension 1: API/Interface Design
Task({
  subagent_type: "api-interface-analyst",
  prompt: `CONTEXT: Designing ${feature}
RESEARCH CONTEXT:
- Spec Analysis: ${specAnalysis}
- Repo Patterns: ${repoResearch}

SCOPE: Analyze API/interface design requirements
CONSTRAINTS: Match existing API patterns in codebase
OUTPUT:
- Endpoint specifications
- Request/response schemas
- Versioning strategy
- Error handling conventions
- API consistency assessment

Tools: Glob, Grep, Read (not bash)`,
  description: "API design",
  run_in_background: true,
});

// Dimension 2: Data Models/Storage
Task({
  subagent_type: "data-model-architect",
  prompt: `CONTEXT: Designing ${feature}
RESEARCH CONTEXT:
- Spec Analysis: ${specAnalysis}
- Repo Patterns: ${repoResearch}

SCOPE: Design data models and storage strategy
CONSTRAINTS: Match existing ORM/database patterns
OUTPUT:
- Entity-relationship model
- Schema definitions (matching ORM)
- Migration strategy
- Index recommendations
- Data integrity constraints

Tools: Glob, Grep, Read (not bash)`,
  description: "Data modeling",
  run_in_background: true,
});

// Dimension 3: UX/User Workflows
Task({
  subagent_type: "ux-workflow-analyst",
  prompt: `CONTEXT: Designing ${feature}
RESEARCH CONTEXT:
- Spec Analysis: ${specAnalysis}
- User Stories: ${specAnalysis}

SCOPE: Map user workflows and interaction patterns
CONSTRAINTS: Match existing UX patterns, ensure accessibility
OUTPUT:
- User journey maps
- Interaction state diagrams
- Form specifications
- Accessibility requirements (WCAG 2.1)
- Error handling UX

Tools: Glob, Grep, Read (not bash)`,
  description: "UX workflows",
  run_in_background: true,
});

// Dimension 4: Scale/Performance
Task({
  subagent_type: "scale-performance-analyst",
  prompt: `CONTEXT: Designing ${feature}
RESEARCH CONTEXT:
- Spec Analysis: ${specAnalysis}
- Repo Patterns: ${repoResearch}

SCOPE: Analyze scalability and performance requirements
CONSTRAINTS: Identify bottlenecks before implementation
OUTPUT:
- Load capacity estimates (current, 10x, 100x)
- Bottleneck identification
- Caching strategy
- Performance budgets
- Scaling roadmap

Tools: Glob, Grep, Read (not bash)`,
  description: "Scale analysis",
  run_in_background: true,
});

// Dimension 5: Security/Threat Models
Task({
  subagent_type: "security-threat-analyst",
  prompt: `CONTEXT: Designing ${feature}
RESEARCH CONTEXT:
- Spec Analysis: ${specAnalysis}
- Repo Patterns: ${repoResearch}

SCOPE: Perform threat modeling and security analysis
CONSTRAINTS: STRIDE framework, OWASP compliance
OUTPUT:
- STRIDE threat model
- Attack surface map
- Security requirements
- Authentication/authorization design
- Data protection strategy

Tools: Glob, Grep, Read (not bash)`,
  description: "Security analysis",
  run_in_background: true,
});

// Dimension 6: Integration/Dependencies
Task({
  subagent_type: "integration-dependency-analyst",
  prompt: `CONTEXT: Designing ${feature}
RESEARCH CONTEXT:
- Spec Analysis: ${specAnalysis}
- Repo Patterns: ${repoResearch}
- Best Practices: ${bestPractices}

SCOPE: Analyze integrations and dependencies
CONSTRAINTS: Minimize new dependencies, plan for failures
OUTPUT:
- External service dependency map
- Package requirements analysis
- API integration specs
- Failure modes and fallbacks
- Version compatibility

Tools: Glob, Grep, Read (not bash)`,
  description: "Integration analysis",
  run_in_background: true,
});
```

### Phase 7: Collect Dimension Analysis

```javascript
// Collect all dimension analysis results
const apiDesign = TaskOutput({ task_id: "api-id", block: true });
const dataModel = TaskOutput({ task_id: "data-id", block: true });
const uxWorkflows = TaskOutput({ task_id: "ux-id", block: true });
const scaleAnalysis = TaskOutput({ task_id: "scale-id", block: true });
const securityAnalysis = TaskOutput({ task_id: "security-id", block: true });
const integrationAnalysis = TaskOutput({
  task_id: "integration-id",
  block: true,
});

// Update progress
TodoWrite({
  todos: [
    {
      content: "Validate input",
      status: "completed",
      activeForm: "Validating input",
    },
    {
      content: "Launch research agents",
      status: "completed",
      activeForm: "Researching",
    },
    {
      content: "Spec/flow analysis",
      status: "completed",
      activeForm: "Analyzing spec/flows",
    },
    {
      content: "Launch dimension analysis",
      status: "completed",
      activeForm: "Analyzing dimensions",
    },
    {
      content: "Synthesize findings",
      status: "in_progress",
      activeForm: "Synthesizing",
    },
    // ...
  ],
});
```

### Phase 8: Synthesis & Gap Analysis (Optional)

For complex features, synthesize dimension analyses and identify cross-cutting concerns:

```javascript
Task({
  subagent_type: "codex-architect",
  prompt: `CONTEXT: Designing ${feature}

RESEARCH FINDINGS:
- Spec Analysis: ${specAnalysis}
- Repo Patterns: ${repoResearch}
- Best Practices: ${bestPractices}
- History: ${historyAnalysis}

DIMENSION ANALYSES:
- API Design: ${apiDesign}
- Data Model: ${dataModel}
- UX Workflows: ${uxWorkflows}
- Scale/Performance: ${scaleAnalysis}
- Security/Threats: ${securityAnalysis}
- Integrations: ${integrationAnalysis}

SCOPE: Synthesize all findings into coherent technical approach
CONSTRAINTS: Resolve conflicts between dimensions, identify trade-offs
OUTPUT:
- Unified technical approach
- Cross-cutting concerns
- Dimension conflicts and resolutions
- Architectural decisions with rationale
- Risk assessment from all dimensions
- Implementation phases

MCP: Use Codex for deep reasoning about architectural trade-offs`,
  description: "Architecture synthesis",
  run_in_background: false, // Wait for this one
});
```

### Phase 9: Write Plan

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

### Phase 10: Generate Task Files

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

### Phase 11: Branch Setup

```javascript
// Check if already on a feature branch (not main/master)
const currentBranch = Bash({ command: "git branch --show-current" }).trim();
const isMainBranch = currentBranch === "main" || currentBranch === "master";

if (isMainBranch) {
  // Create new feature branch only if on main/master
  // Note: Branch uses slash (feature/slug), but folder uses hyphen (feature-slug)
  Bash({
    command: `git checkout -b feature/${slug}`,
    description: "Create feature branch",
  });
} else {
  // Already on a feature branch - stay on it
  console.log(`Staying on current branch: ${currentBranch}`);
}

// Note: Plans and task files are NOT committed to git
// - .claude/plans/ contains local working documents
// - .claude/branches/ is gitignored
```

### Phase 12: Next Steps

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Plan and tasks created. What's next?",
      header: "Next Step",
      options: [
        {
          label: "Start building (Recommended)",
          description: "Run /crew:build with this plan",
        },
        {
          label: "Create GitHub issue",
          description: "Push plan for team review",
        },
        { label: "Review the plan", description: "Walk through key sections" },
        { label: "Done for now", description: "Save and exit" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Constraints

**NEVER CODE!** This command researches and writes plans only.

## Success Criteria

- [ ] AskUserQuestion used for type clarification
- [ ] TodoWrite tracks progress throughout
- [ ] **Foundational research agents launched in parallel (single message)**
- [ ] **spec-flow-analyzer runs AFTER foundational research completes**
- [ ] spec-flow-analyzer receives research context and produces user stories with P1/P2/P3
- [ ] **6 dimension agents launched in parallel (single message)**
- [ ] **api-interface-analyst produces endpoint specifications**
- [ ] **data-model-architect produces entity schemas**
- [ ] **ux-workflow-analyst produces user journey maps**
- [ ] **scale-performance-analyst produces capacity estimates**
- [ ] **security-threat-analyst produces STRIDE analysis**
- [ ] **integration-dependency-analyst produces dependency map**
- [ ] **codex-architect synthesizes all dimension analyses**
- [ ] MCP tools used for docs (Context7, OctoCode) instead of WebFetch
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
- [ ] AskUserQuestion confirms next steps
