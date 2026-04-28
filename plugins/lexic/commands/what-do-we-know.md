---
description: Query everything Lexic knows about a topic
argument-hint: "topic to research (e.g., 'authentication', 'database indexing')"
---

# Lexic: What Do We Know

Deep retrieval of everything this project has recorded about a topic — decisions, architecture notes, learnings, and gotchas.

## Steps

### 1. Validate input

If no topic argument was provided, ask the user: "What topic should I look up?"

### 2. Retrieve comprehensive context

Call `dev_get_feature_context` with the topic. This returns:
- All decisions related to the topic
- Architecture documentation
- Recent activity and changes

### 3. Retrieve learnings

Call `knowledge_query` with:
- **query**: the topic
- **depth**: "comprehensive" (returns up to 10 results)
- **include_learnings**: true

### 4. Search for gotchas

Call `knowledge_query` with:
- **query**: "{topic} gotcha OR issue OR problem OR constraint OR limitation"
- **limit**: 5

### 4b. Surface Nexus governance for the topic

Always pass `lexicon_id` from CLAUDE.md's `<!-- lexic:integration -->` block — this command never queries system-level governance.

- `knowledge_query` with `tags: ["constitution", "law"]`, query `{topic}`, `limit: 5` — surfaces active constitutional laws governing this feature area.
- `knowledge_query` with `tags: ["sop", "rule"]`, query `{topic}`, `limit: 5` — surfaces active process rules.

### 4c. Surface code entities for the topic (skip if no-code Nexus)

Three-state branch:
- **Indexed for this Nexus's repo**: call `code_query` with `{topic}` (limit 10) and `code_module` on the top result's parent module. Include the entities in the briefing.
- **Code stack exists but not indexed**: include a one-line note in the briefing ("Code graph not indexed — structural data unavailable for this topic").
- **No-code Nexus**: skip silently; do not mention code-graph at all.

### 5. Present organized results

Format the results into a structured briefing:

```
## What Lexic knows about: {topic}

### Decisions ({count})
{Chronological list of decisions with dates and rationale}

1. [{date}] **{decision title}**
   - Choice: {what was decided}
   - Why: {rationale}
   - Alternatives rejected: {list}

### Architecture Notes ({count})
{Relevant architecture documentation and design notes}

### Active Governance ({count})
{Constitutional laws and process rules governing this topic, from step 4b}

- {law/rule title} — {scope and binding behavior}

### Code Entities ({count}) {omit this section entirely for no-code Nexuses}
{Functions, classes, modules from step 4c}

- {entity_type}: {name} ({file_path}:{line}) — {connection_count} connections

### Learnings & Gotchas ({count})
{Things discovered through experience}

- {learning with context and confidence level}

### Recent Activity ({count})
{Recent notes and changes related to this topic}

### Gaps
{If any of the above sections returned zero results, note it:}
- No decisions recorded for {topic} — consider logging key choices with /lexic:decide
- No learnings recorded — this area hasn't hit any documented gotchas yet
```

### 6. Offer next steps

Based on the results:

- **If rich context exists**: "This topic is well-documented. The key decisions to respect are: {list top 3}"
- **If sparse**: "Not much recorded here yet. As you work on {topic}, consider logging decisions with `/lexic:decide` so future sessions have context."
- **If contradictions found**: "There may be conflicting information — {describe conflict}. Consider resolving this with a new decision."

## Design Intent

This is the "show me everything" command. Developers use it when starting work on an area they haven't touched recently, or when onboarding to a part of the codebase they're unfamiliar with. The output should be readable as a briefing document — organized, concise, and actionable.
