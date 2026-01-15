---
name: playwright
description: Playwright E2E testing with Page Object pattern, web-first assertions, and proper locators. Triggers on playwright, e2e, page object, getByRole.
license: MIT
triggers:
  - "playwright"
  - "playwrite"
  - "plawright"
  - "e2e"
  - "end[- ]?to[- ]?end"
  - "page[- ]?object"
  - "getByRole"
  - "getByLabel"
  - "getByTestId"
  - "getByText"
  - "browser.*test"
  - "test.*browser"
  - "integration.*test"
  - "test.*integration"
  - "web.*test"
  - "test.*web.*app"
  - "automat.*browser"
  - "browser.*automat"
  - "headless"
  - "headed.*test"
  - "toBeVisible"
  - "toHaveText"
  - "click.*fill"
  - "waitFor"
  - "\\.spec\\.ts"
  - "npx playwright"
  - "test\\.describe"
  - "functional.*test"
  - "ui.*test"
  - "test.*ui"
  - "user.*flow.*test"
  - "test.*user.*flow"
  - "smoke.*test"
  - "regression.*test"
  - "cross[- ]?browser"
---

<objective>
Write reliable E2E tests using Playwright with the Page Object pattern. Use web-first assertions that auto-wait and retry, with proper locator strategies.
</objective>

<mcp_first>
**CRITICAL: Always fetch Playwright documentation for current API.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_context7__query-docs" })
```

```typescript
// Locator patterns
mcp__context7__query_docs({
  libraryId: "/microsoft/playwright",
  query: "How do I use getByRole, getByLabel, getByTestId, and locator?",
});

// Assertions
mcp__context7__query_docs({
  libraryId: "/microsoft/playwright",
  query: "How do I use expect with toBeVisible, toHaveText, and toContainText?",
});

// Page interactions
mcp__context7__query_docs({
  libraryId: "/microsoft/playwright",
  query: "How do I use click, fill, check, and waitFor?",
});
```

**Note:** Context7 v2 uses server-side filtering. Use descriptive natural language queries.
</mcp_first>

<quick_start>
**Page Object pattern:**

```typescript
// pages/login.page.ts
class LoginPage extends BasePage {
  async login(email: string, password: string) {
    await this.page.getByLabel("Email").fill(email);
    await this.page.getByLabel("Password").fill(password);
    await this.page.getByRole("button", { name: "Sign in" }).click();
  }

  async verifyLoggedIn() {
    await expect(
      this.page.getByRole("heading", { name: "Dashboard" }),
    ).toBeVisible();
  }
}
```

**Test structure:**

```typescript
import { test, expect } from "@playwright/test";
import { Pages } from "../pages/pages";

test.describe.serial("Login flow", () => {
  let pages: ReturnType<typeof Pages>;

  test.beforeEach(async ({ page }) => {
    pages = Pages(page);
  });

  test("should login successfully", async () => {
    await pages.loginPage.goto();
    await pages.loginPage.login("user@example.com", "password");
    await pages.loginPage.verifyLoggedIn();
  });
});
```

</quick_start>

<locator_priority>
Use locators in this order (most to least preferred):

1. `getByRole()` - Accessible name
2. `getByLabel()` - Form labels
3. `getByText()` - Visible text
4. `getByTestId()` - Test IDs
5. CSS selectors - Last resort

```typescript
// ✅ Preferred
page.getByRole("button", { name: "Submit" });
page.getByLabel("Email");
page.getByText("Welcome");

// ⚠️ Use when needed
page.getByTestId("submit-button");

// ❌ Avoid
page.locator(".btn-primary");
page.locator("#submit");
```

</locator_priority>

<assertions>
**Web-first assertions (auto-wait):**

```typescript
await expect(locator).toBeVisible();
await expect(locator).toHaveText("expected");
await expect(locator).toContainText("partial");
await expect(locator).toHaveValue("value");
await expect(locator).toBeEnabled();
await expect(locator).toBeChecked();
await expect(page).toHaveURL(/pattern/);
await expect(page).toHaveTitle("Title");
```

</assertions>

<constraints>
**Banned:** Selectors in test files (use page objects), `isVisible()`, CSS class selectors, `page.waitForTimeout()`, `.only`/`.skip` in commits

**Required:**

- Page Objects extend `BasePage`
- `test.describe.serial()` for related tests
- Web-first assertions (auto-wait/retry)
- Extended timeouts for slow operations

**Locator Priority:** `getByRole()` → `getByLabel()` → `getByText()` → `getByTestId()` → CSS
</constraints>

<anti_patterns>
**Common mistakes to avoid:**

- Using `isVisible()` instead of `toBeVisible()` (no auto-wait)
- Hardcoded `waitForTimeout()` instead of web-first assertions
- CSS selectors for elements that have accessible names
- Selectors directly in test files instead of Page Objects
- Committing `.only` or `.skip` to version control
  </anti_patterns>

<commands>
```bash
npx playwright test                    # Run all tests
npx playwright test --ui               # Interactive UI mode
npx playwright test --headed           # Show browser
npx playwright test -g "login"         # Filter by name
npx playwright show-report             # View HTML report
```
</commands>

<library_ids>
Skip resolve step for these known IDs:

| Library    | Context7 ID           |
| ---------- | --------------------- |
| Playwright | /microsoft/playwright |

</library_ids>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production Playwright testing patterns",
      researchGoal: "Search for page object and E2E patterns",
      reasoning: "Need real-world examples of Playwright usage",
      keywordsToSearch: ["getByRole", "playwright", "test.describe"],
      extension: "ts",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Page objects: `keywordsToSearch: ["extends BasePage", "playwright", "page object"]`
- Assertions: `keywordsToSearch: ["toBeVisible", "toHaveText", "expect"]`
- Auth: `keywordsToSearch: ["storageState", "playwright", "authentication"]`
  </research>

<related_skills>

**Design guidelines:** Load via `Skill({ skill: "devtools:vercel-design-guidelines" })` when:

- Testing accessibility patterns (keyboard, focus, ARIA)
- Validating interaction patterns
- Checking responsive design behavior

**Design system:** Load via `Skill({ skill: "devtools:design-principles" })` when:

- Verifying design consistency across views
- Testing visual hierarchy and spacing

**Testing methodology (Trail of Bits):** Load for comprehensive testing:

- `Skill({ skill: "trailofbits:testing-handbook-skills" })` — Fuzzers, sanitizers, coverage guidance

</related_skills>

<success_criteria>

- [ ] Context7 docs fetched for current API
- [ ] Page objects encapsulate selectors
- [ ] Web-first assertions used
- [ ] Tests are isolated
- [ ] Proper locator strategy
      </success_criteria>

<evolution>
**Extension Points:**

- Add custom fixtures for common test setup patterns
- Create domain-specific Page Object base classes
- Add visual regression testing with screenshot comparisons

**Timelessness:** E2E testing with semantic locators and auto-waiting assertions applies to any web testing framework.
</evolution>
