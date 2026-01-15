# Analysis Patterns

## The Analysis Framework

### 1. Scope Definition

Before analyzing, define scope:

- What questions are we trying to answer?
- What areas are in/out of scope?
- What level of depth is needed?

### 2. Data Collection

Gather data systematically:

**File-based metrics:**

```bash
# Count files by type
find . -name "*.ts" | wc -l
find . -name "*.test.ts" | wc -l

# Directory structure
tree -d -L 3
```

**Pattern-based search:**

```bash
# Find specific patterns
grep -r "TODO" --include="*.ts"
grep -r "console.log" --include="*.ts"
```

### 3. Pattern Recognition

Look for:

**Positive patterns:**

- Consistent naming conventions
- Clear module boundaries
- Good test coverage
- Documentation

**Negative patterns:**

- Code duplication
- Large files (>300 lines)
- Deep nesting (>4 levels)
- Commented-out code
- TODO/FIXME accumulation

### 4. Insight Synthesis

Convert observations to insights:

**Observation:** 15 files over 500 lines
**Insight:** Code complexity may be too high in key modules
**Recommendation:** Consider refactoring large files into smaller, focused modules

## Common Analysis Patterns

### The Architecture Check

**Purpose:** Understand system architecture

**Steps:**

1. Identify entry points
2. Map module dependencies
3. Trace data flow
4. Document component relationships

**Output:** Architecture diagram and description

### The Health Check

**Purpose:** Quick assessment of codebase health

**Checklist:**

- [ ] Dependencies up to date?
- [ ] Tests passing?
- [ ] No critical security vulnerabilities?
- [ ] Documentation current?
- [ ] CI/CD functioning?

### The Deep Dive

**Purpose:** Thorough analysis of specific area

**Steps:**

1. Read all code in area
2. Trace all dependencies
3. Review test coverage
4. Check for edge cases
5. Document findings

### The Comparison Analysis

**Purpose:** Compare implementations

**Steps:**

1. Identify comparable elements
2. Define comparison criteria
3. Gather data for each
4. Create comparison matrix
5. Draw conclusions

## Reporting Findings

### Finding Format

```markdown
## Finding: [Title]

**Severity:** High/Medium/Low
**Category:** Structure/Pattern/Quality/Dependency
**Location:** [files/directories affected]

**Observation:**
What was observed

**Impact:**
Why this matters

**Recommendation:**
What to do about it

**Effort:** High/Medium/Low
```

### Prioritization Matrix

|                 | Low Effort | High Effort |
| --------------- | ---------- | ----------- |
| **High Impact** | Quick Wins | Strategic   |
| **Low Impact**  | Fill-ins   | Avoid       |

Focus on Quick Wins first, then Strategic items.

## Tools and Techniques

### Static Analysis

- ESLint/TSLint for code quality
- SonarQube for comprehensive metrics
- madge for dependency graphs

### Manual Review

- Code walkthrough
- Architecture review
- Security audit

### Automated Scanning

- npm audit for security
- bundlesize for bundle analysis
- lighthouse for performance
