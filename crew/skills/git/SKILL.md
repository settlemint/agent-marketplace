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
      command: "${CLAUDE_PLUGIN_ROOT}/scripts/hooks/post-tool/sync-machete-stack.sh"
    - matcher: Bash
      type: command
      command: "${CLAUDE_PLUGIN_ROOT}/scripts/hooks/post-tool/check-pr-scope.sh"
---

<objective>

Git workflow guidance: conventional commits, branch naming, PR workflows.

</objective>

<routing>

| Task          | Resource                      |
| ------------- | ----------------------------- |
| Commit format | `references/conventions.md`   |
| Branch naming | `references/conventions.md`   |
| PR workflow   | `references/conventions.md`   |
| Machete hooks | `references/machete-hooks.md` |
| Feature PR    | `templates/pr-feature.md`     |
| Bug fix PR    | `templates/pr-fix.md`         |
| Refactor PR   | `templates/pr-refactor.md`    |
| Quick PR      | `templates/pr-default.md`     |

</routing>

<commands>

| Command                                          | Purpose                               |
| ------------------------------------------------ | ------------------------------------- |
| `Skill({ skill: "crew:git:setup" })`             | Configure git + machete optimally     |
| `Skill({ skill: "crew:git:discover" })`          | Auto-detect branch layout             |
| `Skill({ skill: "crew:git:pr" })`                | Create PR with template               |
| `Skill({ skill: "crew:git:update-pr" })`         | Update PR title/body                  |
| `Skill({ skill: "crew:git:stack-status" })`      | View branch stack status              |
| `Skill({ skill: "crew:git:stack-add" })`         | Add branch to stack                   |
| `Skill({ skill: "crew:git:traverse" })`          | Sync all stacked branches             |
| `Skill({ skill: "crew:git:sync" })`              | Sync current branch with parent       |
| `Skill({ skill: "crew:git:slide-out" })`         | Remove merged branch from stack       |
| `Skill({ skill: "crew:git:advance" })`           | Fast-forward merge child into current |
| `Skill({ skill: "crew:git:go" })`                | Navigate stack (up/down/next/prev)    |
| `Skill({ skill: "crew:git:checkout-prs" })`      | Checkout PRs from GitHub              |
| `Skill({ skill: "crew:git:retarget-pr" })`       | Change PR base branch                 |
| `Skill({ skill: "crew:git:restack-pr" })`        | Retarget + force push atomically      |
| `Skill({ skill: "crew:git:cleanup-unmanaged" })` | Delete branches not in layout         |
| `Skill({ skill: "crew:git:commit" })`            | Create conventional commit            |
| `Skill({ skill: "crew:git:branch" })`            | Create feature branch                 |
| `Skill({ skill: "crew:git:push" })`              | Push current branch                   |
| `Skill({ skill: "crew:git:clean" })`             | Clean stale branches                  |

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
