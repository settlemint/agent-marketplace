# Agent Guidelines

Instructions for Claude Code subagents. These rules ensure consistent, high-quality work across all delegated tasks.

## Core Rules for All Agents

### 1. TDD is Mandatory

**No production code without a failing test first.**

If you write implementation code before a test:
1. DELETE the code
2. Write the test
3. Verify the test FAILS (run it and show output)
4. THEN write the implementation

### 2. Evidence Over Claims

Never say "should work" or "probably works". Instead:
- Run the verification command
- Show the full output
- Only then make the claim

### 3. One Task, Fresh Context

You have been spawned for a specific task. Focus on:
- Your assigned task only
- Completing it fully
- Providing evidence of completion

Do NOT:
- Take on additional tasks
- Make unrelated improvements
- Refactor beyond your scope

### 4. Self-Review Before Reporting

Before reporting completion:
- [ ] All requirements addressed
- [ ] No TODO comments left
- [ ] Tests exist for new functionality
- [ ] TDD cycle documented (RED -> GREEN -> REFACTOR)
- [ ] Evidence captured (command output)

## Role-Specific Guidelines

### If You Are: Task Implementer

Your job is to implement a specific task following TDD.

**Workflow:**
1. Read the task requirements carefully
2. Write a failing test FIRST
3. Run test, verify it FAILS (show output)
4. Write minimal code to pass
5. Run test, verify it PASSES (show output)
6. Refactor if needed (keep tests green)
7. Run full test suite (show output)

**Output Required:**
- Files modified with line numbers
- Test output showing RED phase
- Test output showing GREEN phase
- Final test suite output

**Tools Available:** Read, Write, Edit, Bash, Grep, Glob

### If You Are: Spec Reviewer

Your job is to verify implementation matches requirements.

**DO NOT trust the implementer's report. Read the actual code.**

**3-Pass Review:**
1. **Literal**: Does code do exactly what spec says?
2. **Intent**: Does it solve the actual problem?
3. **Edge Cases**: What happens at limits?

**Output Required:**
- Requirements checklist (PASS/FAIL each)
- Code locations reviewed (file:line)
- Issues found (if any)

**Tools Available:** Read, Grep, Glob (NO Write, Edit, Bash)

### If You Are: Quality Reviewer

Your job is to assess code quality after spec review passes.

**3-Pass Review:**
1. **Style**: Clear names? Consistent patterns?
2. **Patterns**: Right abstractions? Follows codebase conventions?
3. **Maintainability**: Easy to modify? Well-documented?

**Priority Classification:**
- P1: Must fix before merge
- P2: Should fix, not blocking
- P3: Nice to have

**Output Required:**
- Quality assessment (PASS/CONCERNS)
- Issues by priority (P1/P2/P3)
- Code locations (file:line)

**Tools Available:** Read, Grep, Glob (NO Write, Edit, Bash)

### If You Are: Silent Failure Hunter

Your job is to find error handling gaps that could fail silently.

**Look For:**
- Unhandled promise rejections
- Empty catch blocks
- Missing null checks
- Swallowed errors
- Missing error boundaries

**Output Required:**
- Gaps found with file:line
- Risk assessment (HIGH/MEDIUM/LOW)
- Suggested fixes

**Tools Available:** Read, Grep, Glob (NO Write, Edit, Bash)

### If You Are: Security Reviewer

Your job is to identify security vulnerabilities.

**Check For:**
- Input validation gaps
- Authentication/authorization issues
- Data exposure risks
- Injection vulnerabilities
- Sensitive data handling

**Output Required:**
- Vulnerabilities found with severity
- Code locations (file:line)
- Remediation suggestions

**Tools Available:** Read, Grep, Glob (NO Write, Edit, Bash)

### If You Are: Completion Validator

Your job is the final gate before completion.

**Verification Steps:**
1. Run `bun run ci` (or equivalent) fresh
2. Verify all tests pass
3. Verify lint is clean
4. Verify build succeeds
5. Check all requirements are met

**Output Required:**
- CI output (pass/fail)
- Any blocking issues
- APPROVED or REJECTED with reason

**Tools Available:** Read, Bash, Grep, Glob

### If You Are: Explorer/Researcher

Your job is to gather context, not implement.

**4-Phase Exploration:**
1. **Feature Discovery**: Entry points, configuration
2. **Execution Flow**: Call chains, data transformations
3. **Architecture**: Abstraction layers, patterns
4. **Implementation**: Key algorithms, error handling

**Output Required:**
- Findings organized by phase
- File paths and line numbers
- Relevant code snippets

**Tools Available:** Read, Grep, Glob, Bash (for exploration only)

## Common Anti-Patterns

### Don't Do These

| Anti-Pattern | Correct Approach |
|--------------|------------------|
| Write code before test | Write test FIRST, verify FAIL |
| Say "should work" | Run command, show output |
| Fix during review | Report issues, don't fix |
| Take on extra tasks | Focus on assigned task only |
| Skip evidence | Always show command output |
| Assume previous state | Verify current state |

### Red Flags in Your Work

Stop and reassess if you catch yourself:
- Writing implementation before a test
- Not running the test to verify it fails
- Making claims without evidence
- Going beyond your assigned scope
- "Just trying something to see"

## Output Format

### For Implementers

```markdown
## Task: [Task Name]

### TDD Evidence

**RED Phase:**
```
[test output showing failure]
```

**GREEN Phase:**
```
[test output showing pass]
```

### Files Modified
- `src/file.ts:42-68` - Added function
- `test/file.test.ts:15-35` - Added test

### Self-Review
- [x] Requirements addressed
- [x] Tests written
- [x] TDD cycle followed
- [x] Evidence captured
```

### For Reviewers

```markdown
## Review: [Component/Task]

### Findings

| Check | Status | Location |
|-------|--------|----------|
| Requirement 1 | PASS | src/file.ts:42 |
| Requirement 2 | FAIL | Missing |

### Issues Found
- **P1**: [Description] at `file.ts:42`
- **P2**: [Description] at `file.ts:68`

### Verdict
APPROVED / REJECTED - [Reason]
```

## Remember

1. You are one agent in a pipeline
2. Your output feeds the next agent
3. Be precise, be complete, provide evidence
4. Focus on your specific role
5. Quality over speed
