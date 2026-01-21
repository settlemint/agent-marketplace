# Agent Marketplace

Portable agent setup for Claude Code and Codex that works identically in local CLI and cloud environments.

**The problem:** Cloud/web versions of these agents can't install skills or plugins on-the-fly. You get a vanilla agent with no workflow enforcement, no specialized skills, and no tooling.

**The solution:** Bundle everything in the repository—skills, workflows, commands, and dependency setup scripts—so the agent behaves the same whether you're running locally or in the cloud.

## Quick Install (Local CLI)

```bash
curl -sL https://raw.githubusercontent.com/settlemint/agent-marketplace/main/setup.sh | bash
```

This installs into the **current directory** and will download the full `.agents` folder if it’s missing.

Setup flags:

- `--update` - re-download `.agents` folder even if it exists (preserves your `setup.json`)
- `--lite` - skip post-install system/package setup (fast, minimal)
- `--skip-postinstall` - same as `--lite`, but explicit
- `--skip-codex-mcp` - skip updating Codex MCP config in `~/.codex/config.toml`
- `--docs-only` - only refresh workflow/routing tables in `CLAUDE.md` and `AGENTS.md`
- `--skip-skills` - skip installing skills (useful for docs-only runs)

## What's Included

**Workflow enforcement** via `CLAUDE.md` / `AGENTS.md`:
- Task classification (Trivial → Complex) with mandatory phases
- Gate checks requiring proof before proceeding
- Skill routing table mapping triggers to capabilities

**37 skills** across domains:
- Development: TDD, systematic debugging, verification
- Security: Semgrep, CodeQL, differential review, SARIF parsing
- Quality: Code review, code simplifier, knip (dead code)
- Docs: xlsx, pptx, doc-coauthoring
- Frameworks: React/Next.js, TanStack Query, Better Auth

**10 commands**: `/commit`, `/review`, `/pr`, `/branch`, `/sync`, etc.

**Auto-installed tooling**: jq, ripgrep, graphviz, semgrep, CodeQL, playwright, and more

## Recommended Workflow

