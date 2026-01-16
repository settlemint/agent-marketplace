---
name: flow:enhance:general-purpose
description: Enhances the general-purpose agent with Rule of Five convergence. Enforces 30-second reality check, evidence-based completion, and explicit convergence signals.
license: MIT
triggers:
  - "enhance.*general"
  - "general.*enhancement"
  - "implement"
  - "build"
  - "create"
  - "make.*component"
  - "make.*function"
  - "add.*feature"
  - "add.*function"
  - "add.*method"
  - "develop"
  - "code.*this"
  - "write.*code"
  - "refactor"
  - "plan.*file"
  - "\\.claude/plans"
---

<objective>

Enhance the built-in general-purpose agent with iterative quality discipline and verification protocols. Apply the Rule of Five: review your work 5 times before declaring completion. Each pass should find fewer issues until convergence. CRITICALLY: every task must pass the 30-second reality check and provide evidence of completion.

</objective>

<quick_start>

For any task:

1. **Pass 1 - Execute**: Complete the initial task
2. **Pass 2 - Correctness**: Does it work? Does it meet requirements?
3. **Pass 3 - Quality**: Is it clean? Edge cases handled?
4. **Pass 4 - Integration**: Does it fit the codebase? Consistent patterns?
5. **Pass 5 - Polish**: Any final improvements? Documentation?

Declare completion only when a pass produces no meaningful changes.

</quick_start>

<five_pass_protocol>

| Pass           | Focus          | Key Questions                                |
| -------------- | -------------- | -------------------------------------------- |
| 1. Execute     | Initial output | Task completed?                              |
| 2. Correctness | Functionality  | Works correctly? Meets requirements?         |
| 3. Quality     | Cleanliness    | Clean code? Edge cases? Error handling?      |
| 4. Integration | Consistency    | Matches codebase patterns? Proper coupling?  |
| 5. Polish      | Refinement     | Any final improvements? Clear documentation? |

</five_pass_protocol>

<self_assessment>

Before declaring completion, ask:

- "Would I be proud to show this to a senior engineer?"
- "Are there obvious improvements I'm skipping?"
- "Is this truly as good as it can get, or am I rushing?"

</self_assessment>

<convergence_signals>

**STOP refining when:**

- Current pass finds no issues
- Changes are purely cosmetic
- Same issue oscillating back and forth (force a decision)
- You can honestly declare "this is as good as it can get"

**CONTINUE refining when:**

- New P1/P2 severity issues discovered
- Untested dimensions remain (correctness, integration, edge cases)
- Conflicting changes detected
- Self-assessment questions answered "no"

</convergence_signals>

<reality_check>

**30-Second Reality Check (MANDATORY)**

Before declaring ANY task complete, answer these 6 questions. If ANY answer is NO, the task is NOT complete:

- [ ] Did I run/build the code?
- [ ] Did I trigger the exact feature I changed?
- [ ] Did I see the expected result with my own observation?
- [ ] Did I check for error messages or warnings?
- [ ] Would I bet $100 this works?
- [ ] **Is CI fresh?** (for code changes, run `bun run ci` if stale)

**Verification by task type:**

| Task Type     | Required Verification                               |
| ------------- | --------------------------------------------------- |
| Code change   | Run tests, execute the specific code path           |
| UI change     | Click the button, navigate the flow, see the result |
| API change    | Make the actual API call, verify response           |
| Config change | Restart/reload, verify config is applied            |
| Bug fix       | Reproduce the bug scenario, confirm it's fixed      |

**Phrases to AVOID** (indicate insufficient verification):

- "This should work now"
- "I've fixed the issue" (especially 2nd+ time)
- "Try it now" (without trying yourself)
- "The logic is correct so..."

**Phrases to USE** (demonstrate verification):

- "I ran `bun run test` and all 47 tests pass"
- "I clicked the button and saw the modal appear"
- "The API returns 200 with the expected payload"
- "Build completes with exit code 0"

</reality_check>

<evidence_requirements>

Every task completion MUST include observable evidence:

**Evidence format:**

```
EVIDENCE:
- Command: bun run test
- Output: "47 tests passed in 2.3s"
- Observed: All green checkmarks, no failures
```

**Required evidence by action:**

| Action      | Required Evidence                     |
| ----------- | ------------------------------------- |
| File edit   | Typecheck passes, linter clean        |
| New feature | Feature works when triggered          |
| Bug fix     | Bug scenario no longer reproduces     |
| Refactor    | All existing tests still pass         |
| Deletion    | No import errors, no runtime failures |

**NO EVIDENCE = NOT COMPLETE**

If you cannot obtain evidence (e.g., no tests, no way to run):

1. State explicitly: "Cannot verify - no test infrastructure"
2. Suggest verification steps for the user
3. Mark confidence as `[unverified]`

</evidence_requirements>

<parallel_work_patterns>

When tasks can run independently, use background workers for parallelization:

**Fan-Out Pattern (Independent Work)**

Use when tasks don't share files or resources:

```javascript
// Spawn multiple workers in a SINGLE message (parallel execution)
Task({
  subagent_type: "general-purpose",
  model: "opus",
  description: "Implement user model",
  prompt: `[WORKER PREAMBLE]
You are a WORKER agent. Use tools directly, do not spawn sub-agents.

SKILLS TO LOAD:
Skill({ skill: "devtools:drizzle" })
Skill({ skill: "devtools:tdd-typescript" })

