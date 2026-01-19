---
name: planning-methodology
description: This skill should be used when the user asks to "plan a feature", "create a plan", "design an implementation", "break down a task", "plan this work", "write a spec", or enters plan mode. Provides a 7-phase planning methodology with clarifying questions, structured exploration, Rule of Five convergence, and Linear integration.
version: 2.3.1
---

# Planning Methodology

A structured 7-phase approach to feature and task planning: Context → Clarifying Questions → Specification → Architecture → Tasks → Validation → Documentation.

## Core Principles

- **2-5 Minute Task Granularity** - Tasks completable in 2-5 minutes for progress visibility
- **Exact Specifications** - Include code snippets, precise file paths, specific commands
- **Evidence-Based Completion** - Every step has observable proof of completion
- **TDD Required** - Test-first for all implementation steps
- **No Vague Language** - Ban "appropriate", "best practices", "as needed"
- **Clean Implementation** - Favor full rewrites over backwards-compatibility hacks for internal code
- **YAGNI Ruthlessly** - Systematically eliminate superfluous features
- **One Question at a Time** - Don't overwhelm; ask single focused questions
- **Incremental Presentation** - Break designs into digestible sections, validate each

## Planning Phases

### Phase 1: Context Gathering (Structured Exploration)

Launch parallel research agents using the 4-phase exploration method.

**Structured Exploration Method:**

1. **Feature Discovery** - Locate entry points (APIs, UI components, CLI commands), map feature boundaries and configuration
2. **Execution Flow Analysis** - Follow call chains from entry to output, track data transformations at each step
3. **Architectural Layer Mapping** - Identify abstraction layers (presentation → business logic → data), note design patterns
4. **Implementation Deep-Dive** - Document key algorithms, error handling approaches, performance considerations

**Use Octocode MCP for enhanced research:**
```
// Local LSP analysis
mcp__octocode__lspCallHierarchy({ file: "src/api.ts", symbol: "handleRequest" })
mcp__octocode__lspFindReferences({ file: "src/types.ts", symbol: "User" })

// GitHub research for similar implementations
mcp__octocode__githubSearchCode({ content: "OAuth2 refresh token", extension: "ts", stars: ">100" })
```

**Spawn parallel agents:**
```
Task({ subagent_type: "Explore", prompt: "Feature Discovery: Find entry points for [feature]..." })
Task({ subagent_type: "Explore", prompt: "Execution Flow: Trace call chains in [module]..." })
Task({ subagent_type: "Explore", prompt: "Architecture: Map abstraction layers in [area]..." })
```

**Verify knowledge currency:**
Before implementing with frameworks/libraries, check version awareness against package.json.

**Fetch latest docs using Context7 MCP:**
```
mcp__context7__resolve-library-id({ libraryName: "react" })
mcp__context7__get-library-docs({ context7CompatibleLibraryID: "/facebook/react", topic: "hooks" })
```

Fetch docs for: primary framework, database/ORM, testing framework, any version-sensitive packages.

**Output:** Consolidated research with specific file paths, line numbers, and current documentation references.

### Phase 2: Clarifying Questions

**Before proceeding to design, identify and ask about underspecified aspects.**

**Questioning Strategy:**
- **One question at a time** - Don't overwhelm; ask single focused questions per message
- **Multiple choice preferred** - Use options instead of open-ended when possible
- **Lead with recommendation** - Put recommended option first with "(Recommended)" suffix

**Topics to Clarify:**
- **Edge cases** - What happens at boundaries? Empty inputs? Maximum loads?
- **Error handling** - How should failures be communicated? Retry logic?
- **Integration points** - Which systems need to connect? What APIs?
- **Scope boundaries** - What's explicitly out of scope?
- **Design preferences** - Any preferred patterns or approaches?
- **Backward compatibility** - What existing behavior must be preserved? (external APIs only)
- **Performance needs** - Any latency, throughput, or resource constraints?

**Ask questions BEFORE making assumptions.** Surface ambiguities early to avoid rework.

**Revisit Earlier Decisions:** Stay flexible - if something doesn't make sense later, go back and clarify. Don't proceed with confusion.

**Output:** Clarified requirements with explicit answers to ambiguities.

### Phase 3: Specification & Analysis

Define the specification using Six Core Areas and SpecFlow analysis.

**Six Core Areas Checklist:**
- [ ] **Commands** - What commands will be used/created?
- [ ] **Testing** - What testing strategy applies?
- [ ] **Project Structure** - What directories/files affected?
- [ ] **Code Style** - What patterns to follow?
- [ ] **Git Workflow** - Branch, commit format?
- [ ] **Boundaries** - What should always/ask/never do?

**SpecFlow Analysis:**
Validate spec completeness, identify gaps, edge cases, and refined acceptance criteria.

**Three-Tier Boundaries:**
```
✅ Always Do (without asking):
- [specific actions]

⚠️ Ask First (high-impact decisions):
- [decisions needing approval]

🚫 Never Do (categorically off-limits):
- [prohibited actions]
```

See `references/spec-patterns.md` for templates and vague language replacements.

### Phase 4: Architecture Decision

Document chosen approach with rationale.

**Presenting Options:**
- Present 2-3 competing approaches with transparent trade-offs
- **Lead with recommendation** - Put recommended option first with rationale
- Apply YAGNI ruthlessly - eliminate superfluous features

**Incremental Presentation:**
Break complex designs into digestible sections (200-300 words each):
1. Present first section
2. Validate with user feedback
3. Continue to next section
4. Be prepared to revisit earlier decisions

