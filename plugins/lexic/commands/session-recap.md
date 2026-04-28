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

### 6. Suggest governance promotion (Nexus-scoped only)

Scan the decisions and learnings stored in steps 2–3 for normative phrasing — patterns like "always X", "never Y", "must Z", "from now on", "all future runs should". These are candidates for promotion to a process rule that will be enforced at every relevant gate phase, not just remembered as prose.

For each match, ask the user:

> "This sounds like a normative rule for `{nexus_name}`: '{matched text}'.
> Promote to a process rule? (will run `rule_simulate` first to check for constitution conflicts)"

If the user accepts:

1. Resolve the active `lexicon_id` from the `<!-- lexic:integration -->` block in CLAUDE.md.
2. Call `rule_simulate` with the proposed rule and the `lexicon_id` (always pass it — system-level promotion is operator-only and not accessible from this command).
3. Present the simulation results (verdict, conflicts, replay outcomes).
4. If the simulation passes, ask whether to proceed with `rule_promote` (also Nexus-scoped via `lexicon_id`).

If no normative matches are found, skip silently. Do not invent rules to promote.

### 7. Execute the check-in gesture

After all knowledge has been stored, perform a source-control check-in for the session's code work. The "check-in gesture" is intentionally SCM-agnostic — detect the project's source control system and use the appropriate verb.

**SCM detection (probe in order, first hit wins):**

| Indicator | SCM | Distributed? | Check-in command |
|---|---|---|---|
| `.git/` | git | yes | `git add` + `git commit` |
| `.hg/` | mercurial | yes | `hg commit` |
| `.jj/` | jujutsu | yes | `jj commit` or `jj describe` |
| `.fslckout` or `_FOSSIL_` | fossil | yes | `fossil commit` |
| `.bzr/` | bazaar | yes | `bzr commit` |
| `.svn/` | subversion | **no (centralized)** | `svn commit` |
| `.p4config`, `P4CONFIG` env, or `.p4ignore` | perforce | **no (centralized)** | `p4 submit` |

**If no SCM is detected:** skip with a one-line note ("No source control detected — skipping check-in gesture") and continue to step 8.

**If a distributed SCM is detected:**

1. Check working tree state (e.g., `git status` for git, `hg status` for hg). If clean, skip with "Working tree clean — nothing to check in."
2. Stage the changes (the SCM-appropriate stage command — git uses explicit `git add <files>`; hg/jj/fossil/bzr stage implicitly).
3. Draft a commit message from the "Work Completed" section of the step 4 summary. Format: 50-char subject + blank line + body. Do **not** include any AI/Claude attribution lines (per project convention).
4. Show the user the staged diff summary and the draft message. Ask for confirmation before committing.
5. On approval, perform the commit. **Do not push** — push is a separate, deliberate user action.
6. If a pre-commit hook fails, **do not amend**. Report the failure, leave changes staged, ask the user to fix and re-run `/lexic:session-recap` (or commit manually).

**If a centralized SCM is detected (svn, p4):**

The check-in equivalent is immediately visible to other developers — treat as a shared-state mutation that always requires explicit confirmation. Same flow as distributed (steps 1–4), but make the confirmation prompt explicit about the visibility:

> "This will commit to {svn|perforce} — changes will be immediately visible to all other developers on this depot/repo. Proceed?"

Only on explicit user approval, perform the submit/commit.

### 8. Report to user

```
Session recap stored to Lexic.

  Decisions logged: {count}
  Learnings stored: {count}
  Summary: stored as "{title}"

  Governance promotions:
  {count of rules promoted, or "None suggested" or "User declined"}

  Check-in gesture: {SCM detected and commit hash, or "skipped — {reason}"}

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
