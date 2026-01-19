---
name: plan
description: Start enhanced 7-phase planning workflow with structured exploration and Linear integration
argument-hint: [feature or task description]
allowed-tools: Read, Grep, Glob, Task, AskUserQuestion
---

Begin enhanced planning workflow for: $ARGUMENTS

Load the planning-methodology skill and execute the 7-phase planning process:

## Phase 1: Context Gathering (Structured Exploration)

Use the context-researcher agent with the 4-phase exploration method:
- **Feature Discovery** - Entry points, feature boundaries, configuration
- **Execution Flow** - Call chains, data transformations, state changes
- **Architectural Layers** - Presentation → business logic → data
- **Implementation Deep-Dive** - Algorithms, error handling, performance

Spawn parallel exploration agents for comprehensive coverage.

## Phase 2: Clarifying Questions

Before proceeding to design, use AskUserQuestion to clarify:
- Edge cases and boundary conditions
- Error handling requirements
- Integration points and dependencies
- Scope boundaries (what's explicitly out of scope)
- Design preferences
- Backward compatibility needs (external APIs only)
- Performance requirements

Ask questions BEFORE making assumptions.

## Phase 3: Specification & Analysis

Based on research and clarified requirements:
- Apply Six Core Areas checklist (Commands, Testing, Structure, Style, Git, Boundaries)
- Define three-tier boundaries (Always/Ask/Never)
- Apply SpecFlow analysis for completeness

## Phase 4: Architecture Decision

Use the architecture-analyst agent to:
- Compare options across 6 dimensions
- Apply cross-checking (devil's advocate, security analysis)
- Follow Clean Implementation principle (no backwards-compatibility hacks for internal code)
- Document decision in ADR format with explicit trade-offs

## Phase 5: Task Decomposition

Use the task-decomposer agent to:
- Break work into 2-5 minute tasks
- Add parallelization markers (`[parallel]`, `[serial]`, `[MERGE-WALL]`)
- Front-load merge walls
- Define evidence criteria for each task
- Specify TDD requirements
- Include exact file paths and code snippets

## Phase 6: Validation

Use the plan-validator agent to:
- Apply confidence-based filtering (only report issues ≥80% confidence)
- Run self-verification audits (Completeness, Clarity, Boundary, Testability)
- Apply Rule of Five convergence review
- Detect vague language (target: 0 occurrences)
- Determine plan readiness with quality score

## Phase 7: Documentation & Linear Integration (REQUIRED)

**CRITICAL: This phase is MANDATORY. The planning workflow is NOT complete until you ask about Linear.**

After validation completes:

1. Write the plan to the plan file

2. **REQUIRED: Use AskUserQuestion to ask about Linear integration.** Present these options:
   - Create new Linear ticket with this plan
   - Update existing Linear ticket (user provides ticket ID)
   - Skip Linear integration for now

3. If user chooses Linear integration, use the Linear MCP tools to create or update the ticket with the plan content.

**You MUST ask the Linear question before considering this workflow complete. Do not skip this step.**

---

Execute phases sequentially, using the specialized agents. Each agent chains to the next automatically. Provide cumulative output at each phase.

**Reminder: Phase 7 (Linear integration question) is required before completing the workflow.**
