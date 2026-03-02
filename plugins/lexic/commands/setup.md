---
description: Configure CLAUDE.md with Lexic knowledge management integration. Safe to re-run — idempotent.
argument-hint: "(optional) lexicon name or ID"
---

# Lexic Setup

Configure this project's CLAUDE.md to integrate with Lexic for persistent knowledge management across sessions.

## Steps

### 1. Check for existing CLAUDE.md

Read the `CLAUDE.md` file in the project root directory.

- **If it exists**: Read its full contents. Continue to step 2.
- **If it does not exist**: Note that we'll create a minimal one. Skip to step 3.

### 2. Check for existing Lexic integration

Search the CLAUDE.md contents for the marker `<!-- lexic:integration -->`.

- **If found**: The Lexic integration block already exists. Tell the user it's already configured and offer to update it if they've changed their setup. Show them what's currently there. **Stop here unless they want changes.**
- **If not found**: Continue to step 3.

### 3. Detect project context

Analyze the project to understand the tech stack. Check for:

- `package.json` (Node.js/JS/TS project — check for framework: Next.js, React, Vue, etc.)
- `*.csproj` or `*.sln` (ASP.NET / .NET project)
- `composer.json` or `wp-config.php` (PHP / WordPress)
- `requirements.txt` or `pyproject.toml` (Python)
- `Cargo.toml` (Rust)
- `go.mod` (Go)
- `force-app/` or `sfdx-project.json` (Salesforce)
- `Gemfile` (Ruby)

Also check for:
- `.git/` — is this a git repo?
- Existing test frameworks (jest, vitest, pytest, xunit, phpunit, etc.)
- CI configuration (.github/workflows, .gitlab-ci.yml, etc.)

Record the detected stack. This helps Lexic provide relevant context later.

### 4. Resolve Lexic project

If the user provided a lexicon name/ID as an argument, use that. Otherwise:

Call the MCP tool `project_list` to see available lexicons. If exactly one exists, use it. If multiple exist, ask the user which lexicon this project should use. If none exist, call `project_create` with the project name derived from the directory name or package name.

Record the `lexicon_id` for the integration block.

### 5. Build the integration block

Construct the following block, customized with the detected stack and lexicon:

```markdown
<!-- lexic:integration -->
## Lexic Knowledge Management

This project uses [Lexic](https://lexic.io) for persistent knowledge across coding sessions.

**Project:** {lexicon_name} (`{lexicon_id}`)
**Stack:** {detected stack summary, e.g. "Next.js 15, TypeScript, Supabase, PostgreSQL"}

### Before implementing any feature or fix:
- Query Lexic for prior decisions: `knowledge_query` with relevant topic keywords
- If conflicting decisions exist, surface them before proceeding

### After making significant decisions:
- Log the decision to Lexic: `dev_log_decision` with rationale and alternatives considered
- Significant = architectural choices, library selections, pattern changes, API design decisions

### When discovering project-specific gotchas:
- Store as a learning: `workflow_learning_create` with category and context tags
- Examples: framework quirks, deployment constraints, API rate limits, schema gotchas

### Session workflow (optional):
- Start: `/lexic:start-session` to load recent context
- End: `/lexic:session-recap` to capture what was done
<!-- /lexic:integration -->
```

### 6. Insert the block into CLAUDE.md

**If CLAUDE.md exists:**
- Insert the Lexic block **after** any existing header/title section but **before** the main body of instructions
- If the file has a clear structure (e.g., starts with `# Project Name` then has sections), insert after the first section
- If unclear, append to the end of the file
- Preserve ALL existing content — do not modify anything outside the integration block

**If CLAUDE.md does not exist:**
- Create a new CLAUDE.md with this structure:

```markdown
# {Project Name}

{One-line description based on package.json description, README, or directory name}

<!-- lexic:integration -->
{integration block from step 5}
<!-- /lexic:integration -->

## Development

{Placeholder for the user to fill in their project conventions}
```

### 7. Create .lexic/prompt-engineer.md

Check if `.lexic/prompt-engineer.md` already exists.

