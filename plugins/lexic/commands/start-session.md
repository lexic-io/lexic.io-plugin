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

### 5b. Code graph status (skip for pure-knowledge Nexuses)

Before any further code-related steps, determine whether code-graph tools apply:

- If the working directory has a code stack (package manifest, `.git/`, etc.) AND `code_graph_stats` shows this lexicon's repo in `by_repo` → indexed; proceed normally.
- If a code stack exists but the repo isn't in `by_repo` → unindexed; mention once in the summary, recommend triggering indexing.
- If no code stack exists → pure-knowledge Nexus; **skip all code-graph calls in subsequent commands chained from this session**, and omit code-graph mentions from the summary.

### 6. Surface Nexus governance state

Pass the `lexicon_id` from Step 1 to all calls below. Never call these without `lexicon_id` — system-level governance is operator-only and not relevant to a session-start briefing.

1. Call `knowledge_query` with `tags: ["constitution"]`, `limit: 3` to retrieve the active constitutional version metadata and any pending drafts.
2. Call `knowledge_query` with `tags: ["sop", "rule"]`, `limit: 5` to surface active process rules and any pending `rule_simulate` results that haven't been promoted yet.

Present in the summary as:

```
Nexus governance:
  Active constitution: v{N} ({law_count} laws)
  Drafts awaiting promotion: {count}
  Active process rules: {count}
  Rules simulated but not promoted: {count}
```

If any drafts or simulated-but-not-promoted rules exist, list their titles — these are stalled governance threads worth reviewing this session.

`get_active_threads` is **already auto-called by the init hook** at session start; do not call it again here. If the briefing surfaced anything notable, mention it once in the summary instead of re-fetching.

### 7. Auto-chain to prompt-engineer (when topic provided)

If the user passed a topic argument and there is no active workflow run for it (check the active workflows from Step 3 against the topic):

- Hand off to the `/lexic:prompt-engineer` flow with the topic as input. The user lands in a session with a ready-to-go implementation prompt rather than having to re-invoke a second command.
- Tell the user: `"Topic '{topic}' had no active run. Auto-running /lexic:prompt-engineer..."` then proceed with that command's Phase 0 onward.

If the user passed a topic AND an active workflow run already exists for it:

- Surface the run, show its progress, and offer to resume via `/lexic:run {run_id}` instead of starting fresh.

If no topic was provided:

- Skip auto-chaining. Continue to the summary.
- If `dev_get_feature_context` from Step 5 surfaced any stalled in-progress prompt-engineering threads (decisions referenced but with no implementation work tracked), call them out in the summary and offer to resume one.

### 8. Summary

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

If Step 7 auto-chained to `/lexic:prompt-engineer`, the prompt-engineer output replaces this summary — there is no need to print both.

## Design Intent

This command is the "morning standup" equivalent. It gets the model up to speed on institutional knowledge so it doesn't re-decide things that were already decided or repeat mistakes that were already learned from. It's intentionally brief — a context primer, not a data dump.
