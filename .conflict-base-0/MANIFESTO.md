# Agent Native Development Workflow Manifesto

> _Written by Claude Code Opus 4.5, prompted by Roderik_

## The Vision

This document describes the **Agent Native Development Workflow** (ANDW) - a paradigm shift in how software is built. Instead of writing code line-by-line, developers orchestrate autonomous agents that research, design, implement, and review code with unprecedented quality and speed.

**The fundamental insight**: Software development has always been about managing complexity. We've progressed from assembly to high-level languages, from monoliths to microservices, from manual testing to CI/CD. Each evolution abstracted away lower-level concerns so developers could focus on higher-level problems. Agent-native development is the next abstraction layer - you describe _what_ you want, and autonomous agents figure out _how_ to build it.

The workflow is implemented through two Claude Code plugins:

- **[crew](https://github.com/settlemint/agent-marketplace/tree/main/crew)** - Orchestration, commands, agents, hooks, and state management
- **[devtools](https://github.com/settlemint/agent-marketplace/tree/main/devtools)** - Framework expertise, tooling skills, and domain knowledge

> "Agents work, you orchestrate. Spawn agents for heavy lifting, keep the main thread light for decisions."

### Why This Matters for Business

Traditional software development faces a fundamental scaling problem: as projects grow, coordination costs explode exponentially. Adding developers doesn't linearly increase output - it often decreases it due to communication overhead, context switching, and integration friction.

Agent-native development inverts this equation:

1. **Parallel execution without coordination costs** - Nine research agents can analyze your codebase simultaneously without scheduling meetings
2. **Perfect knowledge transfer** - State files capture everything; no knowledge is lost when team members change
3. **Consistent quality** - Seven-leg code review runs on every change, not just when a senior engineer has time
4. **Reduced cognitive load** - Developers make strategic decisions while agents handle implementation details

### Why This Matters for Engineers

Every developer knows the frustration of context switching, of losing flow state to look up documentation, of debugging issues that proper review would have caught. Agent-native development addresses these pain points:

1. **Stay in flow** - Describe what you want, review the result, iterate. No more jumping between documentation tabs
2. **Built-in best practices** - Skills encode years of framework expertise; you get React 19 patterns, not React 16 antipatterns
3. **Automatic consistency** - Hooks enforce conventions automatically; no more linting commits or style debates
4. **Fearless refactoring** - Comprehensive review agents catch regressions before they reach production

### The Human Role: From Code Monkey to Architect

**This workflow doesn't replace developers - it elevates them.**

The human remains essential at every critical juncture:

- **Defining the vision**: You describe what feature you want, why it matters, and what success looks like
- **Reviewing plans**: Before any code is written, you approve the design, user stories, and approach
- **Validating implementation**: You review generated code, run the product, verify it meets requirements
- **Making judgment calls**: When trade-offs arise, when requirements are ambiguous, when priorities conflict - that's you

What changes is WHERE you spend your cognitive energy. Instead of:

- Writing boilerplate → Reviewing generated code
- Looking up API documentation → Verifying the right APIs were used
- Debugging type errors → Verifying business logic correctness
- Formatting and linting → Thinking about architecture

**You move from executing to directing. From typing to thinking. From implementation details to strategic decisions.**

The most productive engineers using this workflow spend 80% of their time on:

- Feature definition and requirements
- Design review and approval
- Implementation validation
- User experience verification
- Strategic technical decisions

And 20% on:

- Refining AI-generated code
- Edge case handling
- Integration with existing systems
- Performance tuning

This is a fundamental shift in what it means to be a software engineer.

---

## Table of Contents

1. [Philosophy](#philosophy)
2. [Architecture Overview](#architecture-overview)
3. [The Four Phases](#the-four-phases)
4. [Commands Reference](#commands-reference)
5. [Agent Ecosystem](#agent-ecosystem)
6. [Hooks and Scripts](#hooks-and-scripts)
7. [MCP Server Integration](#mcp-server-integration)
8. [State Management](#state-management)
9. [Git Integration](#git-integration)
10. [Devtools Skills](#devtools-skills)
11. [Performance Principles](#performance-principles)
12. [Installation](#installation)
13. [Quick Start](#quick-start)

---

## Philosophy

The Agent Native Development Workflow isn't just a set of tools - it's a philosophy about how humans and AI should collaborate on complex creative work. These principles emerged from thousands of hours of real-world usage building production software.

### Core Principles

#### 1. Agents Work, You Orchestrate

**The problem with traditional AI coding assistants**: They operate in a single-threaded, synchronous manner. You ask a question, wait for a response, ask another question. This mirrors pair programming - useful, but limited.

**The agent-native approach**: Spawn specialized agents that work in parallel. While a research agent analyzes your codebase patterns, another researches framework best practices, and another reviews historical decisions. You don't wait for each; you orchestrate them simultaneously.

**Why this matters**: A human senior developer can only think about one thing at a time. Nine agents can analyze nine dimensions of your problem simultaneously. The result isn't just faster - it's more thorough than any single human could achieve.

**Implementation**:

- Spawn specialized agents for research, implementation, and review
- Keep the main Claude thread for decision-making and coordination
- Never exceed 6 concurrent agents per batch (resource management)

#### 2. State Survives Compaction

**The problem with context windows**: LLMs have finite context. As conversations grow, older context gets "compacted" - summarized or dropped. This means losing crucial decisions, understanding, and progress.

**The agent-native approach**: Persist everything that matters to files. Plans, tasks, progress, decisions - all written to `.claude/branches/{branch}/state.json`. When context compacts, the state survives. When you resume tomorrow, everything is exactly as you left it.

**Why this matters**: Traditional AI assistants forget. You can't leave a complex task halfway done and return to it a week later. With persistent state, you can. Work is genuinely cumulative rather than session-bound.

**Real-world proof**: We regularly run build flows that exceed ONE HOUR of continuous autonomous execution. The context compacts multiple times during this period. Yet the quality remains consistent because:

- Task files track exactly what's done and what remains
- Plan files preserve design decisions
- State JSON captures loop iteration and progress
- Each agent batch starts with fresh context but complete knowledge

A 60-minute build flow might involve:

- 15+ context compactions
- 50+ agent spawns
- 100+ file edits
- 0 loss of quality or direction

**Implementation**:

- All context persisted to `.claude/branches/{branch}/state.json`
- Plans, tasks, and progress survive context window compaction
- Sessions can be resumed without loss of knowledge - hours, days, or weeks later

#### 3. Minimize LLM Roundtrips

**The problem with naive implementations**: Every tool call to the LLM costs time and tokens. A command that requires 5 sequential tool calls takes 5x longer than one that gathers everything at once.

**The agent-native approach**: Shell scripts gather all necessary context in a single invocation. Bang-prefixed snippets (`!`) execute inline without separate tool calls. Hooks run in parallel, never blocking.

**Why this matters**: The difference between a sluggish assistant and a responsive one often comes down to roundtrip optimization. Users shouldn't wait 30 seconds for context that could be gathered in 3.

**Implementation**:

- Shell scripts gather context in a single invocation
- Bang-prefixed snippets (`!`) execute inline without tool calls
- Hooks run in parallel, never blocking the main thread

#### 4. Native UI Elements for Team Visibility

**The problem with text-based interaction**: When AI outputs decisions as prose, team members can't easily track what's happening. Progress is opaque. Choices are buried in paragraphs.

**The agent-native approach**: Use Claude Code's native UI elements. `TodoWrite` creates visible progress bars. `AskUserQuestion` creates structured option dialogs. The workflow is visible and navigable.

**Why this matters**: Software development is a team sport. When one developer uses AI, others need to understand what happened. Native UI elements create a shared understanding that text alone cannot.

**Implementation**:

- `TodoWrite` provides visible progress tracking
- `AskUserQuestion` creates proper UI components for decisions
- All choices use structured options, never plain text questions

#### 5. Quality Through Iteration

**The problem with one-shot generation**: AI that generates code once and moves on produces bugs. Complex features require iteration, testing, and refinement.

**The agent-native approach**: Loop mode enables autonomous completion with verifiable criteria. The build phase doesn't stop until tests pass. Seven-leg review catches issues before they reach production. Every change creates an audit trail.

**Why this matters**: The goal isn't to generate code fast - it's to generate _correct_ code. Iteration loops with objective completion criteria (tests pass, linting clean) ensure the output actually works.

**Implementation**:

- Loop mode enables autonomous completion with verifiable criteria
- Seven-leg review catches issues before they reach production
- Tasks create audit trails for every change

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     CLAUDE CODE SESSION                         │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    MAIN THREAD                           │   │
│  │  • Orchestration decisions                               │   │
│  │  • User interaction (AskUserQuestion)                    │   │
│  │  • Progress tracking (TodoWrite)                         │   │
│  │  • Agent spawning and collection                         │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              │                                  │
│              ┌───────────────┼───────────────┐                  │
│              ▼               ▼               ▼                  │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐    │
│  │   Agent Pool    │ │   Agent Pool    │ │   Agent Pool    │    │
│  │   (max 6)       │ │   (max 6)       │ │   (max 6)       │    │
│  │                 │ │                 │ │                 │    │
│  │ • Research      │ │ • Implementation│ │ • Review        │    │
│  │ • Analysis      │ │ • Test Runner   │ │ • Meta-analysis │    │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘    │
├─────────────────────────────────────────────────────────────────┤
│                         HOOKS LAYER                             │
│  SessionStart → PreToolUse → PostToolUse → PreCompact → Stop    │
├─────────────────────────────────────────────────────────────────┤
│                         MCP SERVERS                             │
│  Context7 (docs) • Codex (reasoning) • OctoCode (GitHub search) │
├─────────────────────────────────────────────────────────────────┤
│                      PERSISTENT STATE                           │
│  .claude/branches/{branch}/state.json                           │
│  .claude/branches/{branch}/tasks/*.md                           │
│  .claude/plans/{slug}.md                                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Four Phases

The workflow follows a **design → build → check → fix** cycle. This isn't an arbitrary structure - it mirrors how senior engineers approach complex problems, formalized into a repeatable process that AI agents can execute consistently.

```
                            THE FOUR-PHASE CYCLE
    ┌─────────────────────────────────────────────────────────────┐
    │                                                             │
    │         ┌────────────┐          ┌────────────┐              │
    │         │   DESIGN   │─────────►│   BUILD    │              │
    │         │            │          │            │              │
    │         │ • Research │          │ • Execute  │              │
    │         │ • Plan     │          │ • Test     │              │
    │         │ • Stories  │          │ • Commit   │              │
    │         └────────────┘          └─────┬──────┘              │
    │               ▲                       │                     │
    │               │                       ▼                     │
    │         ┌─────┴──────┐          ┌────────────┐              │
    │         │    FIX     │◄─────────│   CHECK    │              │
    │         │            │          │            │              │
    │         │ • Triage   │          │ • Review   │              │
    │         │ • Repair   │          │ • Analyze  │              │
    │         │ • Verify   │          │ • Triage   │              │
    │         └────────────┘          └────────────┘              │
    │                                                             │
    │                    ▼ Deploy when clean ▼                    │
    └─────────────────────────────────────────────────────────────┘
```

### Why Four Phases?

Traditional AI coding assistants jump straight to implementation. Ask for a feature, get code. This works for simple tasks but fails catastrophically for complex ones. Why?

1. **Design debt compounds** - Without upfront design, you make assumptions that haunt you later
2. **Context matters** - What already exists in the codebase? What patterns are established?
3. **Quality requires review** - First-draft code contains bugs; catching them early costs 10x less than catching them in production
4. **Problems recur** - Without tracking and iteration, you fix the same bug repeatedly

The four-phase cycle addresses each of these:

- **Design**: Gather context, research best practices, plan before coding
- **Build**: Execute with tracking, commit granularly, test continuously
- **Check**: Multi-dimensional review catches what humans miss
- **Fix**: Address issues systematically, not whack-a-mole

### 1. Design Phase (`/crew:design`)

**Purpose**: Research and create validated implementation plans before writing a single line of code.

**Why design first?** The most expensive bugs are architectural ones - the kind where you realize, three weeks in, that your fundamental approach won't scale, or conflicts with existing patterns, or has security implications you didn't consider. Design phase eliminates these by gathering comprehensive context upfront.

**The nine-agent research approach**: Instead of hoping the AI knows about your codebase, framework best practices, and historical decisions, we explicitly research each dimension in parallel. Nine agents working simultaneously can cover ground that would take a human hours in minutes.

```
                       DESIGN PHASE FLOW
    ┌─────────────────────────────────────────────────────────────┐
    │                                                             │
    │   USER INPUT: "Add feature X with requirements Y"           │
    │                          │                                  │
    │                          ▼                                  │
    │  ┌───────────────────────────────────────────────────────┐  │
    │  │               9 RESEARCH AGENTS (parallel)            │  │
    │  │                                                       │  │
    │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │  │
    │  │  │  Repo    │ │  Best    │ │   Git    │ │Framework │  │  │
    │  │  │ Research │ │Practices │ │ History  │ │  Docs    │  │  │
    │  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │  │
    │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │  │
    │  │  │   API    │ │  Data    │ │   UX     │ │  Scale   │  │  │
    │  │  │Interface │ │  Model   │ │ Workflow │ │  Perf    │  │  │
    │  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │  │
    │  │         ┌──────────┐                                  │  │
    │  │         │ Security │                                  │  │
    │  │         │  Threat  │                                  │  │
    │  │         └──────────┘                                  │  │
    │  └───────────────────────────────────────────────────────┘  │
    │                          │                                  │
    │                          ▼                                  │
    │  ┌───────────────────────────────────────────────────────┐  │
    │  │             CODEX MCP (Deep Reasoning)                │  │
    │  │          Synthesize findings → Architecture           │  │
    │  └───────────────────────────────────────────────────────┘  │
    │                          │                                  │
    │                          ▼                                  │
    │  ┌───────────────────────────────────────────────────────┐  │
    │  │            SPEC-FLOW-ANALYZER AGENT                   │  │
    │  │          Generate user stories & tasks                │  │
    │  └───────────────────────────────────────────────────────┘  │
    │                          │                                  │
    │            ┌─────────────┴─────────────┐                    │
    │            ▼                           ▼                    │
    │   .claude/plans/{slug}.md    .claude/branches/.../tasks/    │
    │   (Design Decisions)          (Executable Tasks)            │
    │                                                             │
    └─────────────────────────────────────────────────────────────┘
```

**Process**:

1. Launch 9 research agents in parallel (single message)
2. Query Codex MCP for architectural synthesis
3. Run `spec-flow-analyzer` to generate user stories
4. Write plan to `.claude/plans/{slug}.md`
5. Generate task files in `.claude/branches/{branch}/tasks/`

**Research Agents** (launched in parallel):

| Agent                            | Why It Matters                                           |
| -------------------------------- | -------------------------------------------------------- |
| `repo-research-analyst`          | Understands YOUR codebase patterns, not generic patterns |
| `best-practices-researcher`      | Current best practices, not outdated tutorials           |
| `git-history-analyzer`           | Why was it built this way? What was tried before?        |
| `api-interface-analyst`          | How will this integrate with existing APIs?              |
| `data-model-architect`           | What entities exist? What migrations needed?             |
| `ux-workflow-analyst`            | How will users actually use this?                        |
| `scale-performance-analyst`      | Will this handle production load?                        |
| `security-threat-analyst`        | What could go wrong from a security perspective?         |
| `integration-dependency-analyst` | What external services are involved?                     |

**The output**: A comprehensive plan document with user stories (prioritized P1/P2/P3), functional requirements, success criteria, and a breakdown of tasks. Each task becomes a separate file that agents will execute in the build phase.

### 2. Build Phase (`/crew:build`)

**Purpose**: Execute work plans with iteration loops and progress tracking.

**Why batch execution?** Individual task files enable parallel execution. Instead of implementing features sequentially, independent tasks run simultaneously. Six agents implementing six components completes 6x faster than one agent doing all six sequentially.

**Why loop mode?** Complex features rarely work on the first attempt. Tests fail. Edge cases emerge. Loop mode enables autonomous iteration: the system keeps working until tests pass, creating fix tasks for failures and re-running until completion criteria are met. You can start a build, go to lunch, and return to completed work.

**Why granular commits?** Each task gets its own commit. This creates a clean git history where you can see exactly what changed for each piece of functionality. Reverting a broken feature doesn't require reverting unrelated changes.

**Process**:

1. Load plan and task files
2. Execute tasks in batches (max 6 parallel agents)
3. Run test-runner agent (haiku model - fast and cheap) after each batch
4. Update task files: `*-pending-*` → `*-complete-*`
5. Commit each completed task with conventional commit message
6. Loop until all tasks complete and CI passes

**Critical Rules** (learned from hard experience):

- **Never run CI commands directly** - use haiku test-runner agent (keeps the main thread responsive)
- **Never exceed 6 concurrent agents** - resource management prevents degradation
- **Launch all agents in single message** - parallel execution only works if all spawned at once
- **Mark tasks complete immediately** - don't batch updates; progress should be visible in real-time

**Loop Mode** (`--loop` flag):

The magic of autonomous completion. With loop mode enabled, the Stop hook checks for a completion promise. If tests aren't passing, if tasks remain pending, the session doesn't end - it continues to the next iteration.

```
                        LOOP MODE EXECUTION FLOW
    ┌─────────────────────────────────────────────────────────────┐
    │                                                             │
    │  START LOOP                                                 │
    │      │                                                      │
    │      ▼                                                      │
    │  ┌──────────────────┐                                       │
    │  │ Execute Batch    │◄─────────────────────────────┐        │
    │  │ (up to 6 tasks)  │                              │        │
    │  └────────┬─────────┘                              │        │
    │           │                                        │        │
    │           ▼                                        │        │
    │  ┌──────────────────┐                              │        │
    │  │ Run Test Suite   │                              │        │
    │  │ (haiku agent)    │                              │        │
    │  └────────┬─────────┘                              │        │
    │           │                                        │        │
    │           ▼                                        │        │
    │  ┌──────────────────┐    NO     ┌──────────────┐   │        │
    │  │  Tests Pass?     │──────────►│ Create Fix   │   │        │
    │  └────────┬─────────┘           │ Tasks        │───┘        │
    │           │ YES                 └──────────────┘            │
    │           ▼                                                 │
    │  ┌──────────────────┐    NO                                 │
    │  │ All Tasks Done?  │──────────────────────────────┘        │
    │  └────────┬─────────┘                                       │
    │           │ YES                                             │
    │           ▼                                                 │
    │  ┌──────────────────┐                                       │
    │  │ Output Promise:  │                                       │
    │  │ "BUILD COMPLETE" │                                       │
    │  └────────┬─────────┘                                       │
    │           │                                                 │
    │           ▼                                                 │
    │  ┌──────────────────┐                                       │
    │  │   Stop Hook      │                                       │
    │  │ Verifies Promise │                                       │
    │  └────────┬─────────┘                                       │
    │           │                                                 │
    │           ▼                                                 │
    │       EXIT LOOP                                             │
    │                                                             │
    └─────────────────────────────────────────────────────────────┘
```

```javascript
// State tracked in .claude/branches/{branch}/state.json
{
  "loop": {
    "active": true,
    "iteration": 3,
    "maxIterations": 15,
    "completionPromise": "BUILD COMPLETE"  // Must be output to finish
  }
}
```

**The completion promise**: A phrase that the AI must output to signal completion. The system checks that it's TRUE - that all tasks are actually complete and CI actually passes - before accepting it. This prevents premature claims of completion.

### Quality Gates: The CI Integration

Quality isn't optional - it's enforced through automated gates at every level:

```
┌─────────────────────────────────────────────────────────────────┐
│                    QUALITY GATE PIPELINE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐    ┌─────────┐  │
│  │  EDIT    │ ──► │  LINT    │ ──► │  TEST    │ ──►│ REVIEW  │  │
│  │  FILE    │     │ (auto)   │     │ (batch)  │    │ (7-leg) │  │
│  └──────────┘     └──────────┘     └──────────┘    └─────────┘  │
│       │                │                │               │       │
│       │                │                │               │       │
│  PostToolUse      Immediate        After each       Before      │
│  hook fires       formatting       agent batch      merge       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Level 1: Immediate Linting (PostToolUse)**
Every file edit triggers automatic formatting:

- TypeScript: Prettier + Biome
- Solidity: Forge fmt
- Shell scripts: shfmt + shellcheck
- Markdown: Prettier + markdownlint

This happens BEFORE you even see the result. Code is always formatted correctly.

**Level 2: Batch Testing (Test Runner Agent)**
After each batch of tasks completes, a haiku-model test runner executes:

- Full test suite runs
- Failures generate new fix tasks
- Build doesn't progress until tests pass

**Level 3: Integration Testing (Loop Completion)**
Before the completion promise can be accepted:

- `bun run ci` must pass (lint + typecheck + unit tests)
- `bun run test:integration` must pass
- All task files must be marked complete

**Level 4: Seven-Leg Review (Before Merge)**
Before any PR merges:

- Seven specialized reviewers analyze the code
- P0 findings block the PR
- P1 findings require resolution

**The result**: Code that reaches production has passed four quality gates. Issues caught early cost 10x less to fix than issues caught in production.

### 3. Check Phase (`/crew:check`)

**Purpose**: Multi-agent code review with automatic triage.

**Why multi-dimensional review?** Human code reviewers are inconsistent. They catch different things on different days. They have expertise gaps. They tire. The seven-leg review system ensures every code change is analyzed across seven distinct dimensions, every time, without fatigue or bias.

**Why seven legs specifically?** These dimensions emerged from analyzing thousands of code review comments across production codebases. Each leg represents a category of issues that reviewers frequently find - or miss. By having dedicated agents for each, nothing falls through the cracks.

```
                       SEVEN-LEG REVIEW SYSTEM
    ┌─────────────────────────────────────────────────────────────┐
    │                                                             │
    │                      CODE CHANGES                           │
    │                          │                                  │
    │    ┌─────────────────────┼─────────────────────┐            │
    │    │      │      │       │       │      │      │            │
    │    ▼      ▼      ▼       ▼       ▼      ▼      ▼            │
    │  ┌───┐  ┌───┐  ┌───┐   ┌───┐   ┌───┐  ┌───┐  ┌───┐          │
    │  │COR│  │PER│  │SEC│   │ELG│   │RES│  │STY│  │SML│          │
    │  │   │  │   │  │   │   │   │   │   │  │   │  │   │          │
    │  └─┬─┘  └─┬─┘  └─┬─┘   └─┬─┘   └─┬─┘  └─┬─┘  └─┬─┘          │
    │    │      │      │       │       │      │      │            │
    │    └──────┴──────┴───────┼───────┴──────┴──────┘            │
    │                          ▼                                  │
    │                  ┌──────────────┐                           │
    │                  │META-REVIEWER │                           │
    │                  │  Synthesize  │                           │
    │                  └──────┬───────┘                           │
    │                         ▼                                   │
    │              ┌──────────────────┐                           │
    │              │  TRIAGE REPORT   │                           │
    │              │  P0 → Block PR   │                           │
    │              │  P1 → Fix now    │                           │
    │              │  P2 → Fix soon   │                           │
    │              └──────────────────┘                           │
    │                                                             │
    │  LEGS: COR=Correctness, PER=Performance, SEC=Security,      │
    │        ELG=Elegance, RES=Resilience, STY=Style, SML=Smells  │
    └─────────────────────────────────────────────────────────────┘
```

**Seven-Leg Review System**:

| Leg             | Focus            | Why It Matters                                                                          |
| --------------- | ---------------- | --------------------------------------------------------------------------------------- |
| **Correctness** | Logic accuracy   | Does the code actually do what it's supposed to? Edge cases, null handling, type safety |
| **Performance** | Speed/efficiency | Will this perform at scale? Complexity analysis, caching, N+1 query detection           |
| **Security**    | Vulnerabilities  | OWASP top 10, injection vectors, auth issues, secret exposure                           |
| **Elegance**    | Design quality   | Is this maintainable? SOLID principles, clean architecture, cohesion                    |
| **Resilience**  | Failure handling | What happens when things go wrong? Error recovery, cleanup, graceful degradation        |
| **Style**       | Conventions      | Is this consistent with the codebase? Naming, formatting, idioms                        |
| **Smells**      | Debt indicators  | Will we regret this later? Anti-patterns, duplication, complexity                       |

**Severity Levels** (actionable triage):

- **P0**: Critical - Must fix before merge, blocks deployment
- **P1**: High - Should fix in this PR, significant impact
- **P2**: Medium - Address soon, can be follow-up PR
- **Observation**: Note for consideration, not blocking

**The meta-reviewer**: After all seven legs complete, an optional meta-reviewer synthesizes findings, identifies cross-cutting concerns, and escalates systemic issues. This catches patterns that individual leg reviewers might miss.

### 4. Fix Phase (`/crew:fix`)

**Purpose**: Repair skills, resolve blockers, address review findings systematically.

**Why a dedicated fix phase?** Ad-hoc fixing leads to whack-a-mole development. You fix one thing, break another. The fix phase treats issues systematically: convert findings to task files, prioritize by severity, fix in order, verify each fix, re-run tests. It's a methodical approach that actually clears the backlog.

**What it does**:

- Converts P0/P1 findings into task files (same format as build tasks)
- Prioritizes fixes by severity (P0 first, then P1)
- Runs targeted fixes based on triage
- Re-runs affected tests after each fix
- Updates PR with resolution notes

**Integration with the cycle**: After fixes complete, you can re-run `/crew:check` to verify all issues are resolved. This creates a tight feedback loop: build → check → fix → check → deploy.

---

## Commands Reference

### Workflow Commands

| Command         | Description                 | Key Features                            |
| --------------- | --------------------------- | --------------------------------------- |
| `/crew:design`  | Create implementation plans | 9 parallel research agents + Codex      |
| `/crew:build`   | Execute work with tracking  | Loop mode, batch execution, auto-commit |
| `/crew:check`   | Multi-agent code review     | 7-leg system, severity triage           |
| `/crew:restart` | Resume pending work         | State recovery after compaction         |
| `/crew:ci`      | Background CI runner        | Haiku agent, non-blocking               |

### Git Commands

| Command                  | Description                       |
| ------------------------ | --------------------------------- |
| `/crew:git:commit`       | Create conventional commit        |
| `/crew:git:pr`           | Commit, push, and open PR         |
| `/crew:git:push`         | Push current branch               |
| `/crew:git:branch`       | Create feature branch             |
| `/crew:git:sync`         | Sync with main                    |
| `/crew:git:stack-add`    | Add branch to machete stack       |
| `/crew:git:stack-status` | Show stack status                 |
| `/crew:git:traverse`     | Sync all stacked branches         |
| `/crew:git:slide-out`    | Remove merged branches from stack |
| `/crew:git:fix-reviews`  | Resolve PR review comments        |
| `/crew:git:update-pr`    | Update PR annotations             |
| `/crew:git:clean`        | Clean stale branches              |
| `/crew:git:undo`         | Undo last commit (keeps changes)  |

---

## Agent Ecosystem

### Research Agents

Used during `/crew:design` to gather comprehensive context:

```
                    PARALLEL AGENT SPAWN PATTERN
    ┌─────────────────────────────────────────────────────────────┐
    │                      MAIN THREAD                            │
    │                          │                                  │
    │        ┌─────────────────┼─────────────────┐                │
    │        │                 │                 │                │
    │        ▼                 ▼                 ▼                │
    │   ┌─────────┐       ┌─────────┐       ┌─────────┐           │
    │   │ Agent 1 │       │ Agent 2 │       │ Agent 3 │   ...     │
    │   │  (bg)   │       │  (bg)   │       │  (bg)   │   up to   │
    │   └────┬────┘       └────┬────┘       └────┬────┘   6 max   │
    │        │                 │                 │                │
    │        ▼                 ▼                 ▼                │
    │   ┌─────────┐       ┌─────────┐       ┌─────────┐           │
    │   │ Result  │       │ Result  │       │ Result  │           │
    │   └────┬────┘       └────┬────┘       └────┬────┘           │
    │        │                 │                 │                │
    │        └─────────────────┼─────────────────┘                │
    │                          ▼                                  │
    │                   COLLECT & SYNTHESIZE                      │
    └─────────────────────────────────────────────────────────────┘

    CRITICAL: All agents MUST be spawned in a SINGLE message
              for true parallel execution
```

```javascript
// All launched in SINGLE message for parallel execution
Task({ subagent_type: "crew:research:repo-research-analyst", ... });
Task({ subagent_type: "crew:research:best-practices-researcher", ... });
Task({ subagent_type: "crew:research:git-history-analyzer", ... });
Task({ subagent_type: "crew:research:framework-docs-researcher", ... });
```

### Design Agents

Dimension analysis for architectural decisions:

```javascript
Task({ subagent_type: "crew:design:api-interface-analyst", ... });
Task({ subagent_type: "crew:design:data-model-architect", ... });
Task({ subagent_type: "crew:design:ux-workflow-analyst", ... });
Task({ subagent_type: "crew:design:scale-performance-analyst", ... });
Task({ subagent_type: "crew:design:security-threat-analyst", ... });
Task({ subagent_type: "crew:design:integration-dependency-analyst", ... });
```

### Review Agents

Seven-leg code review system:

```javascript
// All 7 launched in SINGLE message
const legs = ["correctness", "performance", "security", "elegance",
              "resilience", "style", "smells"];
for (const leg of legs) {
  Task({ subagent_type: `crew:review:seven-legs:${leg}-reviewer`, ... });
}
```

### Workflow Agents

Specialized task execution:

| Agent                        | Purpose                              |
| ---------------------------- | ------------------------------------ |
| `spec-flow-analyzer`         | Generate user stories from research  |
| `work-orchestrator`          | Execute plans with progress tracking |
| `pr-comment-resolver`        | Address PR review comments           |
| `bug-reproduction-validator` | Validate bug reports                 |
| `design-iterator`            | Iterative UI refinement              |
| `content-style-editor`       | Style guide enforcement              |

---

## Hooks and Scripts

Hooks are the nervous system of the Agent Native Development Workflow. They fire at key lifecycle moments, providing context, enforcing conventions, and maintaining state - all without requiring explicit invocation.

### Why Hooks Matter

**The invisible hand problem**: AI assistants don't know things you haven't told them. They don't know your git branch status. They don't know linting rules. They don't know about your machete stack. Hooks inject this context automatically.

**The consistency problem**: Humans forget. We forget to lint. We forget to commit. We forget to update state. Hooks enforce consistency mechanically - after every file edit, lint runs. After every session, state saves. No discipline required.

**The speed imperative**: Hooks must be FAST. Every millisecond of hook execution is a millisecond the user waits. This is why we obsess over performance: single `jq` calls instead of multiple, local binary paths instead of `bunx`, parallel execution instead of sequential. A slow hook is worse than no hook.

### Hook Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    SESSION LIFECYCLE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SessionStart ──► restore state, check stack, inject skills     │
│       │                                                         │
│       ▼                                                         │
│  UserPromptSubmit ──► enforce task-first workflow               │
│       │                                                         │
│       ▼                                                         │
│  PreToolUse ──► suggest skills before Bash commands             │
│       │                                                         │
│       ▼                                                         │
│  [Tool Executes]                                                │
│       │                                                         │
│       ▼                                                         │
│  PostToolUse ──► lint, sync machete, track agents               │
│       │                                                         │
│       ▼                                                         │
│  PreCompact ──► save all state before context compaction        │
│       │                                                         │
│       ▼                                                         │
│  Stop ──► check loop continuation, re-feed if not complete      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Hook Types

```json
{
  "hooks": {
    "SessionStart": [...],    // Restore state, check stack
    "PreCompact": [...],      // Save state before compaction
    "Stop": [...],            // Check loop continuation
    "PreToolUse": [...],      // Suggest skills
    "PostToolUse": [...],     // Lint, sync machete, track agents
    "UserPromptSubmit": [...]  // Enforce task-first workflow
  }
}
```

### SessionStart Hooks

**[restore-session-state.sh](https://github.com/settlemint/agent-marketplace/blob/main/crew/scripts/hooks/session-start/restore-session-state.sh)**

Restores context after compaction:

- Reads unified state from `.claude/branches/{branch}/state.json`
- Outputs plan preview directly (no file read needed)
- Provides TodoWrite-compatible JSON for restoration
- Detects stuck agents from previous session

**Performance**: Single `jq` call extracts all fields at once (~400ms savings).

**[check-stack-status.sh](https://github.com/settlemint/agent-marketplace/blob/main/crew/scripts/hooks/session-start/check-stack-status.sh)**

Reports git-machete stack status and worktree safety warnings.

**[check-linters.sh](https://github.com/settlemint/agent-marketplace/blob/main/crew/scripts/hooks/session-start/check-linters.sh)**

Detects available linters for PostToolUse auto-formatting.

### PreCompact Hooks

**[save-session-state.sh](https://github.com/settlemint/agent-marketplace/blob/main/crew/scripts/hooks/pre-compact/save-session-state.sh)**

Saves all context before compaction:

- Captures plan file content (first 100 lines)
- Saves TodoWrite state in compatible format
- Records active workflow and args
- Scans task files for progress counts
- Creates WIP task if uncommitted changes exist

**Session Completion Discipline**: Work is NOT complete until `git commit` succeeds.

### Stop Hooks

**[check-loop.sh](https://github.com/settlemint/agent-marketplace/blob/main/crew/scripts/hooks/stop/check-loop.sh)**

Controls iteration loop continuation:

- Checks for completion promise in transcript
- Increments iteration counter
- Re-feeds prompt if loop should continue
- Exits with code 1 to block session exit

### PostToolUse Hooks

**[lint-modified-file.sh](https://github.com/settlemint/agent-marketplace/blob/main/crew/scripts/hooks/post-tool/lint-modified-file.sh)**

Auto-formats after Edit/Write:

- Uses local `node_modules/.bin` binaries (saves ~200ms per call)
- Runs prettier + biome for TypeScript
- Runs forge fmt for Solidity
- Runs shfmt + shellcheck for shell scripts

**[sync-machete-stack.sh](https://github.com/settlemint/agent-marketplace/blob/main/crew/scripts/hooks/post-tool/sync-machete-stack.sh)**

Keeps git-machete stack in sync after branch operations.

**[track-agent-spawn.sh](https://github.com/settlemint/agent-marketplace/blob/main/crew/scripts/hooks/post-tool/track-agent-spawn.sh)** / **[track-agent-complete.sh](https://github.com/settlemint/agent-marketplace/blob/main/crew/scripts/hooks/post-tool/track-agent-complete.sh)**

Maintains agent registry in `.claude/branches/{branch}/agents.json`:

- Tracks spawned agents with timestamps
- Updates status on completion
- Enables stuck agent detection

### PreToolUse Hooks

**[suggest-skill.sh](https://github.com/settlemint/agent-marketplace/blob/main/crew/scripts/hooks/pre-tool/suggest-skill.sh)**

Suggests relevant skills based on command:

- `git commit` → suggests `/crew:git:commit`
- `bun run test` → suggests `/crew:ci`

### Bang-Prefix Snippets

Commands in markdown with `!` prefix execute inline without tool calls:

```markdown
<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>
```

This gathers all context in a single invocation, dramatically reducing LLM roundtrips.

---

## MCP Server Integration

MCP (Model Context Protocol) servers extend the AI's capabilities beyond its training data. They provide real-time access to documentation, code repositories, and reasoning systems that would otherwise be unavailable.

### Why MCP Servers?

**The stale knowledge problem**: AI models are trained on data from months or years ago. Framework documentation changes. Best practices evolve. APIs update. MCP servers provide access to current information, not just what was in the training set.

**The breadth vs depth problem**: An AI can know a little about many things, but MCP servers enable deep expertise on demand. Need React 19 patterns? Query Context7. Need to understand how a GitHub library works? Search with OctoCode. Need architectural analysis? Invoke Codex.

**The external integration problem**: Without MCP, AI is limited to what's in the conversation. With MCP, it can query external systems, search repositories, and access specialized reasoning - dramatically expanding its effective capabilities.

### Configured Servers

**[.mcp.json](https://github.com/settlemint/agent-marketplace/blob/main/crew/.mcp.json)**

```json
{
  "mcpServers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp"
    },
    "codex": {
      "type": "stdio",
      "command": "codex",
      "args": [
        "-m",
        "gpt-5.2-codex",
        "-c",
        "model_reasoning_effort=xhigh",
        "mcp-server"
      ]
    },
    "octocode": {
      "type": "stdio",
      "command": "bunx",
      "args": ["-y", "octocode-mcp@latest"]
    },
    "restate-docs": {
      "type": "http",
      "url": "https://docs.restate.dev/mcp"
    }
  }
}
```

### Context7

**Purpose**: Library documentation lookup

**Usage**: Research agents use Context7 v2 to fetch up-to-date documentation for any framework or library. The v2 API uses server-side filtering for 65% fewer tokens and 38% faster responses.

```javascript
MCPSearch({ query: "select:mcp__plugin_crew_context7__query-docs" });
mcp__plugin_crew_context7__query_docs({
  libraryId: "/reactjs/react.dev",
  query: "How do I use hooks and what are the best practices?",
});
```

**Key improvements in v2:**

- Use natural language `query` parameter (not just topic keywords)
- Server-side reranking returns only the most relevant docs

### Codex

**Purpose**: Deep reasoning and architectural synthesis

**Usage**: Called directly (not via agent) for complex design decisions.

```javascript
MCPSearch({ query: "select:mcp__plugin_crew_codex__codex" });
mcp__plugin_crew_codex__codex({
  prompt:
    "Architecture design for: [feature]. Key decisions, trade-offs, risks?",
  model: "o3",
});
```

### OctoCode

**Purpose**: GitHub repository search and code analysis

**Available Tools**:

- `githubSearchCode` - Find code patterns across GitHub
- `githubGetFileContent` - Read specific files
- `githubViewRepoStructure` - Explore repository structure
- `githubSearchRepositories` - Find relevant projects
- `packageSearch` - Search npm/crates/pypi packages

---

## State Management

State management is what transforms ephemeral AI conversations into persistent, resumable work sessions. Without it, every context compaction or session restart means starting over. With it, weeks of work can span dozens of sessions without loss.

### Why State Matters

**The amnesia problem**: LLMs don't remember between sessions. Each conversation starts fresh. This is fine for simple questions but catastrophic for complex work that spans days or weeks.

**The compaction problem**: Even within a session, context windows are finite. When they fill up, older context gets "compacted" - summarized or dropped. Without external state, this means losing crucial decisions and progress.

**The collaboration problem**: When multiple developers (or the same developer on different days) work on a feature, they need shared context. State files provide that shared source of truth.

**The solution**: Write everything that matters to files. Plans document decisions. Task files track progress. State JSON captures execution context. When context compacts, when sessions end, when teammates join - the state survives.

### Unified State File

All branch state lives in `.claude/branches/{slugified-branch}/state.json`:

```
                       STATE FILE STRUCTURE
    ┌─────────────────────────────────────────────────────────────┐
    │  .claude/                                                   │
    │  ├── plans/                                                 │
    │  │   └── {slug}.md         ← Design decisions & approach    │
    │  │                                                          │
    │  ├── branches/                                              │
    │  │   └── {slugified-branch}/                                │
    │  │       ├── state.json    ← Execution context (shown below)│
    │  │       ├── agents.json   ← Agent registry & status        │
    │  │       └── tasks/                                         │
    │  │           ├── 010-complete-p1-us1-setup.md               │
    │  │           ├── 020-pending-p1-us1-implement.md            │
    │  │           └── 030-pending-p2-us2-tests.md                │
    │  │                                                          │
    │  └── settings.json         ← Project-level Claude settings  │
    └─────────────────────────────────────────────────────────────┘

    STATE SURVIVES:
    • Context compaction (automatic)
    • Session end/restart (explicit save)
    • Branch state in .claude/branches/ (gitignored, local)
```

```json
{
  "branch": "feat/new-feature",
  "session": "session-id",
  "compacted_at": "2026-01-07T10:30:00Z",
  "workflow": {
    "phase": "executing",
    "active": "crew:build",
    "args": "--loop"
  },
  "plan": {
    "exists": true,
    "file": ".claude/plans/new-feature.md",
    "preview": "# Plan: New Feature\n..."
  },
  "execution": {
    "todos": [...],
    "pending_count": 3,
    "completed_count": 7
  },
  "tasks": {
    "pending": 3,
    "p1": 1,
    "p2": 2,
    "p3": 0,
    "next": "020-pending-p1-us1-implement-api.md"
  },
  "loop": {
    "active": true,
    "iteration": 5,
    "maxIterations": 15,
    "completionPromise": "BUILD COMPLETE"
  }
}
```

### Task Files

Individual task files in `.claude/branches/{branch}/tasks/`:

```
                      TASK FILE NAMING CONVENTION
    ┌─────────────────────────────────────────────────────────────┐
    │                                                             │
    │    020-pending-p1-us1-implement-api.md                      │
    │    ───┬───────┬──┬──┬──────────┬─────                       │
    │       │       │  │  │          │                            │
    │       │       │  │  │          └── slug: short description  │
    │       │       │  │  │                                       │
    │       │       │  │  └── story: us1 = user story 1           │
    │       │       │  │                                          │
    │       │       │  └── priority: p1/p2/p3                     │
    │       │       │       (p1 = must have, p2 = should have)    │
    │       │       │                                             │
    │       │       └── status: pending/complete                  │
    │       │            (file renamed when status changes)       │
    │       │                                                     │
    │       └── order: execution sequence (010, 020, 030...)      │
    │                                                             │
    │    STATUS TRANSITIONS:                                      │
    │    020-pending-p1-... → 020-complete-p1-... (on success)    │
    │                                                             │
    └─────────────────────────────────────────────────────────────┘
```

**Naming Convention**: `{order}-{status}-{priority}-{story}-{slug}.md`

```markdown
---
status: pending
priority: p1
story: us1
parallel: true
file_path: src/api/users.ts
depends_on: []
---

# T010: Create user API endpoint

## Description

Implement the user CRUD API endpoint.

## Acceptance Criteria

- [ ] GET /api/users returns paginated list
- [ ] POST /api/users creates new user
- [ ] Input validation with Zod

## File Path

`src/api/users.ts`

## Work Log

### 2026-01-07 - Created

**By:** /crew:design
```

### Plan Files

Design plans in `.claude/plans/{slug}.md` following the [plan template](https://github.com/settlemint/agent-marketplace/blob/main/crew/skills/todo-tracking/templates/plan-template.md).

### TodoWrite Integration

TodoWrite provides real-time progress visibility:

```javascript
TodoWrite({
  todos: [
    {
      content: "Implement user API",
      status: "completed",
      activeForm: "Implementing user API",
    },
    {
      content: "Add validation",
      status: "in_progress",
      activeForm: "Adding validation",
    },
    { content: "Write tests", status: "pending", activeForm: "Writing tests" },
  ],
});
```

**Rules**:

- Only ONE task `in_progress` at a time
- Update IMMEDIATELY after each task
- Mark complete as soon as agent finishes

---

## Git Integration

Git is already the backbone of modern software development. The Agent Native Development Workflow doesn't replace git - it enhances it with sophisticated branch management and PR workflows that enable truly parallel feature development.

### Why Advanced Git Integration?

**The big PR problem**: Large features mean large PRs. Large PRs mean slow reviews, merge conflicts, and deployment risk. The solution is smaller, stacked PRs - but managing stacked branches manually is tedious and error-prone.

**The concurrent work problem**: Developers often need to work on multiple features simultaneously. Context-switching between branches loses mental state. Git worktrees solve this by allowing multiple branches to be checked out in different directories.

**The convention problem**: Every team debates commit message formats, branch naming, PR templates. The workflow encodes conventions directly, eliminating debates and ensuring consistency.

### Git-Machete for Stacked Branches

Git-machete enables stacked PRs for parallel feature development:

```bash
# View stack status
git machete status

# Sync all branches with parents and remotes
git machete traverse

# Remove merged branches
git machete slide-out

# Create PR with stack context
git machete github create-pr
```

### Worktrees for Concurrent Work

Worktrees allow multiple branches to be checked out simultaneously:

```bash
# Create worktree for feature branch
git worktree add ../feature-branch feat/new-feature

# Each worktree has independent working directory
# Share the same git objects (efficient)
```

**Worktree Safety Rules**:

- Safe: `git machete update`, `git machete status`
- Dangerous: `git machete traverse`, `git checkout <branch>`

### Conventional Commits

All commits follow conventional format:

```
type(scope): description

Types: feat, fix, refactor, docs, test, chore
```

### PR Templates

Templates selected based on commit type:

- `feat` → Full template with design decisions
- `fix` → Bug fix template with reproduction steps
- `refactor` → Light template
- Mixed → Minimal template

---

## Crew Skills

Skills are reusable knowledge modules that encode expertise. Instead of re-explaining best practices every conversation, skills inject them automatically when relevant context is detected.

### Why Skills?

**The repetition problem**: Every developer conversation about React needs to explain hooks patterns. Every Solidity conversation needs to explain security practices. Skills encode this knowledge once and inject it automatically.

**The expertise gap problem**: Not every developer knows every framework deeply. Skills provide instant access to expert-level patterns and practices, democratizing specialized knowledge.

**The trigger system**: Skills activate automatically based on context. Edit a `.sol` file? Solidity skill activates. Run `git commit`? Git conventions skill activates. No manual invocation required - the right knowledge appears at the right time.

The crew plugin includes skills for workflow orchestration:

### Core Workflow Skills

| Skill                                            | Triggers                          | Purpose                            |
| ------------------------------------------------ | --------------------------------- | ---------------------------------- |
| `compound-engineering:agent-native-architecture` | `agent workflow`, `orchestrate`   | Agent patterns via Every plugin    |
| `crew:skill-builder`                             | `create skill`, `SKILL.md`        | Create, audit, and maintain skills |
| `crew:git`                                       | Commit workflows                  | Git conventions, commits, PRs      |
| `crew:todo-tracking`                             | `persistent task`, `branch.*task` | File-based task management         |
| `crew:crew-patterns`                             | Internal                          | Reusable patterns for commands     |
| `crew:native-tools`                              | Internal                          | Claude Code native tool guidance   |
| `crew:ast-grep`                                  | Mass rename, refactor             | Code transformation with ast-grep  |

### Skill Builder Workflows

The `skill-builder` skill provides workflows for creating new skills:

```javascript
// Create a new skill from scratch
Skill({ skill: "crew:skill-builder", args: "create-new-skill" });

// Create a domain expertise skill (framework/library knowledge)
Skill({ skill: "crew:skill-builder", args: "create-domain-expertise-skill" });

// Audit an existing skill for quality
Skill({ skill: "crew:skill-builder", args: "audit-skill" });

// Upgrade a simple skill to router pattern
Skill({ skill: "crew:skill-builder", args: "upgrade-to-router" });
```

### Agent Architecture Resources

The `agent-native-architecture` skill (from compound-engineering plugin) provides architectural guidance:

| Resource                           | Purpose                               |
| ---------------------------------- | ------------------------------------- |
| `architecture-patterns.md`         | Prompt-native design patterns         |
| `agent-execution-patterns.md`      | Agent spawning and execution patterns |
| `dynamic-context-injection.md`     | Context injection strategies          |
| `files-universal-interface.md`     | File-based agent interfaces           |
| `shared-workspace-architecture.md` | Workspace and state management        |
| `system-prompt-design.md`          | System prompt engineering             |

Invoke via: `Skill({ skill: "compound-engineering:agent-native-architecture" })`

---

## Devtools Skills

While crew skills handle workflow orchestration, devtools skills handle domain expertise - the deep knowledge of specific frameworks, libraries, and tools that developers need daily.

### The Knowledge Currency Problem

Frameworks evolve rapidly. What was best practice in React 16 is an antipattern in React 19. Drizzle ORM patterns differ from Prisma patterns. Solidity security practices change with each exploit. Devtools skills encode CURRENT best practices, updated as the ecosystem evolves.

### MCP-First Philosophy

Many devtools skills follow an "MCP-first" approach: before generating code, they query Context7 for current documentation or OctoCode for real-world patterns. This ensures the advice isn't stale - it's based on the latest sources.

The devtools plugin provides framework expertise (24 skills total):

### Framework Skills

| Skill                     | Triggers                        | Purpose                                  |
| ------------------------- | ------------------------------- | ---------------------------------------- |
| `devtools:react`          | `.tsx`, `component`, `tailwind` | React 19 with Tailwind, shadcn, TanStack |
| `devtools:tanstack-start` | `createFileRoute`, `loader`     | TanStack Start full-stack framework      |
| `devtools:drizzle`        | `pgTable`, `db.select`          | Drizzle ORM patterns                     |
| `devtools:shadcn`         | `@/components/ui`, `cn()`       | shadcn/ui components                     |
| `devtools:radix`          | `Dialog`, `Popover`             | Radix UI primitives                      |

### API & Auth Skills

| Skill                  | Triggers                    | Purpose                             |
| ---------------------- | --------------------------- | ----------------------------------- |
| `devtools:api`         | `orpc`, `.contract.ts`      | oRPC API routes with 5-file pattern |
| `devtools:better-auth` | `better-auth`, `authClient` | Better Auth library patterns        |

### Testing Skills

| Skill                     | Triggers                   | Purpose                       |
| ------------------------- | -------------------------- | ----------------------------- |
| `devtools:vitest`         | `describe`, `it`, `expect` | Unit testing patterns         |
| `devtools:playwright`     | `page`, `getByRole`        | E2E testing with Page Objects |
| `devtools:tdd-typescript` | Default                    | RED-GREEN-REFACTOR cycle      |

### Blockchain Skills

| Skill               | Triggers                       | Purpose                                  |
| ------------------- | ------------------------------ | ---------------------------------------- |
| `devtools:solidity` | `.sol`, `contract`             | Smart contract development with Foundry  |
| `devtools:viem`     | `publicClient`, `walletClient` | Ethereum interactions                    |
| `devtools:thegraph` | `subgraph`, `mapping.ts`       | Subgraph development with AssemblyScript |

### Infrastructure Skills

| Skill                  | Triggers                 | Purpose                                       |
| ---------------------- | ------------------------ | --------------------------------------------- |
| `devtools:turbo`       | `turbo.json`, `monorepo` | Turborepo monorepo build system               |
| `devtools:helm`        | `chart`, `values.yaml`   | Kubernetes Helm charts                        |
| `devtools:restate`     | `ctx.run`, `ctx.sleep`   | Durable execution for fault-tolerant services |
| `devtools:git-machete` | `stacked`, `machete`     | Git branch management with stacked PRs        |

### Utility Skills

| Skill               | Triggers                | Purpose                           |
| ------------------- | ----------------------- | --------------------------------- |
| `devtools:zod`      | Zod validation          | Zod v4 schema patterns            |
| `devtools:pino`     | `log.info`, `log.error` | Pino JSON logging                 |
| `devtools:i18n`     | `i18n`, `t()`           | Internationalization with i18next |
| `devtools:motion`   | `animate`, `motion`     | Motion (Framer Motion) animations |
| `devtools:recharts` | `LineChart`, `BarChart` | Data visualization                |

### Design & Debugging Skills

| Skill                        | Purpose                                                    |
| ---------------------------- | ---------------------------------------------------------- |
| `devtools:design-principles` | Linear/Notion-inspired minimal design - Jony Ive precision |
| `devtools:troubleshooting`   | Structured debugging workflow                              |

---

## External Plugins

Beyond crew and devtools, the workflow integrates with other Claude Code plugins:

### Frontend Design Plugin

**Plugin**: `frontend-design@claude-plugins-official`

**Purpose**: Create distinctive, production-grade frontend interfaces with high design quality. Generates creative, polished code that avoids generic AI aesthetics.

**When to use**: Building web components, pages, or applications that need visual polish.

```javascript
Skill({ skill: "frontend-design:frontend-design" });
```

### Native Browser Automation (Claude-in-Chrome)

**Purpose**: Browser automation for validation, testing, debugging, and exploration. Available natively when the Claude-in-Chrome extension is installed.

**Key Tools** (prefix: `mcp__claude-in-chrome__`):

| Tool                    | Purpose                              |
| ----------------------- | ------------------------------------ |
| `navigate`              | Go to URLs                           |
| `read_page`             | Extract page content as markdown     |
| `form_input`            | Fill form fields                     |
| `computer`              | Click, type, scroll, take screenshot |
| `gif_creator`           | Record multi-step interactions       |
| `tabs_context_mcp`      | Get current tab context              |
| `read_console_messages` | Debug console output                 |
| `read_network_requests` | Inspect API calls                    |

**When to Use Browser Validation**:

1. **After UI changes**: Take screenshots to verify visual implementation
2. **After API integration**: Test endpoints via actual browser requests
3. **During debugging**: Read console logs, inspect network, check page state
4. **For documentation**: Capture workflows as GIFs for PRs

**Proactive Usage**: Claude should proactively use browser tools to validate work when beneficial, especially:

- After implementing frontend components
- When debugging user-reported issues
- To verify test coverage matches actual behavior
- To explore how external APIs respond

```javascript
// First load the tool via MCPSearch
MCPSearch({ query: "select:mcp__claude-in-chrome__navigate" });

// Then use it
mcp__claude-in-chrome__navigate({ url: "http://localhost:3000" });
mcp__claude-in-chrome__computer({ action: "screenshot" });
```

---

## Performance Principles

Performance isn't an afterthought - it's a core design constraint. Every second of delay compounds across thousands of interactions. A 200ms overhead per hook becomes minutes of waste per session. The following principles emerged from measuring, optimizing, and measuring again.

### The 10x Latency Rule

Users perceive 100ms as instant, 1 second as slow, 10 seconds as broken. Every optimization that takes a user-facing operation from 1s to 100ms dramatically improves the experience. We optimize ruthlessly for this.

### 1. Single jq Calls

Bad:

```bash
FIELD1=$(jq -r '.field1' "$FILE")
FIELD2=$(jq -r '.field2' "$FILE")
FIELD3=$(jq -r '.field3' "$FILE")
```

Good:

```bash
read -r FIELD1 FIELD2 FIELD3 < <(jq -r '[.field1, .field2, .field3] | @tsv' "$FILE")
```

### 2. Local Binary Paths

Bad:

```bash
bunx prettier --write "$FILE"  # ~200ms overhead
```

Good:

```bash
./node_modules/.bin/prettier --write "$FILE"  # Direct execution
```

### 3. Bang-Prefix Context Gathering

Bad:

```javascript
// Multiple tool calls
const status = Bash({ command: "git status" });
const branch = Bash({ command: "git branch --show-current" });
const diff = Bash({ command: "git diff --stat" });
```

Good:

```markdown
<git_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/commit-context.sh`
</git_context>
```

### 4. Parallel Agent Execution

Bad:

```javascript
// Sequential - slow
const result1 = Task({ subagent_type: "agent1", ... });
await TaskOutput({ task_id: result1.id });
const result2 = Task({ subagent_type: "agent2", ... });
```

Good:

```javascript
// Parallel - all in single message
Task({ subagent_type: "agent1", run_in_background: true, ... });
Task({ subagent_type: "agent2", run_in_background: true, ... });
Task({ subagent_type: "agent3", run_in_background: true, ... });
// Then collect all
```

### 5. Non-Blocking Hooks

Hooks must never block. Use `set +e` for defensive error handling:

```bash
#!/usr/bin/env bash
set +e  # Continue on errors

# Quick operations only
# No blocking network calls
# Exit 0 on any issue
```

---

## Installation

### Quick Install

The fastest way to get started:

```bash
# Download the script
curl -fsSL -o setup-plugins.sh https://raw.githubusercontent.com/settlemint/agent-marketplace/main/crew/scripts/hooks/session-start/setup-plugins.sh

# Inspect the script (recommended)
cat setup-plugins.sh

# Run the script
bash setup-plugins.sh
```

This script automatically:

- Adds the SettleMint and Every marketplaces
- Installs and updates all plugins (crew, devtools, compound-engineering)
- Clears plugin caches to ensure the latest versions

### Prerequisites

- Claude Code CLI (`claude`) - [Get it here](https://claude.ai/code)
- Node.js 20+ and bun
- git-machete (`brew install git-machete` or `pipx install git-machete`)
- GitHub CLI (`gh`)

### Manual Install

If you prefer manual installation:

```bash
# Add the SettleMint marketplace
/plugin marketplace add settlemint/agent-marketplace

# Install both plugins
/plugin install crew@settlemint
/plugin install devtools@settlemint
```

### Local Development

```bash
# Clone the repository
git clone https://github.com/settlemint/agent-marketplace.git
cd agent-marketplace

# Run Claude with local plugins
claude --plugin-dir ./crew --plugin-dir ./devtools
```

### Verify Installation

```bash
# Check available commands
/help

# You should see:
# /crew:design, /crew:build, /crew:check, /crew:restart
# /crew:git:commit, /crew:git:pr, etc.
# /devtools:* skills
```

---

## Real-World Examples

These aren't hypothetical - they're patterns we use daily to build production software.

### Example 1: Building a Multi-Tenant API with TypeScript

**The ask**: "Add multi-tenant organization API with invitation flows"

**Traditional approach** (weeks of work):

1. Research multi-tenancy patterns
2. Design the invitation workflow
3. Update Drizzle schema with migrations
4. Implement oRPC API endpoints
5. Add authorization middleware
6. Build React invitation UI components
7. Write Vitest unit tests
8. Write Playwright E2E tests
9. Debug issues
10. Code review and revisions

**Agent-native approach** (hours, not weeks):

```
/crew:design Add multi-tenant organization API with email invitation workflow

[9 research agents launch simultaneously]
- repo-research-analyst finds existing auth patterns in codebase
- best-practices-researcher queries Context7 for oRPC patterns
- api-interface-analyst maps required endpoints and contracts
- data-model-architect designs tenant/invitation schema
- security-threat-analyst flags authorization concerns
[... 4 more agents analyzing other dimensions]

[Codex synthesizes architectural approach]
[spec-flow-analyzer generates user stories]

Plan created: .claude/plans/multi-tenant-api.md
14 task files generated in .claude/branches/feat-multi-tenant/tasks/

[User reviews plan, approves approach]

/crew:build multi-tenant-api --loop

[Loop iteration 1]
- 6 agents implement setup tasks in parallel
- Drizzle schema, migrations, base types
- Test runner verifies each batch

[Loop iteration 2-4]
- API endpoints: organizations.contract.ts, organizations.router.ts
- Invitation flow with email integration
- React components with TanStack Query hooks

[Loop iteration 5]
- Vitest unit tests for all endpoints
- Playwright E2E tests for invitation flow
- Automatic fix tasks for test failures

[Loop iteration 6]
- CI passes (lint + typecheck + tests)
- Integration tests pass
- <promise>BUILD COMPLETE</promise>

/crew:check
[7 review agents analyze all changes]
- 0 P0 findings
- 2 P1 findings → converted to tasks
  - Missing Zod validation on invite endpoint
  - Race condition in concurrent invitation acceptance

[Fix P1 issues]

/crew:git:pr
PR #47 created with full context, design decisions documented
```

**Time**: 4 hours autonomous execution + 1 hour human review
**Quality**: More thorough than any single developer could achieve
**Documentation**: Automatic - plan file captures all decisions

### Example 2: Debugging a Complex Race Condition

**The symptom**: "Users occasionally see stale data after updates"

```
/crew:design Investigate and fix stale data race condition in user dashboard

[Research agents explore]
- repo-research-analyst traces data flow
- git-history-analyzer finds when behavior started
- scale-performance-analyst identifies caching layers

[Analysis reveals]
- React Query cache not invalidated on WebSocket updates
- Multiple components subscribe to same data independently
- No coordination between optimistic updates and server state

[Plan generated with 3 fix tasks]

/crew:build --loop

[Loop completes]
- Centralized cache invalidation added
- WebSocket updates trigger React Query refetch
- Optimistic updates properly coordinate with server responses

/crew:check
- Resilience reviewer validates error handling
- Correctness reviewer verifies cache invalidation logic
- Performance reviewer confirms no N+1 queries introduced
```

### Example 3: Kubernetes Helm Chart Development

**The ask**: "Create production-ready Helm chart for our microservices"

**Day 1 (2 hours)**:

```
/crew:design Create Helm chart with ingress, HPA, PDB, and secrets management

[9 research agents launch simultaneously]
- repo-research-analyst examines existing Kubernetes configs
- best-practices-researcher queries Context7 for Helm 3 patterns
- scale-performance-analyst designs HPA thresholds
- security-threat-analyst reviews secrets handling
- integration-dependency-analyst maps service dependencies

[Codex synthesizes chart architecture]
[Plan review with DevOps team]
[Refinements: add support for multiple environments]
```

**Day 2 (3 hours)**:

```
/crew:build helm-chart --loop

[Loop iteration 1]
- Chart.yaml, values.yaml, values-prod.yaml, values-staging.yaml
- Base templates: deployment.yaml, service.yaml, configmap.yaml

[Loop iteration 2-3]
- Advanced templates: ingress.yaml, hpa.yaml, pdb.yaml
- Secrets management with external-secrets integration
- NOTES.txt with usage instructions

[Loop iteration 4]
- helm lint passes
- helm template renders correctly for all environments
- <promise>BUILD COMPLETE</promise>

[Context compacts 5 times - state persists perfectly]
```

**Day 3 (1 hour)**:

```
/crew:check
[7 review agents analyze all templates]
- Security reviewer catches missing networkPolicy
- Resilience reviewer suggests readiness probe improvements
- 3 P1 findings → converted to tasks

/crew:fix
[Issues resolved systematically]

[Manual helm install --dry-run verification]
[Staging deployment test]

/crew:git:pr
PR includes values diff for each environment
```

**Total developer time**: ~6 hours over 3 days
**Autonomous agent time**: ~4 hours
**Result**: Production-ready Helm chart with multi-environment support

---

## Quick Start

### Example: Building a New Feature

```bash
# 1. Start design phase - launches 9 research agents
/crew:design Add user authentication with OAuth2 support

# 2. Review and approve the generated plan
# Plan created at: .claude/plans/user-auth.md
# Tasks created at: .claude/branches/feat-user-auth/tasks/

# 3. Execute the build with loop mode
/crew:build user-auth --loop

# 4. Build runs autonomously:
#    - Executes tasks in batches
#    - Runs tests after each batch
#    - Creates fix tasks for failures
#    - Loops until <promise>BUILD COMPLETE</promise>

# 5. Review code quality
/crew:check

# 6. Address any P0/P1 findings
# Findings added as task files automatically

# 7. Create PR when ready
/crew:git:pr
```

### Example: Resuming After Compaction

```bash
# Context was compacted, session resumed
# Hook automatically outputs:

# CONTEXT: Session state recovered from compact
# ACTION REQUIRED: Found 3 pending tasks (1 P1, 2 P2)
#   Next: 020-pending-p1-us1-implement-api.md
#   **Resume with:** Skill(skill: "crew:build")

# Simply continue:
/crew:restart
```

### Example: Stacked PRs

```bash
# Create base feature branch
/crew:git:branch feat/base-feature

# Work on it, then create stacked branch
/crew:git:branch feat/dependent-feature
/crew:git:stack-add --onto feat/base-feature

# Create PRs with stack annotations
/crew:git:pr

# When base merges, update stack
/crew:git:slide-out feat/base-feature
```

---

## Self-Learning System

The most powerful aspect of the Agent Native Development Workflow isn't what it does - it's how it learns. The system continuously improves through automatic skill activation, immediate hook feedback, and persistent knowledge capture.

### The Compounding Knowledge Effect

Every plan documents design decisions that inform future plans. Every review finding becomes a task that prevents similar issues. Every successful pattern gets encoded in skills. Knowledge compounds over time, making the system more effective with every use.

The workflow includes automated self-improvement:

### Skill Triggers

Skills automatically activate based on context:

- Editing a `.sol` file → `devtools:solidity` skill loads
- Running `git commit` → suggests `/crew:git:commit`
- Test failures → relevant testing skill activates

### Hook Feedback

PostToolUse hooks provide immediate feedback:

- Lint errors surfaced instantly
- Style violations flagged
- Best practices suggested

### Knowledge Persistence

- Plans document design decisions
- Task work logs track implementation choices
- Review findings become learning opportunities

---

## Contributing

This workflow is actively developed. Contributions welcome:

1. Fork the [agent-marketplace repository](https://github.com/settlemint/agent-marketplace)
2. Create a feature branch
3. Use the workflow to build your contribution
4. Submit a PR with generated documentation

---

## License

MIT License - See [LICENSE](https://github.com/settlemint/agent-marketplace/blob/main/LICENSE)

---

_Built with the Agent Native Development Workflow by [SettleMint](https://settlemint.com)_