**Cross-Check with Codex/Devil's Advocate:**
For security-sensitive code, architectural decisions, or complex algorithms, invoke secondary analysis.

Use ADR format:
- **Context:** What situation necessitates this decision?
- **Decision:** What approach was chosen?
- **Consequences:** What trade-offs result?

See `references/codex-patterns.md` for cross-checking prompts.

### Phase 5: Task Decomposition

Break work into 2-5 minute tasks with exact specifications.

**Task Requirements:**
- **2-5 minute granularity** - If longer, break it down
- **Exact file paths** - `src/services/auth.ts`, not "auth file"
- **Code snippets** - For non-trivial changes
- **Evidence criteria** - Command output or observable state
- **TDD requirement** - Write failing test FIRST

**Parallelization Markers:**

| Marker | Meaning | Use When |
|--------|---------|----------|
| `[parallel]` | Can run simultaneously | No shared files |
| `[serial]` | Must wait for prior steps | Depends on prior output |
| `[MERGE-WALL]` | Blocks all parallel work | Restructuring, config changes |

**Merge Wall Triggers:**
- Directory restructuring
- Core abstraction changes
- Configuration file changes
- Package.json modifications

**Front-load merge walls early, then parallelize remaining work.**

See `references/task-templates.md` for examples.

### Phase 6: Validation

Apply Rule of Five convergence with self-verification.

**Review Passes:**
1. **Standard Review** - Obvious gaps, missing tasks
2. **Deep Review** - Edge cases, error handling
3. **Architecture Review** - Integration, patterns, coupling
4. **Existential Review** - Right problem? Right approach?

**Self-Verification Checklist:**
- [ ] Can an agent implement with zero clarifying questions?
- [ ] All boundaries specific and actionable?
- [ ] Every success criterion measurable?
- [ ] No vague language used?
- [ ] TDD included for all code changes?
- [ ] Evidence defined for every step?

See `references/rule-of-five.md` for detailed prompts.

### Phase 7: Documentation & Integration

Persist plan with frequent commit strategy.

**Commit Strategy:**
- One task = one atomic commit opportunity
- Commit after each 2-5 minute task
- Enable easy rollback and progress tracking

**Linear Integration:**
Use AskUserQuestion to offer:
1. Create new Linear ticket with plan
2. Update existing Linear ticket
3. Skip Linear integration

## Agent Workflow

| Agent | Phase | Purpose |
|-------|-------|---------|
| `context-researcher` | 1 | Structured exploration (4-phase method) |
| `architecture-analyst` | 4 | Trade-off evaluation, cross-checking |
| `task-decomposer` | 5 | 2-5 min tasks with evidence |
| `plan-validator` | 6 | Rule of Five + confidence filtering |

**Subagent-per-Task Pattern:**
For execution, spawn fresh subagent per task for rapid iteration and isolation.

## Native Tool Usage

Use Claude Code's native tools effectively throughout planning:

### AskUserQuestion Tool

For gathering user input, always use AskUserQuestion with rich options:
- Present 2-4 options with detailed descriptions
- Include trade-offs and implications in option descriptions
- Mark recommended choice with "(Recommended)" suffix
- Use for: approach selection, scope clarification, priority decisions

**Example:** When choosing architecture approach, present options with pros/cons in descriptions.

### Task Tool (Spawning Agents)

For parallel research and delegation:
```
Task({
  subagent_type: "Explore",
  prompt: "Detailed research instructions...",
  description: "Short 3-5 word summary",
  run_in_background: true  // For async orchestration
})
```

### TaskOutput Tool

Retrieve results from background agents:
```
TaskOutput(task_id="agent_id", block=false)  // Non-blocking check
TaskOutput(task_id="agent_id", block=true, timeout=30000)  // Wait for result
```

### TodoWrite Tool

Track planning progress visibly:
- Update status as each phase completes
- Show current phase and next steps
- Mark tasks `in_progress` while working, `completed` when done

**Example:** Create todo items for each planning phase, update as you progress.

## Plan Quality Standards

| Criterion | Requirement |
|-----------|-------------|
| Task granularity | 2-5 minutes each |
| Specifications | Exact file paths, code snippets |
| Evidence | Observable completion for each step |
| TDD | Required for all implementation |
| Parallelization | All steps marked `[parallel]`/`[serial]` |
| Merge walls | Identified and front-loaded |
| Language | No vague terms without definition |
| Boundaries | Always/Ask/Never defined |

## Banned Vague Language

| Vague | Replace With |
|-------|--------------|
| "appropriate" | Exact criteria or threshold |
| "best practices" | Name the specific practice |
| "as needed" | Specific trigger condition |
| "properly" | List specific validations |
| "handle errors" | Specify catch, log, return |
| "secure" | HTTPS, validation, rate limiting |
| "performant" | "<200ms p95 latency" |

## Additional Resources

### Reference Files

- **`references/rule-of-five.md`** - Convergence framework, review prompts
- **`references/codex-patterns.md`** - Trade-offs, cross-checking, devil's advocate
- **`references/task-templates.md`** - INVEST tasks, 2-5 min examples, evidence
- **`references/spec-patterns.md`** - Six Core Areas, boundaries, vague language

### Integration

- **Octocode MCP** - Semantic code search, LSP analysis, GitHub research
- **Context7 MCP** - Fetch latest documentation for packages
- **Linear MCP** - Ticket creation/updates (SSE OAuth)
- **Plan mode** - Claude Code's built-in planning
- **Explore agent** - Parallel codebase research
