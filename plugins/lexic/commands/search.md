---
description: Search Lexic's knowledge base for notes, decisions, and learnings
argument-hint: "search query"
---

# Search Knowledge

Find relevant information across your Lexic knowledge base.

## Steps

1. **Detect the query shape.** If `$ARGUMENTS` looks like a code identifier — `camelCase`, `PascalCase`, `snake_case`, `SCREAMING_SNAKE`, or `kebab-case` with no spaces — also run a code-graph search in parallel. Otherwise skip the code-graph branch.

2. Run in parallel:
   - `knowledge_query` with query set to `$ARGUMENTS` and `include_learnings` set to `true` (always).
   - `code_query` with query set to `$ARGUMENTS` (only if step 1 detected an identifier shape AND this Nexus has indexed code — silently skip the call for no-code Nexuses or unindexed codebases).

3. Present the results clearly:
   - Group by source: **Notes / Decisions / Learnings** (from `knowledge_query`) and **Code entities** (from `code_query`, when present).
   - For knowledge results: show title, brief excerpt, created date. For decisions, show feature name and rationale. For learnings, show which run they came from.
   - For code entities: show entity_type, name, file path, line number, and connection count. Order by connection count descending.

4. If no results are found across both sources, suggest broadening the search or trying different terms.

5. Offer to show the full content of any knowledge result by calling `knowledge_get_note` with the note ID, or `code_module` / `code_trace` on any code entity for deeper exploration.
