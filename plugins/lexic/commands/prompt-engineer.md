---
description: Generate a structured implementation prompt for an autonomous workflow from a feature description
argument-hint: "feature description"
---

# Prompt Engineer

Generate a detailed, structured implementation prompt from a high-level feature description, ready for use with `/lexic:run`.

**IMPORTANT: You MUST complete ALL phases and steps below in a single response without stopping or asking for confirmation between phases. The user expects to see the final prompt and next-step options. Only stop early if $ARGUMENTS is empty (Step 1).**

## Step 1: Validate input

If `$ARGUMENTS` is empty, ask the user to describe the feature they want to implement. A good description includes what the feature does and why it matters. **Stop here ONLY if input is missing.**

## Step 2: Generate the prompt

Execute ALL of the following phases sequentially. Do not skip any phase or stop between them.

### Phase 0: Load project customizations
1. Read `.lexic/prompt-engineer.md` if it exists — treat its contents as additional mandatory rules
2. If it does not exist, proceed with the generic process below

### Phase 1: Discover — understand what exists
1. Read `CLAUDE.md` for decisions, architecture, anti-patterns
2. Read `.claude/prompts/` directory listing to learn existing format and calibrate specificity
3. Read `.claude/skills/` for relevant skills
4. Call `dev_get_feature_context` with the feature area name from `$ARGUMENTS`
5. Call `knowledge_query` with keywords from the feature description (`include_learnings: true`)
6. Call `code_query` with key entity names from the feature description to find existing implementations
7. Call `code_trace` on critical entities to understand their dependency footprint (callers, callees, imports)

### Phase 2: Scope — map the feature to the codebase
1. Identify codebase areas affected (UI, API, database, background jobs, etc.)
2. **Use `code_query` to find relevant functions, classes, and modules by name** — indexed lookup, faster than grep
3. **Use `code_trace` to map call chains and dependency paths for affected entities** — pre-indexed relationships
4. **Use `code_module` to understand file structure of files that need changes** — before reading source
5. Read the specific files that would need to change
6. Read adjacent files to learn patterns (e.g., if adding a new page, read an existing page)
7. Identify what needs to be created vs. modified
8. Check for dependencies

**Code graph tools (code_query, code_trace, code_module) provide pre-indexed structural data. Use them BEFORE reading files — they reveal relationships (callers, callees, imports, inheritance) that file reads cannot. This is MANDATORY, not optional.**

**Critical rule:** For every file listed in "Files to Modify" in the output, you must have READ that file. No exceptions.

### Phase 3: Decompose — break into tasks
- Break into tasks, each producing a testable result
- Name with action verbs: "Add X", "Wire Y", "Update Z"
- Identify dependencies between tasks
- Each task should be completable in a single agent session

### Phase 4: Specify — write each task in detail
Each task must include:
1. **What to do** — clear description
2. **Where** — exact file paths
3. **How** — code patterns FROM existing files (not invented), with imports
4. **What NOT to do** — guardrails from CLAUDE.md and .lexic/prompt-engineer.md
5. **Acceptance criteria** — binary pass/fail checks (not "works correctly")

### Phase 5: Validate — quality check
Verify before producing output:
- Every file in "Files to Modify" was actually read
- Every code pattern shown is from an actual file, not invented
- No file paths are assumed — all verified via search or directory listing
- Database columns referenced actually exist (or task includes migration)
- Each acceptance criterion is testable without human judgment
- No task says "figure out" or "decide"
- All mandatory guardrails from `.lexic/prompt-engineer.md` are included
- Build/type check reminder included if code changes are involved

## Step 3: Present the result

Display the structured prompt using this template:

```markdown
# {Feature Title}

## Goal
{One paragraph: what and why}

## The Problem / Context
{What exists today, what's wrong, with evidence from codebase}

## Architecture Context
### Patterns to Follow
{Actual patterns with file provenance}
### What NOT to Do
{Guardrails}
### Known Issues / Gotchas
{Discovered during Phase 2}

## What to Build

### Task 1: {Action Verb + Subject}
**Files:** {paths}
**Pattern:** {from real file}
**Acceptance criteria:**
- [ ] {Binary pass/fail check}

## Files to Create / Modify / Reference
## Acceptance Criteria
## Task Dependency Graph
```

After displaying the prompt:
1. Store a summary via `knowledge_store` (title: "Implementation Prompt: {feature name}")
2. Tell user: task count, critical path, risks identified

## Step 4: Offer next steps

Ask the user:

```
What would you like to do with this prompt?

  1. Start a run — kick off /lexic:run with this prompt
  2. Save to file — write to .claude/prompts/{feature-slug}.md
  3. Edit first — make changes before running or saving
```

**If "Start a run":**
- Save the prompt to `.claude/prompts/{feature-slug}.md` first (create the directory if needed).
- Hand off to `/lexic:run` with the prompt content.

**If "Save to file":**
- Slugify the feature name (lowercase, hyphens, no special chars).
- Create `.claude/prompts/` if it doesn't exist.
- Write to `.claude/prompts/{feature-slug}.md`.
- Confirm the file path.

**If "Edit first":**
- Ask what they want to change. Apply edits and re-present.
