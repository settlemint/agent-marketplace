---
name: chrome-testing
description: Use Chrome MCP for interactive browser testing. Covers navigation, forms, screenshots.
license: MIT
triggers:
  - "test in browser"
  - "chrome testing"
  - "fill form"
  - "click button"
  - "take screenshot"
  - "browser automation"
  - "chrome mcp"
  - "claude in chrome"
---

<objective>
Test applications interactively in Chrome using claude-in-chrome MCP tools.
</objective>

<routing>
**Choose the right tool based on your use case:**

| Use Case | Tool | Why |
|----------|------|-----|
| Interactive testing (user watching) | Chrome MCP | Visual feedback, real browser |
| CI/CD automated tests | Playwright MCP | Headless, deterministic |
| E2E test suites with assertions | Playwright MCP | Test API, fixtures, retries |
| Quick page inspection | Chrome MCP | Immediate visual feedback |
| Recording user flows | Chrome MCP | GIF recording, visual capture |

**Decision flow:**
1. Is user present and watching? → Chrome MCP
2. Is this a test with assertions for CI? → Playwright MCP
3. Need to record/demo a flow? → Chrome MCP
</routing>

<authentication>
**SettleMint Local Development:**
- Email: admin@settlemint.com
- Password: settlemint
- Pincode: 111111

*Note: These are local development credentials only.*
</authentication>

<quick_start>
**Workflow:**
1. Get tab context: `tabs_context_mcp`
2. Create/navigate: `tabs_create_mcp` or `navigate`
3. Read page: `read_page` or `get_page_text`
4. Fill forms: `form_input`
5. Click/interact: `computer`
6. Record: `gif_creator`
7. Debug: `read_console_messages`

**Example login flow:**
```
1. tabs_context_mcp() → Get current tabs
2. tabs_create_mcp({ url: "http://localhost:3000/login" })
3. form_input({ selector: "[name=email]", value: "admin@settlemint.com" })
4. form_input({ selector: "[name=password]", value: "settlemint" })
5. computer({ action: "click", selector: "button[type=submit]" })
6. read_page() → Verify login success
```
</quick_start>

<mcp_tools>
| Tool | Purpose |
|------|---------|
| `tabs_context_mcp` | Get current browser tabs (call first!) |
| `tabs_create_mcp` | Create new tab with URL |
| `navigate` | Go to URL in current tab |
| `read_page` | Read page content and structure |
| `get_page_text` | Get text content only |
| `form_input` | Fill form fields |
| `computer` | Click, type, scroll, interact |
| `find` | Find elements on page |
| `gif_creator` | Record interactions as GIF |
| `read_console_messages` | Debug console output |
| `read_network_requests` | Debug network activity |
| `javascript_tool` | Execute JavaScript |
| `resize_window` | Change browser dimensions |
</mcp_tools>

<essential_principles>
- Always call `tabs_context_mcp` first to get tab context
- Use `form_input` for form fields, `computer` for clicks
- Call `read_page` after navigation to verify state
- Use `gif_creator` to record multi-step flows for review
- Check `read_console_messages` when debugging issues
</essential_principles>

<constraints>
**Required:**
- Claude in Chrome extension must be installed and connected
- User must be present (interactive use only)
- Call `tabs_context_mcp` at session start

**Limitations:**
- Not suitable for CI/CD (use Playwright MCP instead)
- Requires active Chrome browser
- Cannot run headless

**For automated/CI testing:**
Load via `Skill({ skill: "devtools:playwright" })` instead.
</constraints>

<anti_patterns>
- **Missing Tab Context:** Interacting without calling `tabs_context_mcp` first
- **CI Usage:** Trying to use Chrome MCP in CI/CD pipelines (use Playwright)
- **Stale State:** Not calling `read_page` after navigation to verify current state
- **Wrong Tool:** Using `computer` for form input (use `form_input` instead)
</anti_patterns>

<related_skills>
**E2E testing with assertions:** Load via `Skill({ skill: "devtools:playwright" })` when:
- Writing test suites for CI/CD
- Need Page Object pattern guidance
- Require deterministic, headless testing

**Design verification:** Load via `Skill({ skill: "devtools:vercel-design-guidelines" })` when:
- Checking accessibility of automated flows
- Validating UI patterns during testing
</related_skills>

<success_criteria>
- [ ] Chrome extension installed and connected
- [ ] Tab context retrieved before interactions
- [ ] Forms filled with correct credentials
- [ ] Actions visible to user for verification
- [ ] GIF recorded for complex flows (optional)
</success_criteria>
