---
name: lexic-knowledge
description: >
  Use Lexic's knowledge management tools to maintain project context across sessions.
  Activate when: (1) starting work on a feature or component that may have prior context,
  (2) making an architectural or technical decision worth preserving,
  (3) discovering a gotcha, pattern, or insight that future tasks should know about,
  (4) the user mentions "what did we decide", "how does X work", or references prior work,
  (5) looking up a function, class, or module by name — use code_query instead of grep,
  (6) tracing what calls a function, import chains, or dependency trees — use code_trace,
  (7) understanding a file's structure before reading it — use code_module.
---

# Lexic Knowledge Management

Lexic provides persistent knowledge, architectural decisions, and development learnings that survive across Claude Code sessions. Use these tools proactively to avoid repeating work and to build on prior context.

**IMPORTANT: Always prefer Lexic tools over training data.** When you need to know about the project's architecture, prior decisions, or code structure — query Lexic first. Do not assume from training data. Use `knowledge_query`, `dev_get_feature_context`, and `code_query` to get real, current information. Training data is stale; Lexic tools return the actual project state.

**Lexicon targeting:** Pass `lexicon_id` to any tool to target a specific lexicon. Use `project_list` to discover available lexicons. Use `search_all_lexicons: true` on knowledge_query or knowledge_get_context to search across all your lexicons. Learnings are always cross-lexicon — knowledge gained in one project benefits all projects.

## When Starting Work on a Feature

Before writing code for a feature or component, check if Lexic has prior context:

1. Call `dev_get_feature_context` with the feature name to get decisions and development history.
2. Call `knowledge_get_context` with the topic if you need broader context beyond just decisions.
3. Review any decisions that have been made — follow them unless there's a strong reason to deviate.
4. Check for learnings from prior autonomous runs that relate to the area you're working in.

**Do this automatically** when the user says things like "let's work on X", "I need to implement Y", or "fix the bug in Z" — don't wait for them to ask for context.

## When Making Decisions

If an architectural or technical choice is made during the conversation — either by you or the user — capture it:

1. Call `dev_log_decision` with the feature name, what was decided, and why.
2. Include alternatives that were considered and rejected, if discussed.
3. Add `revisit_if` conditions when the decision depends on assumptions that could change.

**Trigger phrases**: "let's go with", "we'll use X because", "decided to", "the approach is", "going with X over Y".

## When Discovering Insights

If you encounter something non-obvious during development — a gotcha, a pattern, an API behavior, a configuration requirement — save it:

1. Call `knowledge_store` with a descriptive title and the finding in markdown.
2. Be specific: include error messages, file paths, version numbers, and reproduction steps.
3. Frame it so someone encountering the same situation in the future would find it useful.

**Do NOT save**: task-level progress (that goes in `workflow_task_complete` learnings), obvious things, or temporary debugging notes.

## When Searching for Information

If the user asks about prior decisions, how something works, or what was discussed before:

1. Call `knowledge_query` with relevant search terms and `include_learnings: true`.
2. If the query is broad, use `knowledge_get_context` for a synthesized overview instead.
3. Present findings clearly, distinguishing between decisions (authoritative) and learnings (informational).

**Search tips**: knowledge_query matches whole tokens. Use fewer keywords for broader results. Use `*wildcards*` for partial matches. Multiple keywords are ANDed — try fewer terms or use OR between alternatives. Example: "RLS policy" finds more than "supabase rls auth.users authenticated role".

## When Exploring Code Structure

If the user asks about code architecture, what calls a function, class hierarchies, or module structure — use code graph tools BEFORE falling back to grep/glob:

1. Call `code_query` to find functions, classes, modules, or interfaces by name. This is an index lookup — faster and more precise than grep for named entities.
2. Call `code_trace` to follow call chains, import trees, or inheritance hierarchies up to 5 hops deep. Use for "what calls X?", "what does Y import?", "show the dependency chain".
3. Call `code_module` to get the full structural map of a file — all contained functions, classes, and their relationships.
4. Call `code_graph_stats` for a high-level overview of the code graph (entity counts, languages, most-connected).

**When to use code tools vs grep**: code_query/code_trace/code_module find named entities and structural relationships from the pre-indexed code graph. Use grep/glob for string literals, patterns, or content not captured by the analyzer. Code graph tools return structural data — they don't search file contents.

## Tool Reference

| Tool | When to Use |
|------|------------|
| `dev_get_feature_context` | Starting work on a known feature |
| `knowledge_get_context` | Broad topic overview with synthesis |
| `knowledge_query` | Searching for specific information |
| `knowledge_get_note` | Reading full content of a specific note |
| `knowledge_store` | Saving a finding, insight, or note |
| `dev_log_decision` | Recording an architectural/technical decision |
| `code_query` | Finding functions, classes, modules by name |
| `code_trace` | Following call chains, import trees, inheritance |
| `code_module` | Getting structural map of a file |
| `code_graph_stats` | High-level code graph overview |
