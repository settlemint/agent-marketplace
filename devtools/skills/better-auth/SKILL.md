---
name: better-auth
description: Better Auth library patterns. Use when asked to "setup authentication", "add passkey login", or "configure social auth". Only for projects using better-auth package.
license: MIT
triggers:
  # Library name and variations
  - "better-auth"
  - "betterAuth"
  - "better_auth"
  - "@better-auth"
  # API patterns
  - "authClient"
  - "auth\\.api"
  - "createAuthClient"
  - "drizzleAdapter.*auth"
  # Hooks and methods
  - "useSession"
  - "signIn\\.email"
  - "signIn\\.social"
  - "signOut\\("
  # Plugins
  - "passkey\\(\\)"
  - "twoFactor\\(\\)"
  - "magicLink\\(\\)"
  - "organization\\(\\)"
  # User intent - authentication
  - "(?i)add.*authentication"
  - "(?i)implement.*auth"
  - "(?i)setup.*login"
  - "(?i)add.*passkey"
  - "(?i)webauthn"
  - "(?i)social.*provider"
  - "(?i)google.*login"
  - "(?i)github.*login"
  - "(?i)session.*management"
  - "(?i)2fa|two.*factor"
  - "(?i)magic.*link"
  - "(?i)email.*password.*auth"
  # CLI commands
  - "@better-auth/cli"
  - "BETTER_AUTH_SECRET"
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
  reasoning: "Need current API for Better Auth setup",
});

// Passkey configuration
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["passkey", "webauthn", "authenticator"],
  owner: "better-auth",
  repo: "better-auth",
  path: "packages",
  mainResearchGoal: "Understand passkey implementation",
  researchGoal: "Find passkey plugin patterns",
  reasoning: "Need current API for passkey authentication",
});

// React hooks
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["useSession", "signIn", "signOut"],
  owner: "better-auth",
  repo: "better-auth",
  path: "packages/better-auth/src/client",
  mainResearchGoal: "Understand Better Auth React hooks",
  researchGoal: "Find client-side auth patterns",
  reasoning: "Need current API for React integration",
});
```

</mcp_first>

<quick_start>
**Workflow:**
1. Generate auth schema: `bunx @better-auth/cli generate`
2. Configure server with database adapter
3. Setup client with `createAuthClient`
4. Add protected routes with session checks
5. Test auth flow end-to-end

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
  plugins: [passkey()],
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

  return (
    <button onClick={() => signIn.email({ email, password })}>Sign In</button>
  );
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

<anti_patterns>

- Storing sessions in localStorage (use httpOnly cookies)
- Checking auth only on client side (always verify server-side)
- Exposing user IDs in URLs without authorization checks
- Using predictable session tokens or IDs
- Skipping CSRF protection on auth endpoints
  </anti_patterns>

<commands>
```bash
# Generate auth schema
bunx @better-auth/cli generate -y --config=src/lib/auth/index.ts

# After schema changes

bun run db:generate
bun run db:migrate

````
</commands>

<library_ids>
Skip resolve step for these known IDs:

| Library     | Context7 ID               |
| ----------- | ------------------------- |
| better-auth | /better-auth/better-auth  |
</library_ids>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [{
    mainResearchGoal: "Find production Better Auth patterns",
    researchGoal: "Search for authentication and session patterns",
    reasoning: "Need real-world examples of Better Auth usage",
    keywordsToSearch: ["betterAuth", "signIn", "useSession"],
    extension: "ts",
    limit: 10
  }]
})
````

**Common searches:**

- Passkeys: `keywordsToSearch: ["passkey", "webauthn", "better-auth"]`
- Social login: `keywordsToSearch: ["socialProviders", "google", "github"]`
- Session: `keywordsToSearch: ["useSession", "getSession", "auth.api"]`
  </research>

<related_skills>

**Database schema:** Load via `Skill({ skill: "devtools:drizzle" })` when:

- Setting up auth database schema
- Running auth migrations

**React components:** Load via `Skill({ skill: "devtools:react" })` when:

- Building login/signup forms
- Creating auth UI components
  </related_skills>

<success_criteria>

1. [ ] OctoCode searched for current patterns
2. [ ] Auth instance configured with database
3. [ ] Client hooks set up correctly
4. [ ] Protected routes check session
5. [ ] Social providers configured (if needed)
6. [ ] BETTER_AUTH_SECRET env variable set
</success_criteria>

<evolution>
**Extension Points:**
- Add custom plugins for organization-specific auth flows
- Extend with additional social providers as needed
- Create custom session enrichment middleware

**Timelessness:** Authentication is a universal requirement; Better Auth provides TypeScript-first patterns that evolve with the ecosystem.
</evolution>
