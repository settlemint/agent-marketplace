# Subagent-Driven Development Workflow

Execute complex tasks through fresh subagents per task with two-stage Rule of Five review. This pattern prevents context pollution, ensures quality through independent review, and maintains task isolation.

## Quick Start

For multi-task implementations:

1. **Break work into tasks** - Each task = one subagent
2. **Spawn implementer** - Fresh subagent with task + self-review checklist
3. **Spec review** - 3-pass Rule of Five on requirements compliance
4. **Quality review** - 3-pass Rule of Five on code quality
5. **Mark complete** - Only when BOTH reviews converge

## Core Principle

**Fresh subagent per task.** Context pollution from previous tasks causes quality degradation. Each task gets a clean context.

```
Task 1 → Implementer₁ → Spec Reviewer₁ → Quality Reviewer₁ → ✓
Task 2 → Implementer₂ → Spec Reviewer₂ → Quality Reviewer₂ → ✓
Task 3 → Implementer₃ → Spec Reviewer₃ → Quality Reviewer₃ → ✓
```

## Two-Stage Review Pattern

### Stage 1: Spec Compliance Review

**Purpose:** Verify implementation matches requirements exactly.

**Skeptical reviewer:** Does NOT trust the implementer's report. Reads actual code.

**3-Pass Rule of Five:**

| Pass | Focus | Questions |
|------|-------|-----------|
| 1. Literal | Exact requirements | Does code do exactly what spec says? |
| 2. Intent | Spirit of requirements | Does it solve the actual problem? |
| 3. Edge cases | Boundary conditions | What happens at limits? |

**Spec reviewer prompt template:**

```markdown
You are a SPEC COMPLIANCE REVIEWER. Apply Rule of Five (3 passes).

CRITICAL: DO NOT trust the implementer's report. Read the actual code.

TASK REQUIREMENTS:
[Paste original task requirements]

IMPLEMENTER CLAIMED:
[Paste implementer's completion report]

YOUR JOB:
1. Read the actual code files (not just the report)
2. Compare line-by-line to requirements
3. Check for:
   - Missing requirements
   - Over-engineering (did more than asked)
   - Misunderstood requirements
   - Edge cases not handled

PASS 1 - LITERAL CHECK:
- Does code do exactly what spec says?
- Are all requirements addressed?

PASS 2 - INTENT CHECK:
- Does implementation solve the actual problem?
- Any requirement misinterpretation?

PASS 3 - EDGE CASE CHECK:
- Boundary conditions handled?
- Error cases covered?

OUTPUT FORMAT:
## Spec Compliance Review

### Pass 1: Literal - [PASS/FAIL]
- Findings: [specific issues or "No issues"]
- Evidence: [file:line references]

### Pass 2: Intent - [PASS/FAIL]
- Findings: [specific issues or "No issues"]
- Evidence: [file:line references]

### Pass 3: Edge Cases - [PASS/FAIL]
- Findings: [specific issues or "No issues"]
- Evidence: [file:line references]

### Verdict: [APPROVED / NEEDS FIXES]

If NEEDS FIXES, list specific changes required.
```

### Stage 2: Code Quality Review

**Purpose:** Ensure code meets quality standards.

**Only runs AFTER spec review passes.** No point reviewing quality of wrong code.

**3-Pass Rule of Five:**

| Pass | Focus | Questions |
|------|-------|-----------|
| 1. Style | Readability | Clear names? Consistent patterns? |
| 2. Patterns | Architecture | Right abstractions? Follows codebase conventions? |
| 3. Maintainability | Future-proofing | Easy to modify? Well-documented? |

**Quality reviewer prompt template:**

