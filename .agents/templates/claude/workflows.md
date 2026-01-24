## Development Workflow

Mandatory for implementation tasks. Creating any new file = implementation task. Only exception: pure research/exploration with no artifacts.

### Plan Mode Workflow

When `system-reminder` indicates "Plan mode is active", use this dedicated gate structure:

**PLAN-GATE-1: Understanding**
```
PLAN-GATE-1 CHECK:
- [ ] Classification stated (Trivial/Simple/Standard/Complex)
- [ ] User request understood
- [ ] Codebase exploration complete (mcp__octocode__* for code search, Explore agent for structure)
- [ ] Library docs checked (mcp__context7__* for external libs, local docs for project)
- [ ] Web research done if needed (mcp__exa__* for current info, code examples, company research)
STATUS: PASS | BLOCKED
```

**PLAN-GATE-2: Design**
```
PLAN-GATE-2 CHECK:
- [ ] Implementation approach documented
- [ ] Critical files identified
- [ ] Questions asked (via AskUserQuestion) if ambiguous
- [ ] Plan written to plan file
STATUS: PASS | BLOCKED
```

**After Plan Approval**: Regular workflow resumes at GATE-3 (Implementation phase).

**Plan Mode maps to workflow phases:**
- PLAN-GATE-1 → Phase 1 (Planning)
- PLAN-GATE-2 → Phase 2 (Plan Refinement)
- After approval → Phase 3+ (Implementation onwards)

---

**Enforcement**
- Each phase has a gate; output gate check (see Hard Requirements) before entering.
- Do not proceed if a gate is BLOCKED.
- Each gate checkbox requires proof in same message.

**Task Management (use Tasks tools when available, TodoWrite as fallback)**

Task Granularity:
- **Phase-level tasks:** Create one task per workflow phase (e.g., "Phase 1: Planning", "Phase 3: Implementation")
- **Work-item tasks:** Create sub-tasks for discrete work items within phases (e.g., "Update file X", "Add test for Y")
- **Dependencies:** Use `TaskUpdate({ addBlockedBy: [...] })` to establish ordering

Task Workflow:
```
1. TaskCreate({ subject: "...", description: "...", activeForm: "..." })
2. TaskUpdate({ taskId: "N", status: "in_progress" }) - before starting work
3. [Do the work]
4. TaskUpdate({ taskId: "N", status: "completed" }) - after finishing
5. TaskList - verify all tasks complete before claiming done
```

Multi-Session Collaboration:
- Set `CLAUDE_CODE_TASK_LIST_ID=<list-id>` environment variable to share tasks across sessions
- Example: `CLAUDE_CODE_TASK_LIST_ID=feature-auth claude` - all sessions share the same task list
- Works with `claude -p` and AgentSDK for subagent coordination
- When one session updates a task, changes are visible to all sessions on that list

**Sub-agents (use when 2+ independent tasks)**
- Format: `Task({ subagent_type: "<type>", prompt: "<task>" })`
- Multiple Task() in one message = parallel
- `run_in_background: true` for background agents
- Skills: `subagent-driven-development`, `dispatching-parallel-agents`
- **Agent naming:** Use `name` parameter for tracking (e.g., `name: "test-runner"`)
- **Team coordination:** Use `team_name` to group related agents
- **Permission modes:** Use `mode` parameter to control agent behavior:
  - `default` - standard permissions
  - `plan` - require plan approval before implementation
  - `acceptEdits` - auto-accept file edits
  - `bypassPermissions` - autonomous mode (use sparingly)
  - `delegate` - can spawn sub-agents
  - `dontAsk` - skip confirmation prompts

**Swarm launch from planning**
- After plan approval, use `ExitPlanMode({ launchSwarm: true, teammateCount: N })` to spawn implementation swarm
- Swarm distributes plan tasks across N parallel teammates

**Principles**
- Use latest package versions (@latest/:latest). Verify on npmjs.com, hub.docker.com, pypi.org. If pinned older, note current version.

### Phase 1: Planning
- **STOP: Output GATE-1 before proceeding.**
- Gather context (Explore Task for large codebases; direct tools for small).
- Repo-wide search if needed (mcp__octocode__* or local rg/git).
- Check docs (mcp__context7__* if available; else local docs/README).
- Web research if needed (mcp__exa__web_search_exa for current info, mcp__exa__get_code_context_exa for code examples).
- Company/competitor research (mcp__exa__company_research_exa, mcp__exa__linkedin_search_exa).
- Deep research for complex topics (mcp__exa__deep_researcher_start → mcp__exa__deep_researcher_check).
- If modifying existing behavior: `Skill({ skill: "systematic-debugging" })`.
- Draft plan with file paths and 2-5 minute tasks; mark parallelizable tasks.
- If complex/architectural: `mcp__codex` (Claude Code only).
- If Linear configured: find issue, then comment plan.

### Phase 2: Plan Refinement ⚠️ COMMONLY SKIPPED
- **STOP: Output GATE-2 before proceeding.**
- **REQUIRED:** `Skill({ skill: "ask-questions-if-underspecified" })` - actually invoke the tool.

