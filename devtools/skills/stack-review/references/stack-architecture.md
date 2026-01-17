# Stack Architecture Reference

Architecture and conventions for the full-stack blockchain platform.

## Monorepo Structure

```
.
├── kit/                    # Application packages
│   ├── contracts/          # Solidity smart contracts (Hardhat)
│   ├── dapp/               # TanStack Start frontend (React 19)
│   ├── subgraph/           # TheGraph indexer (AssemblyScript)
│   ├── charts/             # Helm K8s deployment
│   ├── e2e/                # Playwright E2E tests
│   └── migrator/           # Drizzle database migrations
│
├── packages/               # Shared libraries
│   ├── core/               # Infrastructure packages
│   │   ├── database/       # Drizzle ORM abstraction
│   │   ├── config/         # Configuration management
│   │   ├── durable/        # Restate SDK patterns
│   │   ├── cache/          # Redis caching layer
│   │   └── network/        # Viem blockchain client
│   │
│   ├── dalp/               # Domain-specific packages
│   │   ├── database/       # Domain schemas
│   │   ├── abis/           # Contract ABI exports
│   │   └── indexer/        # Restate indexer service
│   │
│   └── services/           # Background services
│       └── indexer/        # Blockchain event indexer
│
├── tools/                  # Development tooling
│   ├── typescript-config/  # Shared tsconfig
│   ├── vitest-config/      # Shared test config
│   ├── i18n/               # Internationalization
│   └── scripts/            # Build scripts
│
└── iaac/                   # Infrastructure as Code
```

## Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Runtime** | Bun | JavaScript runtime, package manager |
| **Build** | Turborepo | Monorepo task orchestration |
| **Frontend** | TanStack Start | Full-stack React framework |
| **UI** | React 19 | UI components |
| **Styling** | Tailwind CSS v4 | Utility-first CSS |
| **Components** | shadcn/ui + Radix | Accessible UI primitives |
| **State** | TanStack Query | Server state management |
| **Forms** | TanStack Form + Zod | Type-safe form handling |
| **Routing** | TanStack Router | File-based routing |
| **API** | ORPC | Type-safe RPC framework |
| **Auth** | Better Auth | Authentication library |
| **Database** | Drizzle ORM + PostgreSQL | Type-safe database access |
| **Caching** | Redis (Keyv) | Session and data caching |
| **Blockchain** | Viem | Ethereum client |
| **Contracts** | Hardhat + Solidity | Smart contract development |
| **Standards** | OpenZeppelin | Contract security standards |
| **Indexing** | TheGraph | Blockchain event indexing |
| **Workflows** | Restate | Durable execution |
| **Testing** | Vitest + Playwright | Unit and E2E tests |
| **Linting** | Biome | Code formatting and linting |

## Package Dependency Flow

```
                    ┌─────────────────┐
                    │   kit/dapp      │
                    │  (Frontend)     │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
     ┌────────────┐  ┌────────────┐  ┌────────────┐
     │ @dalp/abis │  │ @core/     │  │ packages/  │
     │ (Contracts)│  │ database   │  │ services   │
     └────────────┘  └────────────┘  └────────────┘
              │              │              │
              │              │              │
              ▼              ▼              ▼
     ┌────────────┐  ┌────────────┐  ┌────────────┐
     │ kit/       │  │ @dalp/     │  │ @core/     │
     │ contracts  │  │ database   │  │ durable    │
     └────────────┘  └────────────┘  └────────────┘
```

## Conventions

### File Naming

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserProfile.tsx` |
| Routes | lowercase with dashes | `user-profile.tsx` |
| Utilities | camelCase | `formatDate.ts` |
| Constants | SCREAMING_SNAKE | `API_ENDPOINTS.ts` |
| Types | PascalCase with suffix | `UserProfileProps.ts` |
| Tests | `.test.ts` suffix | `formatDate.test.ts` |
| Schemas | `.schema.ts` suffix | `user.schema.ts` |

### Import Order

```typescript
// 1. Node built-ins
import fs from "node:fs";

