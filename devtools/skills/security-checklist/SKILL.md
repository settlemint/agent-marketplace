---
name: security-checklist
description: Security validation checklist for code review. OWASP Top 10, input validation, authentication, and common vulnerability patterns.
license: MIT
triggers:
  # Intent triggers
  - "security check"
  - "security review"
  - "check for vulnerabilities"
  - "is this secure"
  - "security audit"
  - "pen test"

  # Artifact triggers
  - "owasp"
  - "injection"
  - "xss"
  - "csrf"
  - "sql injection"
  - "authentication"
  - "authorization"
  - "secrets"
  - "api key"
---

<objective>
Provide a comprehensive, actionable security checklist for code review. Every code change touching user input, authentication, or data handling should pass these checks before merge.
</objective>

<essential_principles>

- Validate all input at system boundaries (never trust external data)
- Use parameterized queries for all database operations
- Escape output based on context (HTML, URL, JS, SQL)
- Implement least privilege for all access controls
- Never store secrets in code or version control
- Log security events without sensitive data
</essential_principles>

<constraints>
**Banned:**
- String concatenation for SQL queries
- `innerHTML` with user-controlled data
- Hardcoded API keys, passwords, or tokens
- `eval()`, `new Function()`, or dynamic code execution with user input
- Disabled CSRF protection
- `*` in CORS allowed origins for authenticated endpoints

**Required:**

- Parameterized queries or ORM for database access
- Input validation with schema (Zod recommended)
- Output encoding appropriate to context
- CSRF tokens for state-changing operations
- Rate limiting on authentication endpoints
</constraints>

<anti_patterns>

- **Trust Boundary Confusion:** Validating on client but not server
- **Security by Obscurity:** Hiding endpoints instead of authenticating them
- **Verbose Errors:** Leaking stack traces or internal paths to users
- **Default Allow:** Whitelisting being optional instead of required
- **Credential Logging:** Including passwords or tokens in logs
</anti_patterns>

<quick_start>
**Before merging any code that handles:**

- User input → Check Input Validation section
- Authentication → Check Auth section
- Database queries → Check Injection section
- HTML output → Check XSS section
- File operations → Check Path Traversal section
- External requests → Check SSRF section
</quick_start>

<owasp_top_10_checklist>
**A01: Broken Access Control**
- [ ] Authorization checked on every request (not just UI)
- [ ] Direct object references validated against user permissions
- [ ] Admin functions protected by role checks
- [ ] CORS configured with specific origins (not `*`)
- [ ] Directory listing disabled

**A02: Cryptographic Failures**
- [ ] Passwords hashed with bcrypt/argon2 (not MD5/SHA1)
- [ ] Sensitive data encrypted at rest
- [ ] HTTPS enforced for all traffic
- [ ] No secrets in code, logs, or error messages
- [ ] Strong random number generation for tokens

**A03: Injection**
- [ ] All SQL uses parameterized queries
- [ ] User input never passed to shell commands
- [ ] LDAP queries use proper escaping
- [ ] XML parsers disable external entities (XXE)

**A04: Insecure Design**
- [ ] Rate limiting on sensitive operations
- [ ] Account lockout after failed attempts
- [ ] Password requirements enforced
- [ ] Security questions avoided (weak)

**A05: Security Misconfiguration**
- [ ] Default credentials changed
- [ ] Unnecessary features disabled
- [ ] Error messages don't leak internals
- [ ] Security headers configured (CSP, X-Frame-Options)

**A06: Vulnerable Components**
- [ ] Dependencies up to date (`bun outdated`)
- [ ] Known vulnerabilities checked (`bun audit`)
- [ ] Unused dependencies removed
- [ ] Component versions pinned

**A07: Authentication Failures**
- [ ] Multi-factor authentication available
- [ ] Session tokens regenerated on login
- [ ] Logout invalidates session server-side
- [ ] Password reset tokens expire quickly

