# Use appropriate testing methods

> **Repository:** facebook/react
> **Dependencies:** @testing-library/react, @types/react, react

When writing tests, use the appropriate testing utilities and ensure proper test isolation.

For testing warning behaviors:
- Use `assertConsoleErrorDev` or `toErrorDev` instead of gating tests with environment flags like `@gate __DEV__`
- Assert both the warning and the expected behavior outcomes

For testing sequential or asynchronous actions:
- Use logging utilities like `Scheduler.log()` with corresponding assertions like `assertLog(['Action', 'Action'])`

Always clean up after tests that use mocks:
```javascript
// Bad: No cleanup after mocking
console.error = jest.fn();
// Test code...
// Missing cleanup!

// Good: Proper cleanup
const originalConsoleError = console.error;
console.error = jest.fn();
// Test code...
console.error = originalConsoleError; // Or use console.error.mockRestore();

// Better: Use afterEach for guaranteed cleanup
beforeEach(() => {
  jest.spyOn(console, 'error').mockImplementation(() => {});
});

afterEach(() => {
  console.error.mockRestore();
});
```

Failing to clean up mocks can silently break subsequent tests by interfering with their assertions, making test failures difficult to debug.