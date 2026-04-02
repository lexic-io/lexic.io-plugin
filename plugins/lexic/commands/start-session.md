---
description: Load recent Lexic context at the start of a coding session
argument-hint: "(optional) topic or feature area to focus on"
---

# Lexic: Start Session

Load recent decisions, active workflows, and relevant learnings from Lexic to give this session full project memory.

## Steps

### 1. Identify the active lexicon

Read CLAUDE.md and find the `<!-- lexic:integration -->` block. Extract the lexicon ID.

- **If no integration block found**: Tell the user to run `/lexic:setup` first. Stop.

### 2. Load recent decisions

Call `knowledge_query` with:
- **query**: "recent decisions" (or the user's topic argument if provided)
- **tags**: ["decision"]
- **limit**: 10

Present the results as a brief summary:

```
Recent decisions (last 10):
  1. [date] Authentication: Chose JWT over session cookies — performance at scale
  2. [date] Database: Added composite index on (tenant_id, created_at) — query perf
  ...
```

### 3. Load active workflows (if any)

Call `workflow_run_list` with status filter "active".

- **If active runs exist**: Show them with completion percentage
- **If none**: Skip this section

```
Active workflows:
  - "Migrate to v2 API" — 60% complete (6/10 tasks done)
  - "Add export feature" — 20% complete (1/5 tasks done)
```

### 4. Load recent learnings

Call `knowledge_query` with:
- **query**: the user's topic argument if provided; otherwise derive a meaningful query from the project context (repo name from the working directory, key areas mentioned in CLAUDE.md, or recent git log subjects via `git log --oneline -5`)
- **include_learnings**: true
- **limit**: 10

Present learnings grouped by source:

```
Project learnings:
  - {learning from this lexicon}
  - ...

Platform learnings:
  - {cross-project learning relevant to the tools/patterns in use}
  - ...
```

If no learnings are returned, note this and move on — don't fabricate entries.

### 5. Load feature context

If the user provided a topic argument, call `dev_get_feature_context` with that topic.

If no topic argument was provided, call `dev_get_feature_context` with the project or repo name (e.g., from the working directory) to surface any decisions, architecture notes, and recent activity related to this project area.

Present this as a focused context briefing.

### 6. Summary

Print a session-ready summary:

```
Session context loaded from Lexic.

  Decisions: {count} recent
  Active workflows: {count}
  Learnings: {count} relevant

  {If topic provided:}
  Topic focus: "{topic}"
    - {count} related decisions
    - {count} related notes
    - Key context: {one-line summary of most important finding}

  Ready to work. Lexic will be queried automatically before implementations
  that touch areas with prior decisions.
```

## Design Intent

This command is the "morning standup" equivalent. It gets the model up to speed on institutional knowledge so it doesn't re-decide things that were already decided or repeat mistakes that were already learned from. It's intentionally brief — a context primer, not a data dump.