**A08: Data Integrity Failures**
- [ ] Software updates verified (signatures)
- [ ] CI/CD pipeline secured
- [ ] Serialization validated (no unsafe deserialize)

**A09: Logging Failures**
- [ ] Login attempts logged
- [ ] Access control failures logged
- [ ] Logs don't contain sensitive data
- [ ] Log injection prevented

**A10: SSRF**
- [ ] User-supplied URLs validated against allowlist
- [ ] Internal network requests blocked
- [ ] DNS rebinding prevented
</owasp_top_10_checklist>

<input_validation>
**Always validate at the server:**

```typescript
import { z } from 'zod';

// Define schema with strict validation
const userInputSchema = z.object({
  email: z.string().email().max(255),
  name: z.string().min(1).max(100).regex(/^[a-zA-Z\s]+$/),
  age: z.number().int().min(0).max(150),
});

// Validate before processing
const result = userInputSchema.safeParse(request.body);
if (!result.success) {
  return Response.json({ error: 'Invalid input' }, { status: 400 });
}
const validatedData = result.data;
```

**Validation rules:**

| Input Type | Validation |
|------------|------------|
| Email | Format + max length |
| Username | Alphanumeric + length limits |
| Numbers | Type + range |
| URLs | Protocol whitelist + domain validation |
| File names | No path separators, extension whitelist |
| Free text | Length limit + encoding |
</input_validation>

<sql_injection_prevention>
**Never concatenate user input into SQL:**

```typescript
// VULNERABLE - SQL injection possible
const query = `SELECT * FROM users WHERE id = '${userId}'`;

// SAFE - Parameterized query (Drizzle)
const user = await db.select().from(users).where(eq(users.id, userId));

// SAFE - Parameterized query (raw SQL)
const result = await db.execute(
  sql`SELECT * FROM users WHERE id = ${userId}`
);

// SAFE - Prepared statement
const stmt = db.prepare('SELECT * FROM users WHERE id = ?');
const user = stmt.get(userId);
```

**Also applies to:**
- NoSQL queries (MongoDB `$where`, etc.)
- LDAP queries
- XML/XPath queries
- ORM dynamic where clauses
</sql_injection_prevention>

<xss_prevention>
**Escape output based on context:**

```typescript
// HTML context - escape HTML entities
import { escapeHtml } from './utils';
const safe = escapeHtml(userInput);
// or use framework auto-escaping (React, Vue)

// JavaScript context - JSON encode
const safe = JSON.stringify(userInput);

// URL context - encode URI component
const safe = encodeURIComponent(userInput);

// CSS context - validate against whitelist
const safe = allowedColors.includes(userInput) ? userInput : 'inherit';
```

**React-specific:**
```tsx
// SAFE - React escapes by default
<div>{userInput}</div>

// VULNERABLE - dangerouslySetInnerHTML
<div dangerouslySetInnerHTML={{ __html: userInput }} />  // NEVER with user input

// If HTML is required, sanitize first
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userInput) }} />
```

**Content Security Policy header:**
```typescript
// Strict CSP prevents inline scripts
headers: {
  'Content-Security-Policy': "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'"
}
```
</xss_prevention>

<authentication_checklist>
**Password storage:**
```typescript
import { hash, verify } from '@node-rs/argon2';

// Hash with Argon2 (recommended) or bcrypt
const passwordHash = await hash(password, {
  memoryCost: 65536,
  timeCost: 3,
  parallelism: 4,
});

// Verify
const isValid = await verify(passwordHash, password);
```

**Session management:**
```typescript
// Regenerate session ID on login (prevent fixation)
await regenerateSession(request);

// Set secure cookie attributes
setCookie('session', token, {
  httpOnly: true,      // Prevent XSS access
  secure: true,        // HTTPS only
  sameSite: 'strict',  // Prevent CSRF
  maxAge: 3600,        // 1 hour expiry
  path: '/',
});

// Invalidate on logout (server-side)
await deleteSession(sessionId);
```

