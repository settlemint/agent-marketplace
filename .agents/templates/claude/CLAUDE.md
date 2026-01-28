# STOP - MANDATORY FIRST ACTION

## You Are BLOCKED Until Skill Loaded

Before ANY other action (reading files, exploring, planning, answering), you MUST invoke the crew-claude skill using the Skill tool:

```
Skill({ skill: "crew-claude" })
```

The skill content loads inline. After loading, output:

```
CREW-CLAUDE LOADED: ✓
```

**WARNING: Do NOT fake this output.** You must actually call the Skill tool — printing the text without invoking the tool is a violation. The skill contains the full phase workflow, gate definitions, and classification rules that govern ALL subsequent work.

---

## BLOCKED Actions (until Skill tool is invoked and verification output)

You may NOT:
- Explore codebase
- Read files (except SKILL.md)
- Use Task/Explore agents
- Start planning
- Answer questions about code
- Write any code

---

## Post-Compaction Reload

If context was compacted, the skill content is lost. You MUST reload it immediately:

```
Skill({ skill: "crew-claude" })
```

Then check `TaskList` to see where you left off and resume from that point.

---

## Workflow Requirements (always enforced, skill or not)

### Classification First - ALWAYS

Output classification BEFORE any tools/exploration:
- **Trivial**: single-line, typo, comment only
- **Simple**: single file, clear scope
- **Standard**: multi-file, behavior change
- **Complex**: architectural, security-sensitive

### 9 Mandatory Gates

Every implementation MUST pass through ALL gates in order. You may NOT skip gates. Output `GATE: <name> — PASSED` before proceeding to the next phase:

1. **Planning** — classification + research complete
2. **Refinement** — questions asked via AskUserQuestion
3. **Implementation** — skills loaded, TaskCreate used for all work items
4. **Cleanup** — unused code removed, no leftover artifacts
5. **Testing** — test output shown with exit code (`bun run test`)
6. **Review** — `Skill({ skill: "review" })` invoked, findings addressed
7. **Verification** — `Skill({ skill: "verification-before-completion" })` invoked
8. **CI** — `bun run ci` with exit code 0
9. **Integration** — `bun run test:integration` with exit code 0

Skipping a gate or claiming a gate passed without evidence is a violation.

### Skills Must Be INVOKED (not mentioned)

Listing skills is NOT loading them. You must call the Skill tool:
```
Skill({ skill: "test-driven-development" })
Skill({ skill: "verification-before-completion" })
Skill({ skill: "ask-questions-if-underspecified" })
```

### Banned Phrases

Never say: "looks good", "should work", "Done!", "requirements are clear" (without AskUserQuestion), "manual review", "code is simple"

### Task Tracking Required

Before code: `TaskCreate` + `TaskUpdate({ status: "in_progress" })`
After code: `TaskUpdate({ status: "completed" })`
Before completion: `TaskList` to verify ALL tasks are completed

### Drizzle Migration Rules

When working with drizzle migrations:

1. **Never manually edit migration files** - Always use drizzle-kit tooling:
   - `bun run db:generate` - Generate migrations from schema changes
   - `bun run db:push` - Push schema directly (dev only)
   - `bun run db:migrate` - Apply pending migrations

2. **On merge conflicts** - Reset and regenerate:
   ```bash
   git checkout main -- drizzle/
   bun run db:generate
   ```

3. **One migration per branch/PR** - If your branch has multiple new migrations, reset and regenerate to keep history clean:
   ```bash
   git checkout main -- drizzle/
   bun run db:generate
   ```

Files that MUST NOT be manually edited:
- `drizzle/*.sql` - migration files
- `drizzle/meta/_journal.json` - migration journal
- `drizzle/meta/*.snapshot.json` - schema snapshots

---

## Now Load The Skill

**Your next action MUST be:** `Skill({ skill: "crew-claude" })`
