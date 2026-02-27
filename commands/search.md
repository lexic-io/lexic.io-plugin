---
description: Search Lexic's knowledge base for notes, decisions, and learnings
argument-hint: "search query"
---

# Search Knowledge

Find relevant information across your Lexic knowledge base.

## Steps

1. Call `knowledge_query` with query set to `$ARGUMENTS` and `include_learnings` set to `true`.
2. Present the results clearly:
   - Group by type (notes, decisions, learnings) if mixed results are returned
   - Show the title, a brief excerpt, and when it was created
   - For decisions, show the feature name and rationale
   - For learnings, show which run they came from
3. If no results are found, suggest broadening the search or trying different terms.
4. Offer to show the full content of any result the user is interested in by calling `knowledge_get_note` with the note ID.
