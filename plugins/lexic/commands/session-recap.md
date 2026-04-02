---
description: Summarize this session's work and store decisions + learnings to Lexic
argument-hint: "(optional) additional context about what was done"
---

# Lexic: Session Recap

Capture what happened in this session so future sessions have continuity.

## Steps

### 1. Analyze the session

Review the conversation history to identify:

- **Decisions made**: Architectural choices, library selections, pattern changes, approach decisions
- **Learnings discovered**: Gotchas, constraints, things that didn't work, things that worked unexpectedly well
- **Work completed**: Features built, bugs fixed, refactors done
- **Work started but not finished**: Partially implemented features, known remaining tasks
- **Open questions**: Things that still need resolution

### 2. Store decisions

For each significant decision identified, call `dev_log_decision` with:
- **feature**: The relevant area
- **decision**: What was decided
- **rationale**: Why
- **alternatives**: What else was considered

Skip trivial decisions (variable naming, minor formatting). Focus on choices that would be expensive to reverse or that future sessions need to know about.

### 3. Store learnings

For each gotcha or learning, call `workflow_learning_create` with:
- **category**: The type of learning (e.g., "framework_quirk", "deployment", "performance", "api_limitation")
- **content**: What was learned
- **context_tags**: Relevant tags for future retrieval
- **confidence**: How confident we are (high/medium/low)

### 4. Store session summary

Call `knowledge_store` with:
- **title**: "{primary topic or work area} ({date})" — lead with the distinctive content, not a category prefix. The `session-recap` tag already classifies it; the title should maximize semantic distinctiveness for search and similarity.
- **content**: Structured summary of the session
- **tags**: ["session-recap", "{primary-area}"]

The summary should follow this format:

```
## Session: {date}

### Work Completed
- {bullet list of what was done}

### Decisions Made
- {decision}: {one-line rationale} (logged to Lexic)

### Learnings
- {learning}: {brief context} (logged to Lexic)

### Unfinished Work
- {what's remaining and current state}

### Open Questions
- {questions that need answers before next session}
```

### 5. Close ad-hoc attribution session

If any `knowledge_query` calls with `include_learnings: true` were made during this session, an ad-hoc attribution task may exist. Close it by calling `close_adhoc_session` with:
- **output_summary**: The session summary text from step 4 (the full markdown content passed to `knowledge_store`)
- **outcome**: `"success"` unless the session ended with unresolved failures, in which case `"failure"`

This enables the learning attribution pipeline to score which served learnings were relevant to this session's work. Do NOT skip this step — it directly feeds the confidence system.

If `close_adhoc_session` is not available as a tool, skip this step silently (the hourly cron will close it automatically with a weaker fallback summary).

### 6. Report to user

```
Session recap stored to Lexic.

  Decisions logged: {count}
  Learnings stored: {count}
  Summary: stored as "{title}"

  Unfinished work flagged:
  {list, or "None — clean session"}

  Next session: Run /lexic:start-session to pick up where you left off.
```

## What Gets Stored vs. What Doesn't

**Store:**
- Decisions with lasting impact
- Reusable learnings (gotchas, constraints, patterns that work)
- Summary of work done (for continuity)
- Open questions (for next session pickup)

**Don't store:**
- Debugging dead ends that led nowhere useful
- Conversation about preferences or style
- Trivial changes (typo fixes, formatting)
- Sensitive data (credentials, tokens, PII)

## Design Intent

This is the "end of day" ritual. The goal is knowledge extraction, not transcription. A good recap stores 3-5 high-value items, not a play-by-play of every tool call. Future sessions benefit from curated insights, not raw history.
