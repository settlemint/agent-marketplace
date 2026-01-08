---
name: crew:build
description: Execute work plans with iteration loops and progress tracking
argument-hint: "[plan] [--loop] [--max-iterations N]"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite, WebFetch, WebSearch, MCPSearch, Skill
skills:
  - crew:crew-patterns
  - crew:todo-tracking
  - crew:git
hooks:
  Stop:
    - type: command
      command: "${CLAUDE_PLUGIN_ROOT}/scripts/hooks/stop/check-loop.sh"
  PreToolUse:
    - matcher: Bash
      type: command
      command: "${CLAUDE_PLUGIN_ROOT}/scripts/hooks/pre-tool/wrap-long-output.sh"
---

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<prerequisite>

**Load patterns skill first:**

```javascript
Skill({ skill: "crew:crew-patterns" });
```

This provides: `<pattern name="test-runner"/>`, `<pattern name="spawn-batch"/>`, `<pattern name="collect-results"/>`, `<pattern name="todo-progress"/>`, `<pattern name="task-file"/>`, `<pattern name="quality-agents"/>`, `<pattern name="branch-state"/>`.

</prerequisite>

<critical_rules>

**NEVER use Bash for CI commands.** These are BLOCKED by PreToolUse hook:

- `bun run test`, `vitest`, `jest`, `eslint`, `prettier`, `biome`, `ultracite`

**ALWAYS use** `<pattern name="test-runner"/>` from crew-patterns skill.

</critical_rules>

<build_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/workflow/build-context.sh`
</build_context>

<input>
<work_document>$ARGUMENTS</work_document>
</input>

<constraints>

- **Max 6 agents** concurrent (NEVER exceed, NEVER launch while waiting)
- **Agents inherit parent model** (opus/sonnet) - only test-runner uses haiku
- **Agents do NOT run tests** - test-runner agent handles this
- **Output format mandatory**: Agents must output `SUCCESS: <summary>` or `FAILURE: <reason>`
- **Update immediately**: Mark tasks complete as agents finish, commit each task
- **Collect ALL before next batch**: Wait for entire batch before launching more

</constraints>

<loop_mode>

Enabled with `--loop` flag. Stop hook re-feeds prompt until completion.

**State file**: `.claude/branches/{slugified-branch}/state.json`
See `<pattern name="branch-state"/>` for format.

**Completion criteria** (ALL required):

- All task files renamed `*-pending-*` → `*-complete-*`
- `bun run ci` passes
- `bun run test:integration` passes
- Output: `<promise>BUILD COMPLETE</promise>`

**Cancel**: `/crew:cancel-loop "reason"`

</loop_mode>

<process>

<phase name="init-loop">
If `--loop` flag present:

```javascript
const stateFile = `.claude/branches/${slugBranch}/state.json`;
// Check existing state for resume
// If new: initialize loop state with iteration=1
// If resuming: log iteration number, check task files for progress
```

</phase>

<phase name="load-work">
```javascript
Read({ file_path: ".claude/plans/${planSlug}.md" });
// If not found: AskUserQuestion for plan selection
```
Use `<pattern name="todo-progress"/>` to track.
</phase>

<phase name="branch-setup">
```javascript
const branch = Bash({ command: "git branch --show-current" }).trim();
if (branch === "main" || branch === "master") {
  // AskUserQuestion: feature branch or stacked branch
  Bash({ command: `git checkout -b feat/${planSlug}` });
}
// If stacked: git machete add --onto <parent>
```
</phase>

<phase name="load-tasks">
```javascript
const slugBranch = branch.replace(/\//g, "-");
const taskFiles = Glob({ pattern: `.claude/branches/${slugBranch}/tasks/*.md` });
// Group by: phase (setup/found/us1/us2/polish), parallel capability, status
// Create execution plan: parallel tasks in batches of max 6
```
</phase>

<phase name="batch-execution">
For each batch of parallel tasks (max 6):

1. **Launch batch** using `<pattern name="spawn-batch"/>` - ALL in single message
2. **Collect results** using `<pattern name="collect-results"/>`
3. **Update task files**: rename `*-pending-*` → `*-complete-*`, update frontmatter
4. **Commit each task**:
   ```bash
   git add . && git commit -m "feat(${scope}): ${title}"
   ```
5. **Run test-runner** using `<pattern name="test-runner"/>`
6. **Handle failures**: Create fix task files for next iteration

Batch order: setup → found → us1 → us2 → polish
</phase>

<phase name="quality-checks">
Launch quality agents using `<pattern name="quality-agents"/>`.

```javascript
// Collect results, triage by severity (P0/P1/P2)
// Add P0/P1 findings as new task files in current branch
```

</phase>

<phase name="final-validation">
**MANDATORY: Fix ALL issues, even unrelated ones.**

Use the Bash subagent for final validation (runs in separate context, no output pollution):

```javascript
Task({
  subagent_type: "Bash",
  prompt: `Run final validation and report results:

1. Run CI: bun run ci
2. Run integration tests: bun run test:integration
3. Report:
   - If both pass: "VALIDATION PASSED"
   - If failures: List each error with file:line

The Bash subagent handles large output in its own context.`,
  description: "final-validation",
  run_in_background: false,
});
```

Loop until BOTH pass with zero errors.
</phase>

<phase name="completion">
```javascript
const pending = Glob({ pattern: `.claude/branches/${slugBranch}/tasks/*-pending-*.md` });

if (pending.length === 0 && ciPassing && integrationPassing) {
// Clear loop state if active
// Output completion
console.log("<promise>BUILD COMPLETE</promise>");
} else {
// Log remaining tasks
// If loop mode: /compact then Stop hook re-feeds
}

```
</phase>

</process>

<task_prompt_template>

Agent prompts must follow this format:

```

TASK: ${id} - ${title}
FILE: ${file_path}
ACCEPTANCE: ${criteria}
CONSTRAINTS:

- Do NOT run tests (test-runner handles this)
- Stop after implementing
  OUTPUT: "SUCCESS: <summary>" or "FAILURE: <reason>"

```

</task_prompt_template>

<success_criteria>

**Core execution:**
- [ ] TodoWrite updated after EVERY task
- [ ] Max 6 agents concurrent (NEVER exceeded)
- [ ] All agents in batch launched in SINGLE message
- [ ] Task files renamed immediately on completion
- [ ] Granular commit per task
- [ ] `bun run ci` passes
- [ ] `bun run test:integration` passes

**Loop mode (if enabled):**
- [ ] State file updated each iteration
- [ ] `/compact` before next iteration
- [ ] `<promise>BUILD COMPLETE</promise>` only when ALL criteria met

</success_criteria>
```
