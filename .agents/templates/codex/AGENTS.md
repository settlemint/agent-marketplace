# Agents

## Non-negotiables
- Ship production-grade, scalable (>1000 users) implementations; avoid MVP/minimal shortcuts.
- Optimize for long-term sustainability: maintainable, reliable designs.
- Make changes the single canonical implementation in the primary codepath; delete legacy/dead/duplicate paths as part of delivery.
- Use direct, first-class integrations; do not introduce shims, wrappers, glue code, or adapter layers.
- Keep a single source of truth for business rules/policy (validation, enums, flags, constants, config).
- Clean API invariants: define required inputs, validate up front, fail fast.
- Use latest stable libs/docs; if unsure, do a web search.
## Codex behaviour
 - If files change unexpectedly, assume parallel edits and continue; keep your diff scoped. Stop only for conflicts/breakage, then ask the user.
 - When web searching, prefer 2026 (latest) sources/docs unless an older version is explicitly needed.

## Codex Skills
- Skills live in repo `.codex/skills` and global `~/.codex/skills`; if `$<myskill>` isn't found locally, explicitly load `~/.codex/skills/<myskill>/SKILL.md` (plus any `references/`/`scripts/`).
- Use `/skills` to list available skills, `$skill-name` for direct invocation.

## Coding Style
- Target <=500 LOC (hard cap 750; imports/types excluded).
- Keep UI/markup nesting <=3 levels; extract components/helpers when JSX/templating repeats, responsibilities pile up, or variant/conditional switches grow.

## Security guards
- No delete/move/overwrite without explicit user request; for deletions prefer `trash` over `rm`.
- Don’t expose secrets in code/logs; use env/secret stores.
- Validate/sanitize untrusted input to prevent injection, path traversal, SSRF, and unsafe uploads.
- Enforce AuthN/AuthZ and tenant boundaries; least privilege.
- Be cautious with new dependencies; flag supply-chain/CVE risk.

## Git operations
- Use `gh` CLI for GitHub operations (issues/PRs/releases).
- Ask before any `git push`.
- Prefer Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`, etc.).

## Pull requests
- Create/manage PRs via `gh pr ...`.
- Avoid noise (logs/dumps); include only key context, risks, and screenshots when UX changes.

## When using the shell:
- Prefer built-in tools (e.g. `read_file`/`list_dir`/`grep_files`) over ad-hoc shell plumbing when available.
- For shell-based search: `fd` (files), `rg` (text), `ast-grep` (syntax-aware), `jq`/`yq` (extract/transform).

<task-classification>
{{TASK_CLASSIFICATION}}
</task-classification>
<hard-requirements>
{{HARD_REQUIREMENTS}}
</hard-requirements>
<anti-patterns>
{{ANTI_PATTERNS}}
</anti-patterns>
<workflows>
{{WORKFLOWS}}
</workflows>
<skill-routing-table>
{{SKILL_ROUTING_TABLE}}
</skill-routing-table>
