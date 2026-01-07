---
name: crew:git:branch
description: Create a feature branch from main
allowed-tools: Bash(git checkout:*), Bash(git fetch:*), Bash(git branch:*), Bash(git machete:*), AskUserQuestion
---

<constraints>

**CRITICAL: NEVER output plain text questions. Use AskUserQuestion tool for all user choices.**

</constraints>

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/branch-context.sh`
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`

<naming>

`type/short-description`

| Type        | Use           |
| ----------- | ------------- |
| `feat/`     | New feature   |
| `fix/`      | Bug fix       |
| `refactor/` | Restructuring |
| `docs/`     | Documentation |
| `chore/`    | Maintenance   |

</naming>

<process>

Ask branch type:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What type of branch?",
      header: "Type",
      options: [
        { label: "Regular branch", description: "From main" },
        {
          label: "Stacked branch",
          description: "Child of current (stacked PRs)",
        },
      ],
    },
  ],
});
```

**Regular:**

```bash
git fetch origin main && git checkout -b <type>/<name> origin/main
```

**Stacked:**

```bash
git checkout -b <type>/<name>
git machete add --onto $(git rev-parse --abbrev-ref @{-1})
```

</process>
