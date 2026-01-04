---
name: troubleshooting
description: Debugging patterns for common development issues across the stack. Triggers on error, debug, fix, issue, problem, not working.
triggers: ["error", "debug", "fix", "issue", "problem", "not working", "failed", "broken"]
---

<objective>
Systematically debug and resolve development issues across the stack. Use structured debugging approaches to identify root causes efficiently.
</objective>

<quick_start>
**Debugging workflow:**

1. **Observe first** - Check what the system actually produced before editing code
2. **Reproduce** - Confirm the issue consistently
3. **Isolate** - Narrow down the scope
4. **Investigate** - Gather evidence
5. **Fix** - Apply targeted solution
6. **Verify** - Run quality gate before committing
</quick_start>

<observe_before_editing>
**CRITICAL: Confirm what the system actually produced before editing code.**

Outputs don't lie. Code might. Check outputs first.

```bash
# Check if expected files were created
ls -la [path]

# Check logs for errors
tail [logfile]

# Run the failing command manually to see actual error
<command>

# Verify the issue exists before fixing it
```

**DON'T:**
- Assume "hook didn't run" without checking outputs
- Edit code based on what you *think* should happen
- Confuse paths (project vs global, relative vs absolute)
- Fix bugs you haven't reproduced
</observe_before_editing>

<quality_gate>
**MANDATORY: Run CI before every commit. No exceptions.**

```bash
# Full quality gate (REQUIRED before any commit)
bun run ci

# Auto-fix issues
bunx biome check --write
bunx prettier --write

# Shell scripts
shellcheck <file>
shfmt -w <file>
```

**DON'T:**
- Commit then run CI (wrong order)
- Push then check if CI passes remotely
- Skip quality checks "just this once"
- Leave failing tests for "later"
- Mark work complete before CI passes
</quality_gate>

<common_issues>
**Build failures:**

```bash
# Clear all caches
rm -rf node_modules .next dist .turbo
bun install
bun run build
```

**Type errors:**

```bash
# Regenerate types
bun run typecheck
# Check for missing dependencies
bun install
```

**Database issues:**

```bash
# Reset database
bun run db:push
# Check migrations
bun run db:migrate
# View in studio
bun run db:studio
```

**API errors:**

```bash
# Check server logs
# Verify environment variables
# Test endpoint directly with curl
curl -X POST http://localhost:3000/api/route -H "Content-Type: application/json" -d '{}'
```
</common_issues>

<debugging_tools>
**TypeScript:**
- Use `console.log` strategically
- Check TypeScript errors: `bun run typecheck`
- Use debugger with breakpoints

**React:**
- React DevTools for component inspection
- Check console for hydration mismatches
- Verify props with console.log

**Database:**
- Drizzle Studio for data inspection
- Check query with `.toSQL()`
- Verify migrations ran

**Network:**
- Browser DevTools Network tab
- Check request/response payloads
- Verify CORS headers

**Blockchain:**
- Check transaction hash on explorer
- Verify contract address
- Check gas estimation
</debugging_tools>

<error_patterns>
**"Module not found":**
- Check import path (case-sensitive on Linux)
- Verify package is installed
- Check tsconfig paths

**"Type X is not assignable to Y":**
- Check type definitions
- Verify generic parameters
- Look for version mismatches

**"ECONNREFUSED":**
- Service not running
- Wrong port/host
- Firewall blocking

**"Hydration mismatch":**
- Server/client render differently
- Check conditional rendering
- Verify date/time handling
</error_patterns>

<investigation_strategy>
1. **Read the error message** - Often contains the solution
2. **Check recent changes** - `git diff` what changed
3. **Search codebase** - Find similar patterns
4. **Check documentation** - Use Context7 MCP
5. **Search issues** - GitHub issues, Stack Overflow
6. **Isolate the problem** - Create minimal reproduction
</investigation_strategy>

<simplicity_first>
**Always prefer the simplest change possible.**

**DO:**
- Make code readable above all else
- Delete unused code completely (no `_unused` prefixes)
- Use combined edits so linter can remove unused imports
- Make bigger changes if they improve readability

**DON'T:**
- Add migration/backwards-compatibility shims
- Keep code "just in case" (YAGNI)
- Add abstractions for one-time operations
- Create helpers for code used once
</simplicity_first>

<mcp_for_debugging>
**Use MCP to research error patterns:**

```typescript
// Search for similar issues
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["error message keywords"],
  owner: "relevant-org",
  repo: "relevant-repo",
  path: "issues",
  mainResearchGoal: "Find similar reported issues",
  researchGoal: "Get solutions from issues",
  reasoning: "May find documented fix"
})

// Get current documentation
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/library/id",
  topic: "error handling troubleshooting"
})
```
</mcp_for_debugging>

<success_criteria>
- [ ] Observed actual output before editing code
- [ ] Issue reproduced consistently
- [ ] Root cause identified
- [ ] Fix applied (simplest change possible)
- [ ] Quality gate passed (`bun run ci`)
- [ ] Issue verified resolved
- [ ] No regressions introduced
</success_criteria>
