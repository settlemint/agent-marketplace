# Plan Mode Plugin v2.5.5

Enhanced planning workflow for Claude Code with structured exploration, clarifying questions, confidence-based validation, and Linear integration.

## Features

### Core Methodology
- **7-Phase Planning**: Context → Clarifying Questions → Specification → Architecture → Tasks → Validation → Documentation
- **Structured Exploration**: 4-phase codebase analysis (Feature Discovery → Execution Flow → Architecture → Deep-Dive)
- **Clarifying Questions**: Ask about edge cases, error handling, integration points BEFORE designing
- **One Question at a Time**: Don't overwhelm; ask single focused questions
- **2-5 Minute Tasks**: Every task decomposes to 2-5 minutes of focused work
- **Clean Implementation**: Favor full rewrites over backwards-compatibility hacks for internal code
- **YAGNI Ruthlessly**: Systematically eliminate superfluous features

### Quality Controls
- **Confidence-Based Filtering**: Only report validation issues with ≥80% confidence
- **Evidence-Based Completion**: Verifiable completion criteria for every task
- **TDD Requirements**: Test requirements specified for all code changes
- **Vague Language Detection**: Zero tolerance for ambiguous terms
- **Parallelization Markers**: All tasks marked `[parallel]`, `[serial]`, or `[MERGE-WALL]`

### Workflow
- **Parallel Research Agents**: Multiple exploration agents run simultaneously
- **SpecFlow Analysis**: Six Core Areas checklist with three-tier boundaries
- **Rule of Five**: Iterative convergence review
- **Linear Integration**: Create or update Linear tickets with completed plans

## Prerequisites

- Claude Code CLI
- GitHub CLI (`gh auth login`) for Octocode MCP
- Linear account (for ticket integration)

## Setup

1. Enable the plugin in Claude Code:
   ```bash
   claude --plugin-dir /path/to/plan-mode
   ```

2. On first use of Linear integration, you'll be prompted to authenticate via OAuth in your browser.

## Usage

### Automatic Enhancement

The plugin automatically enhances plan mode sessions. When plan mode is detected (via `EnterPlanMode` or session permissions indicating plan mode), the 7-phase workflow activates:

1. Structured codebase exploration with parallel agents
2. Clarifying questions to resolve ambiguities
3. Specification with Six Core Areas and boundaries
4. Architecture decision with cross-checking
5. 2-5 minute task breakdown with parallelization
6. Confidence-filtered validation
7. Documentation and optional Linear sync

### Manual Command

Use `/plan` to start an enhanced planning session manually:

```
/plan implement user authentication with OAuth
```

## Components

### Skill: `planning-methodology` (v2.1)

Core planning knowledge including:
- 7-phase workflow with clarifying questions
- Structured exploration method (4 phases)
- Confidence-based filtering
- Clean implementation principle

### Agents

| Agent | Phase | Purpose |
|-------|-------|---------|
| `context-researcher` | 1 | Structured exploration (4-phase method) |
| `architecture-analyst` | 4 | Trade-off evaluation, cross-checking, clean implementation |
| `task-decomposer` | 5 | 2-5 min tasks with parallelization and evidence |
| `plan-validator` | 6 | Confidence-filtered validation (≥80%) |

### Hook: `enhance-planning`
Advisory-only guidance that never blocks normal operation; detects plan mode via permissions or explicit plan mode entry.

### MCP Servers

| Server | Purpose |
|--------|---------|
| **Octocode** | Semantic code research, LSP analysis, GitHub search for similar implementations |
| **Context7** | Fetch latest documentation for packages used in the plan |
| **Linear** | Create or update Linear tickets with completed plans |

## The 7 Phases

### Phase 1: Context Gathering (Structured Exploration)

Use the 4-phase exploration method:

1. **Feature Discovery** - Entry points, feature boundaries, configuration
2. **Execution Flow** - Call chains, data transformations, state changes
3. **Architectural Layers** - Presentation → business logic → data
4. **Implementation Deep-Dive** - Algorithms, error handling, performance

**Octocode MCP Tools:**
- `lspCallHierarchy` - Trace function call relationships
- `lspFindReferences` - Find all usages of a symbol
- `lspGotoDefinition` - Navigate to definitions
- `githubSearchCode` - Find similar implementations on GitHub
- `githubSearchRepositories` - Discover reference architectures

