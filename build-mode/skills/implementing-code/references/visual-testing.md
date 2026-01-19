# Visual Testing Reference

## Table of Contents

- [Overview](#overview)
- [Chrome MCP for Development](#chrome-mcp-for-development)
- [Playwright for Test Generation](#playwright-for-test-generation)
- [Visual Testing Workflow](#visual-testing-workflow)
- [Verification Patterns](#verification-patterns)
- [Anti-Patterns](#anti-patterns)

## Overview

Visual testing ensures UI changes work correctly in the actual browser. Use two complementary tools:

| Tool | Phase | Purpose |
|------|-------|---------|
| Chrome MCP | Development | Real-time verification, quick iterations |
| Playwright | Completion | Generate persistent E2E tests for CI |

## Chrome MCP for Development

Use during implementation for fast feedback loops.

### Available Tools

| Tool | Purpose |
|------|---------|
| `navigate` | Go to URL |
| `read_page` | Extract page content |
| `computer` | Screenshots, clicks, typing |
| `javascript_tool` | Run assertions in browser |
| `gif_creator` | Record interaction flows |
| `form_input` | Fill form fields |
| `find` | Locate elements |

### Navigation

```javascript
// Navigate to dev server
mcp__claude-in-chrome__navigate({
  url: "http://localhost:3000/feature"
})

// Wait for page to load
mcp__claude-in-chrome__read_page({
  selector: ".main-content"
})
```

### Taking Screenshots

```javascript
// Screenshot entire viewport
mcp__claude-in-chrome__computer({
  action: "screenshot"
})

// Screenshot specific element
mcp__claude-in-chrome__javascript_tool({
  code: `
    const element = document.querySelector('.target-component');
    element.scrollIntoView();
  `
})
mcp__claude-in-chrome__computer({
  action: "screenshot"
})
```

### Running Assertions

```javascript
// Verify element exists
mcp__claude-in-chrome__javascript_tool({
  code: `
    const button = document.querySelector('button[type="submit"]');
    if (!button) throw new Error('Submit button not found');
    return button.textContent;
  `
})

// Verify element state
mcp__claude-in-chrome__javascript_tool({
  code: `
    const input = document.querySelector('#email');
    return {
      value: input.value,
      disabled: input.disabled,
      valid: input.checkValidity()
    };
  `
})
```

### Interaction Testing

```javascript
// Click button
mcp__claude-in-chrome__computer({
  action: "click",
  coordinate: [100, 200] // x, y position
})

// Type in input
mcp__claude-in-chrome__form_input({
  selector: "#email",
  value: "test@example.com"
})

// Submit form
mcp__claude-in-chrome__computer({
  action: "click",
  element: "button[type='submit']"
})
```

### Recording Demos

```javascript
// Record interaction as GIF
mcp__claude-in-chrome__gif_creator({
  name: "login-flow",
  frames: 20,
  interval: 500 // ms between frames
})

// Perform actions while recording...
// GIF saved automatically
```

### Network Inspection

```javascript
// Check API calls
mcp__claude-in-chrome__read_network_requests({
  filter: "/api/"
})

// Verify response status
mcp__claude-in-chrome__javascript_tool({
  code: `
    // Check if API returned expected data
    return window.__lastApiResponse; // Assuming you set this
  `
})
```

## Playwright for Test Generation

Use before completion to create persistent E2E tests.

### Generating Test Files

```javascript
// Create a Playwright test
const testContent = `
import { test, expect } from '@playwright/test';

test('user can log in', async ({ page }) => {
  await page.goto('/login');

  await page.fill('#email', 'test@example.com');
  await page.fill('#password', 'password123');
  await page.click('button[type="submit"]');

  await expect(page.locator('.dashboard')).toBeVisible();
  await expect(page).toHaveURL('/dashboard');
});
`;

// Write to test file
Write({
  file_path: "tests/e2e/login.spec.ts",
  content: testContent
})
```

### Common Test Patterns

**Navigation test:**
```typescript
test('navigation works', async ({ page }) => {
  await page.goto('/');
  await page.click('a[href="/about"]');
  await expect(page).toHaveURL('/about');
});
```

**Form submission:**
```typescript
test('form submission succeeds', async ({ page }) => {
  await page.goto('/contact');
  await page.fill('#name', 'Test User');
  await page.fill('#email', 'test@example.com');
  await page.fill('#message', 'Hello world');
  await page.click('button[type="submit"]');

  await expect(page.locator('.success-message')).toBeVisible();
});
```

**Visual regression:**
```typescript
test('component looks correct', async ({ page }) => {
  await page.goto('/component-demo');
  await expect(page.locator('.target-component')).toHaveScreenshot();
});
```

**API interaction:**
```typescript
test('displays data from API', async ({ page }) => {
  await page.goto('/users');

  // Wait for API response
  await page.waitForResponse('/api/users');

  // Verify data rendered
  await expect(page.locator('.user-list')).toContainText('John Doe');
});
```

### Running Playwright Tests

```bash
# Run all E2E tests
bunx playwright test

# Run specific test
bunx playwright test tests/e2e/login.spec.ts

# Run with UI mode
bunx playwright test --ui

# Generate report
bunx playwright show-report
```

## Visual Testing Workflow

### Development Phase

```
1. Make code changes
    ↓
2. Start dev server: bun run dev
    ↓
3. Navigate with Chrome MCP
    ↓
4. Verify visually (screenshots)
    ↓
5. Run assertions (javascript_tool)
    ↓
6. Iterate if needed
    ↓
7. Looks correct? Proceed to completion
```

### Completion Phase

```
1. All development verification passed
    ↓
2. Generate Playwright test file
    ↓
3. Run test locally: bunx playwright test
    ↓
4. Test passes? ✓
    ↓
5. Commit test file with feature
    ↓
6. CI will run tests on future changes
```

## Verification Patterns

### Element Existence

```javascript
// Chrome MCP
mcp__claude-in-chrome__javascript_tool({
  code: `!!document.querySelector('.expected-element')`
})

// Playwright
await expect(page.locator('.expected-element')).toBeVisible();
```

### Text Content

```javascript
// Chrome MCP
mcp__claude-in-chrome__javascript_tool({
  code: `document.querySelector('.heading').textContent`
})

// Playwright
await expect(page.locator('.heading')).toHaveText('Welcome');
```

### Element State

```javascript
// Chrome MCP - check disabled state
mcp__claude-in-chrome__javascript_tool({
  code: `document.querySelector('button').disabled`
})

// Playwright
await expect(page.locator('button')).toBeDisabled();
```

### Form Values

```javascript
// Chrome MCP
mcp__claude-in-chrome__javascript_tool({
  code: `document.querySelector('#input').value`
})

// Playwright
await expect(page.locator('#input')).toHaveValue('expected value');
```

### Visual Appearance

```javascript
// Chrome MCP - screenshot for manual review
mcp__claude-in-chrome__computer({ action: "screenshot" })

// Playwright - automated visual regression
await expect(page.locator('.component')).toHaveScreenshot('component.png');
```

### Error States

```javascript
// Chrome MCP - check error display
mcp__claude-in-chrome__javascript_tool({
  code: `
    const error = document.querySelector('.error-message');
    return error ? error.textContent : null;
  `
})

// Playwright
await page.fill('#email', 'invalid');
await page.click('button[type="submit"]');
await expect(page.locator('.error-message')).toHaveText('Invalid email');
```

### Loading States

```javascript
// Chrome MCP - verify loading indicator
mcp__claude-in-chrome__javascript_tool({
  code: `!!document.querySelector('.loading-spinner')`
})

// Wait for loading to finish
mcp__claude-in-chrome__javascript_tool({
  code: `
    return new Promise(resolve => {
      const check = () => {
        if (!document.querySelector('.loading-spinner')) {
          resolve(true);
        } else {
          setTimeout(check, 100);
        }
      };
      check();
    });
  `
})

// Playwright
await expect(page.locator('.loading-spinner')).toBeHidden();
```

## Anti-Patterns

### Testing Implementation Details

```javascript
// WRONG: Testing CSS classes
expect(element.classList.contains('active')).toBe(true);

// RIGHT: Testing user-visible behavior
expect(element.getAttribute('aria-selected')).toBe('true');
// or
await expect(locator).toHaveClass(/active/); // if class indicates visible state
```

### Flaky Timing

```javascript
// WRONG: Fixed delays
await new Promise(r => setTimeout(r, 2000));
expect(something).toBe(true);

// RIGHT: Wait for condition
await page.waitForSelector('.loaded');
await expect(locator).toBeVisible();
```

### Over-Mocking in E2E

```javascript
// WRONG: Mocking everything in E2E
page.route('/api/**', mock);

// RIGHT: Test real flows, mock only external services
page.route('**/external-api.com/**', mock);
```

### Screenshot-Only Testing

```javascript
// WRONG: Only screenshots, no assertions
takeScreenshot(); // "Looks right to me"

// RIGHT: Assertions + screenshots as evidence
await expect(button).toBeVisible();
await expect(button).toHaveText('Submit');
takeScreenshot(); // Evidence, not the test
```

### Ignoring Accessibility

```javascript
// WRONG: Only visual testing
await expect(button).toBeVisible();

// RIGHT: Include accessibility
await expect(button).toBeVisible();
await expect(button).toHaveAttribute('aria-label');
await expect(page).toHaveNoViolations(); // axe-core
```
