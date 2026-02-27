---
name: lexic-knowledge
description: >
  Use Lexic's knowledge management tools to maintain project context across sessions.
  Activate when: (1) starting work on a feature or component that may have prior context,
  (2) making an architectural or technical decision worth preserving,
  (3) discovering a gotcha, pattern, or insight that future tasks should know about,
  (4) the user mentions "what did we decide", "how does X work", or references prior work.
---

# Lexic Knowledge Management

Lexic provides persistent knowledge, architectural decisions, and development learnings that survive across Claude Code sessions. Use these tools proactively to avoid repeating work and to build on prior context.

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

## Tool Reference

| Tool | When to Use |
|------|------------|
| `dev_get_feature_context` | Starting work on a known feature |
| `knowledge_get_context` | Broad topic overview with synthesis |
| `knowledge_query` | Searching for specific information |
| `knowledge_get_note` | Reading full content of a specific note |
| `knowledge_store` | Saving a finding, insight, or note |
| `dev_log_decision` | Recording an architectural/technical decision |
