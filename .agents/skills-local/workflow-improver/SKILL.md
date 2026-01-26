---
name: workflow-improver
description: Evaluate session using OpenAI eval-skills framework (Outcome/Process/Style/Efficiency). Analyzes session transcript vs Claude Code config to score performance and generate improvement recommendations. Creates GitHub issue with rubric scores and actionable plan.
context: fork
agent: general-purpose
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(gh:*)
---

# Workflow Improver

Analyze the current session transcript alongside Claude Code configuration to compare what was intended versus what actually happened. Generate improvement recommendations and create a GitHub issue.

## Session Discovery

Claude Code stores session transcripts at:
```
~/.claude/projects/{project-path-encoded}/{session-id}.jsonl
```

**Find the current session:**
```bash
# Project path encoded (replace / with -)
!`pwd | tr '/' '-' | sed 's/^-//'`

# Find session directory
!`ls -t ~/.claude/projects/ | head -20`

# Current session ID
${CLAUDE_SESSION_ID}
```

**Read the session transcript:**
Use the Read tool to read: `~/.claude/projects/!`pwd | tr '/' '-' | sed 's/^-//'`/${CLAUDE_SESSION_ID}.jsonl`

## Analysis Framework (OpenAI Eval-Skills)

### 1. Outcome Goals (Task Completion)

Analyze the transcript for:
- **User requests**: What did the user ask for?
- **Final artifacts**: What was produced?
- **Completion status**: Was the task fully completed?

**Checklist:**
- [ ] User's primary request fulfilled
- [ ] All acceptance criteria met
- [ ] No partial implementations left

### 2. Process Goals (Correct Steps)

Analyze the transcript for:
- **Skill loading**: Were skills loaded? At the right time?
- **Gate compliance**: Were all gates passed? Any skipped?
- **Tool selection**: Were the right tools used?

**Checklist:**
- [ ] Required skills loaded (TDD, verification, etc.)
- [ ] All gates output with proofs
- [ ] Tools used appropriately (no grep when Grep tool available, etc.)
- [ ] Task management used for multi-step work

### 3. Style Goals (Convention Conformance)

Analyze the transcript for:
- **Iteration quality**: Were iterations meaningful or boilerplate?
- **Output format**: Did responses follow required formats?
- **Documentation**: Were changes properly documented?

**Checklist:**
- [ ] Gate outputs follow required format
- [ ] Iteration counts tracked
- [ ] Evidence provided for each gate checkbox

### 4. Efficiency Goals (Resource Optimization)

Analyze the transcript for:
- **Context management**: Was context used efficiently?
- **Tool calls**: Were there unnecessary/redundant calls?
- **Parallelization**: Were parallel opportunities exploited?

**Checklist:**
- [ ] No redundant file reads
- [ ] Parallel tasks dispatched in parallel
- [ ] Explore agent used for broad searches

## Configuration Files to Review

Read these files to understand the intended workflow:

1. **CLAUDE.md**: `./CLAUDE.md`
2. **Crew skill**: `.agents/skills-local/crew-claude/SKILL.md` (contains workflows, hard requirements, anti-patterns, and skill routing)

## Scoring Rubric

For each category, assign a score (0-100) and pass/fail:

| Category | Score Range | Pass Threshold |
|----------|-------------|----------------|
| Outcome | 0-100 | ≥70 |
| Process | 0-100 | ≥60 |
| Style | 0-100 | ≥50 |
| Efficiency | 0-100 | ≥50 |

**Scoring Guidelines:**

**Outcome:**
- 90-100: All requests fulfilled, high quality output
- 70-89: Primary request fulfilled, minor gaps
- 50-69: Partial completion, significant gaps
- 0-49: Failed to complete primary request

**Process:**
- 90-100: All skills loaded, all gates passed with proofs
- 70-89: Most skills loaded, gates mostly complete
- 50-69: Some skills missing, gates incomplete
- 0-49: Major process violations

**Style:**
- 90-100: Perfect format compliance, meaningful iterations
- 70-89: Good format, some boilerplate iterations
- 50-69: Format issues, iterations lack depth
- 0-49: Format violations, no meaningful iteration

**Efficiency:**
- 90-100: Optimal tool usage, perfect parallelization
- 70-89: Good efficiency, minor redundancy
- 50-69: Some wasted operations
- 0-49: Significant inefficiency

## Output Format

Generate a structured analysis:

```json
{
  "session_id": "${CLAUDE_SESSION_ID}",
  "outcome": { "score": <N>, "pass": <bool>, "notes": "<summary>" },
  "process": { "score": <N>, "pass": <bool>, "notes": "<summary>" },
  "style": { "score": <N>, "pass": <bool>, "notes": "<summary>" },
  "efficiency": { "score": <N>, "pass": <bool>, "notes": "<summary>" },
  "overall": <average>,
  "improvements": [
    { "priority": 1, "category": "<O/P/S/E>", "file": "<path>", "suggestion": "<change>" }
  ]
}
```

## GitHub Issue Creation

After analysis, create a GitHub issue:

```bash
gh issue create --repo settlemint/agent-marketplace \
  --title "Workflow Improvement: Session ${CLAUDE_SESSION_ID}" \
  --label "workflow-improvement,session-memory" \
  --body "$(cat <<'EOF'
## Workflow Improvement Recommendations

**Session analyzed:** ${CLAUDE_SESSION_ID}
**Project:** !`basename $(pwd)`
**Date:** !`date +%Y-%m-%d`

### Session Evaluation Scores

| Category | Score | Pass | Notes |
|----------|-------|------|-------|
| Outcome | <score>/100 | <emoji> | <notes> |
| Process | <score>/100 | <emoji> | <notes> |
| Style | <score>/100 | <emoji> | <notes> |
| Efficiency | <score>/100 | <emoji> | <notes> |
| **Overall** | **<avg>** | | |

### Session Summary
<Brief summary of what the user wanted to accomplish>

### Intent vs Execution Analysis
| User Intent | What Happened | Category | Gap |
|-------------|---------------|----------|-----|
| <request 1> | <execution>   | <O/P/S/E> | <gap> |

### Improvements by Priority

#### P1 (Critical)
- [ ] [File: path] [Change: description]

#### P2 (Important)
- [ ] [File: path] [Change: description]

#### P3 (Nice-to-have)
- [ ] [File: path] [Change: description]

### Suggested New Skills/Routing
- [ ] Add skill: [name] - addresses [category] gap
- [ ] Add routing: [trigger] -> [skill]

### Workflow Adjustments
- [ ] [Phase/gate modification]

---
**Files analyzed:**
- Session: ~/.claude/projects/[path]/[session].jsonl
- Config: CLAUDE.md, .claude/skills/*, .agents/skills-local/crew-claude/*
**Framework:** OpenAI eval-skills (Outcome/Process/Style/Efficiency)
EOF
)"
```

## Execution Steps

1. **Discover session**: Find and read the current session transcript
2. **Analyze transcript**: Parse user messages, tool calls, and outputs
3. **Score each category**: Apply rubric to generate scores
4. **Read config files**: Understand intended workflow
5. **Identify gaps**: Compare intent vs execution
6. **Generate improvements**: Prioritized, actionable suggestions
7. **Create issue**: GitHub issue with full analysis

Begin by discovering the session transcript.
