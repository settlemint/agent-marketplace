---
name: update-pr
description: Update PR title and body from commits
argument-hint: [--regenerate] [PR number]
---

Update an existing PR's title and body based on current commits, preserving valuable content.

## Current State

```bash
gh pr view --json number,title,body,baseRefName 2>/dev/null || echo "No PR found"
```

## Workflow

### Step 1: Validate PR Exists

```bash
PR_NUM=$(gh pr view --json number -q '.number' 2>/dev/null)
[[ -z "$PR_NUM" ]] && echo "ERROR: No PR found for current branch"
```

If no PR found → stop and instruct to use `/pr` first.

### Step 2: Analyze Existing Body

Fetch current PR body and identify sections:

```bash
gh pr view --json body -q '.body'
```

**Parse for preserved content:**
- `# User description` block (between `# User description` and `---`)
- `## Summary by cubic` block (between `<!-- This is an auto-generated description by cubic. -->` markers)
- Greptile findings (`<h3>Greptile Summary</h3>` to end of that block)
- Gemini summaries (`## Summary of Changes` from gemini-code-assist)
- Implementation Plan (`<details><summary>Implementation Plan</summary>` block)

### Step 3: Decide Update Mode

**Use Full Regenerate mode if:**
- `--regenerate` flag is passed, OR
- Body has no `# User description` section, OR
- Body is dominated by auto-generated noise without clear structure

**Otherwise use Incremental Update mode.**

### Step 4: Gather Current Commits

```bash
BASE=$(gh pr view --json baseRefName -q '.baseRefName')
git log origin/${BASE}..HEAD --pretty=format:"%s" | head -20
git diff --stat origin/${BASE}
```

### Step 5: Generate Title

- Single commit → use commit message as title
- Multiple commits → `type(scope): summary of changes`
- Mixed types → use most significant (feat > fix > refactor > docs > chore)

### Step 6: Generate/Update Body

**For Incremental Update:**
1. Keep preserved `# User description` section exactly as-is
2. Update `## Commits` with current commit list
3. Update `## Files Changed` / `## What Changed` with current diff stat
4. If plan file exists locally (`~/.claude/plans/*.md`), update Implementation Plan
5. If no local plan but PR has Implementation Plan, keep existing
6. Keep review agent sections (cubic, Greptile, Gemini) at the end

**For Full Regenerate:**
1. Select template based on primary commit type:

| Commit Type | Template |
|-------------|----------|
| `feat` | `templates/pr-feature.md` |
| `refactor`, `docs`, `chore`, `test` | `templates/pr-refactor.md` |
| `fix`, other | `templates/pr-body.md` |

2. Read template from `skills/using-git/templates/`
3. Fill placeholders:
   - `{{SUMMARY}}` - Brief description from commits
   - `{{COMMITS}}` - List of commits
   - `{{FILES_CHANGED}}` - Files modified from `git diff --stat`
   - `{{WHY}}` - Extract from plan file or commit bodies
   - `{{PLAN}}` - Full plan content if available

4. Append preserved review agent findings at the end (cubic, Greptile, Gemini)

**Include plan if available:**

```bash
PLAN_FILE=$(ls -t ~/.claude/plans/*.md 2>/dev/null | head -1)
if [[ -n "$PLAN_FILE" ]]; then
  PLAN_CONTENT=$(cat "$PLAN_FILE")
fi
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

## Constraints

**Banned:**
- Destroying user-written content in `# User description` section
- Removing review agent findings (cubic, Greptile, Gemini) without `--regenerate`
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
