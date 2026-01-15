---
name: ast-grep
description: Mass rename/replace across codebase. Use when user asks to rename functions, replace patterns, or refactor code across files. Better than grep for code changes.
license: MIT
triggers:
  # Explicit requests
  - "rename all"
  - "replace all.*with"
  - "refactor.*across"
  - "change all.*to"
  - "find and replace"
  - "ast-grep"
  - "sg "
  # Import modifications
  - "fix.*import"
  - "remove.*import"
  - "unused import"
  - "clean.*import"
  - "update.*import.*across"
  # Lint/code fixes at scale
  - "fix.*across.*files"
  - "fix all.*lint"
  - "remove.*from.*files"
  # Pattern-based changes
  - "replace.*pattern"
  - "change.*syntax"
  - "migrate.*to"
  - "convert all"
  # Exploration
  - "find all.*usage"
  - "where is.*used"
  - "show me all"
  - "audit.*code"
---

<objective>
Search, explore, and refactor code using AST patterns. Unlike grep, ast-grep understands syntax - finds code structures, ignores strings/comments.
</objective>

<quick_start>

```bash
# SEARCH - Find patterns
sg run -p "console.log($$$)" -l typescript           # Find all console.log calls
sg run -p "async function $FUNC($$$)" -l typescript  # Find async functions

# EXPLORE - Understand code (read-only)
sg run -p "use$HOOK($$$)" -l tsx --debug-query       # See AST structure
sg run -p "import { $$$IMPORTS } from '$MOD'" -l ts --json  # JSON output

# REPLACE - Refactor code
sg run -p "console.log($MSG)" -r "logger.info($MSG)" -l ts --debug-query  # Preview
sg run -p "console.log($MSG)" -r "logger.info($MSG)" -l ts  # Apply

# LINT - Use YAML rules
sg scan -c sgconfig.yml                              # Run all rules
sg scan -r rules/no-console.yml                      # Single rule
```

</quick_start>

<pattern_syntax>

| Syntax    | Meaning                | Example                      |
| --------- | ---------------------- | ---------------------------- |
| `$NAME`   | Single AST node        | `$FUNC($ARG)`                |
| `$$$`     | Zero or more nodes     | `function($$$ARGS)`          |
| `$$$NAME` | Named multiple nodes   | `import { $$$IMPORTS } from` |
| `$_`      | Anonymous (no capture) | `$_.map($$$)`                |
| `$$VAR`   | Unnamed node capture   | Tree-sitter specific         |

**Rules:** `$` + UPPERCASE + optional digits. Valid: `$A`, `$FUNC1`, `$_`. Invalid: `$func`, `$123`.

</pattern_syntax>

<exploration>

**Explore codebases with ast-grep (read-only operations):**

```bash
# Understand AST structure
sg run -p "your code pattern" --debug-query -l typescript

# Find all usages across codebase
sg run -p "useQuery($$$)" -l tsx --heading           # Group by file
sg run -p "fetch($URL)" -l typescript -A 3 -B 3      # With context

# JSON output for analysis
sg run -p "$_.$METHOD($$$)" -l typescript --json | jq '.[] | .file'

# Audit patterns
sg run -p "eval($$$)" -l typescript                  # Security audit
sg run -p "any" -l typescript                        # Find type annotations
```

**Interactive playground:** https://ast-grep.github.io/playground.html

</exploration>

<cli_commands>

| Command   | Purpose                | Key Flags                                               |
| --------- | ---------------------- | ------------------------------------------------------- |
| `sg run`  | Search/replace         | `-p` pattern, `-r` rewrite, `-l` lang, `-i` interactive |
| `sg scan` | Lint with rules        | `-c` config, `-r` rule, `--json`, `--format github`     |
| `sg test` | Test YAML rules        | `-c` config, `-U` update snapshots                      |
| `sg new`  | Scaffold project/rules | `project`, `rule`, `test`                               |

**Common flags:** `--debug-query` (preview), `--json` (output), `-A/-B/-C` (context), `--heading` (group)

</cli_commands>

<routing>

Load reference files based on context:

| Working On         | Load Reference           | Command                          |
| ------------------ | ------------------------ | -------------------------------- |
| Exploring codebase | `exploration-guide.md`   | Understanding patterns, auditing |
| TypeScript/TSX     | `typescript-patterns.md` | Functions, imports, React, types |
| Bash/shell         | `bash-patterns.md`       | Variables, conditionals, loops   |
| Terraform (.tf)    | `terraform-patterns.md`  | Resources, variables, modules    |
| Helm/YAML          | `yaml-patterns.md`       | Values, K8s resources            |
| Writing YAML rules | `rule-schema.md`         | Full rule syntax                 |
| Transformations    | `transformations.md`     | substring, replace, convert      |

**Note:** Markdown is NOT supported (use ripgrep instead).

</routing>

<common_patterns>

**TypeScript (most common):**

