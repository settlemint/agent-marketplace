# Detection Patterns by Audit Dimension

## 1. Large Files

**Thresholds:**

- > 500 lines: P2 - needs refactoring consideration
- > 1000 lines: P1 - actively blocks comprehension

**Detection:**

```bash
# List all files sorted by line count
find src -name "*.ts" -o -name "*.tsx" | xargs wc -l | sort -rn | head -30

# Find specifically large files
find src \( -name "*.ts" -o -name "*.tsx" \) -exec wc -l {} + | awk '$1 > 500' | sort -rn
```

**Split point indicators:**

- Multiple exported functions/classes (>5)
- Mixed concerns (UI + data fetching + business logic)
- Multiple "sections" separated by comment headers
- Repeated import patterns within file

---

## 2. Low Coverage

**Detection:**

```bash
# Check for files without corresponding test files
for f in $(find src -name "*.ts" ! -name "*.test.ts" ! -name "*.spec.ts"); do
  test_file="${f%.ts}.test.ts"
  spec_file="${f%.ts}.spec.ts"
  if [ ! -f "$test_file" ] && [ ! -f "$spec_file" ]; then
    echo "No test: $f"
  fi
done

# Run coverage and check for gaps
bun run test --coverage
```

**High-risk untested paths:**

- Error handling branches
- Edge cases in business logic
- API error responses
- Authentication/authorization checks

---

## 3. Duplication

**Conceptual duplication (P2):**

- Multiple implementations of same domain concept
- Parallel class/interface hierarchies
- Similar utility functions in different files

**Code duplication:**

```bash
# Find similar function names
grep -rh "^export.*function\|^function" --include="*.ts" src/ | sort | uniq -d

# Look for similar file names
find src -name "*.ts" | xargs -I{} basename {} | sort | uniq -d
```

**Consolidation strategy:**

1. Identify canonical location
2. Merge implementations (prefer simpler)
3. Update all imports
4. Delete redundant file

---

## 4. Dead Code

**Unused exports:**

```bash
# Manual check for each export
grep -rh "^export " --include="*.ts" src/ | while read -r line; do
  name=$(echo "$line" | grep -oE 'export (const|function|class|type|interface) [a-zA-Z0-9_]+' | awk '{print $NF}')
  if [ -n "$name" ]; then
    count=$(grep -r "import.*$name\|from.*$name" --include="*.ts" src/ | wc -l)
    if [ "$count" -eq 1 ]; then  # Only the export itself
      echo "Potentially unused: $name"
    fi
  fi
done
```

**Unreachable code patterns:**

- `if (false)` blocks
- Code after unconditional return/throw
- Switch cases for impossible values
- Catch blocks that can never trigger

**Commented-out code:**

```bash
# Find large commented blocks
grep -rn "^[[:space:]]*//" --include="*.ts" src/ | awk -F: '{print $1}' | uniq -c | awk '$1 > 5'
```

---

## 5. YAGNI Violations

**Over-abstraction signals:**

| Pattern          | YAGNI Signal       |
| ---------------- | ------------------ |
| Interface        | Single implementor |
| Factory          | Single product     |
| Config type      | Only defaults used |
| Abstract class   | Single child       |
| Strategy pattern | Single strategy    |
| Plugin system    | No plugins         |

**Detection:**

```bash
# Find interfaces and count implementations
grep -rh "^export interface" --include="*.ts" src/ | while read -r line; do
  name=$(echo "$line" | grep -oE 'interface [A-Z][a-zA-Z0-9]+' | awk '{print $2}')
  impl_count=$(grep -r "implements $name" --include="*.ts" src/ | wc -l)
  if [ "$impl_count" -eq 1 ]; then
    echo "Single implementation: $name"
  fi
done
```

**Resolution:**

- Inline single-use abstractions
- Replace factory with direct construction
- Flatten unnecessary inheritance

---

## 6. Library Opportunities

**Common hand-rolled patterns that libraries solve:**

| Hand-rolled         | Library Alternative     |
| ------------------- | ----------------------- |
| Date formatting     | date-fns, dayjs         |
| Form validation     | zod, yup, valibot       |
| HTTP client wrapper | ky, got, axios          |
| Deep object merge   | lodash.merge, deepmerge |
| UUID generation     | uuid, nanoid            |
| Retry logic         | p-retry, async-retry    |
| State machine       | xstate, robot           |

**Detection signals:**

- Functions with "util", "helper", "common" in path
- Similar code in npm packages you already use
- Complex regex for standard formats (email, URL, etc.)

---

## 7. Misplaced Files

**Common misplacements:**

| File Type         | Expected Location         |
| ----------------- | ------------------------- |
| React components  | `/components/` or `/app/` |
| Utility functions | `/lib/` or `/utils/`      |
| Type definitions  | `/types/` or co-located   |
| Test files        | Co-located with source    |
| Config files      | Project root              |
| API routes        | `/api/` or `/routes/`     |

**Detection:**

```bash
# Components not in components folder
find src -name "*.tsx" ! -path "*/components/*" ! -path "*/app/*" ! -path "*/pages/*"

# Utils with side effects (shouldn't have)
grep -rn "^import.*from" --include="*.ts" src/utils/ | grep -E "react|next|express"
```

---

## 8. Debug Cruft

**Console statements:**

```bash
grep -rn "console\.\(log\|warn\|error\|debug\|trace\)" --include="*.ts" --include="*.tsx" src/
```

**TODO/FIXME comments:**

```bash
grep -rn "TODO\|FIXME\|HACK\|XXX\|TEMP\|REMOVE" --include="*.ts" --include="*.tsx" src/
```

**Disabled tests:**

```bash
grep -rn "\.skip\|\.only\|xit\|xdescribe" --include="*.test.ts" --include="*.spec.ts" src/
```

**Stale plan files:**

```bash
find .claude/plans -name "*.md" -mtime +30  # Plans older than 30 days
```

**Temporary files:**

```bash
find . -name "*.bak" -o -name "*.tmp" -o -name "*.orig" -o -name "*~"
```
