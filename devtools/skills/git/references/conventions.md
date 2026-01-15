# Git Conventions

## Commit Format

```
<type>(<scope>): <description>

[optional body]
```

**Types:**
| Type | Use For |
| ---------- | ---------------------------- |
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change (no feature/fix) |
| `test` | Adding/updating tests |
| `chore` | Build, deps, tooling |

**Scopes:** contracts, dapp, subgraph, charts, e2e, api, skill

**Examples:**

```
feat(dapp): add asset transfer form
fix(contracts): correct balance calculation
refactor(api): extract validation to middleware
```

## Branch Naming

```
<username>/<type>/<slug>
```

**Examples:**

- `roderik/feat/asset-transfer`
- `roderik/fix/balance-calc`
- `roderik/chore/update-deps`

## Hard Rules

**Banned:**

- Commits without conventional format
- Committing `.env.local`, `.pem`, `.key`, credentials
- Force push to main

**Required:**

- Run `bun run ci` before push
- PR description with summary and test plan
- Resolve all review threads before merge
