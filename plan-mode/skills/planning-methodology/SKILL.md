---
name: planning-methodology
description: This skill should be used when the user asks to "plan a feature", "create a plan", "design an implementation", or enters plan mode. 7-phase methodology: Context, questions, spec, architecture, tasks, validation, Linear.
version: 2.3.1
---

# Planning Methodology

7 phases: Context → Questions → Spec → Architecture → Tasks → Validation → Linear

## Core Principles

- **2-5 min tasks** with exact file paths, code snippets
- **Evidence** for every step
- **TDD** for all implementation
- **No vague language** ("appropriate", "best practices")
- **YAGNI** ruthlessly
- **One question at a time**, multiple choice preferred

## Phases

### 1. Context Gathering

4-phase exploration via parallel Explore agents:
1. Feature Discovery - entry points, boundaries
2. Execution Flow - call chains, transformations
3. Architecture - layers, patterns
4. Deep-Dive - algorithms, error handling

Use Octocode MCP (LSP, GitHub) + Context7 MCP (docs).

### 2. Clarifying Questions

One question at a time, multiple choice with "(Recommended)" suffix.
Topics: edge cases, errors, integration, scope, preferences.

### 3. Specification

Six Core Areas: Commands, Testing, Structure, Style, Git, Boundaries.

Boundaries format:
- ✅ Always Do
- ⚠️ Ask First
- 🚫 Never Do

### 4. Architecture

2-3 options, lead with recommendation, ADR format.
Cross-check security/complex decisions.

### 5. Task Decomposition

2-5 min tasks with `[parallel]`/`[serial]`/`[MERGE-WALL]`.
Exact paths, code snippets, TDD, evidence.
Front-load merge walls.

### 6. Validation

Rule of Five: Standard → Deep → Architecture → Existential
Self-verify: Zero clarifying questions? Measurable criteria? No vague language?

### 7. Linear Integration (REQUIRED)

Ask about Linear: Create ticket, update existing, or skip.

## Agents

| Agent | Phase |
|-------|-------|
| context-researcher | 1 |
| architecture-analyst | 4 |
| task-decomposer | 5 |
| plan-validator | 6 |

## Quality Standards

| Criterion | Requirement |
|-----------|-------------|
| Granularity | 2-5 min |
| Paths | Exact |
| Evidence | Observable |
| Markers | [parallel]/[serial] |

## Banned Language

Replace: "appropriate" → exact criteria, "best practices" → name it, "handle errors" → catch/log/return.
