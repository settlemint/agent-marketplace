## Development Philosophy

This codebase will outlive you. Every shortcut you take becomes
someone else's burden. Every hack compounds into technical debt
that slows the whole team down.

You are not just writing code. You are shaping the future of this
project. The patterns you establish will be copied. The corners
you cut will be cut again.

Fight entropy. Leave the codebase better than you found it.

## Non-negotiables
- Ship production-grade, scalable (>1000 users) implementations; avoid MVP/minimal shortcuts.
- Optimize for long-term sustainability: maintainable, reliable designs.
- Make changes the single canonical implementation in the primary codepath; delete legacy/dead/duplicate paths as part of delivery.
- Use direct, first-class integrations; do not introduce shims, wrappers, glue code, or adapter layers.
- Keep a single source of truth for business rules/policy (validation, enums, flags, constants, config).
- Clean API invariants: define required inputs, validate up front, fail fast.
- Use latest stable libs/docs; if unsure, do a web search.

## Coding Style
- Target <=500 LOC (hard cap 750; imports/types excluded).
- Keep UI/markup nesting <=3 levels; extract components/helpers when JSX/templating repeats, responsibilities pile up, or variant/conditional switches grow.

## Security guards
- No delete/move/overwrite without explicit user request; for deletions prefer `trash` over `rm`.
- Don't expose secrets in code/logs; use env/secret stores.
- Validate/sanitize untrusted input to prevent injection, path traversal, SSRF, and unsafe uploads.
- Enforce AuthN/AuthZ and tenant boundaries; least privilege.
- Be cautious with new dependencies; flag supply-chain/CVE risk.

## Codex behaviour
- If files change unexpectedly, assume parallel edits and continue; keep your diff scoped. Stop only for conflicts/breakage, then ask the user.
- When web searching, prefer 2026 (latest) sources/docs unless an older version is explicitly needed.
- Set an approval mode that matches the task risk; switch with `/approvals` as needed, and use full access sparingly.
- Use `/review` for a second set of eyes on risky or wide changes.
- Keep AGENTS.md scoped and lean to avoid unnecessary context bloat.

## Codex Skills
- Skills live in repo `.codex/skills` and global `~/.codex/skills`; if `$<myskill>` isn't found locally, explicitly load `~/.codex/skills/<myskill>/SKILL.md` (plus any `references/`/`scripts/`).
- Use `/skills` to list available skills, `$skill-name` for direct invocation.

## When using the shell
- Prefer built-in tools (e.g. `read_file`/`list_dir`/`grep_files`) over ad-hoc shell plumbing when available.
- For shell-based search: `fd` (files), `rg` (text), `ast-grep` (syntax-aware), `jq`/`yq` (extract/transform).
