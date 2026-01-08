---
name: crew:git:stack-status
description: Show git-machete branch stack status with visual indicators
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite, WebFetch, WebSearch, MCPSearch, Skill
context: fork
hooks:
  PostToolUse: false
  PreToolUse: false
---

<constraints>

**CRITICAL: NEVER output plain text questions. Use AskUserQuestion tool for all user choices.**

</constraints>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<edge_colors>

| Color           | Meaning                         | Action                                       |
| --------------- | ------------------------------- | -------------------------------------------- |
| 🟢 **Green**    | In sync with parent             | No action needed                             |
| 🟡 **Yellow**   | In sync, but fork point differs | Hidden commits exist, may need investigation |
| 🔴 **Red**      | Out of sync with parent         | Run `Skill({ skill: "crew:git:sync" })`      |
| ⚫ **Gray** (o) | Merged into parent              | Run `Skill({ skill: "crew:git:slide-out" })` |

</edge_colors>

<process>

## Step 1: Check for Layout

If no layout:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "No git-machete layout found. What to do?",
      header: "Setup",
      options: [
        {
          label: "Discover layout (Recommended)",
          description: "Auto-detect from history",
        },
        { label: "Skip", description: "Continue without machete" },
      ],
      multiSelect: false,
    },
  ],
});
```

If "Discover layout":

```javascript
Skill({ skill: "crew:git:discover" });
```

## Step 2: Update PR Annotations

```bash
# Annotate branches with PR numbers and URLs
git machete github anno-prs 2>/dev/null || true
```

## Step 3: Show Status

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What level of detail?",
      header: "Detail",
      options: [
        { label: "Summary", description: "Branch tree only" },
        {
          label: "With commits (Recommended)",
          description: "Show commits per branch",
        },
        { label: "Full", description: "Commits + fork points + remotes" },
      ],
      multiSelect: false,
    },
  ],
});
```

**Summary:**

```bash
git machete status
```

**With commits:**

```bash
git machete status --list-commits
```

**Full:**

```bash
git machete status --list-commits --list-commits-with-hashes
echo
echo "=== Fork Points ==="
for branch in $(git machete list managed); do
    fp=$(git machete fork-point "$branch" 2>/dev/null || echo "unknown")
    echo "$branch: $fp"
done
```

## Step 4: Analyze Issues

```bash
status_output=$(git machete status 2>/dev/null)

# Count issues
red_count=$(echo "$status_output" | grep -c "^[^o].*[│├└]" 2>/dev/null || echo "0")
merged_count=$(echo "$status_output" | grep -cE "^\s*o\s" 2>/dev/null || echo "0")
```

## Step 5: Suggest Actions

If issues detected, suggest next steps:

**If red edges (out of sync):**

```
⚠️ $red_count branch(es) out of sync with parent.

Recommended: Run `Skill({ skill: "crew:git:traverse" })` to sync all branches.
```

**If gray edges (merged):**

```
🔀 $merged_count merged branch(es) detected.

Recommended: Run `Skill({ skill: "crew:git:slide-out" })` to clean up.
```

**If all green:**

```
✅ All branches are in sync!
```

</process>

<annotations>

Branches may have annotations showing:

- **PR #123** — GitHub PR number
- **rebase=no** — Skip rebase during traverse (not your branch)
- **push=no** — Skip push during traverse (not your branch)
- **slide-out=no** — Don't auto-slide-out when merged

**Example status output:**

```
  main
  │
  ├─ feature-auth  PR #45
  │  │
  │  └─ feature-auth-tests  PR #46 rebase=no push=no
  │
  └─o feature-old  PR #30  (merged)
```

</annotations>

<quick_actions>

After viewing status, common next steps:

| Situation                  | Command                                  |
| -------------------------- | ---------------------------------------- |
| Branches out of sync       | `Skill({ skill: "crew:git:traverse" })`  |
| Merged branches to clean   | `Skill({ skill: "crew:git:slide-out" })` |
| Need to add current branch | `Skill({ skill: "crew:git:stack-add" })` |
| Navigate to another branch | `Skill({ skill: "crew:git:go" })`        |
| Create PR for branch       | `Skill({ skill: "crew:git:pr" })`        |

</quick_actions>

<success_criteria>

- [ ] Status displayed with proper edge coloring
- [ ] PR annotations shown (if GitHub PRs exist)
- [ ] Issues identified (red/gray edges)
- [ ] Next action suggestions provided

</success_criteria>
