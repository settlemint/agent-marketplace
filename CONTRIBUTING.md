# Contributing

Thanks for helping improve this repo. The primary goal is consistent behavior across Claude Code and Codex (local + web).

## Ground rules

- Treat `.agents/setup.json` as the source of truth.
- Do not hand-edit the contents inside `<workflows>` or `<skill-routing-table>` in `CLAUDE.md` or `AGENTS.md`.
- Keep changes scoped to the goal of cross-environment parity.

## Common tasks

Refresh the workflow/routing tables after updating skills or setup config:

```bash
./scripts/refresh-docs
```

Skip heavy installs when you only need docs updated:

```bash
./.agents/setup.sh --docs-only
```

## Testing

There is no test suite yet. If you add scripts or tooling, include a minimal verification step in the README.