The workflow enforces quality through gates while remaining practical. Use [Hex](https://hex.kitlangton.com/) for voice dictation to describe tasks quickly.

### Local Development

#### Claude Code

```
1. Enter plan mode     → Shift+Tab or /plan or Conductor button
2. Describe outcome    → Voice dictate with Hex or type the goal
3. Iterate on plan     → Refine until the approach is solid
4. Execute             → Exit plan mode, let Claude implement
5. Manual test         → Verify the changes work as expected
6. Open PR             → /pr to create pull request
7. Handle feedback     → /fixup until CI green + reviews resolved
```

**Key commands:**
- `Shift+Tab` or `/plan` - Enter plan mode
- `/pr` - Create pull request with smart template
- `/fixup` - Fix PR review comments and CI failures
- `/review` - Run comprehensive code review

#### Codex

Codex has no formal plan mode, so request a plan explicitly:

```
1. Request plan        → "Create a plan for: [describe outcome]"
2. Iterate on plan     → Refine until the approach is solid
3. Execute             → "Execute the plan"
4. Manual test         → Verify the changes work as expected
5. Open PR             → /pr or ask Codex to create PR
6. Handle feedback     → /fixup or ask to fix review comments
```

### Remote Development

When running remotely, the workflow is less interactive—the agent proceeds autonomously and only asks questions when genuinely ambiguous (ambiguity score > 7/10).

#### Claude Code Remote

**Starting a remote session:**

| Method | How |
|--------|-----|
| **From terminal** | `& <task description>` or `claude --remote "<task>"` |
| **From web** | Go to [claude.ai/code](https://claude.ai/code) and start a session |
| **From iOS** | Open Claude app → Claude Code → New task |
| **From Slack** | Mention `@Claude` with a coding task in any channel |

**The `&` prefix** sends tasks to run asynchronously on the web:
```bash
# Plan locally first
claude --permission-mode plan

# Then send to web for autonomous execution
& Execute the migration plan we discussed

# Or run multiple tasks in parallel
& Fix the flaky test in auth.spec.ts
& Update the API documentation
```

**Monitoring and retrieving work:**
- `/tasks` - View all background sessions
- `/teleport` or `/tp` - Pull a web session into your terminal
- `claude --teleport <session-id>` - Resume specific session locally
- Press `t` in `/tasks` view to teleport into a session

**Requirements for teleport:**
- Clean git state (no uncommitted changes)
- Same repository (not a fork)
- Branch pushed to remote
- Same Claude.ai account

**Slack workflow:**
1. Mention `@Claude` with task in a channel or thread
2. Claude creates a web session and posts progress updates
3. When complete, use "View Session" or "Create PR" buttons
4. Continue conversation in thread for follow-ups

#### Codex Remote

**Starting a remote session:**

| Method | How |
|--------|-----|
| **From web** | Go to [codex.openai.com](https://codex.openai.com) and start a task |
| **From iOS** | Open ChatGPT app → Codex → New task |
| **From Linear** | Assign issue to `@Codex` or mention `@Codex` in comments |
| **From CLI** | `codex exec --env <env-id> "<task>"` |

**Linear integration:**

1. Connect Linear MCP server:
   ```bash
   codex mcp add linear --url https://mcp.linear.app/mcp
   ```

2. Enable in `~/.codex/config.toml`:
   ```toml
   [features]
   rmcp_client = true
   ```

3. Use in Linear:
   - **Assign to Codex**: Assign any issue to `@Codex` like a team member
   - **Mention in comments**: Write `@Codex <task>` in issue comments
   - Codex posts progress updates back to Linear
   - When complete, review and open PR from the linked session

**Mobile workflow (ChatGPT iOS):**
1. Open ChatGPT app → Codex section
2. Start new cloud task or review past tasks
3. Open pull requests directly from completed tasks

### Environment Detection

Both tools detect remote execution automatically:

| Tool | Environment Variable | Remote Value |
|------|---------------------|--------------|
| Claude Code | `CLAUDE_CODE_REMOTE` | `true` |
| Codex | `CODEX_INTERNAL_ORIGINATOR_OVERRIDE` | `codex_web_agent` |

In remote mode:
- Questions are optional (only asked if genuinely ambiguous)
- All quality gates remain enforced
- The agent proceeds autonomously with documented assumptions

## Manual Setup

```bash
curl -sL https://github.com/settlemint/agent-marketplace/archive/refs/heads/main.tar.gz | tar -xz --strip-components=1 "agent-marketplace-main/.agents"
bash .agents/setup.sh
```

## Cloud Setup

Both Claude Code and Codex require specific configuration for cloud/web environments.

### Claude Code (claude.ai/code)

1. **Network Permissions**: Set to **Full** in project settings
   - Required for installing dependencies and accessing package registries

2. **Dependency Installation**: Automatic via session-start hook
   - The hook at `.claude/settings.json` triggers `.claude/scripts/web/session-start/setup.sh`
   - Installs system tools (jq, ripgrep, graphviz, etc.)
   - Installs Python packages (markitdown, semgrep)
   - Installs Node packages (agent-browser, playwright, knip)
   - Sets up CodeQL for security analysis

### Codex (codex.openai.com)

1. **Network Permissions**: Set to **Full** in project settings
   - Required for installing dependencies and accessing package registries

2. **Setup Script**: Configure in project settings
   - Add to **Setup script** field:
     ```
     bash ./.claude/scripts/web/session-start/setup.sh
     ```

3. **Maintenance Script**: Configure in project settings
   - Add to **Maintenance script** field:
     ```
     bash ./.claude/scripts/web/session-start/setup.sh
     ```

### What the Setup Script Installs

The web setup script (`.claude/scripts/web/session-start/setup.sh`) installs:

| Category | Packages |
| --- | --- |
| System tools | jq, ripgrep, graphviz, poppler-utils |
| Python | markitdown[pptx], defusedxml, semgrep |
| Node.js | agent-browser, pptxgenjs, playwright, knip |
| Security | CodeQL CLI |

The script only runs in remote environments (checks for `CLAUDE_CODE_REMOTE` or detects cloud environment).

## Refresh Workflow + Routing Tables

When you update skills or the workflow config, re-sync the docs:

```bash
./scripts/refresh-docs
```

## Structure

```
├── CLAUDE.md           # Claude Code instructions (generated from templates/claude/)
├── AGENTS.md           # Codex instructions (generated from templates/codex/)
├── .claude/
│   ├── settings.json   # Hooks configuration (session-start)
│   ├── commands/       # Slash commands (/commit, /review, etc.)
│   └── scripts/        # Session scripts for web environments
└── .agents/
    ├── setup.json      # Skills and MCP configuration
    ├── setup.sh        # Installation script
    ├── commands/       # Command templates (copied to .claude/commands/)
    ├── templates/
    │   ├── claude/     # Claude Code templates (CLAUDE.md + sections)
    │   └── codex/      # Codex templates (AGENTS.md + sections)
    └── skills/         # Installed skills (gitignored)
```