// 2. External packages
import { createContext } from "react";
import { z } from "zod";

// 3. Internal packages (monorepo)
import { db } from "@core/database";
import { userSchema } from "@dalp/database";

// 4. Relative imports
import { UserCard } from "./UserCard";
import type { UserProps } from "./types";
```

### Component Structure

```typescript
// 1. Imports
import { useState } from "react";
import { z } from "zod";

// 2. Types/Schemas
const userSchema = z.object({
  name: z.string(),
  email: z.string().email(),
});

type UserProps = z.infer<typeof userSchema>;

// 3. Component
export function UserProfile({ name, email }: UserProps) {
  const [isEditing, setIsEditing] = useState(false);

  return (
    <div className="p-4">
      {/* Component JSX */}
    </div>
  );
}
```

### Route Structure (TanStack Start)

```
kit/dapp/src/routes/
├── __root.tsx              # Root layout
├── index.tsx               # Home page (/)
├── _authenticated/         # Protected routes group
│   ├── route.tsx           # Auth check layout
│   ├── dashboard.tsx       # /dashboard
│   └── settings/
│       ├── route.tsx       # /settings layout
│       └── profile.tsx     # /settings/profile
└── login.tsx               # /login (public)
```

### Database Schema (Drizzle)

```typescript
// packages/dalp/database/src/schema/user.schema.ts
import { pgTable, uuid, text, timestamp } from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  id: uuid("id").primaryKey().defaultRandom(),
  email: text("email").notNull().unique(),
  name: text("name").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});

// Export types for use in application
export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;
```

### API Routes (ORPC)

```typescript
// kit/dapp/src/server/routers/user.router.ts
import { router, procedure } from "@orpc/server";
import { z } from "zod";
import { db } from "@core/database";
import { users } from "@dalp/database";

export const userRouter = router({
  getById: procedure
    .input(z.object({ id: z.string().uuid() }))
    .query(async ({ input }) => {
      return db.query.users.findFirst({
        where: eq(users.id, input.id),
      });
    }),

  create: procedure
    .input(z.object({
      email: z.string().email(),
      name: z.string().min(1),
    }))
    .mutation(async ({ input }) => {
      return db.insert(users).values(input).returning();
    }),
});
```

## Commands Reference

| Command | Purpose |
|---------|---------|
| `bun run dev` | Start dev environment with Docker |
| `bun run dev:reset` | Clean restart with fresh state |
| `bun run build` | Build all packages |
| `bun run test` | Run unit tests (Vitest) |
| `bun run test:e2e` | Run E2E tests (Playwright) |
| `bun run test:contracts` | Run contract tests |
| `bun run ci` | Full CI pipeline |
| `bun run lint` | Biome linting |
| `bun run typecheck` | TypeScript type checking |
| `bun run artifacts` | Generate contract ABIs |
| `bun run codegen` | Generate subgraph types |
| `bun verify-translations` | Validate i18n keys |

## Environment Configuration

```bash
# .env.local (development)
DATABASE_URL=postgres://user:pass@localhost:5432/dev
REDIS_URL=redis://localhost:6379
RESTATE_ADMIN_URL=http://localhost:9070

# Contract deployment
DEPLOYER_PRIVATE_KEY=0x...
MAINNET_RPC_URL=https://...
ETHERSCAN_API_KEY=...

# Auth
BETTER_AUTH_SECRET=...
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
```

## Docker Services

Local development requires these services:

```yaml
# docker-compose.yml
services:
  postgres:
    image: postgres:16
    ports: ["5432:5432"]

  redis:
    image: redis:7
    ports: ["6379:6379"]

  restate:
    image: restatedev/restate:latest
    ports:
      - "8080:8080"   # Ingress
      - "9070:9070"   # Admin

  subgraph:
    image: graphprotocol/graph-node
    ports: ["8000:8000"]
```

Start with: `bun run dev:up`
Reset with: `bun run dev:reset`
