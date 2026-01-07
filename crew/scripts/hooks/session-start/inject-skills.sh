#!/usr/bin/env bash
# Inject available crew skills and commands at session start
# Helps Claude know what tools are available

set +e

cat <<'EOF'
## Crew Plugin - Available Commands & Skills

### Slash Commands
| Command | Purpose |
|---------|---------|
| `/crew:design` | Create implementation plans with research |
| `/crew:build` | Execute plans with progress tracking |
| `/crew:check` | Multi-agent code review |
| `/crew:ci` | Run CI in background haiku agent |
| `/crew:git:commit` | Guided commit with context |
| `/crew:git:pr` | Create PR with template |
| `/crew:git:branch` | Create feature branch |
| `/crew:git:sync` | Sync branch with main |

### Skills (auto-loaded by triggers)
| Skill | Triggers | Purpose |
|-------|----------|---------|
| git | commit, branch, pr | Git conventions and workflows |
| agent-architecture | agent, orchestration | Agent patterns and loops |
| skill-builder | skill, create skill | Skill creation framework |
| todo-tracking | todo, task | File-based task management |

### Best Practices
- **Git commits**: Use conventional format `type(scope): description`
- **CI checks**: Use Skill(skill: "crew:ci") to run in background (keeps main thread free)
- **Planning**: Use Skill(skill: "crew:design") before implementing complex features
- **Progress**: Use TodoWrite to track multi-step tasks
EOF

exit 0