**Rate limiting:**
```typescript
// Limit login attempts
const rateLimiter = new RateLimiter({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per window
  keyGenerator: (req) => req.ip + req.body.email,
});
```
</authentication_checklist>

<secrets_management>
**Never commit secrets:**

```bash
# .gitignore (mandatory)
.env
.env.*
*.pem
*.key
credentials.json
```

**Environment variables:**
```typescript
// Load from environment, not code
const apiKey = process.env.API_KEY;
if (!apiKey) throw new Error('API_KEY required');

// Validate required secrets at startup
const requiredSecrets = ['DATABASE_URL', 'API_KEY', 'JWT_SECRET'];
for (const secret of requiredSecrets) {
  if (!process.env[secret]) {
    throw new Error(`Missing required secret: ${secret}`);
  }
}
```

**Secret rotation:**
- API keys: Support multiple active keys during rotation
- Database passwords: Use IAM authentication where possible
- JWT secrets: Sign with key ID, support multiple keys
</secrets_management>

<common_vulnerabilities>
**Path traversal:**
```typescript
// VULNERABLE
const file = fs.readFileSync(`uploads/${userFilename}`);

// SAFE - resolve and validate path
const safePath = path.resolve('uploads', path.basename(userFilename));
if (!safePath.startsWith(path.resolve('uploads'))) {
  throw new Error('Invalid path');
}
```

**SSRF prevention:**
```typescript
// VULNERABLE - user controls URL
const response = await fetch(userProvidedUrl);

// SAFE - validate against allowlist
const allowedHosts = ['api.example.com', 'cdn.example.com'];
const url = new URL(userProvidedUrl);
if (!allowedHosts.includes(url.host)) {
  throw new Error('URL not allowed');
}
```

**Mass assignment:**
```typescript
// VULNERABLE - all fields from request
await db.update(users).set(request.body).where(eq(users.id, id));

// SAFE - explicit field selection
const { name, email } = request.body;
await db.update(users).set({ name, email }).where(eq(users.id, id));
```
</common_vulnerabilities>

<security_headers>
**Recommended headers:**

```typescript
// Next.js / middleware example
const securityHeaders = {
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'X-XSS-Protection': '1; mode=block',
  'Referrer-Policy': 'strict-origin-when-cross-origin',
  'Permissions-Policy': 'camera=(), microphone=(), geolocation=()',
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  'Content-Security-Policy': "default-src 'self'; script-src 'self'",
};
```
</security_headers>

<related_skills>

**Deep security analysis:** Load via `Skill({ skill: "devtools:codex-patterns" })` when:

- Need OWASP-specific vulnerability analysis
- Complex attack vector evaluation
- Threat modeling

**API security:** Load via `Skill({ skill: "devtools:api" })` when:

- Designing secure API endpoints
- Implementing authentication middleware

**Input validation:** Load via `Skill({ skill: "devtools:zod" })` when:

- Building validation schemas
- Runtime type checking

**Smart contract security:** Load via `Skill({ skill: "devtools:solidity" })` when:

- Auditing Solidity code
- Checking for reentrancy, overflow, etc.

</related_skills>

<success_criteria>

1. [ ] OWASP Top 10 checklist reviewed for relevant categories
2. [ ] All user input validated with schema (Zod)
3. [ ] SQL queries use parameterization (no concatenation)
4. [ ] Output escaped for context (HTML, URL, JS)
5. [ ] Authentication uses secure password hashing
6. [ ] Sessions configured with secure cookie attributes
7. [ ] No secrets in code or version control
8. [ ] Security headers configured
9. [ ] Dependencies checked for vulnerabilities
</success_criteria>

<evolution>
**Extension Points:**
- Add domain-specific checklists (blockchain, healthcare, finance)
- Integrate with automated security scanning (SAST/DAST)
- Build pre-commit hooks for secret detection

**Timelessness:** OWASP Top 10 principles evolve slowly; input validation, output encoding, and least privilege are fundamental security concepts that persist across technology stacks.
</evolution>
