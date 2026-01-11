<objective>

GitButler's MCP server and AI integration. Enable AI tools (Claude Code, Cursor, VS Code) to manage commits automatically.

</objective>

<mcp_server>

Start the MCP server:

```bash
but mcp
```

The MCP server provides the `gitbutler_update_branches` tool for AI agents to auto-commit changes to isolated branches.

**Configuration in Claude Code:**

Add to `.mcp.json`:

```json
{
  "mcpServers": {
    "gitbutler": {
      "type": "stdio",
      "command": "but",
      "args": ["mcp"]
    }
  }
}
```

</mcp_server>

<hook_integration>

Register GitButler hooks in Claude Code settings (`.claude/settings.json`):

```json
{
  "hooks": {
    "PreToolUse": ["but claude pre-tool"],
    "PostToolUse": ["but claude post-tool"],
    "Stop": ["but claude stop"]
  }
}
```

**Hook behavior:**

- `PreToolUse`: Prepares context before AI tool execution
- `PostToolUse`: Updates GitButler state after tool execution
- `Stop`: Finalizes session, auto-commits remaining changes

</hook_integration>

<agents_tab>

GitButler's desktop client includes an Agents tab for managing AI sessions:

**Per-branch sessions:**

- Isolated contexts per virtual branch
- Token/cost monitoring
- Model selection (Claude Sonnet, etc.)
- Thinking mode variations

**Features:**

- Automatic TODO breakout from agent plans
- Prompt templates
- Auto-commits with AI-generated messages

</agents_tab>

<auto_commit_workflow>

With MCP integration, AI agents can:

1. Make changes to files
2. GitButler auto-detects changes
3. Changes assigned to appropriate virtual branch (based on rules)
4. Agent calls `gitbutler_update_branches`
5. Changes committed with AI-generated message
6. Branch ready for push

**Example session:**

```
User: "Add user authentication"
AI: [Creates auth files, modifies routes]
GitButler: [Assigns to 'add-auth' branch, commits: "feat: add user authentication system"]
User: but push add-auth
```

</auto_commit_workflow>

<mcp_tool_usage>

**MCP Tool: `mcp__gitbutler__gitbutler_update_branches`**

Call this tool after making code changes to auto-commit them:

```javascript
mcp__gitbutler__gitbutler_update_branches({
  fullPrompt: "Add user authentication with login form",
  changesSummary:
    "- Created auth controller\n- Added login form component\n- Updated routes",
  currentWorkingDirectory: "/Users/user/project",
});
```

**Parameters:**

| Parameter                 | Required | Description                                          |
| ------------------------- | -------- | ---------------------------------------------------- |
| `fullPrompt`              | Yes      | The original user request that triggered the changes |
| `changesSummary`          | Yes      | Bullet list of what changed and why                  |
| `currentWorkingDirectory` | Yes      | Full path to the git project root                    |

**When to use:**

- After completing a set of related code changes
- When you want GitButler to auto-assign and commit changes
- At natural stopping points in the workflow

**Note:** Other operations (branch creation, pushing, status) still use CLI commands. The MCP tool is specifically for committing changes with context.

</mcp_tool_usage>

<rules_for_ai>

GitButler can auto-assign AI changes using rules:

**Session ID Rule:**
Claude Code session ID can be captured to assign all changes from that session to a specific branch.

**Path-based rules:**

```
Path: src/auth/*
Branch: add-auth
```

**Content-based rules:**

```
Content: /authenticate|login|session/
Branch: add-auth
```

Rules are evaluated in order. Multiple matching rules combine with AND logic.

</rules_for_ai>

<commit_message_generation>

GitButler generates commit messages using AI:

**Features:**

- Semantic prefix selection (feat, fix, refactor, etc.)
- Character limit enforcement (50 title, 72 body)
- Context-aware from diff content
- Streaming generation display
- Customizable prompts per project

**CLI usage:**

```bash
# Let GitButler generate message
but commit

# Or provide your own
but commit -m "feat: add login form"
```

</commit_message_generation>

<internal_mode>

For deeper integration:

```bash
but mcp --internal
```

Internal mode provides additional capabilities for tight editor integration.

</internal_mode>

<success_criteria>

- MCP server configured and running
- Hooks registered in Claude Code settings
- AI changes auto-assigned to branches
- Commits generated with meaningful messages
- Branches ready for push after AI session

</success_criteria>
