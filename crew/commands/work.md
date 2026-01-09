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
  - devtools:tdd-typescript
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

Execute a plan perfectly using Ralph Loop for guaranteed completion. **Strictly enforces TDD (Test-Driven Development)** - NO implementation code without failing tests first. Parallelizes work, runs CI continuously, uses browser testing for UI, runs quality reviews, and writes all findings back to the plan for the loop to address.

</objective>

<tdd_enforcement>

**MANDATORY: Load and follow `devtools:tdd-typescript` skill for ALL implementation.**

```javascript
Skill({ skill: "devtools:tdd-typescript" });
```

This is NON-NEGOTIABLE. Every story MUST:

1. Follow RED-GREEN-REFACTOR cycle exactly as defined in the skill
2. Pass all phase gates (test fails → test passes → still passes)
3. Meet coverage requirements (80% lines, 75% branches, 90% functions)

**No exceptions. No shortcuts. Test fails first, then implement.**

</tdd_enforcement>

<workflow>

## Step 0: Load TDD Skill (MANDATORY)

```javascript
// Force load TDD skill - this is non-negotiable
Skill({ skill: "devtools:tdd-typescript" });
```

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

## TDD ENFORCEMENT (MANDATORY)

**At start of EVERY iteration, load the TDD skill:**
Skill({ skill: 'devtools:tdd-typescript' })

Follow it EXACTLY. No implementation without failing test first. No exceptions.

## Execution Loop

1. **Read Plan**: Load .claude/plans/${slug}.yaml
   - Check 'findings' section for ALL issues to fix
   - Check story statuses (pending/in_progress/complete)

2. **Fix ALL Findings First**:
   - Fix EVERY issue in findings (P0, P1, P2, observations)
   - No new features until findings empty
   - Mark fixed issues as status: fixed

3. **Execute Stories via TDD**:
   - P1 stories first, then P2, then P3
   - For EACH story: Skill({ skill: 'devtools:tdd-typescript' }) then follow workflow
   - Update story status in plan on completion

4. **Run CI** (after each story):
   Skill({ skill: 'crew:work:ci', args: '${slug}' })
   - Writes failures to plan 'findings' section
   - If failures: fix ALL before proceeding

5. **Browser Testing** (for UI stories):
   - Load MCPSearch for claude-in-chrome tools
   - Take screenshots to verify UI implementation
   - Test user flows described in acceptance criteria

6. **Quality Review** (after each phase):
   Skill({ skill: 'crew:work:review', args: '${slug}' })
   - Writes ALL findings to plan (P0/P1/P2/Obs)
   - Fix ALL findings before proceeding

7. **Commit Progress**:
   - Conventional commits per story/fix
   - Push regularly

8. **Check Completion**:
   - All stories status: complete
   - ZERO findings in plan (all fixed)
   - CI passing (no failures)
   - Coverage meets requirements
   - Output: <promise>WORK COMPLETE</promise>

## Key Rules
- TDD per devtools:tdd-typescript - NO EXCEPTIONS
- Fix ALL findings before new features
- Read plan at START of each iteration
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

- [ ] devtools:tdd-typescript skill followed for ALL stories
- [ ] ALL findings fixed (P0, P1, P2, observations) - ZERO open
- [ ] CI passing with no failures
- [ ] Coverage requirements met per TDD skill
- [ ] Browser testing for UI stories
- [ ] `<promise>WORK COMPLETE</promise>` output when genuinely done

</success_criteria>
