---
name: crew:git:commit
description: Create a conventional commit
argument-hint: "[commit message]"
allowed-tools:
  - Bash
---

<commit_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/commit-context.sh`
</commit_context>

<objective>

Create conventional commit. Check for sensitive files. Format: `type(scope): description`

</objective>

<workflow>

## Step 1: Check for Sensitive Files

```bash
# If sensitive files staged, unstage them
git diff --cached --name-only | grep -E '\.(env|pem|key)$|credentials|secrets' && \
  echo "⚠️ Sensitive files detected - unstaging" && \
  git reset HEAD $(git diff --cached --name-only | grep -E '\.(env|pem|key)$|credentials|secrets')
```

## Step 2: Stage and Commit

```bash
git add <files>
git commit -m "type(scope): description"
```

</workflow>

<success_criteria>

- [ ] No sensitive files committed
- [ ] Conventional commit format used

</success_criteria>

<notes>

Follow @patterns/git-safety.md for protected files and operations.

</notes>
