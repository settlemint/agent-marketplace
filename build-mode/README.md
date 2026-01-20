# Build Mode Plugin v1.4.6

TDD-driven implementation execution with subagent orchestration, systematic debugging, visual testing, and verification before completion.

## Overview

Build Mode complements Plan Mode by executing implementation plans with rigorous quality gates. It guides you to verify code is **complete and correct before CI** through:

- **TDD Workflow**: Red-Green-Refactor cycle for all changes
- **Subagent Orchestration**: Fresh context per task prevents pollution
- **Two-Stage Review**: Spec compliance, then quality assessment
- **Visual Testing**: Chrome MCP + Playwright for UI verification
- **Verification Before Completion**: No claims without evidence

## Installation

```bash
# Via marketplace (when published)
/plugin marketplace add settlemint/agent-marketplace
/plugin install build-mode@settlemint

# Local development
claude --plugin-dir ~/path/to/build-mode
```

## Commands

### `/build [task]`

Execute implementation with full TDD workflow and quality gates.

```
/build "Add user authentication with JWT"
/build continue  # Resume from plan
```

**Workflow:**
1. Task setup and test coverage check
2. TDD implementation (Red → Green → Refactor)
3. Two-stage review (Spec → Quality)
4. Error handling verification
5. Visual testing (if UI)
6. Final validation gate
7. Code health cleanup

### `/fixup [PR number]`

Fix PR review comments and CI failures with educational feedback.

```
/fixup        # Current branch PR
/fixup 123    # Specific PR
```

**Features:**
- Fetches unresolved review threads
- Checks CI status
- Fixes issues and pushes
- Resolves threads with feedback (✓ correct, ◐ partial, ✗ incorrect)
- Verifies all threads resolved

## Agents

| Agent | Purpose | When Used |
|-------|---------|-----------|
| `task-implementer` | TDD implementation | Each task in plan |
| `spec-reviewer` | Requirement verification | After implementation |
| `quality-reviewer` | Code quality assessment | After spec passes |
| `silent-failure-hunter` | Error handling gaps | All code changes |
| `visual-tester` | UI verification | Frontend changes |
| `completion-validator` | Final gate | Before marking done |

## Skills

### implementing-code

Core TDD and verification methodology:
- Red-Green-Refactor workflow
- 5-step gate function
- Debugging workflow
- Visual testing patterns

### improving-code-health

"Leave it better than you found it" principle:
- Opportunistic cleanup during implementation
- Dead code detection
- Debug cruft removal
- Code smell identification

## Hooks

Advisory-only hooks that never block normal operations:

| Hook | Event | Purpose |
|------|-------|---------|
| TDD Reminder | PreToolUse (Write/Edit) | Reminder to follow TDD during implementation |

## Integration with Plan Mode

Build Mode is designed to work with Plan Mode:

1. **Plan Mode** creates the implementation plan
2. **Build Mode** executes each task with TDD
3. Progress is tracked across both plugins
4. If context is compacted, re-open the plan file to resume

```bash
# Typical workflow
/plan "Add user dashboard feature"  # Creates plan
/build continue                      # Executes plan with TDD
```

## Legacy Code Strategy

Build Mode handles legacy code intelligently:

**Priority for test backfilling:**
- P0: Security, auth, payments - MUST test before modifying
- P1: Business logic - Test before modifying
- P2: API endpoints - Add integration tests
- P3+: Utilities - Opportunistic

When modifying files without tests:
1. Write characterization tests for existing behavior
2. Then proceed with TDD for new changes
3. Silent failure hunter catches error handling gaps

## Visual Testing

Two tools for comprehensive UI verification:

**Chrome MCP** (Development iteration):
- Real-time browser interaction
- Screenshot capture
- Console log reading
- GIF recording for flows

**Playwright** (E2E test generation):
- Persistent test scripts
- CI-ready assertions
- Cross-browser support

## Quality Gates

Before moving to next task:
- [ ] Tests pass: `bun run test`
- [ ] Lint clean: `bun run lint`
- [ ] CI gates: `bun run ci`
- [ ] Spec review: APPROVED
- [ ] Quality review: APPROVED
- [ ] Error handling: No P0 issues

## MCP Servers

- **Playwright**: E2E testing and automation

Chrome MCP is used via the built-in tools when available.

## Configuration

The plugin uses these defaults which work with most TypeScript/Bun projects:

```bash
bun run test   # Test command
bun run lint   # Lint command
bun run ci     # CI validation (optional)
```

## Philosophy

### Evidence Over Claims

Every completion claim requires evidence:
- Test output (pass/fail counts)
- Screenshots for UI
- Lint status
- Files modified with line ranges

### The 5-Step Gate

1. **IDENTIFY**: What should we verify?
2. **RUN**: Execute verification
3. **READ**: Examine output
4. **VERIFY**: Cross-reference claims
5. **CLAIM**: Only now assert completion

### TDD Non-Negotiables

1. Never write implementation before test
2. Test must fail for the RIGHT reason
3. Write MINIMUM code to pass
4. Refactor only while green

## Troubleshooting

**Hooks not triggering:**
- Restart Claude Code session after plugin changes
- Check `claude --debug` for hook loading

**Tests not found:**
- Ensure `bun run test` works in project root
- Check test file naming (`.test.ts`, `.spec.ts`)

**Visual testing issues:**
- Ensure dev server is running
- Check Chrome MCP connection
- Verify localhost is accessible

## Related Plugins

- **plan-mode**: Implementation planning and architecture
- **devtools**: Developer tooling and utilities

## Version History

- **v1.4.6**: Add skill invocation hints to hook systemMessages for better auto-loading
- **v1.4.5**: Convert PreToolUse hooks from prompt-based to command-based for deterministic behavior (fixes blocking issues)
- **v1.4.4**: Update skill descriptions to use official third-person trigger format for better auto-triggering
- **v1.4.3**: Fix prompt hook to return proper JSON format (use 'allow' instead of 'approve')
- **v1.4.2**: Remove SessionStart hook (prompt hooks not supported for SessionStart event)
- **v1.4.1**: Add missing timeout values to prompt hooks (fixes SessionStart:startup hook error)
- **v1.4.0**: Make hooks advisory-only (fail-open), remove blocking command hooks, and detect build mode via permissions as a fallback to explicit /build
- **v1.3.0**: Added proactive agent orchestration - SessionStart hook injects agent guidance, all agent descriptions updated with PROACTIVELY keyword, implementing-code skill now explicitly requires build-mode agents instead of generic Explore/general-purpose agents
- **v1.2.1**: Strengthened TDD hook messages with explicit REQUIRED/MANDATORY language and `<system-reminder>` formatting to reduce Claude ignoring reminders
- **v1.2.0**: Add iterative-retrieval skill for subagent context refinement with automatic integration into debugging and review workflows
- **v1.1.1**: Fixed Playwright MCP package name from `@anthropic/mcp-playwright` to `@playwright/mcp`
- **v1.1.0**: Replaced slow LLM-based hooks with fast command-based hooks - TDD enforcement now via emphatic skill instructions (superpowers-style) instead of per-edit LLM validation. Zero LLM calls per edit cycle.
- **v1.0.3**: Fixed TDD hook test detection - improved prompt to properly recognize test file edits and test runs in conversation history
- **v1.0.2**: Changed TDD hook from soft reminders to hard blocking - code edits now require test evidence
- **v1.0.1**: Fixed Stop hook JSON validation error by using natural language instructions instead of explicit approve/block format
- **v1.0.0**: Initial release with TDD workflow, subagent orchestration, visual testing, and quality gates

## License

MIT
