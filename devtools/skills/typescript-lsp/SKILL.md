---
name: typescript-lsp
description: Use when navigating code semantically, finding references, or tracing call hierarchies. Covers LSP tools for type-aware code analysis.
license: MIT
triggers:
  # Intent triggers
  - "go to definition"
  - "find references"
  - "find all usages"
  - "who calls this"
  - "where is this defined"
  - "trace call hierarchy"

  # Artifact triggers
  - "lsp"
  - "lspGotoDefinition"
  - "lspFindReferences"
  - "lspCallHierarchy"
  - "lineHint"
  - "language server"
---

<objective>
Use LSP (Language Server Protocol) tools for semantic code navigation and analysis. LSP provides type-aware operations that text search cannot: finding true definitions, all references (including dynamic), and call relationships. Always search first to get lineHint before calling LSP tools.
</objective>

<quick_start>
**The Funnel Method: Search -> LSP -> Read**

```
1. SEARCH: Grep/localSearchCode for symbol → get file + lineHint
2. LSP: Call lspGotoDefinition/lspFindReferences with lineHint
3. READ: Only read implementation AFTER locating via LSP
```

**Critical Rule:** Never call LSP tools without lineHint from a prior search. LSP tools require exact line numbers (1-indexed).
</quick_start>

<constraints>
**Banned:**
- Calling LSP tools without lineHint from prior search
- Using 0-indexed line numbers (LSP uses 1-indexed)
- Guessing line numbers instead of searching first
- Using lspCallHierarchy for non-function symbols (types, variables)

**Required:**

- Always search first to obtain lineHint
- Verify lineHint is 1-indexed (first line = 1)
- Fall back to Grep/ast-grep if LSP unavailable
  </constraints>

<anti_patterns>

- **Blind LSP Calls:** Calling LSP without searching first; fails without lineHint
- **Wrong Tool Selection:** Using lspCallHierarchy for types (use lspFindReferences)
- **Index Confusion:** Mixing 0-indexed and 1-indexed line numbers
- **LSP Dependency:** Not falling back when LSP server unavailable
- **Incomplete Tracing:** Stopping at first reference instead of tracing full call chain
  </anti_patterns>

<available_tools>
**Core LSP Tools:**

| Tool                                    | Purpose                         | Use When                             |
| --------------------------------------- | ------------------------------- | ------------------------------------ |
| `lspGotoDefinition(lineHint)`           | Jump to where symbol is defined | "Where is X defined?"                |
| `lspFindReferences(lineHint)`           | Find all usages of symbol       | "Who uses X?" (types, vars, all)     |
| `lspCallHierarchy(lineHint, direction)` | Trace call relationships        | "Who calls X?" / "What does X call?" |

**Tool Selection Guide:**

| Question                   | Tool                         | Notes                        |
| -------------------------- | ---------------------------- | ---------------------------- |
| "What is X?"               | `lspGotoDefinition`          | Locates definition           |
| "Who uses X?" (all usages) | `lspFindReferences`          | Types, variables, any symbol |
| "Who calls function X?"    | `lspCallHierarchy(incoming)` | Functions only               |
| "What does X call?"        | `lspCallHierarchy(outgoing)` | Functions only               |

**Important:** `lspCallHierarchy` only works for functions/methods. For types, interfaces, and variables, use `lspFindReferences`.
</available_tools>

<lineHint_requirement>
**CRITICAL: lineHint is MANDATORY**

LSP tools require a line number hint from a prior search. Never guess line numbers.

**Correct Workflow:**

```bash
# Step 1: Search to find the symbol and get line number
Grep({ pattern: "function processUser", output_mode: "content" })
# Result: src/users.ts:47: export function processUser(...)

# Step 2: Call LSP with lineHint from search result
lspGotoDefinition({ file: "src/users.ts", lineHint: 47 })
```

**Wrong (will fail):**

```bash
# Never call LSP without searching first
lspGotoDefinition({ file: "src/users.ts", lineHint: 1 })  # Guessing = WRONG
```

**Validation Checkpoint (before ANY LSP call):**

- Did I search for this symbol first?
- Do I have lineHint from search results?
- Is lineHint 1-indexed (line 1 = first line)?
  </lineHint_requirement>

