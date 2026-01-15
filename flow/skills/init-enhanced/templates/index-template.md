---
name: index-template
description: Template for .claude/docs/_index.md quick reference
---

<template>

````markdown
<!-- AUTO-GENERATED: index -->

# {PROJECT_NAME}

{ONE_LINE_DESCRIPTION}

## Quick Reference

| Aspect    | Details                                        |
| --------- | ---------------------------------------------- |
| Type      | {PROJECT_TYPE: monorepo/monolith/microservice} |
| Language  | {PRIMARY_LANGUAGE}                             |
| Framework | {MAIN_FRAMEWORK}                               |
| Database  | {DATABASE_IF_ANY}                              |

## Documentation

| Doc                                   | Description                     |
| ------------------------------------- | ------------------------------- |
| [Architecture](architecture.md)       | Codebase structure and patterns |
| [Getting Started](getting-started.md) | Setup and configuration         |
| [Data Layer](data-layer.md)           | Models, schemas, validation     |
| [API Reference](api-reference.md)     | Endpoints and interfaces        |
| [Testing](testing.md)                 | Test patterns and coverage      |
| [Deployment](deployment.md)           | CI/CD and infrastructure        |
| [Dependencies](dependencies.md)       | Key packages explained          |
| [Glossary](glossary.md)               | Domain terminology              |

## Common Commands

```bash
# Development
{DEV_COMMAND}

# Testing
{TEST_COMMAND}

# Build
{BUILD_COMMAND}
```
````

## Key Entry Points

- `{MAIN_ENTRY}` - Application entry
- `{CONFIG_ENTRY}` - Configuration
- `{ROUTES_ENTRY}` - API routes (if applicable)

<!-- END AUTO-GENERATED -->

## Notes

_Add project-specific notes here. This section is preserved on updates._

```

</template>

<usage>

Replace placeholders with actual values from agent exploration:

- `{PROJECT_NAME}` - from package.json name or directory
- `{ONE_LINE_DESCRIPTION}` - from package.json description or inferred
- `{PROJECT_TYPE}` - detected from structure (turbo.json = monorepo, etc.)
- `{PRIMARY_LANGUAGE}` - from tsconfig.json, .py files, etc.
- `{MAIN_FRAMEWORK}` - Next.js, Express, FastAPI, etc.
- `{DATABASE_IF_ANY}` - from prisma schema, drizzle config, etc.
- `{DEV_COMMAND}` - from package.json scripts
- `{TEST_COMMAND}` - vitest, jest, pytest, etc.
- `{BUILD_COMMAND}` - from package.json scripts

</usage>

<token_budget>

Target: ~200 tokens for the auto-generated section.
User notes section can grow without affecting context efficiency.

</token_budget>
```
