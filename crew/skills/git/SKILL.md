---
name: git
description: Git conventions for commits, branches, and pull requests. Conventional commit format and PR workflows.
triggers:
  - "commit"
  - "branch"
  - "\\bpr\\b"
  - "pull request"
  - "conventional commit"
hooks:
  PostToolUse:
    - matcher: Bash
      type: command
      command: "${CLAUDE_PLUGIN_ROOT}/scripts/hooks/post-tool/check-pr-scope.sh"
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
| Feature PR    | `templates/pr-feature.md`   |
| Bug fix PR    | `templates/pr-fix.md`       |
| Refactor PR   | `templates/pr-refactor.md`  |
| Quick PR      | `templates/pr-default.md`   |

</routing>

<commands>

| Command                                        | Purpose                         |
| ---------------------------------------------- | ------------------------------- |
| `Skill({ skill: "crew:git:pr:create" })`       | Create PR with template         |
| `Skill({ skill: "crew:git:pr:update" })`       | Update PR title/body            |
| `Skill({ skill: "crew:git:sync" })`            | Sync current branch with parent |
| `Skill({ skill: "crew:git:commit" })`          | Create conventional commit      |
| `Skill({ skill: "crew:git:branch:new" })`      | Create feature branch           |
| `Skill({ skill: "crew:git:push" })`            | Push current branch             |
| `Skill({ skill: "crew:git:clean" })`           | Clean stale branches            |
| `Skill({ skill: "crew:git:commit-and-push" })` | Commit and push in one step     |
| `Skill({ skill: "crew:git:undo" })`            | Undo last commit (keep changes) |

</commands>

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
