---
name: crew:work
description: Execute plans perfectly using Ralph Loop for iterative completion
argument-hint: "[plan slug]"
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
  - crew:git
hooks:
  PostToolUse: false
  PreToolUse: false
---

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<objective>

Execute a plan perfectly using Ralph Loop for guaranteed completion. Parallelizes work, runs CI continuously, uses browser testing for UI, runs quality reviews, and writes all findings back to the plan for the loop to address.

</objective>

<workflow>

## Step 1: Load Plan

```javascript
const slug = "$ARGUMENTS".trim() || inferFromBranch();
const planPath = `.claude/plans/${slug}.yaml`;
const plan = Read({ file_path: planPath });
```

## Step 2: Validate Readiness

```javascript
if (plan.open_questions?.length > 0) {
  AskUserQuestion({
    questions: [
      {
        question: `Plan has ${plan.open_questions.length} open questions. Resolve first?`,
        header: "Questions",
        options: [
          { label: "Yes (Recommended)", description: "Run crew:plan:refine" },
          { label: "Continue anyway", description: "Proceed with unknowns" },
        ],
        multiSelect: false,
      },
    ],
  });
}
```

## Step 3: Start Ralph Loop

```javascript
Skill({
  skill: "ralph-loop:ralph-loop",
  args: `"Execute plan: ${slug}

## Plan Location
.claude/plans/${slug}.yaml

## Execution Loop

1. **Read Plan**: Load .claude/plans/${slug}.yaml
   - Check 'findings' section for issues to fix
   - Check story statuses (pending/in_progress/complete)

2. **Execute Stories** (parallel, max 6 agents):
   - P1 stories first, then P2, then P3
   - Use <pattern name='spawn-batch'/> for parallelism
   - Each agent: implement story, write tests
   - Update story status in plan on completion

3. **Run CI** (after each batch):
   Skill({ skill: 'crew:work:ci', args: '${slug}' })
   - Writes failures to plan 'findings' section
   - If failures: fix them before proceeding

4. **Browser Testing** (for UI stories):
   - Load MCPSearch for claude-in-chrome tools
   - Take screenshots to verify UI implementation
   - Test user flows described in acceptance criteria

5. **Quality Review** (after each phase):
   Skill({ skill: 'crew:work:review', args: '${slug}' })
   - Writes P0/P1/P2 findings to plan
   - Fix P0/P1 before proceeding

6. **Commit Progress**:
   - Conventional commits per story/fix
   - Push regularly

7. **Check Completion**:
   - All stories status: complete
   - No P0/P1 findings in plan
   - CI passing (no failures in findings)
   - Output: <promise>WORK COMPLETE</promise>

## Key Rules
- Read plan at START of each iteration (it may have new findings)
- Write ALL findings to plan (CI failures, review issues)
- Fix findings BEFORE adding new features
- Use browser tools for any UI work
- Only output completion promise when genuinely done
" --completion-promise "WORK COMPLETE" --max-iterations 50`,
});
```

</workflow>

<plan_findings_format>

The plan file gets a 'findings' section for the loop to track:

```yaml
findings:
  ci:
    - id: CI-001
      type: test
      status: open
      file: src/api/users.ts
      line: 45
      message: "Expected 200, got 404"
      added: "2024-01-09T14:30:00Z"
    - id: CI-002
      type: lint
      status: fixed
      file: src/utils/format.ts
      line: 12
      message: "Unused variable 'temp'"
      added: "2024-01-09T14:30:00Z"
      fixed: "2024-01-09T14:35:00Z"

  review:
    - id: REV-001
      severity: p0
      leg: security
      status: open
      file: src/auth/login.ts
      line: 47
      message: "SQL injection via username"
      fix: "Use parameterized query"
      added: "2024-01-09T14:32:00Z"
```

</plan_findings_format>

<browser_testing>

For UI stories, use Claude-in-Chrome MCP tools:

```javascript
// Load browser tools
MCPSearch({ query: "select:mcp__claude-in-chrome__navigate" });
MCPSearch({ query: "select:mcp__claude-in-chrome__browser_take_screenshot" });

// Navigate and verify
mcp__claude-in-chrome__navigate({ url: "http://localhost:3000/feature" });
mcp__claude-in-chrome__browser_take_screenshot({ name: "feature-initial" });

// Test acceptance criteria
mcp__claude-in-chrome__browser_click({ selector: "#submit-button" });
mcp__claude-in-chrome__browser_take_screenshot({ name: "feature-after-submit" });

// Read screenshots to verify
Read({ file_path: "/tmp/feature-after-submit.png" });
```

</browser_testing>

<success_criteria>

- [ ] Plan loaded and validated
- [ ] Ralph Loop started with completion promise
- [ ] Findings written to plan (not separate files)
- [ ] CI runs after each batch
- [ ] Browser testing for UI stories
- [ ] Reviews run after each phase
- [ ] All P0/P1 findings fixed before completion
- [ ] `<promise>WORK COMPLETE</promise>` output when done

</success_criteria>
