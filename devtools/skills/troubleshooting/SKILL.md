---
name: troubleshooting
description: Use when debugging errors, fixing issues, or troubleshooting problems. Systematic workflow for identifying root causes.
license: MIT
triggers:
  # Intent triggers
  - "help debug"
  - "fix this"
  - "troubleshoot"
  - "not working"
  - "find bug"
  - "root cause"

  # Artifact triggers
  - "error message"
  - "stack trace"
  - "TypeError|ReferenceError|SyntaxError"
  - "ECONNREFUSED|ENOENT|EPERM"
  - "Module not found"
  - "hydration mismatch"
  - "cannot read property"
  - "undefined is not"
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

<constraints>
**Banned:**
- Editing code before observing actual output
- Fixing bugs without reproduction steps
- Committing fixes without running CI/quality gate
- Making multiple changes simultaneously (confuses root cause)

**Required:**

- Verify issue exists before attempting fix
- Run quality gate (`bun run ci`) before every commit
- Create regression test for fixed bugs
- Document fixes with explanatory comments (see `devtools/rules/fix-documentation.md`)

**Fix comment pattern:**

```typescript
// Fixed: [summary of what changed]
// Why: [root cause explanation of the issue]
```
</constraints>

<anti_patterns>

- **Shotgun Debugging:** Making random changes hoping something works
- **Print Statement Pollution:** Adding console.log everywhere without removing them
- **Assumption-Driven Fixes:** Fixing what you think is wrong without evidence
- **Blame Shifting:** Assuming external services are broken before checking your code
- **Zombie Code:** Commenting out code instead of deleting it; creates confusion
- **Pre-existing Bailout:** Claiming errors are "pre-existing" to avoid fixing them; during implementation YOU own ALL errors you encounter - fix them or escalate with specific environment requirements
  </anti_patterns>

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
- Edit code based on what you _think_ should happen
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

<ci_feedback_loop>
**When CI fails, feed errors back systematically.**

CI failures are debugging opportunities. Parse output and iterate until green.

**Workflow:**

1. **Capture failure** - Copy specific error messages from CI output
2. **Feed back** - "CI failed with: [specific error]. Let's debug."
3. **Reproduce locally** - Run the same command locally
4. **Fix** - Apply targeted solution (see troubleshooting workflow)
5. **Verify locally** - Run `bun run ci` before pushing
6. **Create regression test** - Prevent this failure from recurring
7. **Re-run CI** - Confirm fix works in CI environment

**Example iteration:**

```
CI Output:
  FAIL tests/auth.test.ts
  TypeError: Cannot read property 'id' of undefined
    at getUserProfile (auth.ts:45)

Debugging response:
1. Error: TypeError accessing .id on undefined at auth.ts:45
2. Reproduce: bun run test tests/auth.test.ts
3. Investigate: Read auth.ts:45, trace where user comes from
4. Root cause: [identified]
5. Fix: [applied]
6. Verify: bun run ci passes locally
7. Regression test: Added test for null user case
```

**Parsing CI output:**

```bash
# Extract failing tests
grep -E "FAIL|Error|TypeError|ReferenceError" ci-output.log

# Get specific line numbers
grep -oE "[a-zA-Z]+\.(ts|tsx|js):[0-9]+" ci-output.log

# Count failures
grep -c "FAIL" ci-output.log
```

**Common CI-specific issues:**

| CI Failure | Local Works | Likely Cause |
|------------|-------------|--------------|
| Module not found | Works | Missing dependency in package.json |
| Timeout | Works | CI has slower runners, add timeout |
| Permission denied | Works | File permissions, secrets not available |
| Out of memory | Works | CI has limited resources, optimize |

**DON'T:**

- Push hoping CI will pass ("works on my machine")
- Ignore flaky tests (fix the flakiness)
- Add retries without understanding root cause
- Skip local verification before pushing
</ci_feedback_loop>

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

<agent_debugging>
**Agent-compatible alternatives for GUI debugging tools:**

Many debugging tools above require human interaction (DevTools, Drizzle Studio). Here are programmatic alternatives agents can use:

**React inspection (instead of React DevTools):**

```tsx
// Add temporary logging to components
console.log("Component render:", { props, state: useState()[0] });

// Or wrap with a debug HOC
function withDebug<P>(Component: React.FC<P>, name: string) {
  return (props: P) => {
    console.log(`[${name}] render:`, props);
    return <Component {...props} />;
  };
}

// Check rendered output via tests
import { render, screen } from "@testing-library/react";
const { container } = render(<MyComponent />);
console.log(container.innerHTML);
```

**Database inspection (instead of Drizzle Studio):**

