# Task Templates

Templates for 2-5 minute tasks with parallelization markers, evidence definitions, and TDD requirements.

## Table of Contents

- [2-5 Minute Task Rule](#2-5-minute-task-rule)
- [Task Format](#task-format)
- [Parallelization Markers](#parallelization-markers)
  - [Marker Definitions](#marker-definitions)
  - [Merge Wall Detection](#merge-wall-detection)
- [Evidence Definitions](#evidence-definitions)
- [TDD Requirements](#tdd-requirements)
- [INVEST Criteria](#invest-criteria)
- [Complete Task Examples](#complete-task-examples)
- [Dependency Graph](#dependency-graph)
- [Task Quality Checklist](#task-quality-checklist)
- [Anti-Patterns](#anti-patterns)

## 2-5 Minute Task Rule

**Each task should take 2-5 minutes to implement.** If longer, break it down.

### Why This Granularity?

- **Progress visibility** - Frequent completions show movement
- **Error isolation** - Small tasks = small blast radius
- **Parallel opportunity** - Fine-grained tasks enable fan-out
- **Review efficiency** - Easier to review small changes
- **Frequent commits** - One task = one atomic commit

### Breaking Down Large Tasks

**Before (too big, ~30 minutes):**
```
1. Implement user authentication
```

**After (2-5 minutes each):**
```
1. [serial] Create User type in src/types/user.ts
2. [parallel] Create auth service file structure
3. [parallel] Write failing test for login()
4. [serial] Implement login() to pass test
5. [parallel] Write failing test for logout()
6. [serial] Implement logout() to pass test
7. [serial] Add auth middleware
8. [serial] Wire auth routes in app.ts
```

## Task Format

```markdown
N. [parallel|serial] <Step description>
   - File: `exact/path/to/file.ts`
   - Code: (for non-trivial changes)
     ```typescript
     export async function login(email: string, password: string): Promise<string> {
       // Implementation
     }
     ```
   - TDD: Write failing test for <behavior> first
   - Evidence: `bun run test auth.test.ts` passes
```

## Parallelization Markers

### Marker Definitions

| Marker | Meaning | Use When |
|--------|---------|----------|
| `[parallel]` | Can run simultaneously | No shared files or resources |
| `[serial]` | Must wait for prior steps | Touches shared files or depends on prior output |
| `[MERGE-WALL]` | Blocks ALL parallel work | Directory restructuring, config changes |

### Example Plan Structure

```markdown
1. [parallel] Create user model in src/models/user.ts
2. [parallel] Create auth service in src/services/auth.ts
3. [serial] Integrate user model into auth service
4. [parallel] Write unit tests for user model
5. [parallel] Write unit tests for auth service
6. [serial] Run full test suite and verify integration
```

### Merge Wall Detection

Flag steps that create merge walls - points where parallel work MUST serialize.

**Merge Wall Triggers:**
- Directory restructuring (affects all imports)
- Core abstraction changes (ripples through codebase)
- Cross-cutting concerns (logging, auth, database schema)
- Configuration file changes (affects all workers' assumptions)
- Package.json/lockfile modifications

**Mark merge walls explicitly:**
```
3. [serial] [MERGE-WALL] Restructure src/ into feature folders
   Reason: All subsequent file paths will change
```

**Strategy:** Front-load merge walls early in the plan, then parallelize remaining work.

## Evidence Definitions

Each task MUST define completion evidence. No step is complete without observable proof.

### Evidence Types

| Type | Example |
|------|---------|
| **Command** | `bun run test` exits with code 0 |
| **Output** | "All 47 tests pass" appears in stdout |
| **File state** | `src/models/user.ts` exists and exports `User` |
| **Observable** | Button appears in UI when page loads |
| **Metric** | Coverage >= 80% reported by vitest |

### Evidence in Tasks

```markdown
2. [parallel] Create auth service
   - File: src/services/auth.ts
   - Exports: AuthService class with login(), logout(), verify()
   - Evidence: `bun run typecheck` passes, `grep "export class AuthService" src/services/auth.ts` succeeds
```

**Why this matters:** Prevents "should work" thinking. Completion can be verified objectively.

## TDD Requirements

**Every implementation step MUST include TDD.**

### TDD in Task Format

```markdown
3. [serial] Implement user authentication
   - File: src/services/auth.ts
   - TDD: Write failing test for login() before implementing
   - Evidence: Test fails → implementation passes test → coverage ≥80%
```

### TDD by Step Type

| Step Type | TDD Requirement |
|-----------|-----------------|
| New feature | Failing test first, then implement |
| Bug fix | Failing test reproduces bug, then fix |
| Refactor | Existing tests pass before and after |
| API endpoint | Integration test before implementation |

## INVEST Criteria

### Independent
- Can be worked on in isolation
- Doesn't block multiple other tasks
- Can be merged independently

### Negotiable
- Describes what, not how
- Allows for discovery during implementation
- Doesn't over-specify solution

### Valuable
- Moves the project forward
- Could theoretically be shipped alone

### Estimable
- Well-defined boundaries (2-5 minutes)
- No major unknowns
- Acceptance criteria are concrete

### Small
- Target: 2-5 minutes of focused work
- If larger, decompose further

### Testable
- Has observable evidence
- Can be objectively verified
- Defines "done"

## Complete Task Examples

### Example: API Endpoint (2-5 min each)

```markdown
### Phase 1: Setup

1. [parallel] Create User type
   - File: `src/types/user.ts`
   - Code:
     ```typescript
     export interface User {
       id: string;
       email: string;
       name: string;
     }
     ```
   - Evidence: `bun run typecheck` passes

2. [parallel] Write failing test for GET /users/:id
   - File: `src/routes/users.test.ts`
   - TDD: Test expects 200 with user object
   - Evidence: `bun run test users.test.ts` fails with "expected 200"

### Phase 2: Implementation

3. [serial] Implement GET /users/:id endpoint
   - File: `src/routes/users.ts`
   - Code:
     ```typescript
     app.get('/users/:id', async (req, res) => {
       const user = await db.users.findById(req.params.id);
       if (!user) return res.status(404).json({ error: 'Not found' });
       return res.json(user);
     });
     ```
   - TDD: Make failing test pass
   - Evidence: `bun run test users.test.ts` passes

4. [parallel] Add 404 test case
   - File: `src/routes/users.test.ts`
   - TDD: Test expects 404 for non-existent ID
   - Evidence: Test passes

5. [parallel] Add 400 test case
   - File: `src/routes/users.test.ts`
   - TDD: Test expects 400 for invalid ID format
   - Evidence: Test passes
```

### Example: UI Component (2-5 min each)

```markdown
1. [parallel] Create component file structure
   - File: `src/components/UserAvatar/index.ts`
   - Evidence: File exists with empty export

2. [parallel] Write failing test for image display
   - File: `src/components/UserAvatar/UserAvatar.test.tsx`
   - TDD: Test expects img element when imageUrl provided
   - Evidence: Test fails

3. [serial] Implement basic avatar with image
   - File: `src/components/UserAvatar/UserAvatar.tsx`
   - TDD: Make image test pass
   - Evidence: `bun run test UserAvatar` passes

4. [parallel] Write failing test for initials fallback
   - File: `src/components/UserAvatar/UserAvatar.test.tsx`
   - TDD: Test expects initials when no imageUrl
   - Evidence: Test fails

5. [serial] Implement initials fallback
   - File: `src/components/UserAvatar/UserAvatar.tsx`
   - TDD: Make initials test pass
   - Evidence: Both tests pass
```

## Dependency Graph

Build tasks in dependency order:

```
[Foundation Tasks] ─┬─→ [Core Feature Tasks] ─→ [Integration Tasks]
                    │
[Parallel Tasks] ───┘
```

### Ordering Principles

1. **Merge walls first** - Front-load restructuring
2. **Types before logic** - Schema/types before implementation
3. **Tests before code** - TDD requires failing test first
4. **Core before edge** - Happy path before error handling
5. **Parallelize after merge walls** - Fan out remaining work

## Task Quality Checklist

Before finalizing task list:

- [ ] Each task is 2-5 minutes
- [ ] All tasks have `[parallel]` or `[serial]` marker
- [ ] Merge walls identified and front-loaded
- [ ] Evidence defined for every task
- [ ] TDD requirement included for code changes
- [ ] Exact file paths specified
- [ ] Code snippets for non-trivial changes
- [ ] Dependencies are explicit
- [ ] No circular dependencies
- [ ] Critical path identified

## Anti-Patterns

### Too Big
```
❌ 1. Implement entire auth system
✅ 1-8. [8 tasks of 2-5 minutes each]
```

### Missing Evidence
```
❌ Evidence: Should work
✅ Evidence: `bun run test auth.test.ts` exits 0
```

### Missing Parallelization
```
❌ 1. Create user model
   2. Create auth service
✅ 1. [parallel] Create user model
   2. [parallel] Create auth service
```

### Vague Files
```
❌ File: auth file
✅ File: src/services/auth.ts
```

### Missing TDD
```
❌ 3. Implement login function
✅ 3. [serial] Implement login function
   - TDD: Write failing test first
   - Evidence: Test fails → passes → coverage ≥80%
```
