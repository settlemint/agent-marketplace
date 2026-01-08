---
name: crew:review-pr
description: Review a PR with multi-agent analysis and optional GitHub review posting
argument-hint: "[PR number]"
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
context: fork
skills:
  - crew:crew-patterns
hooks:
  PostToolUse: false
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

This provides: `<pattern name="quality-agents"/>`, `<pattern name="task-file"/>`.

</prerequisite>

<input>
<pr_number>$ARGUMENTS</pr_number>
</input>

<seven_leg_system>

| Leg             | Focus            | Key Checks                             |
| --------------- | ---------------- | -------------------------------------- |
| **Correctness** | Logic accuracy   | Edge cases, null handling, type safety |
| **Performance** | Speed/efficiency | Complexity, caching, N+1 queries       |
| **Security**    | Vulnerabilities  | OWASP, injection, auth, secrets        |
| **Elegance**    | Design quality   | SOLID, clean architecture, cohesion    |
| **Resilience**  | Failure handling | Error recovery, cleanup, degradation   |
| **Style**       | Conventions      | Naming, formatting, idioms             |
| **Smells**      | Debt indicators  | Anti-patterns, duplication, complexity |

**Severity levels:**

- **P0**: Critical - Must fix, blocks deployment
- **P1**: High - Should fix, significant impact
- **P2**: Medium - Address soon
- **Observation**: Note for consideration

**Output format:** `[Severity] file:line - Description`

</seven_leg_system>

<scripts>

```bash
# List open PRs for selection
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-list-open.sh [--json]

# Get PR info
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-info.sh <PR_NUMBER>

# Get PR diff
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-diff.sh <PR_NUMBER> [--files-only]

# Post review with file comments
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-post-review.sh <PR_NUMBER> <EVENT> <BODY_FILE> [COMMENTS_JSON]
# EVENT: APPROVE | REQUEST_CHANGES | COMMENT
# COMMENTS_JSON format: [{"path": "src/file.ts", "line": 42, "body": "Comment text"}]
```

</scripts>

<process>

<phase name="determine-pr">

If `<pr_number>` is empty or unclear:

```bash
# Get list of open PRs
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-list-open.sh --json
```

Then present selection:

```javascript
// Parse PR list into options
// AskUserQuestion allows max 4 options, so show 3 recent + hint about "Other"
const prs = JSON.parse(prListOutput);
const totalPRs = prs.length;
const options = prs.slice(0, 3).map((pr) => ({
  label: `#${pr.number}: ${pr.title.substring(0, 25)}`,
  description: `${pr.headRefName} by @${pr.author.login} (+${pr.additions}/-${pr.deletions})`,
}));

// Add a 4th option showing there are more PRs available
if (totalPRs > 3) {
  options.push({
    label: `${totalPRs - 3} more PRs...`,
    description: "Select 'Other' below to enter a PR number directly",
  });
}

AskUserQuestion({
  questions: [
    {
      question: `Found ${totalPRs} open PRs. Which one to review?`,
      header: "PR",
      options: options,
      multiSelect: false,
    },
  ],
});
// Note: User can always select "Other" to type a specific PR number
```

If user selects "X more PRs..." or "Other", show full list:

```bash
# Display all open PRs for reference
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-list-open.sh
```

Then ask for the PR number directly.

</phase>

<phase name="fetch-pr-context">

```bash
# Get PR info
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-info.sh ${PR_NUMBER}

# Get changed files
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-diff.sh ${PR_NUMBER} --files-only