```markdown
You are a CODE QUALITY REVIEWER. Apply Rule of Five (3 passes).

CONTEXT: This implementation has already passed spec compliance review.
Your job is quality, not correctness.

FILES TO REVIEW:
[List of files modified]

CODEBASE PATTERNS:
Load: Skill({ skill: "devtools:code-health" })

PASS 1 - STYLE:
- Clear, descriptive names?
- Consistent with codebase style?
- No magic numbers or strings?
- Appropriate comments (not too many, not too few)?

PASS 2 - PATTERNS:
- Right level of abstraction?
- Follows existing codebase patterns?
- No unnecessary complexity?
- DRY (Don't Repeat Yourself)?

PASS 3 - MAINTAINABILITY:
- Easy to modify later?
- Clear error messages?
- Testable design?
- No hidden dependencies?

OUTPUT FORMAT:
## Code Quality Review

### Pass 1: Style - [PASS/CONCERNS]
- Findings: [specific issues or "No issues"]
- Evidence: [file:line references]

### Pass 2: Patterns - [PASS/CONCERNS]
- Findings: [specific issues or "No issues"]
- Evidence: [file:line references]

### Pass 3: Maintainability - [PASS/CONCERNS]
- Findings: [specific issues or "No issues"]
- Evidence: [file:line references]

### Verdict: [APPROVED / SUGGESTIONS]

If SUGGESTIONS, prioritize as:
- P1: Must fix before merge
- P2: Should fix, not blocking
- P3: Nice to have
```

## Implementer Self-Review Checklist

Before reporting completion, implementers MUST self-review:

```markdown
## Self-Review Checklist (Complete BEFORE reporting)

### Completeness
- [ ] All requirements addressed (re-read the task)
- [ ] No TODO comments left behind
- [ ] No placeholder code

### Quality
- [ ] Names are clear and descriptive
- [ ] No obvious simplifications missed
- [ ] Follows existing codebase patterns

### Discipline
- [ ] YAGNI: No extra features added
- [ ] TDD: Tests written first (if applicable)
- [ ] No "while I'm here" scope creep

### Testing
- [ ] Tests exist for new functionality
- [ ] Tests verify actual behavior (not implementation)
- [ ] Edge cases covered

### Evidence
- [ ] Can demonstrate feature works
- [ ] Test output captured
- [ ] No failing tests
```

## Full Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ ORCHESTRATOR: Plan tasks, maintain TodoWrite                │
└─────────────────────────┬───────────────────────────────────┘
                          │
         ┌────────────────┴────────────────┐
         │        For each task:           │
         │                                 │
         ▼                                 │
┌─────────────────────────────────────┐    │
│ 1. SPAWN IMPLEMENTER (fresh context)│    │
│    - Full task description          │    │
│    - Self-review checklist          │    │
│    - TDD requirement                │    │
└─────────────────┬───────────────────┘    │
                  │                        │
                  ▼                        │
┌─────────────────────────────────────┐    │
│ 2. IMPLEMENTER WORKS                │    │
│    - Asks questions if unclear      │    │
│    - Follows TDD                    │    │
│    - Completes self-review          │    │
│    - Reports completion             │    │
└─────────────────┬───────────────────┘    │
                  │                        │
                  ▼                        │
┌─────────────────────────────────────┐    │
│ 3. SPAWN SPEC REVIEWER              │    │
│    - Task requirements              │    │
│    - Implementer report             │    │
│    - "DO NOT TRUST THE REPORT"      │    │
└─────────────────┬───────────────────┘    │
                  │                        │
                  ▼                        │
         ┌───────┴───────┐                 │
         │ Spec Review   │                 │
         │    PASS?      │                 │
         └───────┬───────┘                 │
          NO     │     YES                 │
          │      │      │                  │
          ▼      │      ▼                  │
