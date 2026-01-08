---
description: Enforce squashed migrations in PRs (max 1 new migration per PR)
globs: "**/drizzle/**/*.sql,**/migrations/**/*.sql,drizzle.config.ts"
alwaysApply: false
---

# Migration Squash Rule

**HARD RULE: At most 1 new migration file per PR.**

## Why This Matters

- Keeps migration history clean and reviewable
- Prevents migration conflicts between branches
- Makes rollbacks simpler (one migration = one logical change)
- Reduces deployment complexity

## Detection

During PR review, check for new migration files:

```bash
# Count new migration files in this PR
new_migrations=$(git diff main...HEAD --name-only --diff-filter=A | grep -E '\.(sql)$' | grep -iE '(migration|drizzle)' | wc -l)

if [[ "$new_migrations" -gt 1 ]]; then
  echo "[P0] migration-squash: Found $new_migrations new migrations. Maximum allowed: 1"
  echo "Run: bunx drizzle-kit generate --squash"
fi
```

## Enforcement

### Severity: P0 (Blocks Deployment)

If more than 1 new migration file is detected in a PR:

```
[P0] migrations/:line - Multiple migrations detected ($count files).
     Squash with: bunx drizzle-kit generate --squash
```

### How to Fix

1. Delete all new migration files added in this PR
2. Re-generate a single squashed migration:
   ```bash
   bunx drizzle-kit generate --squash
   ```
3. Commit the single new migration file

### Alternative: Manual Squash

If drizzle-kit squash isn't available:

1. Note the schema changes from all migrations
2. Delete all new migration files
3. Create one migration with all changes combined
4. Test: `bunx drizzle-kit push` or `bunx drizzle-kit migrate`

## Exceptions

None. This rule has no exceptions.

If you believe you need multiple migrations in a single PR, you should split the PR into multiple PRs, each with its own migration.

## Integration with /crew:check

The correctness-reviewer agent will automatically check this rule when:
- Migration files (*.sql) are in the diff
- drizzle.config.ts exists in the project

This check runs as part of the standard 7-leg review process.
