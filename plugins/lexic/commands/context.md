---
description: Load context from Lexic's knowledge base for a feature or topic before starting work
argument-hint: "feature name or topic"
---

# Load Context

Assemble everything Lexic knows about a topic before you start working on it.

## Steps

1. Call `dev_get_feature_context` with feature set to `$ARGUMENTS`.
2. Call `knowledge_get_context` with topic set to `$ARGUMENTS` and depth set to `comprehensive`.
3. **Code-graph context (skip if no-code Nexus):** check whether the working directory has a code stack (package manifest, `.git/`, etc.) and whether `code_graph_stats` shows this lexicon's repo in `by_repo`.
   - If indexed: call `code_query` with `$ARGUMENTS` to surface code entities (functions, classes, modules) by name, then `code_module` on the top primary module to get its structural map.
   - If a code stack exists but isn't indexed: skip with a one-line note ("Code graph not indexed for this Nexus — structural context unavailable").
   - If pure-knowledge Nexus: skip silently.
4. Synthesize the results into a briefing:
   - **Decisions made**: List architectural and technical decisions with their rationale. Flag any that have `revisit_if` conditions that may now be relevant.
   - **Key knowledge**: Summarize the most important findings, patterns, and gotchas.
   - **Code entities** (if step 3 returned results): list the relevant functions/classes/modules with file paths and connection counts.
   - **Recent learnings**: Highlight insights from recent autonomous runs that relate to this feature.
   - **Open questions**: If there are gaps — decisions referenced but not recorded, conflicting information, or areas with no prior context — call them out.
5. Ask the user if they want to dive deeper into any specific area, or if they're ready to start working.
