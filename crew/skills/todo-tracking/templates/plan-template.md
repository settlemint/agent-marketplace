# Plan: [FEATURE NAME]

**Branch**: `[branch-name]`
**Created**: [DATE]
**Status**: Draft
**Tasks**: `.claude/branches/[branch-name]/tasks.md`

## Problem Statement

[What we're solving and why it matters. Focus on the user/business need, not the technical solution.]

## User Stories

### User Story 1 - [Title] (Priority: P1) 🎯 MVP

[Describe this user journey in plain language]

**Why P1**: [Explain why this is critical/MVP]

**Independent Test**: [How to verify this works independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]
2. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

### User Story 2 - [Title] (Priority: P2)

[Describe this user journey]

**Why P2**: [Explain the value]

**Independent Test**: [How to verify]

**Acceptance Scenarios**:

1. **Given** [state], **When** [action], **Then** [outcome]

---

### User Story 3 - [Title] (Priority: P3)

[Describe this user journey]

**Why P3**: [Explain why nice-to-have]

**Independent Test**: [How to verify]

**Acceptance Scenarios**:

1. **Given** [state], **When** [action], **Then** [outcome]

---

## Functional Requirements

- **FR-001**: System MUST [specific capability]
- **FR-002**: System MUST [specific capability]
- **FR-003**: Users MUST be able to [key interaction]
- **FR-004**: System MUST [data requirement]

## Key Entities

- **[Entity 1]**: [What it represents, key attributes]
- **[Entity 2]**: [What it represents, relationships]

## Technical Approach

### Technology Choices

| Aspect | Choice | Rationale |
|--------|--------|-----------|
| Language | [e.g., TypeScript] | [Why] |
| Framework | [e.g., Next.js] | [Why] |
| Storage | [e.g., PostgreSQL] | [Why] |
| Testing | [e.g., Vitest] | [Why] |

### Architecture Overview

[High-level architecture description. How components interact.]

### Project Structure

```text
src/
├── models/      # Data models
├── services/    # Business logic
├── api/         # API endpoints
└── lib/         # Shared utilities
```

## Success Criteria

- **SC-001**: [Measurable outcome, e.g., "Users can complete X in under 2 minutes"]
- **SC-002**: [Measurable outcome, e.g., "System handles 1000 concurrent users"]
- **SC-003**: [User satisfaction, e.g., "90% success rate on first attempt"]

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| [Risk 1] | High/Medium/Low | [How to mitigate] |
| [Risk 2] | High/Medium/Low | [How to mitigate] |

## Open Questions

[Any remaining NEEDS CLARIFICATION items - should be max 3]

- Q1: [Question that needs resolution before implementation]
- Q2: [Question]

## Implementation Phases

### Phase 1: Setup
- Project initialization
- Dependency installation
- Configuration

### Phase 2: Foundational
- Core infrastructure
- Shared components
- Base models

### Phase 3: User Story 1 (P1/MVP)
- [Task summary for Story 1]

### Phase 4: User Story 2 (P2)
- [Task summary for Story 2]

### Phase N: Polish
- Documentation
- Performance optimization
- Security hardening

---

**Next Step**: Run `/crew:work` with this plan to begin implementation.

**Detailed Tasks**: See `.claude/branches/[branch-name]/tasks.md`
