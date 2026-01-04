---
name: git-conventions
description: This skill covers git commit conventions and PR workflows for DALP. It should be used when creating commits, branches, or pull requests.
triggers: ["commit", "branch", "\\bpr\\b", "pull request"]
depends_on: []
---

<constraints>

## Hard Rules

**Banned:** Commits without conventional format, committing `.env.local`, force push to main

**Required:**

- Conventional commit format
- Descriptive branch names
- PR description with context

</constraints>

<commit_format>

## Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

## Types

| Type       | Use For                      |
| ---------- | ---------------------------- |
| `feat`     | New feature                  |
| `fix`      | Bug fix                      |
| `docs`     | Documentation only           |
| `refactor` | Code change (no feature/fix) |
| `test`     | Adding/updating tests        |
| `chore`    | Build, deps, tooling         |

## Scopes

| Scope       | Package/Area         |
| ----------- | -------------------- |
| `contracts` | Smart contracts      |
| `dapp`      | Frontend application |
| `subgraph`  | TheGraph indexer     |
| `indexer`   | Ponder indexer       |
| `charts`    | Helm charts          |
| `e2e`       | End-to-end tests     |
| `api`       | API/oRPC routes      |

## Examples

```
feat(dapp): add asset transfer form
fix(contracts): correct balance calculation in transfer
docs(api): update OpenAPI descriptions
refactor(dapp): extract form validation to hook
test(contracts): add fuzz tests for mint function
chore(deps): update TanStack dependencies
```

</commit_format>

<branch_naming>

## Branch Names

```
<type>/<short-description>
```

Examples:

- `feat/asset-transfer-form`
- `fix/balance-calculation`
- `refactor/form-validation`

</branch_naming>

<pr_workflow>

## Pull Request Workflow

1. Create branch from `main`
2. Make changes with conventional commits
3. **Run `bun run ci` before pushing** - catches all lint errors locally
4. Push and create PR with description
5. Address review comments
6. Squash merge to main

**CRITICAL:** Always run `bun run ci` before pushing. This runs actionlint, shellcheck, shfmt, biome, and all other checks. Never push without it.

</pr_workflow>

<github_scripts>

## Helper Scripts

```bash
# Get repo info
.claude/skills/crew/scripts/git/gh-repo-info.sh

# Get PR info for current branch
.claude/skills/crew/scripts/git/gh-pr-info.sh

# Get unresolved PR comments
.claude/skills/crew/scripts/git/gh-pr-threads.sh

# Resolve a PR thread
.claude/skills/crew/scripts/git/gh-pr-resolve-thread.sh <thread_id>
```

</github_scripts>

<hooks>

## Automated Guardrails

| Hook                 | Trigger            | Action                          |
| -------------------- | ------------------ | ------------------------------- |
| `check-git-commit`   | PreToolUse (Bash)  | Validates commit message format |
| `check-gh-pr-create` | PreToolUse (Bash)  | Validates PR creation           |
| `post-push-review`   | PostToolUse (Bash) | Suggests PR review after push   |

Located in: `.claude/skills/crew/scripts/hooks/`

</hooks>

<related_skills>

- `build-system` - CI pipeline to run before commit
- `troubleshooting` - Common git issues

</related_skills>

<checklist>

- [ ] Commit follows conventional format
- [ ] Scope matches affected package
- [ ] Description is clear and concise
- [ ] No secrets committed
- [ ] CI passes

</checklist>