┌─────────────┐  │  ┌─────────────────────┐│
│Implementer  │  │  │ 4. SPAWN QUALITY    ││
│fixes issues │  │  │    REVIEWER         ││
│(same agent) │  │  │    - Files modified ││
└──────┬──────┘  │  │    - Codebase style ││
       │         │  └──────────┬──────────┘│
       └─────────┘             │           │
                               ▼           │
                      ┌────────┴───────┐   │
                      │ Quality Review │   │
                      │     PASS?      │   │
                      └────────┬───────┘   │
                       NO      │    YES    │
                       │       │     │     │
                       ▼       │     ▼     │
              ┌─────────────┐  │  ┌────────┴──────────┐
              │Implementer  │  │  │ 5. MARK COMPLETE  │
              │addresses    │  │  │    - Update todo  │
              │suggestions  │  │  │    - Next task    │
              └──────┬──────┘  │  └───────────────────┘
                     │         │           │
                     └─────────┘           │
                                           │
         └─────────────────────────────────┘
```

## TodoWrite Integration

Orchestrator maintains task list across subagent invocations:

```javascript
// At start of workflow
TodoWrite({
  todos: [
    { content: "Task 1: Create user model", status: "pending", activeForm: "Creating user model" },
    { content: "Task 2: Add auth service", status: "pending", activeForm: "Adding auth service" },
    { content: "Task 3: Create API routes", status: "pending", activeForm: "Creating API routes" }
  ]
})

// Before spawning implementer
TodoWrite({
  todos: [
    { content: "Task 1: Create user model", status: "in_progress", activeForm: "Creating user model" },
    // ... rest unchanged
  ]
})

// After BOTH reviews pass
TodoWrite({
  todos: [
    { content: "Task 1: Create user model", status: "completed", activeForm: "Creating user model" },
    { content: "Task 2: Add auth service", status: "in_progress", activeForm: "Adding auth service" },
    // ... rest
  ]
})
```

**Rule:** Only mark task complete when BOTH spec and quality reviews pass.

## Security Guardrails

### Treat Subagent Outputs as Untrusted

Subagents may hallucinate completion or misunderstand requirements.

**Verification requirements:**
- Spec reviewer MUST read actual code, not trust report
- Quality reviewer MUST verify patterns against codebase
- Orchestrator MUST run tests before marking complete

### Least-Privilege Tool Scopes

Subagents should only have tools needed for their role:

| Role | Tools Allowed | Tools Denied |
|------|---------------|--------------|
| Implementer | Read, Write, Edit, Bash, Glob, Grep | Task (no sub-subagents) |
| Spec Reviewer | Read, Glob, Grep | Write, Edit, Bash |
| Quality Reviewer | Read, Glob, Grep | Write, Edit, Bash |

### Secret Redaction

Before spawning subagents, ensure context doesn't include:
- API keys or tokens
- Database credentials
- Private keys
- Environment secrets

**Pattern:**

```javascript
// Safe context preparation
const taskContext = sanitizeContext(originalContext, {
  redact: [".env", "credentials", "secrets", "tokens"]
});
```

## When to Use This Pattern

**Use subagent-driven development for:**
- Multi-file changes (3+ files)
- Complex features with multiple components
- Quality-critical implementations
- Tasks that would benefit from fresh perspective review

**Don't use for:**
- Single-file changes
- Simple bug fixes
- Documentation updates
- Trivial refactors

## Success Criteria

- [ ] Each task has dedicated implementer subagent (fresh context)
- [ ] Spec review completes 3 passes (literal, intent, edge cases)
- [ ] Quality review completes 3 passes (style, patterns, maintainability)
- [ ] Both reviews pass before task marked complete
- [ ] TodoWrite reflects accurate task status throughout
- [ ] Security guardrails applied (untrusted outputs, least-privilege)

## Anti-Patterns

- **Reusing implementer context** - Polluted context degrades quality
- **Trusting implementer reports** - Always read actual code
- **Skipping quality review** - Even "correct" code can be unmaintainable
- **Parallel reviews** - Quality review needs spec review to pass first
- **Marking complete early** - Wait for both reviews to converge

## References

- Superpowers plugin: subagent-driven-development skill
- Rule of Five: 5-pass convergence pattern
- Two-stage review: spec compliance + code quality separation
