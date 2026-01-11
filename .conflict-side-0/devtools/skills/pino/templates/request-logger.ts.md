# Request Logger Middleware Template

```typescript
import type { Request, Response, NextFunction } from "express";
import { logger } from "./logger";

export function requestLogger(req: Request, res: Response, next: NextFunction) {
  const start = Date.now();
  const requestId = crypto.randomUUID();

  // Create request-scoped child logger
  req.log = logger.child({ requestId });

  req.log.info(
    {
      method: req.method,
      url: req.url,
      userAgent: req.get("user-agent"),
    },
    "incoming request",
  );

  res.on("finish", () => {
    req.log.info(
      {
        method: req.method,
        url: req.url,
        statusCode: res.statusCode,
        duration: Date.now() - start,
      },
      "request completed",
    );
  });

  next();
}
```

## Type Extension

```typescript
// types/express.d.ts
import type { Logger } from "pino";

declare global {
  namespace Express {
    interface Request {
      log: Logger;
    }
  }
}
```

## Usage

```typescript
app.use(requestLogger);

// In route handlers
app.get("/users", (req, res) => {
  req.log.info({ userId: req.params.id }, "fetching user");
  // ...
});
```
