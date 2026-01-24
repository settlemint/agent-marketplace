---
name: reviewers
description: 4400+ curated code review prompts from leading open-source repositories
user-invocable: true
version: '1.0'
---

# Code Reviewers

A collection of 4400+ curated code review guidelines derived from real code review comments in leading open-source repositories.

## Attribution

This skill contains content from [baz-scm/awesome-reviewers](https://github.com/baz-scm/awesome-reviewers), licensed under Apache 2.0.

## Skill Categories

The reviewers are organized into 10 skill domains. Read each file in `skills/` for detailed guidance:

| Category | File | Focus |
|----------|------|-------|
| AI-Assisted Development | `skills/ai-assisted-development.md` | Leveraging AI coding assistants while maintaining quality |
| Code Readability | `skills/code-readability.md` | Writing clear, maintainable code |
| Code Refactoring | `skills/code-refactoring.md` | Improving code structure and design |
| Data & ML | `skills/data-ml.md` | Data pipelines and machine learning |
| DevOps & Cloud | `skills/devops-cloud.md` | Infrastructure and deployment |
| Documentation | `skills/documentation.md` | Code and API documentation |
| Full-Stack Development | `skills/full-stack-development.md` | Frontend and backend integration |
| Secure Coding | `skills/secure-coding.md` | Security best practices |
| Team Collaboration | `skills/team-collaboration.md` | Code review and teamwork |
| Testing & Debugging | `skills/testing-debugging.md` | Test strategies and debugging |

## Reviewer Organization

The 4400+ reviewers in `reviewers/` are prefixed by source project. Major projects include:

| Prefix | Project | Count |
|--------|---------|-------|
| `react-*` | React | 109 |
| `kubeflow-*` | Kubeflow | 62 |
| `neon-*` | Neon | 50 |
| `sentry-*` | Sentry | 48 |
| `spring-*` | Spring | 46 |
| `mastodon-*` | Mastodon | 45 |
| `grafana-*` | Grafana | 43 |
| `cypress-*` | Cypress | 43 |
| `bun-*` | Bun | 37 |
| `deno-*` | Deno | 36 |
| `nest-*` | NestJS | 36 |
| `checkov-*` | Checkov | 38 |
| `argo-*` | Argo CD | 38 |
| `posthog-*` | PostHog | 39 |
| `teleport-*` | Teleport | 39 |

And 165+ more projects.

## Reviewer File Format

Each reviewer follows this format:

```yaml
---
title: <Review guideline title>
description: <Brief description>
repository: <source OSS repo>
label: <category>
language: <programming language>
comments_count: <number of supporting comments>
repository_stars: <repo popularity>
---

<Detailed guidelines with examples and code blocks>
```

## Usage

### Selecting Relevant Reviewers

1. **By Language**: Filter reviewers by the `language` field in their frontmatter
   ```bash
   grep -l "language: TypeScript" reviewers/*.md
   ```

2. **By Project/Framework**: Use project prefixes to find relevant patterns
   - React apps: `react-*`, `next-*`
   - Python: `airflow-*`, `kubeflow-*`, `boto3-*`
   - Go: `kubernetes-*`, `teleport-*`, `argo-*`
   - Rust: `deno-*`, `bun-*`, `workerd-*`

3. **By Category**: Use the `label` field
   - Code Style
   - Performance
   - Security
   - Testing
   - Documentation

### Applying Reviewers to Code Review

When reviewing code:

1. **Identify the tech stack** from the files being reviewed
2. **Select 5-10 relevant reviewers** based on:
   - Programming language
   - Framework/library in use
   - Type of change (feature, refactor, bugfix)
3. **Read each selected reviewer** for specific guidelines
4. **Apply the patterns** when commenting on the code

### Integration with Differential Review

When using the `differential-review` skill:

1. First identify changed files and their languages
2. Load relevant reviewers for those languages/frameworks
3. Use reviewer guidelines to inform your review comments

### Quick Reference by Technology

**TypeScript/JavaScript:**
- `react-*`, `next-*`, `angular-*`, `nest-*`, `bun-*`, `deno-*`

**Python:**
- `airflow-*`, `kubeflow-*`, `boto3-*`, `checkov-*`, `prowler-*`

**Go:**
- `kubernetes-*`, `teleport-*`, `argo-*`, `grafana-*`

**Rust:**
- `deno-*` (core), `bun-*` (native), `workerd-*`

**Infrastructure/DevOps:**
- `kubernetes-*`, `argo-*`, `grafana-*`, `checkov-*`, `prowler-*`

**Security:**
- `checkov-*`, `prowler-*`, `teleport-*`, `sentry-*`