**Local Mode (interactive):**
- **REQUIRED:** Use `AskUserQuestion` tool for questions - **NEVER plain text questions**.
- **REQUIRED:** Ask at least one clarifying question. No exceptions. "Requirements clear" is a banned phrase.

**Remote Mode (autonomous):**
- Assess ambiguity: Is the request genuinely unclear? (Score 1-10)
- If ambiguity ≤ 7: proceed with reasonable assumptions, document them in plan.
- If ambiguity > 7: ask focused questions via `AskUserQuestion` (max 2-3 questions).
- "Requirements clear" is allowed when genuinely clear.

**Both modes:**
- Even "simple ports" have ambiguity: error handling idioms, edge cases, output format, version compatibility.
- Review plan vs requirements; update.
- Deep review: `mcp__codex` (Claude Code) or manual (Codex).
- Each iteration must deepen: requirements clarity, edge cases, error handling, test strategy.
- **Iteration tracking:** Output "Plan Refinement Iteration N of M" for each pass.

**Questions to consider (ask via `AskUserQuestion` tool if needed):**
- Scope: What's included/excluded?
- Behavior: How should edge cases behave?
- Output: What format/structure is expected?
- Error handling: How should failures be handled?
- Testing: What test coverage is expected?
- Compatibility: Version constraints? Breaking changes?

### Phase 3: Implementation
- **STOP: Output GATE-3 before proceeding.**
- **REQUIRED:** Load skills via `Skill({ skill: "..." })` tool - not just mention them:
  - `Skill({ skill: "test-driven-development" })` - even for shell scripts, config files, "ports".
  - `Skill({ skill: "verification-before-completion" })` - load now, execute in Phase 7.
- **Self-check before proceeding:** Search context for `<invoke name="Skill">`. If not found, STOP.
- **Loading = Commitment:** Once you invoke a skill, you MUST follow its instructions. No exceptions.
- **Task tracking workflow:**
  1. `TaskCreate` for each work item (or `TodoWrite(in_progress)` fallback)
  2. `TaskUpdate({ status: "in_progress" })` before starting each task
  3. RED (failing test) -> GREEN (minimal code)
  4. `TaskUpdate({ status: "completed" })` after each task
- Iron Law: no production code before a failing test. No exceptions for "simple" file types.
- **REQUIRED:** If 2+ independent tasks exist, use parallel Task agents - not sequential Bash.
- **Parallel check:** Review task list (`TaskList`) - can any tasks run simultaneously? If yes, dispatch parallel agents.
- **Agent configuration:** Use `name` for tracking, `mode: "plan"` for risky changes, `mode: "bypassPermissions"` for trusted work.
- Load `dispatching-parallel-agents` skill when parallelization is possible.

### Phase 4: Cleanup
- **STOP: Output GATE-4 before proceeding.**
- `code-simplifier`, `claude-md-improver` (if CLAUDE.md needs maintenance), `deslop`, `knip`.
- For non-JS/TS files: note "cleanup skills N/A" but still output gate.

### Phase 5: Testing
- **STOP: Output GATE-5 before proceeding.**
- Run `bun run ci` or `bun run lint` + `bun run test`.
- If no project tests exist, note this explicitly.
- If UI: `agent-browser`, run visual checks.
- Check for silent failure gaps.
- **REQUIRED:** Show test output with exit code.

### Phase 6: Review ⚠️ COMMONLY SKIPPED
- **STOP: Output GATE-6 before proceeding.**
- **REQUIRED:** Run `Skill({ skill: "review" })` or `/review` - do not skip.
- **REQUIRED:** Show review output in gate.
- **"Manual review" is NOT acceptable** - must invoke the skill tool.
- Review for bugs/regressions/missing tests.
- Security review if auth/data/payments (semgrep/codeql).
- `differential-review` for diff security.
- "Code is simple, doesn't need review" is a banned phrase.
- **Iteration tracking:** Output "Review Iteration N of M" for each pass.

### Phase 7: Verification (iterations per classification)
- **STOP: Output GATE-7 before proceeding.**
- **REQUIRED:** Execute `Skill({ skill: "verification-before-completion" })` - not just load.
- **REQUIRED:** Show verification output in gate.
- **REQUIRED:** Run `TaskList` to verify all tasks are completed.
- Run completion validation.
- Document evidence (exit codes, test counts, warnings).
- Update README/docs if behavior changed.
- Update Linear issue if configured; otherwise note status in response.
- **Iteration tracking:** Output "Verification Iteration N of M" for each pass.

### Phase 8: CI Validation ⚠️ MANDATORY FINAL STEP
- **STOP: Output GATE-8 before claiming completion.**
- **REQUIRED:** Run CI commands in this priority:
  1. `bun run ci` (if available)
  2. `npm run ci` / `pnpm run ci` (if bun unavailable)
  3. Fallback: `bun run lint && bun run test && bun run build` (if no ci script)
- **REQUIRED:** Show full CI output with exit code 0 in gate.
- If no CI/lint/test/build scripts exist: document this explicitly in GATE-8.
- This phase runs AFTER Phase 7 verification - it is the absolute last check.
- **No completion claim without GATE-8 passing.**
- **GATE-DONE:** List all gates passed (1-8) + evidence + iteration counts + TaskList output before completion claim.