**Fetch Latest Documentation:**
Use Context7 MCP to get current docs for all packages the plan will touch (framework, ORM, testing, etc.)

### Phase 2: Clarifying Questions

Ask about underspecified aspects BEFORE designing:
- Edge cases and boundary conditions
- Error handling requirements
- Integration points and dependencies
- Scope boundaries (what's out of scope)
- Design preferences
- Backward compatibility needs (external APIs only)
- Performance requirements

**Questioning Strategy:**
- One question at a time (don't overwhelm)
- Multiple choice preferred
- Lead with recommendation
- Stay flexible - revisit earlier decisions when needed

### Phase 3: Specification & Analysis
- Six Core Areas checklist
- SpecFlow analysis
- Three-tier boundaries (Always/Ask/Never)

### Phase 4: Architecture Decision
- Present 2-3 options, lead with recommendation
- YAGNI ruthlessly - eliminate superfluous features
- Incremental presentation (200-300 word sections, validate each)
- Cross-checking (devil's advocate, security)
- Clean implementation principle
- ADR documentation

### Phase 5: Task Decomposition
- 2-5 minute tasks
- Parallelization markers
- Merge wall identification
- Evidence definitions
- TDD requirements

### Phase 6: Validation
- Confidence-based filtering (≥80% only)
- Self-verification audits
- Rule of Five convergence
- Vague language detection

### Phase 7: Documentation
- Persist plan to standard location
- Optional Linear ticket creation/update

## Clean Implementation Principle

For internal code, favor full modifications over backwards-compatibility hacks:

| Code Type | Approach |
|-----------|----------|
| External APIs | Maintain compatibility |
| Smart contracts | Preserve compatibility |
| **Internal code** | **Clean rewrite, update all callers** |

**Avoid:**
- `_deprecated` suffixes
- Wrapper functions for compatibility
- Keeping unused code "just in case"
- Re-exporting "in case something uses it"

## Task Format

```markdown
N. [parallel|serial] <Step description>
   - File: `exact/path/to/file.ts`
   - Code: (for non-trivial changes)
     ```typescript
     // Implementation snippet
     ```
   - TDD: Write failing test for <behavior> first
   - Evidence: `bun run test auth.test.ts` passes
```

## Configuration

No additional configuration required. The plugin uses sensible defaults.

Linear integration uses OAuth (SSE transport) - authenticate via browser when prompted.

## Version History

- **v2.5.5**: Convert PreToolUse hooks from prompt-based to command-based for deterministic behavior
- **v2.5.4**: Update skill descriptions to use official third-person trigger format for better auto-triggering
- **v2.5.3**: Fix prompt hook to return proper JSON format (use 'allow' instead of 'approve')
- **v2.5.2**: Remove SessionStart hook (prompt hooks not supported for SessionStart event)
- **v2.5.1**: Remove UserPromptSubmit hook to prevent stop-hook blocks on background task notifications
- **v2.5.0**: Make hooks advisory-only (fail-open), detect plan mode via permissions as a fallback to native EnterPlanMode, remove stop-time blocking
- **v2.4.1**: Fix prompt hooks to approve non-planning requests instead of blocking, preventing infinite loops
- **v2.4.0**: Add iterative-retrieval skill for subagent context refinement with automatic integration into Phase 1 exploration
- **v2.3.3**: Add SessionStart and UserPromptSubmit hooks for Conductor plan mode compatibility
- **v2.3.2**: Fixed Stop hook JSON validation error by using natural language instructions instead of explicit approve/block format
- **v2.3.1**: Fixed skill name format for AgentSkills compliance (lowercase-hyphens), added TOC to reference files
- **v2.3.0**: Added Octocode MCP for semantic code research, LSP analysis, and GitHub cross-repo search
- **v2.2.0**: Added brainstorming patterns (one question at a time, lead with recommendation, incremental presentation, YAGNI ruthlessly, revisit flexibility), Context7 MCP for latest documentation
- **v2.1.0**: Added clarifying questions phase, structured exploration, confidence filtering, clean implementation principle
- **v2.0.0**: Added 2-5 min tasks, parallelization, evidence, TDD, cross-checking, vague language detection
- **v1.0.0**: Initial release with 6-phase methodology, Rule of Five, Linear integration