# Get full diff
${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-diff.sh ${PR_NUMBER}
```

</phase>

<phase name="launch-reviewers">

Launch ALL 7 using `<pattern name="quality-agents"/>` in SINGLE message:

```javascript
const legs = [
  "correctness",
  "performance",
  "security",
  "elegance",
  "resilience",
  "style",
  "smells",
];
for (const leg of legs) {
  Task({
    subagent_type: `crew:review:seven-legs:${leg}-reviewer`,
    prompt: `CONTEXT: Review PR #${prNumber}
TITLE: ${prTitle}
FILES: ${files.join(", ")}
DIFF:
${diff}

FOCUS: ${legFocus[leg]}
OUTPUT FORMAT: [P0|P1|P2|Obs] file:line - description

Use Glob, Grep, Read to examine the actual code. Do NOT run bash commands.
Return findings in the specified format, one per line.`,
    description: `${leg} review`,
    run_in_background: true,
  });
}
```

</phase>

<phase name="collect-synthesize">

```javascript
const findings = [];
for (const leg of legs) {
  const result = TaskOutput({ task_id: leg.id, block: true });
  findings.push(...parseFindings(result, leg));
}
// Deduplicate and sort by severity: P0 → P1 → P2 → Obs
// Group by file for review comments
```

</phase>

<phase name="meta-analysis">

Optional for complex reviews with many findings:

```javascript
Task({
  subagent_type: "crew:review:seven-legs:meta-reviewer",
  prompt: `Synthesize findings from all 7 legs. Find: cross-leg patterns, priority escalations, systemic issues.\nMCP: Use Codex for deep reasoning.`,
  run_in_background: false,
});
```

</phase>

<phase name="create-task-files">

Add findings as task files using `<pattern name="task-file"/>`:

```javascript
const slugBranch = prBranch.replace(/\//g, "-");
// Findings start at order 050
// Naming: {order}-pending-{severity}-found-{slug}.md
// Example: 050-pending-p0-found-fix-null-deref.md
```

Each finding task includes:

- Leg dimension (correctness, security, etc.)
- Severity (P0/P1/P2/Obs)
- File:line location
- Recommended fix

</phase>

<phase name="ask-post-review">

```javascript
AskUserQuestion({
  questions: [
    {
      question: `Found ${p0} P0, ${p1} P1, ${p2} P2, ${obs} observations. Post as GitHub review?`,
      header: "Post review",
      options: [
        {
          label: "Yes, as COMMENT (Recommended)",
          description: "Add review comments without approval/request changes",
        },
        {
          label: "Yes, REQUEST_CHANGES",
          description: "Request changes on the PR",
        },
        { label: "No", description: "Keep findings local only" },
      ],
      multiSelect: false,
    },
  ],
});
```

</phase>

<phase name="post-github-review">

If user chose to post:

```javascript
// 1. Create review body file
Write({
  file_path: "/tmp/review-body.md",
  content: `## Code Review Summary

**Findings:** ${p0} Critical, ${p1} High, ${p2} Medium, ${obs} Observations

### Critical Issues (P0)
${p0Findings.map((f) => `- ${f.file}:${f.line} - ${f.description}`).join("\n")}

### High Priority (P1)
${p1Findings.map((f) => `- ${f.file}:${f.line} - ${f.description}`).join("\n")}

### Medium Priority (P2)
${p2Findings.map((f) => `- ${f.file}:${f.line} - ${f.description}`).join("\n")}

---
*Review generated by crew:review-pr*`,
});

// 2. Create comments JSON for file-level comments
// Only include findings that have valid line numbers in the diff
Write({
  file_path: "/tmp/review-comments.json",
  content: JSON.stringify(
    findings
      .filter((f) => f.line && f.path)
      .map((f) => ({
        path: f.path,
        line: f.line,
        body: `**[${f.severity}] ${f.leg}**\n\n${f.description}\n\n${f.fix ? `**Suggested fix:** ${f.fix}` : ""}`,
      })),
  ),
});

// 3. Post review
Bash({
  command: `${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-post-review.sh ${prNumber} ${reviewEvent} /tmp/review-body.md /tmp/review-comments.json`,
});
```

</phase>

<phase name="report-result">

Output summary:

- Number of findings by severity
- Task files created
- GitHub review URL (if posted)
- Suggest next steps: `/crew:build` to fix, or manual review

</phase>

</process>

<success_criteria>

- [ ] PR selected via argument or AskUserQuestion
- [ ] All 7 canonical reviewers launched in single message
- [ ] Findings deduplicated and prioritized
- [ ] Task files created with naming convention
- [ ] User asked about posting GitHub review
- [ ] If posting: review submitted with file-level comments
- [ ] Summary provided with next steps

</success_criteria>
