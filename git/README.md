# Git Plugin v1.3.2

Git workflow automation with conventional commits, smart branching, PR templates, and safe push/sync operations.

## Commands

| Command | Purpose |
|---------|---------|
| `/commit` | Create conventional commit with selective staging |
| `/commit-push` | Commit and push to remote in one step |
| `/branch` | Create branch with `username/type/slug` naming |
| `/pr` | Create PR with template-based body, draft/auto-merge options |
| `/update-pr` | Update PR title and body from commits, preserving valuable content |
| `/push` | Push with safety checks and force-with-lease |
| `/sync` | Merge or rebase from main with conflict guidance |
| `/clean-gone` | Remove local branches deleted from remote |

## Installation

```bash
# Via marketplace
/install git@settlemint

# Local development
claude --plugin-dir ~/path/to/git
```

## Usage

### Quick Workflow

```bash
/branch feat add-user-auth     # Create feature branch
# ... make changes ...
/commit                        # Commit with conventional format
/push                          # Push to remote
/pr                            # Create PR with template
```

### Commit Types

| Type | Use When |
|------|----------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change (no feature/fix) |
| `test` | Adding/updating tests |
| `chore` | Maintenance, deps, config |
| `perf` | Performance improvement |

### Branch Naming

Format: `username/type/slug`

Examples:
- `roderik/feat/user-authentication`
- `roderik/fix/null-pointer-login`
- `roderik/chore/bump-dependencies`

## Requirements

- Git installed and configured
- GitHub CLI (`gh`) for PR operations
- Repository with remote origin

## Skills

The `using-git` skill provides:
- Conventional commit conventions
- Branch naming patterns
- PR template selection logic
- Conflict resolution guidance
- Merge vs rebase decision tree

## Scripts

Helper scripts in `scripts/`:
- `context.sh` - Git context (branch, status, changes)
- `pr-info.sh` - PR metadata
- `pr-checks.sh` - CI status

## Version History

- **v1.3.2**: Update skill descriptions to use official third-person trigger format for better auto-triggering
- **v1.3.1**: Add "Ready + auto-squash" option to `/pr` command to skip auto-merge question
- **v1.3.0**: Add auto-retry with rebase when push is rejected due to remote changes
- **v1.2.0**: Add `/update-pr` command to update PR title and body from commits, preserving user description and review agent findings
- **v1.1.0**: Add `/commit-push` command for combined commit and push workflow
- **v1.0.0**: Initial release with commit, branch, pr, push, sync, clean-gone commands

## License

MIT
