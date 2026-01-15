---
name: doc-template
description: Template for individual documentation files
---

<template>

```markdown
<!-- AUTO-GENERATED: {DOC_ID} -->

# {DOC_TITLE}

{BRIEF_DESCRIPTION}

## Overview

{SUMMARY_PARAGRAPH}

## Key Components

| Component | Location | Purpose   |
| --------- | -------- | --------- |
| {NAME}    | `{PATH}` | {PURPOSE} |

## Patterns

{IDENTIFIED_PATTERNS}

## References

- `{FILE_PATH}:{LINE}` - {DESCRIPTION}

<!-- END AUTO-GENERATED -->

## Notes

_Add manual observations here. This section is preserved on updates._
```

</template>

<doc_specific_sections>

### architecture.md

- Directory structure tree
- Module boundaries
- Architectural decisions

### getting-started.md

- Prerequisites
- Installation steps
- Environment setup
- First run commands

### data-layer.md

- Schema overview
- Key entities
- Relationships
- Validation patterns

### api-reference.md

- Endpoint table (method, path, description)
- Authentication approach
- Common patterns

### testing.md

- Framework and config
- Test organization
- Running tests
- Coverage approach

### deployment.md

- CI/CD pipeline
- Build process
- Deployment targets
- Environment configuration

### dependencies.md

- Core dependencies table
- Notable dev deps
- Internal packages (monorepo)

### glossary.md

- Term definitions table
- Domain concepts
- Abbreviations

</doc_specific_sections>

<merge_rules>

1. **Preserve manual content**: Everything outside `<!-- AUTO-GENERATED -->` markers is user content
2. **Replace generated content**: Everything between markers gets replaced on update
3. **Add Notes section**: If doc has no Notes section, add template at end
4. **Format consistency**: Use tables for structured data, keep prose minimal

</merge_rules>

<token_budget>

Target per doc:

- architecture.md: 400-600 tokens
- getting-started.md: 300-500 tokens
- data-layer.md: 400-600 tokens
- api-reference.md: 300-500 tokens
- testing.md: 200-400 tokens
- deployment.md: 200-400 tokens
- dependencies.md: 200-400 tokens
- glossary.md: 200-400 tokens

Total generated: ~2500-4000 tokens

</token_budget>
