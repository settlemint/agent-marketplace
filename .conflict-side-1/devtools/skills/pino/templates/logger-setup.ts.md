# Pino Logger Setup Template

```typescript
import pino from "pino";

export const logger = pino({
  level: process.env.LOG_LEVEL ?? "info",
  formatters: {
    level: (label) => ({ level: label }),
  },
  redact: {
    paths: ["password", "token", "apiKey", "*.password", "*.token"],
    censor: "[REDACTED]",
  },
});

// Child logger for specific module
export const createModuleLogger = (module: string) => logger.child({ module });
```

## Placeholders

| Placeholder | Example                 | Description           |
| ----------- | ----------------------- | --------------------- |
| `LOG_LEVEL` | `debug`, `info`, `warn` | Log level from env    |
| `module`    | `auth`, `api`           | Module name for child |

## Pretty Printing (Development)

```typescript
import pino from "pino";

export const logger = pino({
  transport: {
    target: "pino-pretty",
    options: {
      colorize: true,
      translateTime: "SYS:standard",
      ignore: "pid,hostname",
    },
  },
});
```

## Dependencies

```bash
bun add pino
bun add -d pino-pretty  # dev only
```
