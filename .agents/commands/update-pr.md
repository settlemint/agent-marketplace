---
name: update-pr
description: Update PR title and body from commits
argument-hint: [--regenerate] [PR number]
---

Update an existing PR's title and body based on current commits.

## Context

```bash
! gh pr view --json number,title,baseRefName 2>/dev/null || echo "No PR found"
! git log origin/main..HEAD --oneline 2>/dev/null | head -10
! git diff --stat origin/main 2>/dev/null | tail -5
```

## Workflow

### Step 1: Validate PR Exists

```bash
PR_NUM=$(gh pr view --json number -q '.number' 2>/dev/null)
[[ -z "$PR_NUM" ]] && echo "ERROR: No PR found for current branch"
```

If no PR found -> stop and instruct to use `/pr` first.

### Step 2: Analyze Existing Body

Fetch current PR body and identify preserved sections:

```bash
gh pr view --json body -q '.body'
```

**Parse for preserved content:**
- `# User description` block
- Review agent sections (cubic, Greptile, Gemini)
- Implementation Plan collapsible

### Step 3: Decide Update Mode

**Use Full Regenerate mode if:**
- `--regenerate` flag is passed, OR
- Body has no structured sections, OR
- Body is dominated by auto-generated noise

**Otherwise use Incremental Update mode.**

### Step 4: Gather Current Commits

```bash
BASE=$(gh pr view --json baseRefName -q '.baseRefName')
git log origin/${BASE}..HEAD --pretty=format:"%s" | head -20
git diff --stat origin/${BASE}
```

### Step 5: Generate Title

- Single commit -> use commit message as title
- Multiple commits -> `type(scope): summary of changes`
- Mixed types -> use most significant (feat > fix > refactor > docs > chore)

### Step 6: Generate/Update Body

**For Incremental Update:**
1. Keep preserved sections exactly as-is
2. Update `## Commits` with current commit list
3. Update `## Files Changed` with current diff stat
4. Update Implementation Plan if local plan exists
5. Keep review agent sections at the end

**For Full Regenerate:**
1. Select template based on primary commit type
2. Fill placeholders
3. Append preserved review agent findings

**Include plan if available:**

```bash
PLAN_FILE=$(ls -t ~/.claude/plans/*.md 2>/dev/null | head -1)
[[ -n "$PLAN_FILE" ]] && PLAN_CONTENT=$(cat "$PLAN_FILE")
```

### Step 7: Update PR

```bash
gh pr edit $PR_NUM --title "type(scope): description"
gh pr edit $PR_NUM --body "$(cat <<'EOF'
[assembled body]
EOF
)"
```

### Step 8: Confirm Update

```bash
gh pr view --json url -q '.url'
```

## Template Structure

```markdown
## Summary
- Brief description of changes

## Commits
- list of commits

## Files Changed
- diff stat

<details>
<summary>Implementation Plan</summary>

[Plan content if available]

</details>
```

## Constraints

**Banned:**
- Destroying user-written content
- Removing review agent findings without `--regenerate`
- Updating PR that doesn't exist
- Replacing good structure with worse structure

**Required:**
- Preserve review agent findings by default
- Title matches primary commit type
- Incremental update unless `--regenerate` or body is broken

## Success Criteria

- [ ] PR exists for current branch
- [ ] User description preserved (unless `--regenerate`)
- [ ] Review agent sections preserved
- [ ] Commits list reflects current branch state
- [ ] Files changed reflects current diff
- [ ] Title updated if commits changed
- [ ] PR URL returned to user