```bash
# Functions
sg -p "async function $FUNC($$$)" -l typescript
sg -p "const $NAME = ($$$) => $BODY" -l typescript
sg -p "const $NAME = async ($$$) => $BODY" -l typescript

# Imports
sg -p 'import { $$$IMPORTS } from "$MODULE"' -l typescript
sg -p 'import $DEFAULT from "$MODULE"' -l typescript

# React
sg -p "use$HOOK($$$)" -l tsx
sg -p "<$COMPONENT $$$PROPS />" -l tsx
sg -p "useState($INITIAL)" -l tsx

# Types
sg -p "interface $NAME { $$$BODY }" -l typescript
sg -p "type $NAME = $TYPE" -l typescript

# Common refactors
sg -p "console.log($$$)" -r "" -l typescript         # Remove console.log
sg -p '$A && $A()' -r '$A?.()' -l typescript         # Optional chaining
```

</common_patterns>

<vs_grep>

| Use ast-grep (sg)           | Use ripgrep (rg)       |
| --------------------------- | ---------------------- |
| Syntax-aware matching       | Raw text/regex search  |
| Ignores strings/comments    | All text matches       |
| Precise refactoring         | Fast file search       |
| Pattern-based replacement   | Simple find/replace    |
| TypeScript, HCL, Bash, YAML | Markdown, config files |

**Rule of thumb:** Use `sg` for code structure, `rg` for text content.

</vs_grep>

<lsp_complement>
**Use LSP to verify refactoring scope before applying ast-grep changes:**

ast-grep excels at pattern-based transformations, but LSP provides semantic verification:

- `lspFindReferences(lineHint)` - Understand full impact before pattern replacement
- `lspCallHierarchy(lineHint)` - Trace call chains that will be affected

**Workflow:**

1. ast-grep scan to find patterns → identify files/lines
2. `lspFindReferences` → verify scope is as expected
3. ast-grep apply → execute transformation

**CRITICAL:** Always search first to get `lineHint` (1-indexed line number). Never call LSP tools without a lineHint from search results.

**When to use:**

- Mass rename → verify all usages found before replacing
- API migration → trace call chains to understand impact
- Function signature change → find all callers first

Load LSP skill for detailed patterns: `Skill({ skill: "devtools:typescript-lsp" })`
</lsp_complement>

<languages>

**Supported (31 languages):** Bash, C, C++, C#, CSS, Elixir, Go, Haskell, HCL, HTML, Java, JavaScript, JSON, Kotlin, Lua, Nix, PHP, Python, Ruby, Rust, Scala, Solidity, Swift, TypeScript, TSX, YAML

**Language flags:** `-l typescript`, `-l tsx`, `-l hcl`, `-l bash`, `-l yaml`

**Not supported:** Markdown (use ripgrep)

</languages>

<constraints>
**Banned:**
- Using grep for code structure changes (use ast-grep)
- Applying changes without `--debug-query` preview first
- Wrong language flag (tsx vs typescript matters)
- Patterns that match strings/comments when code is intended

**Required:**

- Always preview with `--debug-query` before refactors
- Use correct language flag for file type
- Test patterns on single file before codebase-wide changes
- Use `--json` output for programmatic workflows
  </constraints>

<anti_patterns>

- Using `$_` when you need to capture the value for replacement
- Forgetting `$$$` for variadic matches (function arguments)
- Writing overly specific patterns that miss valid variations
- Applying changes to entire codebase without file filtering
- Ignoring the difference between `-l typescript` and `-l tsx`
  </anti_patterns>

<research>
**Find ast-grep patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find ast-grep rule patterns",
      researchGoal: "Search for YAML rules and pattern syntax",
      reasoning: "Need real-world examples of ast-grep usage",
      keywordsToSearch: ["sgconfig", "ast-grep", "rule"],
      extension: "yml",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Rules: `keywordsToSearch: ["rule:", "pattern:", "fix:"]`
- TypeScript: `keywordsToSearch: ["sg run", "-l typescript", "console.log"]`
- React: `keywordsToSearch: ["use$HOOK", "-l tsx", "useState"]`
  </research>

<related_skills>

**Code search:** Load via `Skill({ skill: "devtools:troubleshooting" })` when:

- Debugging issues found via pattern search
- Investigating code patterns

**React patterns:** Load via `Skill({ skill: "devtools:react" })` when:

- Refactoring React components
- Finding React anti-patterns

**Testing:** Load via `Skill({ skill: "devtools:vitest" })` when:

- Verifying refactors with tests
- Testing after mass renames
  </related_skills>

<success_criteria>

- [ ] Pattern matches expected structures (test with `--debug-query`)
- [ ] Correct language flag (`tsx` for JSX, `typescript` for pure TS)
- [ ] Preview changes before applying refactors
- [ ] Use `--json` for programmatic analysis
      </success_criteria>

<evolution>
**Extension Points:**
- Create project-specific YAML rules in `sgconfig.yml`
- Add custom linting rules for team conventions
- Integrate with CI for automated code quality checks

**Timelessness:** AST-based search and replace is fundamentally more reliable than regex for code transformations.
</evolution>
