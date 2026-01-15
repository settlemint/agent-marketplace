---
name: init-monorepo
description: Monorepo/turborepo codebase documentation workflow with per-package docs
---

<objective>

Generate comprehensive documentation for monorepo/turborepo codebases. Creates root-level docs plus per-package documentation in `.claude/docs/packages/`.

</objective>

<detection>

Triggers when any of these exist:

- `turbo.json`
- `pnpm-workspace.yaml`
- `lerna.json`
- `packages/` directory with multiple package.json files

</detection>

<workflow>

## Step 1: Detect monorepo structure

```bash
# Identify packages
if [[ -f "pnpm-workspace.yaml" ]]; then
  PACKAGES=$(yq '.packages[]' pnpm-workspace.yaml | tr -d "'\"")
elif [[ -f "turbo.json" ]]; then
  PACKAGES=$(find . -name "package.json" -path "*/packages/*" -o -name "package.json" -path "*/apps/*" | xargs dirname)
else
  PACKAGES=$(find ./packages -maxdepth 2 -name "package.json" | xargs dirname)
fi
```

## Step 2: Generate root documentation

Run the standard workflow for root-level docs, focusing on:

- Monorepo tooling (turborepo, pnpm workspaces, etc.)
- Shared configuration
- Cross-package dependencies
- Build pipeline

## Step 3: Generate per-package docs

For each package, launch an Explore agent:

```javascript
packages.forEach((pkg) => {
  Task({
    subagent_type: "Explore",
    description: `Document ${pkg.name}`,
    prompt: `Analyze the ${pkg.name} package:
- Purpose and responsibility
- Key exports and public API
- Dependencies (internal and external)
- Entry points and build output
- How it relates to other packages

Output format:
## ${pkg.name}
Brief description
### Exports
- key exports
### Dependencies
- internal: [list]
- external: [list]

Keep under 300 tokens.`,
    run_in_background: true,
  });
});
```

## Step 4: Create package documentation structure

```
.claude/docs/
├── _index.md           # Root overview + package links
├── architecture.md     # Monorepo architecture
├── getting-started.md  # Setup + workspace commands
├── packages/
│   ├── _index.md       # Package overview table
│   ├── api.md          # Per-package doc
│   ├── web.md
│   └── shared.md
└── .meta.json
```

## Step 5: Package index template

Generate `.claude/docs/packages/_index.md`:

```markdown
<!-- AUTO-GENERATED: packages-index -->

# Packages

| Package     | Description          | Dependencies          |
| ----------- | -------------------- | --------------------- |
| @org/api    | Backend API server   | @org/shared           |
| @org/web    | Frontend application | @org/shared, @org/api |
| @org/shared | Shared utilities     | -                     |

<!-- END AUTO-GENERATED -->
```

## Step 6: Update .meta.json for packages

Add package-specific watch patterns:

```json
{
  "docs": {
    "packages/api.md": {
      "watchPatterns": ["packages/api/**", "apps/api/**"]
    },
    "packages/web.md": {
      "watchPatterns": ["packages/web/**", "apps/web/**"]
    }
  }
}
```

## Step 7: Cross-package dependency graph

If significant, include a dependency graph in architecture.md:

```
@org/web ──→ @org/api ──→ @org/shared
    │                         ↑
    └─────────────────────────┘
```

</workflow>

<success_criteria>

- [ ] Root docs created
- [ ] Per-package docs in `packages/` subdirectory
- [ ] Package index with overview table
- [ ] Cross-references between packages
- [ ] Watch patterns scoped to package directories

</success_criteria>
