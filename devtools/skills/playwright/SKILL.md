---
name: playwright
description: Playwright E2E testing. Use when asked to "write E2E test", "test user flow", or "automate browser testing". Covers Page Object pattern, web-first assertions, and proper locators.
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
**Workflow:**
1. Create Page Object extending BasePage
2. Add locators using getByRole/getByLabel priority
3. Write test with describe.serial for related tests
4. Use web-first assertions (toBeVisible, toHaveText)
5. Run with `npx playwright test`

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

<few_shot_examples>
<example name="page-object-pattern">
<input>Create a Page Object for a todo app with add, complete, and filter functionality</input>
<output>
**tests/pages/base.page.ts:**
```typescript
import { Page } from "@playwright/test";

export class BasePage {
  constructor(protected page: Page) {}

  async goto(path: string = "/") {
    await this.page.goto(path);
  }
}
```

**tests/pages/todo.page.ts:**
```typescript
import { expect, Page } from "@playwright/test";
import { BasePage } from "./base.page";

export class TodoPage extends BasePage {
  // Locators - using getByRole/getByLabel priority
  private readonly newTodoInput = () => this.page.getByLabel("New todo");
  private readonly todoList = () => this.page.getByRole("list", { name: "Todo items" });
  private readonly todoItems = () => this.page.getByRole("listitem");
  private readonly filterAll = () => this.page.getByRole("link", { name: "All" });
  private readonly filterActive = () => this.page.getByRole("link", { name: "Active" });
  private readonly filterCompleted = () => this.page.getByRole("link", { name: "Completed" });
  private readonly clearCompleted = () => this.page.getByRole("button", { name: "Clear completed" });

  // Get specific todo item
  private todoItem(text: string) {
    return this.todoItems().filter({ hasText: text });
  }

  // Actions
  async addTodo(text: string) {
    await this.newTodoInput().fill(text);
    await this.newTodoInput().press("Enter");
  }

  async completeTodo(text: string) {
    await this.todoItem(text).getByRole("checkbox").check();
  }

  async deleteTodo(text: string) {
    // Hover to reveal delete button (common pattern)
    await this.todoItem(text).hover();
    await this.todoItem(text).getByRole("button", { name: "Delete" }).click();
  }

  async filterBy(filter: "all" | "active" | "completed") {
    const filters = {
      all: this.filterAll,
      active: this.filterActive,
      completed: this.filterCompleted,
    };
    await filters[filter]().click();
  }

  async clearAllCompleted() {
    await this.clearCompleted().click();
  }

  // Assertions (keep in page object for reuse)
  async expectTodoCount(count: number) {
    await expect(this.todoItems()).toHaveCount(count);
  }

  async expectTodoVisible(text: string) {
    await expect(this.todoItem(text)).toBeVisible();
  }

  async expectTodoNotVisible(text: string) {
    await expect(this.todoItem(text)).not.toBeVisible();
  }

  async expectTodoCompleted(text: string) {
    await expect(this.todoItem(text).getByRole("checkbox")).toBeChecked();
  }
}
```

**tests/pages/pages.ts:**
```typescript
import { Page } from "@playwright/test";
import { TodoPage } from "./todo.page";

export function Pages(page: Page) {
  return {
    todoPage: new TodoPage(page),
    // Add more pages as needed
  };
}
```

**tests/todo.spec.ts:**
```typescript
import { test } from "@playwright/test";
import { Pages } from "./pages/pages";

test.describe.serial("Todo management", () => {
  let pages: ReturnType<typeof Pages>;

  test.beforeEach(async ({ page }) => {
    pages = Pages(page);
    await pages.todoPage.goto("/");
  });

  test("should add a new todo", async () => {
    await pages.todoPage.addTodo("Buy groceries");
    await pages.todoPage.expectTodoVisible("Buy groceries");
    await pages.todoPage.expectTodoCount(1);
  });

  test("should complete a todo", async () => {
    await pages.todoPage.addTodo("Learn Playwright");
    await pages.todoPage.completeTodo("Learn Playwright");
    await pages.todoPage.expectTodoCompleted("Learn Playwright");
  });

  test("should filter completed todos", async () => {
    await pages.todoPage.addTodo("Task 1");
    await pages.todoPage.addTodo("Task 2");
    await pages.todoPage.completeTodo("Task 1");

    await pages.todoPage.filterBy("completed");
    await pages.todoPage.expectTodoVisible("Task 1");
    await pages.todoPage.expectTodoNotVisible("Task 2");

    await pages.todoPage.filterBy("active");
    await pages.todoPage.expectTodoNotVisible("Task 1");
    await pages.todoPage.expectTodoVisible("Task 2");
  });
});
```
</output>
<reasoning>Page Object encapsulates all selectors and actions. Uses getByRole/getByLabel exclusively. Assertions in page object enable reuse. Tests read like user stories with no selectors visible.</reasoning>
</example>

<example name="authentication-with-storage-state">
<input>Set up authentication that persists across tests using storage state</input>
<output>
**tests/auth.setup.ts:**
```typescript
import { test as setup, expect } from "@playwright/test";
import path from "path";

const authFile = path.join(__dirname, "../.auth/user.json");

setup("authenticate", async ({ page }) => {
  // Navigate to login
  await page.goto("/login");

  // Fill credentials
  await page.getByLabel("Email").fill(process.env.TEST_USER_EMAIL!);
  await page.getByLabel("Password").fill(process.env.TEST_USER_PASSWORD!);
  await page.getByRole("button", { name: "Sign in" }).click();

  // Wait for auth to complete
  await expect(page.getByRole("heading", { name: "Dashboard" })).toBeVisible();

  // Save authentication state
  await page.context().storageState({ path: authFile });
});
```

**playwright.config.ts:**
```typescript
import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  projects: [
    // Setup project runs first
    { name: "setup", testMatch: /.*\.setup\.ts/ },

    // Tests use authenticated state
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
        storageState: ".auth/user.json",
      },
      dependencies: ["setup"],
    },
  ],
});
```

**tests/dashboard.spec.ts:**
```typescript
import { test, expect } from "@playwright/test";

// This test runs with authenticated state (no login needed)
test("authenticated user can access dashboard", async ({ page }) => {
  await page.goto("/dashboard");

  // Already logged in from setup
  await expect(page.getByRole("heading", { name: "Dashboard" })).toBeVisible();
  await expect(page.getByText("Welcome back")).toBeVisible();
});
```

**.gitignore addition:**
```
# Playwright auth state
.auth/
```
</output>
<reasoning>Storage state persists cookies/localStorage between tests, avoiding repeated logins. Setup project runs once before test projects. Auth file excluded from git for security.</reasoning>
</example>
</few_shot_examples>

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

1. [ ] Context7 docs fetched for current API
2. [ ] Page objects encapsulate selectors
3. [ ] Web-first assertions used
4. [ ] Tests are isolated
5. [ ] Proper locator strategy (getByRole preferred)
</success_criteria>

<evolution>
**Extension Points:**

- Add custom fixtures for common test setup patterns
- Create domain-specific Page Object base classes
- Add visual regression testing with screenshot comparisons

**Timelessness:** E2E testing with semantic locators and auto-waiting assertions applies to any web testing framework.
</evolution>
