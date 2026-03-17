# Lexic Plugin for Claude Code

This plugin connects [Claude Code](https://code.claude.com) to [Lexic](https://lexic.io) — an AI-powered knowledge management system that gives your coding sessions persistent memory, architectural decision tracking, and autonomous task orchestration.

## What You Get

### Slash Commands

| Command | Description |
|---------|------------|
| `/Lexic:run` | Execute an autonomous coding run with task orchestration, context assembly, and learning capture |
| `/Lexic:status` | Check the status of your workflow runs and tasks |
| `/Lexic:context` | Load everything Lexic knows about a feature before you start working |
| `/Lexic:decide` | Record an architectural or technical decision with rationale and alternatives |
| `/Lexic:save` | Quickly capture a finding or insight to the knowledge base |
| `/Lexic:search` | Search across your notes, decisions, and development learnings |
| `/Lexic:learn` | Record a learning that feeds into future autonomous run context |
| `/Lexic:template` | Browse, create, and launch runs from reusable workflow templates |
| `/Lexic:setup` | Configure CLAUDE.md with Lexic integration — safe to re-run, idempotent |
| `/Lexic:start-session` | Load recent decisions, active workflows, and learnings at the start of a session |
| `/Lexic:session-recap` | Summarize the session and store decisions + learnings to Lexic |
| `/Lexic:what-do-we-know` | Deep retrieval of everything Lexic knows about a topic including gotchas |
| `/Lexic:optimize-claude-md` | Analyze CLAUDE.md and suggest what to keep, move to Lexic, or remove |

### Integrated MCP Server

The plugin automatically connects to Lexic's hosted MCP server, giving Claude access to:

- **Knowledge management** — Store and retrieve project-specific notes, findings, and research
- **Decision tracking** — Record architectural choices with rationale, alternatives, and revisit conditions
- **Autonomous workflows** — Create, execute, and monitor multi-task coding runs with context assembly
- **Development learnings** — Insights captured from autonomous runs, surfaced when relevant to future work
- **Workflow templates** — Reusable blueprints created from successful runs
- **Code graph** — Query pre-indexed code structure: find functions/classes by name, trace call chains, explore module hierarchies

### Proactive Skills

The plugin includes two skills that teach Claude to use Lexic **proactively** without explicit commands:

**Knowledge Management** — Automatically loads prior context when you start working on a feature, captures architectural decisions as they happen, saves non-obvious findings during development, and searches the knowledge base when you reference prior discussions.

**Workflow Hygiene** — Suggests creating templates after successful runs, checks for stale or paused runs when you resume a session, searches for matching templates before starting new workflows from scratch, and guides you toward the right capture tool (`/Lexic:learn` for run-level insights vs `/Lexic:save` for reference material).

## Installation

### Prerequisites

- [Claude Code](https://code.claude.com) installed
- A Lexic account ([sign up at lexic.io](https://lexic.io))

### Install the Plugin

1. Add the Lexic marketplace:

```
/plugin marketplace add lexic-io/Lexic.io-plugin
```

2. Install the plugin:

```
/plugin install lexic@lexic-marketplace
```

3. Restart Claude Code.

4. The first time you use a Lexic command, you'll be prompted to sign in via your browser (Google, GitHub, or Microsoft). That's it — no API keys, no environment variables.

5. Run setup in your project to configure `CLAUDE.md` with Lexic context instructions:

```
/Lexic:setup
```

This writes a Lexic integration block into your project's `CLAUDE.md` so Claude automatically loads prior context, captures decisions, and uses Lexic tools proactively. Safe to re-run — it only adds what's missing.

### Other Clients

If you're not using Claude Code's plugin system, you can connect to the Lexic MCP server directly.

**Claude Code (manual config):**

Add to `~/.claude/mcp.json` (global) or `.mcp.json` (project-level):

```json
{
  "mcpServers": {
    "lexic": {
      "type": "http",
      "url": "https://mcp.lexic.io/api/mcp"
    }
  }
}
```

**Cursor:**

Add to `.cursor/mcp.json` in your project:

```json
{
  "mcpServers": {
    "lexic": {
      "url": "https://mcp.lexic.io/api/mcp"
    }
  }
}
```

**Windsurf, VS Code, or other clients that don't yet support Streamable HTTP:**

Use the `mcp-remote` bridge (requires Node.js):

```json
{
  "mcpServers": {
    "lexic": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.lexic.io/api/mcp"]
    }
  }
}
```

## Quick Start

**First time on a new project — run setup:**
```
/Lexic:setup
```

**Load context before working:**
```
/Lexic:context authentication
```

**Start an autonomous run:**
```
/Lexic:run Add user profile settings page
```

**Record a decision:**
```
/Lexic:decide Use JWT refresh tokens instead of session cookies for auth
```

**Check on your runs:**
```
/Lexic:status
```

**Capture a learning for future runs:**
```
/Lexic:learn Supabase RLS policies silently return empty results if you join auth.users — use auth.jwt()->'app_metadata' instead
```

**Templatize a successful run:**
```
/Lexic:template create a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d
```

**Start a run from a template:**
```
/Lexic:template use add-crud-feature
```

## How Autonomous Runs Work

`/Lexic:run` orchestrates multi-task coding sessions:

1. **Setup** — Creates a run and breaks your goal into tasks with acceptance criteria
2. **Preflight** — Shows estimated credit cost and asks for confirmation
3. **Execution** — Works through tasks one at a time, with full context assembly at each step:
   - Prior task outputs (so it builds on completed work)
   - Architectural decisions (so it follows established patterns)
   - Knowledge base entries (so it knows your project's gotchas)
   - Failed attempt logs (so it doesn't repeat mistakes)
   - Learnings from prior runs (so institutional knowledge compounds)
4. **Completion** — Reports results, captures learnings, and unblocks dependent runs

Each task produces specific, actionable learnings that become context for future tasks and runs. When a run completes cleanly, Lexic suggests saving it as a template for reuse.

## Learn vs Save

Both commands capture information, but they serve different purposes:

| | `/Lexic:learn` | `/Lexic:save` |
|---|---|---|
| **What** | Implementation insights and gotchas | Reference material and notes |
| **Fed into** | Autonomous run context assembly | General knowledge base queries |
| **Examples** | "RLS silently fails on auth.users joins" | "API design review meeting notes" |
| **When** | You discovered something that should change how future runs work | You want to store something for later reference |

Rule of thumb: if a future autonomous run should change its approach because of what you learned, use `/Lexic:learn`. If it's just good to know, use `/Lexic:save`.

## Troubleshooting

### OAuth sign-in doesn't open a browser

Claude Code should open your default browser when you first use a Lexic tool. If nothing happens:

- Make sure you're running Claude Code in a terminal that can open browser windows (not a headless SSH session).
- Try running `/Lexic:search test` to force the auth flow.
- If you're behind a corporate proxy or firewall, ensure `mcp.lexic.io` and `app.lexic.io` are reachable.

### Tools not loading after install

- Confirm the plugin is installed: run `/plugin list` and verify `lexic` appears.
- Restart Claude Code — plugins load at startup, not mid-session.
- Check that `.mcp.json` exists in the plugin directory and points to `https://mcp.lexic.io/api/mcp`.

### "Unauthorized" or 401 errors

- Your session may have expired. Restart Claude Code to trigger a fresh OAuth flow.
- Verify your Lexic account is active at [app.lexic.io](https://app.lexic.io).
- If you recently changed your login provider (e.g., switched from GitHub to Google), make sure you're signing in with the same provider linked to your Lexic account.

### Tools respond slowly on first use

The MCP server runs on Vercel's serverless infrastructure. The first request after a period of inactivity may take 1–3 seconds due to cold start. Subsequent calls in the same session are fast.

### Using behind a corporate proxy

If your organization routes traffic through a proxy, you may need to set `HTTPS_PROXY` in your environment before launching Claude Code:

```bash
export HTTPS_PROXY=http://your-proxy:8080
```

### Still stuck?

Open an issue at [github.com/lexic-io/Lexic.io-plugin/issues](https://github.com/lexic-io/Lexic.io-plugin/issues) or email support@lexic.io.

## About Lexic

Lexic is a knowledge management system designed for AI-assisted development. It solves the "context loss" problem — where every new Claude Code session starts from zero, forgetting what was decided, what was tried, and what was learned.

Learn more at [lexic.io](https://lexic.io).

## Changelog

### 0.1.0 (Initial Release)

- 13 slash commands: run, status, context, decide, save, search, learn, template, setup, start-session, session-recap, what-do-we-know, optimize-claude-md
- Remote MCP server connection via Streamable HTTP
- OAuth authentication (Google, GitHub, Microsoft)
- Proactive knowledge skill for automatic context loading and decision capture
- Workflow hygiene skill for template suggestions, session resumption, and learn/save guidance
- Autonomous run orchestration with preflight cost estimates and learning capture

## License

MIT
