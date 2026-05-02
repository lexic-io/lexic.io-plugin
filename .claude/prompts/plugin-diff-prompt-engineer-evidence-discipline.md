# Proposed Plugin Diff: Evidence Discipline for `lexic:prompt-engineer`

> **Scope reduced 2026-05-02** — after reading the live skill prose at `plugins/lexic/commands/prompt-engineer.md`, Diffs 2 (Phase 1 probe step) and 4 (Critical rule update) were determined to be redundant with content already present (Phase 1 steps 5-10 already cover Knowledge Tools + Code Graph Tools; Phase 2 line 57 already has the file-read Critical rule). Diff 3 (Phase 5 validate gate) and Diff 1 (Evidence Discipline section) remain net-new. The corrected, narrower scope is captured as a structured implementation prompt at `plugin-evidence-discipline-implementation.md` — that is the canonical artifact for executing this work. This document is preserved as the historical proposal that drove the live-skill review.


**Purpose**: Promote the "Evidence Discipline" principle from project-local `.lexic/prompt-engineer.md` into the platform-level `lexic:prompt-engineer` skill prose, so every Lexic-using project inherits it instead of re-discovering it the hard way.

**Origin**: Spec 10b retrospective (2026-04-30) surfaced a class of failure where unverified data-shape claims propagated from prompt → spec → implementation → tests, only being caught at runtime against live data. The fix at the project level prevents recurrence in this codebase; promoting to the plugin prevents recurrence across all projects.

---

## Target file in the plugin repo

`lexic:prompt-engineer` skill prose — the document loaded when a user invokes `/lexic:prompt-engineer`. Path likely something like `skills/prompt-engineer.md` in the Lexic plugin distribution (verify against actual repo layout before applying).

---

## Diff 1 — New top-level "Evidence Discipline" section

**Insert location**: Immediately after the opening description block, before "Step 1: Validate input".

**Add:**

```markdown
## Evidence Discipline (foundational — applies to every claim in a generated spec)

**Ungrounded and unverified data is not actionable or usable. Claims require verifiable and provable data points.**

This is foundational, not a checklist item to satisfy later. A spec that says "X exists", "Y is empty", or "Z always returns N" must carry an evidence citation that lets the reader independently re-verify the claim. No exceptions for confidence, urgency, or apparent obviousness.

**Evidence priority order:**

1. **Live data probe** — a query (with timestamp) whose result is reproduced in the spec. Required for any claim about row counts, column distributions, presence/absence of records, or "what value does column X actually contain." Substitute "API call", "filesystem inspection", or equivalent for non-database data sources.
2. **Code citation with file:line** — required for any claim about what code does, what calls what, or what a function returns. The reader must be able to navigate to that exact location and verify.
3. **Read-back of an authoritative artifact** — migration file content, generated type file, OpenAPI/JSON schema, RLS policy definition. Cite path + line range.
4. **Memory note or prior-agent assertion** — weakest form of evidence. Acceptable for procedural guidance ("how we handle X") but **NOT acceptable for data-shape claims** (row counts, column values, distribution patterns). Memory drifts; treat memory-served claims as hypotheses to verify, not as ground truth.

**The lesson**: when a spec contains a filter or count claim that names a specific column value, the minimum discovery work is to query the actual values in that column. Memory notes and code patterns are starting points for hypotheses, not substitutes for verification. Accept the few-second cost of probing; the cost of not probing is shipping bugs into the implementation chain where they cost orders of magnitude more to catch.
```

---

## Diff 2 — New Phase 1 (Discover) step

**Insert location**: In `### Phase 1: Discover — understand what exists`, after the existing `knowledge_query` step (currently step 6 in the project-local file's numbering; locate equivalent step in the platform skill).

**Add as a new numbered step:**

```markdown
N. **Probe live data for any column or value referenced in a filter recommendation.** For every claim of the form "there are N rows", "column X has value Y", "filter Z excludes population W" that you anticipate writing in the spec, run a probe of the actual data first:
   - SQL stores: `SELECT col, COUNT(*) FROM table GROUP BY col` for distribution; `information_schema.columns` for defaults; `pg_constraint` for CHECK constraints
   - Non-SQL: equivalent inspection (API call, filesystem listing, process state query)
   Memory notes and code patterns produce hypotheses; this step produces evidence. Do not skip even when the claim feels obvious — assumed values drift from real values especially in long-lived codebases.
```

---

## Diff 3 — New Phase 5 (Validate) gate

**Insert location**: In `### Phase 5: Validate — quality check`, append to the existing verification list.

**Add:**

```markdown
- **Evidence citation present for every quantitative claim**: no claim of the form "there are N rows", "column X has value Y", "filter Z excludes population W", "this branch never fires", or "this is unused" appears without either a probe-result reproduction or a code-citation that proves it. Memory notes do not satisfy this gate.
```

---

## Diff 4 — Update the "Critical rule" callout in Phase 2

**Existing text** (in `### Phase 2: Scope`):

```
**Critical rule:** For every file listed in "Files to Modify" in the output, you must have READ that file. No exceptions.
```

**Replace with:**

```
**Critical rules:**
- For every file listed in "Files to Modify" in the output, you must have READ that file. No exceptions.
- For every quantitative claim or filter recommendation, you must have RUN the verifying probe. No exceptions. (See Evidence Discipline section.)
```

---

## Validation that the diff is correct

After applying, the next `/lexic:prompt-engineer` invocation in any project should:

1. Display the Evidence Discipline section as part of the skill's loaded prose
2. Cause Phase 1 to include a live-probe step for any filter recommendation
3. Cause Phase 5 to fail validation if the spec contains an unverified quantitative claim

---

## Project-level file (`.lexic/prompt-engineer.md`) — what stays

Keep the concrete Lexico-specific failure-mode example (`actor_type='system'` in Spec 10b) in the project file. That's institutional memory specific to this codebase's data shape and is valuable for future Lexico engineers as a cautionary tale. The platform-level skill carries the abstract principle; the project-level file carries the concrete case.

---

## Submission notes

- This diff is additive — no existing skill behavior changes, only new mandatory steps
- Estimated review surface: ~50 lines added across 4 locations in one file
- No code changes outside the skill prose
- Backward compatible with all existing project-level `.lexic/prompt-engineer.md` overrides