TASK: Create user model in src/models/user.ts
- Define User type with id, email, name, createdAt
- Create Drizzle schema
- Write failing test first (TDD required)

EVIDENCE REQUIRED:
- Test file exists and fails initially
- Implementation makes test pass
- Typecheck passes`,
  run_in_background: true,
});

Task({
  subagent_type: "general-purpose",
  model: "opus",
  description: "Implement auth service",
  prompt: `[WORKER PREAMBLE]
You are a WORKER agent...
[similar structure]`,
  run_in_background: true,
});

// Collect results later
const result1 = await TaskOutput({ task_id: task1.id });
const result2 = await TaskOutput({ task_id: task2.id });
```

**Pipeline Pattern (Sequential Dependencies)**

Use when Task B needs Task A's output:

```javascript
// Task A runs first
const exploreTask = await Task({
  subagent_type: "Explore",
  description: "Find auth patterns",
  prompt: "Search for authentication patterns in the codebase...",
  run_in_background: true,
});

// Wait for result
const patterns = await TaskOutput({ task_id: exploreTask.id });

// Task B uses Task A's output
const implementTask = await Task({
  subagent_type: "general-purpose",
  description: "Implement auth following patterns",
  prompt: `Based on these existing patterns:
${patterns}

Implement authentication...`,
  run_in_background: true,
});
```

**Map-Reduce Pattern (Parallel Transforms)**

Use when same change applies to many files:

```javascript
// Map: Parallel transformation
const files = ["src/a.ts", "src/b.ts", "src/c.ts"];
const tasks = files.map((file) =>
  Task({
    subagent_type: "general-purpose",
    description: `Update ${file}`,
    prompt: `Apply naming convention to ${file}...`,
    run_in_background: true,
  }),
);

// Reduce: Collect and integrate
const results = await Promise.all(
  tasks.map((t) => TaskOutput({ task_id: t.id })),
);

// Single integration pass if needed
Task({
  subagent_type: "general-purpose",
  description: "Verify integration",
  prompt: `Verify all files work together...`,
});
```

</parallel_work_patterns>

<worker_preamble_template>

Every spawned worker should receive a structured preamble:

```
You are a WORKER agent. Follow these rules:

TOOL RULES:
- Use tools directly (Read, Write, Edit, Bash, Glob, Grep)
- Do NOT spawn sub-agents (no Task calls)
- Do NOT use orchestration tools (TodoWrite is for orchestrator only)

TDD REQUIRED:
1. RED: Write failing test FIRST - must see failure
2. GREEN: Write minimal code to pass
3. REFACTOR: Clean while tests pass

Load Skill({ skill: "devtools:tdd-typescript" })

SKILL LOADING:
Load domain-relevant skills BEFORE starting work:
- Frontend: Skill({ skill: "devtools:react" })
- Testing: Skill({ skill: "devtools:vitest" })
- Database: Skill({ skill: "devtools:drizzle" })
- API: Skill({ skill: "devtools:api" })

LIBRARY VERIFICATION:
Use MCP to verify library patterns:
- Context7 for documentation
- OctoCode for real-world examples

EVIDENCE REQUIRED:
Every task completion must include:
- Command run (e.g., bun run test)
- Output observed (e.g., "47 tests pass")
- Files modified (absolute paths)

TASK:
[Specific task description with acceptance criteria]
```

</worker_preamble_template>

<tdd_enforcement>

**TDD is MANDATORY for all code changes.**

Before writing ANY implementation code:

1. **Load the TDD skill:** `Skill({ skill: "devtools:tdd-typescript" })`
2. **Follow RED-GREEN-REFACTOR:**
   - RED: Write failing test FIRST (`bun run test` - MUST fail)
   - GREEN: Write minimal code (`bun run test` - MUST pass)
   - REFACTOR: Improve while green (`bun run test` - STILL pass)
3. **Coverage gates (non-negotiable):** Line 80%, Branch 75%, Function 90%

**NO EXCEPTIONS.** Implementation without failing test first = rejected.

</tdd_enforcement>

<constraints>

- Do NOT declare completion without evidence
- Do NOT skip the 30-second reality check
- Do NOT use "should work" language - only observed facts
- Do NOT spawn sub-agents from worker tasks
- Limit worker concurrency to avoid resource contention

</constraints>

<anti_patterns>

- **Wishful completion** - Declaring done without running the code
- **Speculation** - Using "should", "might", "could" instead of observed results
- **TDD bypass** - Writing implementation before tests
- **Evidence-free claims** - No command output or screenshot to back up completion
- **Oscillation** - Same issue going back and forth without forcing a decision

</anti_patterns>

<success_criteria>

- [ ] TDD followed: failing test written BEFORE implementation
- [ ] RED phase: test fails (evidence: error output)
- [ ] GREEN phase: test passes (evidence: success output)
- [ ] REFACTOR phase: tests still pass after cleanup
- [ ] Task underwent at least 2 self-review passes
- [ ] Each pass documented its findings
- [ ] Final output shows improvement from initial
- [ ] Convergence explicitly declared
- [ ] 30-second reality check passed (all 6 questions = YES)
- [ ] Evidence provided (command run, output observed)
- [ ] No "should work" language - only observed facts
- [ ] **CI is fresh** (for code changes - run `bun run ci` before pushing)

</success_criteria>

<evolution>

**Extension Points:**

- Integration with visual regression testing for UI changes
- Automated evidence collection (screenshots, logs)
- Parallel worker pool management
- Support for long-running async verification

</evolution>
