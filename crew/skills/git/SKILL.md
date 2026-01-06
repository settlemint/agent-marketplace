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

Git workflow guidance: conventional commits, branch naming, PR workflows.

</objective>

<routing>

| Task          | Resource                    |
| ------------- | --------------------------- |
| Commit format | `references/conventions.md` |
| Branch naming | `references/conventions.md` |
| PR workflow   | `references/conventions.md` |

</routing>

<scripts>

| Script                    | Purpose                 |
| ------------------------- | ----------------------- |
| `gh-pr-info.sh`           | Get PR info             |
| `gh-pr-threads.sh`        | Get unresolved comments |
| `gh-pr-resolve-thread.sh` | Resolve thread          |
| `branch-context.sh`       | Branch context          |
| `commit-context.sh`       | Commit context          |
| `pr-context.sh`           | PR context              |

</scripts>

<success_criteria>

- Commit: `type(scope): description`
- Branch: `type/short-description`
- No secrets in staged changes
- PR has summary and test plan

</success_criteria>
