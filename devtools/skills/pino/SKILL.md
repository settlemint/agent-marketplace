---
name: pino
description: Pino fast JSON logger for Node.js. Use when asked to "add logging", "setup structured logging", or "configure logger". Covers log levels, child loggers, transports, and redaction.
license: MIT
triggers:
  [
    "pino",
    "pino-pretty",
    "pino-http",
    "pinojs",
    "logger\\.info",
    "logger\\.error",
    "logger\\.warn",
    "logger\\.debug",
    "logger\\.fatal",
    "logger\\.trace",
    "log\\.info",
    "log\\.error",
    "log\\.warn",
    "log\\.debug",
    "child\\s*logger",
    "structured\\s*log",
    "json\\s*log",
    "log.*transport",
    "log.*redact",
    "request.*log",
    "node.*logger",
    "fast.*logger",
    "log\\s*level",
  ]
---

<objective>
Implement structured logging using Pino - the fastest Node.js JSON logger. Configure log levels, child loggers, and transports for different environments.
</objective>

<mcp_first>
**CRITICAL: Fetch Pino documentation before implementing.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_octocode__githubSearchCode" })
```

```typescript
// Pino configuration
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["pino", "logger", "transport"],
  owner: "pinojs",
  repo: "pino",
  path: "lib",
  mainResearchGoal: "Understand Pino logger configuration",
  researchGoal: "Find logger setup patterns",
  reasoning: "Need current API for Pino setup",
});

// Transports
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["pino-pretty", "transport", "destination"],
  owner: "pinojs",
  repo: "pino",
  path: "docs",
  mainResearchGoal: "Understand Pino transports",
  researchGoal: "Find transport configuration patterns",
  reasoning: "Need current API for log transports",
});
```

</mcp_first>

<quick_start>
**Templates:**

| Template                         | Purpose                             |
| -------------------------------- | ----------------------------------- |
| `templates/logger-setup.ts.md`   | Logger configuration with redaction |
| `templates/request-logger.ts.md` | HTTP request middleware             |

**Basic usage:**

```typescript
import { logger } from "./logger";

logger.info("Server started");
logger.error({ err }, "Database connection failed");
```

**With pretty printing (development):**

```typescript
import pino from "pino";

const logger = pino({
  level: "debug",
  transport: {
    target: "pino-pretty",
    options: {
      colorize: true,
      translateTime: "HH:MM:ss",
      ignore: "pid,hostname",
    },
  },
});
```

**Child loggers:**

```typescript
const requestLogger = logger.child({ requestId: req.id });
requestLogger.info("Processing request");
// Output: {"level":30,"requestId":"abc123","msg":"Processing request"}
```

</quick_start>

<log_levels>
| Level | Value | Use Case |
|-------|-------|----------|
| `fatal` | 60 | App crash |
| `error` | 50 | Error conditions |
| `warn` | 40 | Warning conditions |
| `info` | 30 | Normal operations |
| `debug` | 20 | Debug information |
| `trace` | 10 | Detailed tracing |
</log_levels>

<patterns>
**Structured logging:**

```typescript
// Good - structured data
logger.info({ userId, action: "login" }, "User logged in");

// Bad - string interpolation
logger.info(`User ${userId} logged in`);
```

**Error logging:**

```typescript
try {
  await riskyOperation();
} catch (error) {
  // Pass error as `err` property for proper serialization
  logger.error({ err: error, context: "riskyOperation" }, "Operation failed");
}
```

**Request logging middleware:**

```typescript
function requestLogger(req, res, next) {
  const start = Date.now();
  const log = logger.child({ requestId: req.id });

  res.on("finish", () => {
    log.info(
      {
        method: req.method,
        url: req.url,
        status: res.statusCode,
        duration: Date.now() - start,
      },
      "Request completed",
    );
  });

  req.log = log;
  next();
}
```

**Redaction (hide sensitive data):**

```typescript
const logger = pino({
  redact: ["password", "creditCard", "*.secret", "users[*].token"],
});

logger.info({ password: "secret123" }); // password: "[Redacted]"
```

</patterns>

<transports>
**Multiple transports:**

```typescript
import pino from "pino";

const logger = pino({
  transport: {
    targets: [
      {
        target: "pino-pretty",
        options: { colorize: true },
        level: "debug",
      },
      {
        target: "pino/file",
        options: { destination: "./app.log" },
        level: "info",
      },
    ],
  },
});
```

**Custom transport:**

```typescript
const logger = pino({
  transport: {
    target: "./my-transport.js",
    options: { customOption: true },
  },
});
```

</transports>

<constraints>
**Best practices:**
- Use structured data (objects) not string interpolation
- Pass errors as `err` property
- Use child loggers for context
- Redact sensitive fields
- Set appropriate log level per environment

**Performance:**

- Pino is async by default
- Use `pino.destination()` for sync in critical paths
- Avoid logging in hot paths
  </constraints>

<anti_patterns>
**Common mistakes to avoid:**

- String interpolation instead of structured data: `log.info(\`User ${id}\`)` loses queryability
- Missing `err` property for errors: `log.error(error)` should be `log.error({ err: error })`
- Logging sensitive data without redaction (passwords, tokens, PII)
- Using `console.log` instead of Pino in production code
- Creating new logger instances instead of using child loggers for context
  </anti_patterns>

<library_ids>
Skip resolve step for these known IDs:

| Library     | Context7 ID         |
| ----------- | ------------------- |
| Pino        | /pinojs/pino        |
| pino-pretty | /pinojs/pino-pretty |

</library_ids>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production Pino logging patterns",
      researchGoal: "Search for logger configuration and transports",
      reasoning: "Need real-world examples of Pino setup",
      keywordsToSearch: ["pino", "logger", "child", "redact"],
      extension: "ts",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Transports: `keywordsToSearch: ["pino", "transport", "targets", "destination"]`
- Redaction: `keywordsToSearch: ["pino", "redact", "password", "secret"]`
- HTTP logging: `keywordsToSearch: ["pino-http", "request", "middleware"]`
  </research>

<related_skills>

**API development:** Load via `Skill({ skill: "devtools:api" })` when:

- Adding request logging middleware
- Logging API errors

**Testing:** Load via `Skill({ skill: "devtools:vitest" })` when:

- Mocking loggers in tests
- Verifying log output
  </related_skills>

<success_criteria>

1. [ ] Logger configured with appropriate level
2. [ ] Structured logging (not string interpolation)
3. [ ] Errors passed as `err` property
4. [ ] Sensitive data redacted
5. [ ] Pretty printing in development only
</success_criteria>

<evolution>
**Extension Points:**

- Add custom transports for new log destinations (Datadog, Loki, etc.)
- Extend serializers for domain-specific object formatting
- Add new redaction patterns as sensitive data types emerge

**Timelessness:** Structured JSON logging is the foundation of modern observability. Pino patterns apply to any logging library.
</evolution>
