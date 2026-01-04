---
name: git
description: Git conventions for commits, branches, and pull requests. Conventional commit format and PR workflows.
triggers:
  - "commit"
  - "branch"
  - "\\bpr\\b"
  - "pull request"
  - "conventional commit"
---

<objective>

Provide git workflow guidance including conventional commit format, branch naming conventions, and PR workflows.

</objective>

<routing>

## Task Routing

| Task | Resource |
|------|----------|
| Commit format | `references/conventions.md` |
| Branch naming | `references/conventions.md` |
| PR workflow | `references/conventions.md` |

</routing>

<references>

## Domain Knowledge

- `references/conventions.md` - Commit format, branch naming, PR workflow

</references>

<scripts>

## Helper Scripts

Helper scripts are available in `crew/scripts/git/`:

| Script | Purpose |
|--------|---------|
| `gh-pr-info.sh` | Get PR info for current branch |
| `gh-pr-threads.sh` | Get unresolved PR comments |
| `gh-pr-resolve-thread.sh` | Resolve a PR thread |
| `branch-context.sh` | Branch context for commits |
| `commit-context.sh` | Commit context |
| `pr-context.sh` | PR context |
| `push-context.sh` | Push context |
| `sync-context.sh` | Sync context |
| `clean-context.sh` | Clean branches context |
| `undo-context.sh` | Undo context |

</scripts>
