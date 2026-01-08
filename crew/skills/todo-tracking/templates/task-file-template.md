---
status: pending
priority: p1
story: us1
type: change        # gotcha | problem | howto | change | discovery | rationale | decision | tradeoff
parallel: true
file_path: src/path/to/file.ts
depends_on: []
tokens: ~150        # Approximate content size for ROI decisions
---

# T{ORDER}: {ICON} {Semantic Title ~10 words}

<!--
Legend (use in title):
  🔴 Gotcha     - Critical edge case that breaks assumptions
  🟡 Problem    - Fix/workaround for known issue
  🔵 How-to     - Technical explanation or implementation
  🟢 Change     - Code/architecture modification (default)
  🟣 Discovery  - Non-obvious insight learned
  🟠 Rationale  - Design reasoning (why it exists)
  🟤 Decision   - Architectural choice made
  ⚖️ Trade-off  - Deliberate compromise accepted

Example titles:
  🔴 Hook timeout: 60s default too short for npm install
  🟡 Race condition in auth: add mutex lock
  🟢 Add user validation middleware to API routes
  🟤 Use Redis over Memcached for session caching
-->

## Description

{What needs to be done and why. Keep it focused - one task = one clear goal.}

## Acceptance Criteria

- [ ] **Given** {initial state}, **When** {action}, **Then** {expected outcome}
- [ ] **Given** {initial state}, **When** {action}, **Then** {expected outcome}

## File Path

`{src/path/to/file.ts}`

## Implementation Notes

{Context for the implementing agent:}
- {Technology/framework to use}
- {Existing patterns to follow}
- {Constraints or requirements}

## Related Files

{Other files that may need awareness but not modification:}
- `src/related/file.ts` - {why relevant}

## Work Log

### {DATE} - Created
**By:** /crew:design
**Status:** Generated from plan
