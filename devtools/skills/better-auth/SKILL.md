---
name: better-auth
description: Better Auth authentication library for TypeScript. Covers session management, passkeys, social auth, and organization features. Triggers on better-auth, auth, session, passkey.
triggers: ["better-auth", "auth", "session", "passkey", "signIn", "signOut", "useSession"]
---

<objective>
Implement authentication using Better Auth - a TypeScript-first auth library with built-in support for passkeys, social providers, organizations, and more.
</objective>

<mcp_first>
**CRITICAL: Use OctoCode to search Better Auth patterns.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_octocode__githubSearchCode" })
```

```typescript
// Better Auth server setup
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["betterAuth", "database", "socialProviders"],
  owner: "better-auth",
  repo: "better-auth",
  path: "packages/better-auth/src",
  mainResearchGoal: "Understand Better Auth server configuration",
  researchGoal: "Find auth instance setup patterns",
  reasoning: "Need current API for Better Auth setup"
})

// Passkey configuration
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["passkey", "webauthn", "authenticator"],
  owner: "better-auth",
  repo: "better-auth",
  path: "packages",
  mainResearchGoal: "Understand passkey implementation",
  researchGoal: "Find passkey plugin patterns",
  reasoning: "Need current API for passkey authentication"
})

// React hooks
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["useSession", "signIn", "signOut"],
  owner: "better-auth",
  repo: "better-auth",
  path: "packages/better-auth/src/client",
  mainResearchGoal: "Understand Better Auth React hooks",
  researchGoal: "Find client-side auth patterns",
  reasoning: "Need current API for React integration"
})
```
</mcp_first>

<quick_start>
**Server setup (lib/auth/index.ts):**

```typescript
import { betterAuth } from "better-auth";
import { drizzleAdapter } from "better-auth/adapters/drizzle";
import { passkey } from "@better-auth/passkey";

export const auth = betterAuth({
  database: drizzleAdapter(db, {
    provider: "pg",
  }),
  emailAndPassword: {
    enabled: true,
  },
  plugins: [
    passkey(),
  ],
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
  },
});

export type Session = typeof auth.$Infer.Session;
```

**Client setup:**

```typescript
import { createAuthClient } from "better-auth/react";

export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_APP_URL,
});

export const { useSession, signIn, signOut } = authClient;
```

**Usage in components:**

```tsx
function LoginButton() {
  const { data: session, isPending } = useSession();

  if (isPending) return <Spinner />;

  if (session) {
    return <button onClick={() => signOut()}>Sign Out</button>;
  }

  return <button onClick={() => signIn.email({ email, password })}>Sign In</button>;
}
```
</quick_start>

<plugins>
| Plugin | Purpose |
|--------|---------|
| `passkey` | WebAuthn/passkey authentication |
| `organization` | Multi-tenant organizations |
| `twoFactor` | 2FA with TOTP |
| `magicLink` | Email magic links |
| `anonymous` | Anonymous sessions |
</plugins>

<social_providers>
```typescript
socialProviders: {
  google: { clientId, clientSecret },
  github: { clientId, clientSecret },
  discord: { clientId, clientSecret },
  apple: { clientId, clientSecret, teamId, keyId, privateKey },
}
```
</social_providers>

<constraints>
**Required:**
- Use Drizzle adapter for database
- Set `BETTER_AUTH_SECRET` env variable
- Generate auth schema: `bunx @better-auth/cli generate`
- Handle session in API routes via `auth.api.getSession`

**Security:**
- Never expose auth secret
- Validate sessions on protected routes
- Use HTTPS in production
</constraints>

<commands>
```bash
# Generate auth schema
bunx @better-auth/cli generate -y --config=src/lib/auth/index.ts

# After schema changes
bun run db:generate
bun run db:migrate
```
</commands>

<success_criteria>
- [ ] OctoCode searched for current patterns
- [ ] Auth instance configured with database
- [ ] Client hooks set up correctly
- [ ] Protected routes check session
- [ ] Social providers configured (if needed)
</success_criteria>