<workflow_patterns>
**Pattern 1: Find Definition**

```
User: "Where is processUser defined?"
1. Grep({ pattern: "processUser", output_mode: "content" }) → line 47
2. lspGotoDefinition({ file: "src/users.ts", lineHint: 47 })
3. Read result to see implementation
```

**Pattern 2: Find All Usages**

```
User: "Find all usages of UserConfig type"
1. Grep({ pattern: "UserConfig", output_mode: "content" }) → line 12
2. lspFindReferences({ file: "src/types.ts", lineHint: 12 })
3. Review all locations where UserConfig is used
```

**Pattern 3: Trace Call Chain**

```
User: "What calls handleSubmit?"
1. Grep({ pattern: "handleSubmit", output_mode: "content" }) → line 85
2. lspCallHierarchy({ file: "src/form.tsx", lineHint: 85, direction: "incoming" })
3. For each caller, optionally trace further up the chain
```

**Pattern 4: Impact Analysis**

```
User: "What would break if I change calculateTotal?"
1. Grep({ pattern: "calculateTotal", output_mode: "content" }) → line 156
2. lspFindReferences({ file: "src/pricing.ts", lineHint: 156 })
3. Review all dependents to understand impact
```

</workflow_patterns>

<when_to_use>
**LSP vs Other Tools:**

| Scenario                   | Best Tool               | Why                       |
| -------------------------- | ----------------------- | ------------------------- |
| Find where X is defined    | LSP `lspGotoDefinition` | Semantic accuracy         |
| Find all usages of X       | LSP `lspFindReferences` | Catches dynamic refs      |
| Find call relationships    | LSP `lspCallHierarchy`  | Type-aware                |
| Find text pattern in files | Grep                    | Faster for text search    |
| Mass rename/replace        | ast-grep                | AST-aware transformations |
| Find files by name         | Glob                    | Pattern matching          |

**Use LSP When:**

- You need semantic understanding (not just text matching)
- Dynamic imports or computed references exist
- Type information matters
- Tracing call chains across files

**Use Grep/ast-grep When:**

- Initial discovery (to get lineHint for LSP)
- Text patterns that aren't symbols
- Mass transformations needed
- LSP tools not available
  </when_to_use>

<installation_notes>
**Current Status of TypeScript LSP Plugin:**

The official `typescript-lsp@claude-plugins-official` plugin has known issues:

- Incomplete config files (missing `plugin.json`, `.lsp.json`)
- Server registration may fail

**Manual Setup (if needed):**

```bash
npm install -g @vtsls/language-server typescript
```

**Community Alternatives:**

- `ktnyt/cclsp` - Community LSP integration
- `Piebald-AI/claude-code-lsps` - Multi-language LSP support

**Graceful Degradation:**
If LSP tools are unavailable, fall back to:

1. Grep for text-based search
2. ast-grep for AST-aware analysis
3. Read tool for manual inspection

Load troubleshooting skill if LSP fails: `Skill({ skill: "devtools:troubleshooting" })`
</installation_notes>

<related_skills>
**Complementary Skills:**

- `Skill({ skill: "devtools:ast-grep" })` - Mass refactoring with AST patterns
- `Skill({ skill: "devtools:troubleshooting" })` - Debugging workflows
- `Skill({ skill: "devtools:code-health" })` - Dead code detection
- `Skill({ skill: "devtools:tdd-typescript" })` - Test-implementation linking
  </related_skills>

<success_criteria>

- [ ] Always search first to obtain lineHint before LSP calls
- [ ] Use correct tool: lspFindReferences for types/vars, lspCallHierarchy for functions
- [ ] lineHint is 1-indexed (first line = 1, not 0)
- [ ] Fall back to Grep/ast-grep if LSP unavailable
- [ ] Trace complete call chains when analyzing impact
      </success_criteria>

<evolution>
**Extension Points:**
- Add language-specific LSP patterns via references (Go, Rust, Python)
- Extend with refactoring workflows using LSP rename capabilities
- Integrate with code review workflows for impact analysis

**Timelessness:** Language Server Protocol is a standard interface adopted across all major editors; semantic code navigation patterns apply regardless of specific LSP implementation.
</evolution>
