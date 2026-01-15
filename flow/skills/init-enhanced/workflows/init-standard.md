---
name: init-standard
description: Standard single-project codebase documentation workflow
---

<objective>

Generate comprehensive documentation for a single-project codebase using 6 parallel exploration agents. Output modular docs to `.claude/docs/` with merge markers for safe updates.

</objective>

<workflow>

## Step 1: Pre-flight checks

```bash
# Ensure we're in a git repo
git rev-parse --is-inside-work-tree || exit 1

# Get current git SHA for staleness tracking
GIT_SHA=$(git rev-parse HEAD)
```

## Step 2: Launch parallel exploration agents

Launch ALL 6 agents in a SINGLE message for true parallelism:

```javascript
// Agent 1: Structure & Architecture
Task({
  subagent_type: "Explore",
  description: "Analyze codebase structure",
  prompt: `Map the repository structure for documentation:
- Top-level directories and their purposes
- Key entry points (main files, index files)
- Architecture pattern (monorepo, microservices, monolith)
- File naming conventions
- Module boundaries and organization

Use progressive disclosure: Glob first, then targeted Grep/Read.
Cite specific file:line for observations.
Keep output under 500 tokens.`,
  run_in_background: true,
});

// Agent 2: Configuration & Setup
Task({
  subagent_type: "Explore",
  description: "Analyze configuration and setup",
  prompt: `Document configuration and environment setup:
- Config files (tsconfig, eslint, prettier, etc.)
- Environment variables and .env patterns
- Build configuration (vite, webpack, esbuild, etc.)
- Package manager (npm, yarn, pnpm, bun)
- Required setup steps for new developers

Focus on what's needed to get started.
Keep output under 500 tokens.`,
  run_in_background: true,
});

// Agent 3: Data & Business Logic
Task({
  subagent_type: "Explore",
  description: "Analyze data layer and domain",
  prompt: `Document the data layer and business domain:
- Database schemas and models
- ORM/ODM usage (Prisma, Drizzle, TypeORM, etc.)
- Data validation patterns (Zod, Yup, etc.)
- Core business entities and their relationships
- Domain terminology (glossary terms)

Identify key abstractions and domain language.
Keep output under 600 tokens.`,
  run_in_background: true,
});

// Agent 4: APIs & Interfaces
Task({
  subagent_type: "Explore",
  description: "Analyze API layer",
  prompt: `Document the API and interface layer:
- API endpoints and routes
- Request/response patterns
- Authentication and authorization approach
- Middleware stack
- GraphQL schemas or WebSocket handlers (if any)

Focus on the public interface surface.
Keep output under 500 tokens.`,
  run_in_background: true,
});

// Agent 5: Testing & DevOps
Task({
  subagent_type: "Explore",
  description: "Analyze testing and deployment",
  prompt: `Document testing and deployment:
- Test framework (Vitest, Jest, Playwright, etc.)
- Test organization and patterns
- CI/CD pipeline (GitHub Actions, etc.)
- Docker configuration
- Deployment targets

Focus on how to run tests and deploy.
Keep output under 600 tokens.`,
  run_in_background: true,
});

// Agent 6: Dependencies
Task({
  subagent_type: "Explore",
  description: "Analyze dependencies",
  prompt: `Document key dependencies:
- Core runtime dependencies and their purposes
- Notable dev dependencies
- Internal packages (if monorepo)
- Peer dependency requirements

Focus on the most important 10-15 packages.
Keep output under 400 tokens.`,
  run_in_background: true,
});
```

## Step 3: Collect agent results

Wait for all agents to complete and collect their findings.

## Step 4: Generate documentation files

For each doc, use the merge marker pattern:

```markdown
<!-- AUTO-GENERATED: {section} -->

{Agent findings formatted for the doc}

<!-- END AUTO-GENERATED -->
```

If a doc already exists:

1. Parse existing content for `<!-- AUTO-GENERATED: X -->` markers
2. Replace only content between markers
3. Preserve everything outside markers

## Step 5: Create \_index.md

Synthesize a quick reference from all agent findings:

- Project overview (1-2 sentences)
- Key technologies
- Quick links to each doc
- Common commands

## Step 6: Generate .meta.json

```json
{
  "generated": "{timestamp}",
  "gitSha": "{GIT_SHA}",
  "docs": {
    "architecture.md": {
      "updated": "{timestamp}",
      "watchPatterns": [
        "**/package.json",
        "**/tsconfig.json",
        "src/**/index.ts"
      ]
    },
    "getting-started.md": {
      "updated": "{timestamp}",
      "watchPatterns": ["package.json", ".env*", "docker-compose*"]
    },
    "data-layer.md": {
      "updated": "{timestamp}",
      "watchPatterns": [
        "**/schema*",
        "**/models/**",
        "**/*.prisma",
        "**/drizzle/**"
      ]
    },
    "api-reference.md": {
      "updated": "{timestamp}",
      "watchPatterns": ["**/routes/**", "**/api/**", "**/handlers/**"]
    },
    "testing.md": {
      "updated": "{timestamp}",
      "watchPatterns": [
        "**/*.test.*",
        "**/*.spec.*",
        "vitest.config.*",
        "playwright.config.*"
      ]
    },
    "deployment.md": {
      "updated": "{timestamp}",
      "watchPatterns": [".github/**", "Dockerfile*", "*.yaml", "*.yml"]
    },
    "dependencies.md": {
      "updated": "{timestamp}",
      "watchPatterns": ["package.json", "pnpm-lock.yaml", "package-lock.json"]
    },
    "glossary.md": {
      "updated": "{timestamp}",
      "watchPatterns": ["**/types/**", "**/interfaces/**", "**/models/**"]
    }
  }
}
```

## Step 7: Verify output

- [ ] All docs created in `.claude/docs/`
- [ ] Each doc under 600 tokens
- [ ] `_index.md` provides quick navigation
- [ ] `.meta.json` has correct git SHA
- [ ] Docs are git-tracked

</workflow>

<success_criteria>

- [ ] 8 documentation files created
- [ ] Total tokens under 4000
- [ ] Progressive disclosure structure
- [ ] Ready for incremental updates

</success_criteria>
