---
title: never manually edit migration files
description:
  Never manually edit files in the drizzle folder (migrations, snapshots, journals).
  Always use drizzle-kit commands (db:generate, db:push, db:migrate) to generate and manage
  migrations. Manual edits corrupt migration state and cause unrecoverable issues.
repository: drizzle-team/drizzle-orm
label: Migrations
language: TypeScript
comments_count: 0
repository_stars: 29461
---

Never manually edit, create, or delete files in the `drizzle/` folder. These files are generated and managed exclusively by drizzle-kit.

## Files that MUST NOT be manually edited

- `drizzle/*.sql` - migration files
- `drizzle/meta/_journal.json` - migration journal tracking applied migrations
- `drizzle/meta/*.snapshot.json` - schema snapshots for diff calculation

## Always use drizzle-kit commands

```bash
# Generate new migration from schema changes
bun run db:generate

# Push schema changes directly (development only)
bun run db:push

# Apply pending migrations
bun run db:migrate
```

## Why manual edits are forbidden

1. **Journal corruption**: The `_journal.json` tracks which migrations have been applied. Manual edits desync local state from the database.
2. **Snapshot mismatch**: Snapshots are used to calculate diffs. Manual changes break future migration generation.
3. **Duplicate migrations**: Manual SQL files without journal entries cause drizzle-kit to regenerate the same changes.
4. **Unrecoverable state**: Once corrupted, the only fix is often to reset the migration history entirely.

## If you need to modify a migration

1. If migration is NOT yet applied: delete the migration files and re-run `bun run db:generate`
2. If migration IS already applied: create a new migration with the correction via `bun run db:generate`

Never edit the SQL or journal files directly.