- **If it exists**: Leave it untouched. Do not overwrite user customizations.
- **If it does not exist**: Create the `.lexic/` directory (if needed) and write this file:

```markdown
# Prompt Engineer — Project Customizations
#
# This file is read by /lexic:prompt-engineer to tailor prompt generation
# to your specific codebase. It is NOT read by coding agents — it configures
# the prompt engineering process itself.
#
# Add your project's mandatory guardrails, stack details, common patterns,
# and conventions below. Each section is optional — delete or leave empty
# any section that doesn't apply.
#
# To use: run /lexic:prompt-engineer "your feature description"
# The prompt engineer will read this file automatically during Phase 0.

## Stack
#
# Describe your tech stack so generated prompts reference the right tools.
# Example:
#   - Next.js 15, TypeScript, PostgreSQL
#   - Python 3.12, FastAPI, SQLAlchemy

## Mandatory Guardrails
#
# Rules that must appear in EVERY generated prompt. These are your project's
# non-negotiable constraints.
# Example:
#   - Always check authentication before database writes
#   - Never log PII to stdout
#   - All database queries must use parameterized statements

## Knowledge Tools
#
# If your project has MCP tools for querying prior decisions or storing
# context, list them here so the prompt engineer uses them.
# Example:
#   - `dev_get_feature_context` — get decisions for a feature area
#   - `knowledge_query` — search for prior decisions

## Patterns to Watch For
#
# Common failure patterns specific to your codebase. The prompt engineer
# checks for these during Phase 2 (scoping).
# Example:
#   - API handler exists but not registered in router
#   - Migration references column that doesn't exist yet

## Test Conventions
#
# Testing rules to include in generated prompts.
# Example:
#   - Use factories for test data, not raw SQL
#   - Integration tests run against a test database

## Output Conventions
#
# Where and how prompts should be saved, and any build checks to include.
# Example:
#   - Save prompts to `.claude/prompts/{feature-name}.md`
#   - Build check: `npm run typecheck`
```

This file is intentionally blank (comments only) so it does nothing until the user adds their own rules. The comments are written for a human reader — they explain what each section does and show examples.

### 8. Store the setup event in Lexic

Call `knowledge_store` with:
- **title**: "Project Setup: {project name}"
- **content**: Summary of detected stack, lexicon assignment, and setup date
- **tags**: ["setup", "project-config"]

This creates a knowledge anchor so future sessions know when and how the project was configured.

### 9. Verify the MCP connection

Call `knowledge_query` with the search term "setup" to verify the Lexic MCP tools are accessible and the lexicon is reachable.

- **If successful**: Report success to the user
- **If failed**: Report the error and suggest checking their MCP server configuration

### 10. Report to the user

Print a summary:

```
Lexic setup complete.

  Project: {name}
  Lexicon: {lexicon_name}
  Stack:   {detected stack}

  CLAUDE.md:                    {created / updated}
  .lexic/prompt-engineer.md:    {created / already exists}

  Available commands:
    /lexic:start-session       Load recent decisions + active context
    /lexic:prompt-engineer     Generate implementation prompts from feature descriptions
    /lexic:log-decision        Record an architectural decision
    /lexic:what-do-we-know     Query everything Lexic knows about a topic
    /lexic:session-recap       Summarize and store session learnings
    /lexic:optimize-claude-md  Analyze CLAUDE.md for improvement opportunities

  Customize prompt generation by editing .lexic/prompt-engineer.md
  The integration block in CLAUDE.md is marked with <!-- lexic:integration -->
  so it's safe to edit — just keep the markers intact for future updates.
```

## Idempotency

This command is safe to re-run. The `<!-- lexic:integration -->` markers ensure:
- Existing integration blocks are detected and not duplicated
- Updates replace the block between markers, preserving everything else
- The user is always asked before any modification to an existing block

## What This Command Does NOT Do

- Does not modify any source code
- Does not install dependencies
- Does not create or modify MCP server configuration (that's a separate setup step)
- Does not overwrite existing CLAUDE.md content outside the integration markers
- Does not make assumptions about the user's coding conventions — that's their CLAUDE.md, not ours