```bash
# Direct SQL queries
bun run db:query "SELECT * FROM users LIMIT 10"

# Or use drizzle's toSQL for query inspection
# In code: console.log(query.toSQL())

# PostgreSQL direct access
psql $DATABASE_URL -c "SELECT * FROM users LIMIT 10"

# Check table structure
psql $DATABASE_URL -c "\d users"
```

**Network inspection (instead of Browser DevTools):**

```bash
# Test API endpoints directly
curl -v http://localhost:3000/api/endpoint \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}'

# Check response headers
curl -I http://localhost:3000/api/endpoint

# Trace full request/response
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:3000/api/endpoint

# Monitor requests in real-time (requires server-side logging)
tail -f logs/requests.log
```

**React hydration debugging (instead of console inspection):**

```tsx
// Add hydration boundary logging
if (typeof window !== "undefined") {
  console.log("Client render:", new Date().toISOString());
} else {
  console.log("Server render:", new Date().toISOString());
}

// Check for hydration-unsafe patterns
grep -rE "(Date\.now|Math\.random|new Date\(\))" --include="*.tsx" src/
```

**Memory/performance debugging (instead of DevTools Performance):**

```bash
# Node.js memory profiling
node --inspect --expose-gc dist/server.js

# Check bundle size
bun run build && du -sh dist/

# Analyze bundle
npx source-map-explorer dist/*.js
```

**Browser automation for visual debugging:**

```typescript
// Use Playwright for programmatic browser inspection
import { chromium } from "playwright";

const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto("http://localhost:3000");

// Read console messages
page.on("console", (msg) => console.log("Browser:", msg.text()));

// Network requests
page.on("request", (req) => console.log(">>", req.method(), req.url()));
page.on("response", (res) => console.log("<<", res.status(), res.url()));

// Screenshot for visual verification
await page.screenshot({ path: "debug.png" });

// Get page content
const html = await page.content();
console.log(html);
```

**Key principle:** When a debugging approach requires GUI interaction, find the underlying data source and access it programmatically (logs, SQL, HTTP, test renders).
</agent_debugging>

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
  reasoning: "May find documented fix",
});

// Get current documentation
mcp__context7__query_docs({
  libraryId: "/library/id",
  query: "How do I handle errors and troubleshoot common issues?",
});
```

</mcp_for_debugging>

<lsp_for_debugging>
**Use LSP tools for semantic code navigation during debugging:**

When debugging errors with stack traces, LSP provides type-aware navigation:

- `lspGotoDefinition(lineHint)` - Jump to error source from stack trace locations
- `lspCallHierarchy(incoming, lineHint)` - Trace what called the failing function
- `lspFindReferences(lineHint)` - Find all call sites that might trigger the error

**Workflow:**

1. Grep for error message → get file + lineHint
2. `lspGotoDefinition` → jump to source
3. `lspCallHierarchy(incoming)` → trace callers

**CRITICAL:** Always search first to get `lineHint` (1-indexed line number). Never call LSP tools without a lineHint from search results.

**When to use:**

- Stack traces point to specific lines → use LSP to navigate
- Need to understand call chain → use `lspCallHierarchy`
- Finding all places that trigger an error → use `lspFindReferences`

Load LSP skill for detailed patterns: `Skill({ skill: "devtools:typescript-lsp" })`
</lsp_for_debugging>

<reference_index>

| Reference                 | Content                                                |
| ------------------------- | ------------------------------------------------------ |
| `regenerate-vs-repair.md` | When to delete and regenerate code vs trying to fix it |
| `boundary-complexity.md`  | AI cognition degradation at system boundaries          |

</reference_index>

<related_skills>

**Testing:** Load via `Skill({ skill: "devtools:vitest" })` when:

- Writing regression tests for fixed bugs
- Reproducing issues with failing tests

**Iterative review:** Load via `Skill({ skill: "devtools:rule-of-five" })` when:

- Fix requires multiple review passes
- Complex bug with architectural implications

**React debugging:** Load via `Skill({ skill: "devtools:react" })` when:

- Debugging React component issues
- Investigating hydration mismatches
  </related_skills>

<success_criteria>

1. [ ] Observed actual output before editing code
2. [ ] Issue reproduced consistently
3. [ ] Root cause identified
4. [ ] Fix applied (simplest change possible)
5. [ ] Quality gate passed (`bun run ci`)
6. [ ] Issue verified resolved
7. [ ] No regressions introduced
</success_criteria>

<evolution>
**Extension Points:**
- Add domain-specific debugging references (React, database, network)
- Extend with team-specific runbooks for common failure modes
- Integrate with monitoring/alerting patterns

**Timelessness:** Systematic debugging is a fundamental engineering skill; observe-reproduce-isolate-fix workflow applies to any technology stack.
</evolution>
