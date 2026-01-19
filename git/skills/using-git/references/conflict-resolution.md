# Conflict Resolution Guide

## Contents
- Understanding Conflict Markers
- Resolution Strategies (Keep Yours, Keep Theirs, Keep Both, Manual Merge)
- Common Conflict Patterns
- Post-Resolution Checklist
- Commands
- Tools
- Prevention Tips

## Understanding Conflict Markers

When Git encounters conflicting changes, it marks the file:

```
<<<<<<< HEAD
your changes (current branch)
=======
their changes (incoming branch)
>>>>>>> origin/main
```

## Resolution Strategies

### 1. Keep Yours

Remove the incoming section entirely:

```diff
- <<<<<<< HEAD
  your changes
- =======
- their changes
- >>>>>>> origin/main
```

**Use when:** Your changes supersede theirs, or theirs are outdated.

### 2. Keep Theirs

Remove your section entirely:

```diff
- <<<<<<< HEAD
- your changes
- =======
  their changes
- >>>>>>> origin/main
```

**Use when:** Their changes are correct and yours should be discarded.

### 3. Keep Both

Combine both changes logically:

```diff
- <<<<<<< HEAD
  your changes
- =======
  their changes
- >>>>>>> origin/main
```

becomes:

```
your changes
their changes
```

**Use when:** Both changes are valid and should coexist.

### 4. Manual Merge

Rewrite the section entirely:

```diff
- <<<<<<< HEAD
- your changes
- =======
- their changes
- >>>>>>> origin/main
+ combined or new version
```

**Use when:** Neither version is exactly right.

## Common Conflict Patterns

### Package Version Bumps

```
<<<<<<< HEAD
  "typescript": "5.3.0"
=======
  "typescript": "5.2.0"
>>>>>>> origin/main
```

**Resolution:** Keep the higher version (usually yours).

### Added vs Deleted Code

```
<<<<<<< HEAD
function newHelper() {
  // new code
}
=======
>>>>>>> origin/main
```

**Resolution:** Usually keep the addition unless it conflicts with a deliberate removal.

### Import Statements

```
<<<<<<< HEAD
import { foo, bar } from './utils';
=======
import { foo, baz } from './utils';
>>>>>>> origin/main
```

**Resolution:** Combine imports: `import { foo, bar, baz } from './utils';`

### Configuration Objects

```
<<<<<<< HEAD
const config = {
  timeout: 5000,
  retries: 3,
};
=======
const config = {
  timeout: 3000,
  debug: true,
};
>>>>>>> origin/main
```

**Resolution:** Merge properties logically:
```javascript
const config = {
  timeout: 5000,  // Keep your value or decide
  retries: 3,
  debug: true,    // Keep their addition
};
```

## Post-Resolution Checklist

- [ ] All conflict markers removed (`<<<<<<<`, `=======`, `>>>>>>>`)
- [ ] Code compiles/builds successfully
- [ ] Tests pass
- [ ] Changes make logical sense together
- [ ] No duplicate imports, functions, or definitions

## Commands

```bash
# View conflicted files
git diff --name-only --diff-filter=U

# Mark file as resolved after editing
git add <resolved-file>

# Continue merge after all conflicts resolved
git merge --continue

# Continue rebase after all conflicts resolved
git rebase --continue

# Abort if things go wrong
git merge --abort
git rebase --abort
```

## Tools

### Visual Diff Tools

```bash
# Configure merge tool
git config --global merge.tool vimdiff

# Use merge tool
git mergetool
```

### VS Code

1. Open conflicted file
2. Click "Accept Current", "Accept Incoming", "Accept Both", or edit manually
3. Save file
4. Stage: `git add <file>`

## Prevention Tips

1. **Sync frequently** - Merge/rebase from main often
2. **Small PRs** - Fewer changes = fewer conflicts
3. **Communicate** - Let team know about large refactors
4. **Lock files** - For truly unmergeable files (binary, generated)
