# Plugin Implementation: Evidence Discipline (lexic:prompt-engineer skill)

## Goal

Add a foundational "Evidence Discipline" rule to the platform-level `lexic:prompt-engineer` skill so every Lexic-using project inherits it. The rule says: ungrounded data-shape claims (row counts, column values, filter behavior) require live probes or code citations as evidence; memory notes and prior-agent assertions produce hypotheses, not ground truth.

## The Problem / Context

### Originating incident

Lexico's Spec 10b retrospective (2026-04-30) surfaced a class of failure where unverified data-shape claims propagated from prompt -> spec -> implementation -> tests, only being caught at runtime against live data. Specifically: a `.neq('actor_type', 'system')` filter recommendation was inherited from three converging-but-stale signals (an admin spot-check, a classifier short-circuit, a system-generated learning) without any of them being a live data probe. A 5-second `SELECT actor_type, source, COUNT(*) FROM notes GROUP BY 1,2` would have surfaced the analyzer-rows-are-`human`-not-`system` reality immediately.

The fix shipped at the project level (Lexico's `.lexic/prompt-engineer.md`, commit `dcc98e28`, 2026-05-02) prevents recurrence in Lexico. Promoting the principle to the platform skill prevents recurrence across all Lexic-using projects.

### Live skill prose state (verified 2026-05-02)

File: `plugins/lexic/commands/prompt-engineer.md`. Already has:
- **Phase 0**: reads `.lexic/prompt-engineer.md` for project overlays.
- **Phase 1: Discover** steps 5-7: knowledge tools (`dev_get_feature_context`, `knowledge_query`, governance-tagged knowledge_query).
- **Phase 1: Discover** steps 8-10: code graph tools (`code_query`, `code_trace`, `code_pattern`).
- **Phase 2: Scope** steps 2-6: code graph tools (`code_query`, `code_trace`, `code_module`, `code_pattern`, `code_orphan_consumers`).
- **Phase 5: Validate** lines 74-84: file-read gate, code-pattern provenance gate, file-path verification gate, database-column existence gate, build/type-check reminder, `code_orphan_consumers` gate, governance-load gate.
- **Critical rule** (line 57): every file in "Files to Modify" must have been READ.
- **Output template** (lines 90-118): placeholders that already mention "evidence from codebase" and "with file provenance."
- **Save-to-file convention** (lines 132, 142-143): `.claude/prompts/{feature-slug}.md`.

What is **NOT yet present**:
- A foundational Evidence Discipline section that explicitly defines evidence priority (live probe > code citation > authoritative artifact > memory note) for quantitative claims.
- A Phase 5 gate that explicitly requires evidence citation for every "there are N rows" / "column X has value Y" / "filter Z excludes population W" / "this branch never fires" claim.

This implementation prompt scopes only those two net-new additions. Earlier drafts (see `plugin-diff-prompt-engineer-evidence-discipline.md`) proposed promoting Knowledge Tools and Code Graph Tools sections too — those proposals were superseded after reading the live skill, which already covers both.

## Architecture Context

### Patterns to Follow

#### Foundational rule placement

Insert the Evidence Discipline section as a top-level construct between the introduction (lines 6-11) and Step 1 (line 12), so it's loaded as a foundational rule before the phase-by-phase process. This mirrors how Lexico's project-local file places it (after Stack, before Mandatory Guardrails — it's foundational, not procedural).

#### Phase 5 augmentation

The existing Phase 5 list (lines 74-84) is a flat bullet list of validation gates. Append the new evidence-citation gate as another bullet at the end. Match the existing wording style (terse imperatives, no introductions per bullet).

#### Output template alignment

The output template at lines 90-118 already encourages evidence references via placeholder text. The Evidence Discipline section makes those placeholders binding, not optional. No change to the template itself is needed.

### What NOT to Do

- **Do NOT promote Knowledge Tools or Code Graph Tools sections.** They are already in Phase 1 + Phase 2. Adding them again would create duplicate guidance with potentially-divergent wording.
- **Do NOT promote a "Mandatory Guardrails" section.** The platform skill distributes guardrails inline across phases (no top-level guardrails block). Lexico's project-local `Mandatory Guardrails` section contains Lexico-specific bullets (`consumeWordsForLexicon`, RLS multi-tenant, `lib/i18n/strings`, etc.) that should NOT generalize.
- **Do NOT include Lexico's Spec 10b case study verbatim.** The abstract principle goes to the plugin; the concrete cautionary tale stays in Lexico's `.lexic/prompt-engineer.md`. The plugin section may close with a sentence noting "Project-local `.lexic/prompt-engineer.md` files may include concrete failure-mode examples specific to that project's data shape" — that's the only reference back.
- **Do NOT modify project-specific content** in any project's `.lexic/prompt-engineer.md`. That's a separate per-project follow-up, gated on this plugin promotion shipping.
- **Do NOT change existing phase numbering, validation gates, or output structure.** This is purely additive.

### Known Issues / Gotchas

1. **Phase 0 already loads `.lexic/prompt-engineer.md`** (line 21): Lexico's project file currently contains its own Evidence Discipline section. After this plugin promotion ships, Lexico's project file can be slimmed to remove the duplicated section in a separate follow-up PR. Until then, both files have the section — this is intentional during the transition window; the project-local file overrides at load time and the content is identical.
2. **The output template (lines 90-118)** is intentionally not changed. The placeholders already say "with evidence from codebase" and "with file provenance"; the new Evidence Discipline section makes those placeholders binding, which is sufficient.
3. **Plugin versioning**: if `plugins/lexic/.claude-plugin/plugin.json` carries a version, bump the patch level (additive, behavior-preserving change to a skill).

## What to Build

### Task 1: Add Evidence Discipline section to the skill prose

**Files**: edit `plugins/lexic/commands/prompt-engineer.md` (the live skill file).

**What to do**: Insert a new top-level `## Evidence Discipline` section between the intro paragraph (ending at line 11) and `## Step 1: Validate input` (line 12). Section content:

```markdown
## Evidence Discipline (foundational — applies to every claim in a generated spec)

**Ungrounded and unverified data is not actionable or usable. Claims require verifiable and provable data points.**

This is foundational, not a checklist item to satisfy later. A spec that says "X exists", "Y is empty", or "Z always returns N" must carry an evidence citation that lets the reader independently re-verify the claim. No exceptions for confidence, urgency, or apparent obviousness.

**Evidence priority order:**

1. **Live data probe** — a data query (with timestamp) whose result is reproduced in the spec. Required for any claim about record counts, field distributions, presence or absence of records, or "what value does field X actually contain." The probe mechanism depends on the data source — SQL query, NoSQL query, REST/GraphQL API call, log query, analytics event count, filesystem inspection, or equivalent — but the requirement (reproducible, re-verifiable result with a timestamp) is the same regardless of store.
2. **Code citation with file:line** — required for any claim about what code does, what calls what, or what a function returns. The reader must be able to navigate to that exact location and verify.
3. **Read-back of an authoritative artifact** — migration file content, generated type file, OpenAPI/JSON schema, RLS policy definition. Cite path + line range.
4. **Memory note or prior-agent assertion** — weakest form of evidence. Acceptable for procedural guidance ("how we handle X") but **NOT acceptable for data-shape claims** (record counts, field values, distribution patterns). Memory drifts; treat memory-served claims as hypotheses to verify, not as ground truth.

**Required pre-spec verification for these claim types:**

- **"This filter excludes X"** -> probe the actual values in that field and cite the result before recommending the filter.
- **"There are N records that..."** -> run the count query against the data store and cite the timestamp.
- **"Field Y has value Z by default"** -> query the authoritative metadata for the data store in question (schema introspection, type definitions, etc.) for the actual default, OR read the canonical artifact that set it. Do not infer from code defaults.
- **"This is dead code / never executes"** -> trace callers AND cite a code path or runtime check that proves the branch can never fire.
- **"The existing pattern is X"** -> cite at least 2 file:line examples of that pattern actually in use. One example is anecdote; two is a pattern.

**The lesson**: when a spec contains a filter or count claim that names a specific field value, the minimum discovery work is to query the actual values in that field. Memory notes and code patterns are starting points for hypotheses, not substitutes for verification. Accept the few-second cost of probing; the cost of not probing is shipping bugs into the implementation chain where they cost orders of magnitude more to catch.

Project-local `.lexic/prompt-engineer.md` files may include concrete failure-mode examples specific to that project's data shape.
```

**Acceptance criteria**:
- [ ] Section inserted between intro and Step 1.
- [ ] Markdown heading levels match surrounding prose (`##` matches Step 1 / Step 2).
- [ ] Section does not include Lexico's Spec 10b case study verbatim (only the closing reference to project-local files).

### Task 2: Add evidence-citation gate to Phase 5

**Files**: edit `plugins/lexic/commands/prompt-engineer.md`.

**What to do**: In Phase 5: Validate (the bullet list at lines 74-84), append a new bullet at the end of the list:

```markdown
- Every quantitative claim has an evidence citation: no claim of the form "there are N records", "field X has value Y", "filter Z excludes population W", "this branch never fires", or "this is unused" appears without either a probe-result reproduction or a code-citation that proves it. Memory notes do not satisfy this gate.
```

**Acceptance criteria**:
- [ ] Bullet appended at the end of the Phase 5 list.
- [ ] Wording matches the Evidence Discipline section's vocabulary (uses "claim", "probe", "code-citation", "memory notes" consistently).
- [ ] No existing bullet renumbered, removed, or modified.

### Task 3: Verification

**Files**: none (commands only).

**What to do**:
1. Read the modified `plugins/lexic/commands/prompt-engineer.md` end-to-end. Confirm:
   - New Evidence Discipline section is between the intro and Step 1.
   - Phase 5 list has the new bullet at the end.
   - All other phases, validation gates, output template, and Step 3/4 sections are unchanged.
2. **Project-leakage check** — grep the modified `plugins/lexic/commands/prompt-engineer.md` for project-specific terms that must not appear in the platform skill. The grep must return zero matches for each of: `Lexico`, `Lexic.io` (the product, distinct from the plugin/Nexus terminology that legitimately appears), `Spec 10b`, `actor_type`, `.neq(`, `consumeWordsForLexicon`, `lib/i18n/strings`. If any match surfaces, the abstraction has leaked — remove the offending content before proceeding. Also verify case-insensitively for any other obviously project-coupled term (table names, column names, internal feature codenames) introduced during editing.
3. Bump `plugins/lexic/.claude-plugin/plugin.json` patch version if a version field exists.
4. If the plugin repo has a test or lint pass, run it and confirm 0 failures.
5. Optionally trigger `/lexic:prompt-engineer` against a sandbox project to confirm the new section is loaded.

**Acceptance criteria**:
- [ ] File diff shows additions only — no deletions or modifications outside the two insertion points.
- [ ] Project-leakage grep returns zero matches for each named term.
- [ ] Plugin tests/lint (if any) pass.
- [ ] Live invocation surfaces the new content.

## Files to Create / Modify / Reference

### Modify

| File | Tasks | Description |
|---|---|---|
| `plugins/lexic/commands/prompt-engineer.md` | T1, T2 | Two additive insertions: Evidence Discipline section + Phase 5 evidence-citation gate. |
| `plugins/lexic/.claude-plugin/plugin.json` (if versioned) | T3 | Patch-version bump. |

### Reference (read, do not modify)

| File | Purpose |
|---|---|
| Lexico's `.lexic/prompt-engineer.md` | Source of the Evidence Discipline rule, including the Spec 10b case study (which stays project-local). |
| Lexico's `.claude/prompts/plugin-diff-prompt-engineer-evidence-discipline.md` | Earlier 4-diff proposal; superseded by this prompt's narrower scope after reading the live skill. |

## Acceptance Criteria (whole feature)

- [ ] `plugins/lexic/commands/prompt-engineer.md` contains the Evidence Discipline section + Phase 5 evidence-citation gate.
- [ ] No existing content in the skill prose changed outside the two insertion points.
- [ ] Plugin version bumped per the repo's versioning convention.
- [ ] PR description references the Spec 10b retrospective and Lexico commit `dcc98e28`.

## Mandatory Guardrails

- **Read `plugins/lexic/commands/prompt-engineer.md` end-to-end before editing.** This prompt's "live state" inventory was captured 2026-05-02; if the file evolved since, re-verify before assuming the inventory is still accurate.
- **Additive only.** No existing section, phase, gate, or template element is removed or behaviorally altered.
- **No Lexico-specific content.** The Spec 10b case study, Lexico Stack, and Lexico guardrails stay in Lexico's project file. Only the abstract principle transfers.
- **Verify after applying.** Re-read the file; if a test suite exists, run it; if possible, do a sandbox invocation.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Skill prose evolved since 2026-05-02 inventory | Task 1 explicitly requires reading the live file before editing. The two insertion points are described relative to anchors ("between intro and Step 1", "at the end of the Phase 5 bullet list") rather than absolute line numbers — so they survive minor drift. |
| Duplicate content between project-local and platform skill during transition | Acceptable: Phase 0 of the skill loads `.lexic/prompt-engineer.md` overlays, so Lexico's local copy continues to apply. After this ships, Lexico's project file can be slimmed in a separate PR. |
| Plugin version not bumped | Final whole-feature acceptance criterion catches this. |
| Stage 2 cleanup (per-project trimming) skipped | Out of scope; tracked separately. The transition state (both files have the section) is correct and harmless during the window. |

## Two-stage rollout (explicit)

This prompt scopes ONLY stage 1 (plugin promotion). Stage 2 (per-project cleanup) is a separate follow-up:

- **Stage 1 (this prompt)**: plugin gets the Evidence Discipline section + Phase 5 gate. No project files modified.
- **Stage 2 (follow-up, per project)**: Once the plugin ships and deploys, each Lexic-using project's `.lexic/prompt-engineer.md` can be slimmed by removing the now-duplicated Evidence Discipline section. Project-specific content (Stack, guardrails, case studies) stays. For Lexico specifically, the cleanup is tracked separately; do not include it in this PR.

The sequencing matters: deleting from project files before the plugin ships creates a coverage gap.
