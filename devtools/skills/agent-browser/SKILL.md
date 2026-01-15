---
name: agent-browser
description: Headless browser automation CLI for AI agents using ref-based element selection. Routes between agent-browser, Playwright MCP, and Claude Chrome integration.
license: MIT
triggers:
  - "(?i)\\bagent[- ]?browser\\b"
  - "(?i)\\bbrowse\\s+website\\b"
  - "(?i)\\bfill\\s+form\\b"
  - "(?i)\\bclick\\s+button\\b"
  - "(?i)\\btake\\s+screenshot\\b"
  - "(?i)\\bscrape\\s+page\\b"
  - "(?i)\\bweb\\s+automation\\b"
  - "(?i)\\bheadless\\s+browser\\b"
  - "@e[0-9]+"
  - "(?i)\\bsnapshot\\b"
  - "(?i)\\bweb\\s+scraping\\b"
  - "(?i)\\bautomate\\s+browser\\b"
  - "(?i)\\bbrowser\\s+automation\\b"
  - "(?i)\\bnavigate\\s+to\\b"
  - "(?i)\\bextract\\s+data\\b"
  - "(?i)\\bweb\\s+crawl\\b"
  - "(?i)\\bvercel[- ]?labs\\b"
---

<objective>
Automate browser interactions using the appropriate tool for the use case. Default to agent-browser for AI agent workflows, Playwright MCP for testing, and Claude Chrome for interactive sessions.
</objective>

<routing>
**Choose the right tool based on your use case:**

| Use Case                                | Tool           | Why                                                   |
| --------------------------------------- | -------------- | ----------------------------------------------------- |
| AI agent workflows (headless, scripted) | agent-browser  | Refs enable deterministic selection, no vision needed |
| E2E testing with assertions             | Playwright MCP | Full test API, fixtures, retries, parallelization     |
| User watching/debugging live            | Claude Chrome  | Visual feedback, user can intervene                   |
| Form filling with AI decisions          | agent-browser  | Snapshot provides semantic context                    |
| Complex multi-step test suites          | Playwright MCP | Better test organization                              |
| Quick page inspection                   | Claude Chrome  | Immediate visual feedback                             |
| Scraping/data extraction                | agent-browser  | Structured output, sessions                           |
| Recording user flows                    | Claude Chrome  | GIF recording, visual capture                         |

**Decision flow:**

1. Is user present and watching? → Claude Chrome
2. Is this a test with assertions? → Playwright MCP
3. Otherwise → agent-browser (default)
   </routing>

<essential_principles>

- Always snapshot before interacting to get fresh refs
- Use `--json` flag for machine-readable output
- Re-snapshot after navigation or major state changes
- Use refs (@e1, @e2) not CSS selectors when available
- Use sessions for parallel browser instances
  </essential_principles>

<quick_start>
**The ref pattern (core workflow):**

```bash
# 1. Navigate and snapshot
agent-browser open example.com
agent-browser snapshot -i --json

# 2. AI identifies refs from snapshot output
# Output: { "refs": { "@e1": "button:Submit", "@e2": "input:Email" } }

# 3. Interact using refs
agent-browser click @e1
agent-browser fill @e2 "user@example.com"

# 4. Re-snapshot after state changes
agent-browser snapshot -i --json
```

**Why refs work for AI:**

- Deterministic element IDs from accessibility tree
- No vision model needed
- Semantic labels (button, input, link)
- Survives page changes within session
  </quick_start>

<reference_index>
| Reference | Content |
|-----------|---------|
| commands-reference.md | All CLI commands: navigation, snapshots, interactions, waits, sessions, selectors |
| tool-comparison.md | Playwright MCP vs Claude Chrome - when to use each, feature comparison |
| workflow-examples.md | Login flow, data extraction, form filling, multi-step checkout, parallel sessions |
</reference_index>

<installation>
**agent-browser setup:**

```bash
npm install -g agent-browser
agent-browser install  # Downloads Chromium
```

**Verify installation:**

```bash
agent-browser open https://example.com
agent-browser snapshot -i
agent-browser close
```

</installation>

<constraints>
**Banned:**
- Guessing refs without snapshotting first
- Hardcoding refs across sessions (they change)
- Using CSS selectors when refs are available
- Interacting without re-snapshotting after navigation

**Required:**

- Always snapshot before interacting to get fresh refs
- Use `--json` flag for machine-readable output
- Re-snapshot after navigation or major state changes

**Best practices:**

- Use `-i` (interactive) to reduce snapshot size
- Use `-c` (compact) to remove empty nodes
- Scope snapshots with `-s` when page is large
  </constraints>

<anti_patterns>

- **Stale Refs:** Using refs from previous snapshot after page navigation; always re-snapshot
- **CSS Selector Fallback:** Defaulting to CSS selectors when refs are available; refs are more reliable
- **Missing Waits:** Clicking before page fully loads; use wait conditions for async content
- **Session Confusion:** Mixing refs between different browser sessions
- **Snapshot Bloat:** Taking full-page snapshots when scoped snapshots would suffice
  </anti_patterns>

<related_skills>
**E2E testing patterns:** Load via `Skill({ skill: "devtools:playwright" })` when:

- Writing test suites with assertions
- Need Page Object pattern guidance
- Setting up CI/CD for tests

**Design verification:** Load via `Skill({ skill: "devtools:vercel-design-guidelines" })` when:

- Checking accessibility of automated flows
- Validating UI patterns during testing
  </related_skills>

<success_criteria>

- [ ] Correct tool selected based on use case routing
- [ ] Snapshots taken before interactions (for agent-browser)
- [ ] Refs used instead of CSS selectors
- [ ] Wait conditions used for async operations
- [ ] Re-snapshot after state changes
      </success_criteria>

<evolution>
**Extension Points:**
- Add domain-specific workflow templates (login flows, checkout, data extraction)
- Extend with error recovery patterns for flaky interactions
- Integrate with visual regression testing workflows

**Timelessness:** Browser automation is essential for AI agents; ref-based element selection provides deterministic interactions regardless of UI framework changes.
</evolution>
