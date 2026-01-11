---
name: native-tools
description: Internal reference for Claude Code tools. Triggered when Claude uses wrong tool patterns.
triggers:
  - "bash.*find.*-name"
  - "bash.*grep.*-r"
  - "bash.*cat "
  - "bash.*sed.*-i"
context: fork
---

<objective>

Native tools are optimized for agent use. ALWAYS prefer over equivalent bash commands.

</objective>

<critical_rule>

| Bad (Bash)            | Good (Native)                                  |
| --------------------- | ---------------------------------------------- |
| `find . -name "*.ts"` | `Glob({pattern: "**/*.ts"})`                   |
| `grep -r "pattern" .` | `Grep({pattern: "pattern"})`                   |
| `cat file.txt`        | `Read({file_path: "file.txt"})`                |
| `sed -i 's/old/new/'` | `Edit({old_string: "old", new_string: "new"})` |
| `echo "text" > file`  | `Write({file_path: "file", content: "text"})`  |

</critical_rule>

<routing>

| Category            | Reference                        | Tools                      |
| ------------------- | -------------------------------- | -------------------------- |
| File Search         | `references/file-search.md`      | Glob, Grep                 |
| File Operations     | `references/file-operations.md`  | Read, Edit, Write          |
| User Interaction    | `references/user-interaction.md` | AskUserQuestion, TodoWrite |
| Agent Orchestration | `references/orchestration.md`    | Task, TaskOutput           |
| External Resources  | `references/external.md`         | WebFetch, WebSearch, Bash  |

Related: `ast-grep` skill for structural code patterns.

</routing>

<bash_subagent>

## Bash Subagent for Large Output Commands

For commands with large output (tests, builds, CI), use the **Bash subagent** instead of direct Bash:

```javascript
// DON'T: Direct Bash pollutes main context
Bash({ command: "bun run test" });

// DO: Bash subagent runs in separate context
Task({
  subagent_type: "Bash",
  prompt: "Run bun run test and report pass/fail with error details",
  description: "test-runner",
});
```

**When to use Bash subagent:**

- Test suites (`bun run test`, `vitest`, `jest`)
- CI checks (`bun run ci`, `eslint`, `tsc`)
- Builds (`bun run build`, `turbo build`)
- Package installs (`bun install`, `npm i`)
- Any command with verbose output

**When to use direct Bash:**

- Quick commands: `git status`, `ls`, `pwd`
- Single-line output commands
- Commands where you need immediate inline result

</bash_subagent>

<quick_reference>

| Tool            | Permission | Purpose                |
| --------------- | ---------- | ---------------------- |
| Glob            | No         | Find files by pattern  |
| Grep            | No         | Search file contents   |
| Read            | No         | Read file contents     |
| Edit            | Yes        | Modify files           |
| Write           | Yes        | Create/overwrite files |
| AskUserQuestion | No         | Interactive questions  |
| TodoWrite       | No         | Task tracking          |
| Task            | No         | Spawn sub-agents       |
| TaskOutput      | No         | Get agent results      |
| Bash            | Yes        | Shell commands         |

</quick_reference>

<common_patterns>

```javascript
// Search then read
Glob({ pattern: "src/**/*.ts" });
Grep({ pattern: "function handleAuth", type: "ts" });
Read({ file_path: "src/auth/handler.ts" });

// Edit workflow (ALWAYS read first)
Read({ file_path: "path/to/file.ts" });
Edit({
  file_path: "path/to/file.ts",
  old_string: "const x = 1",
  new_string: "const x = 2",
});

// Agent orchestration
Task({
  subagent_type: "Explore",
  prompt: "...",
  description: "task",
  run_in_background: true,
});
TaskOutput({ task_id: "abc123", block: true });
```

</common_patterns>

<success_criteria>

- File search uses Glob (not `find`/`ls`)
- Content search uses Grep (not `grep`/`rg`)
- File reading uses Read (not `cat`/`head`/`tail`)
- File editing uses Edit (not `sed`/`awk`)
- Read called before Edit

</success_criteria>
