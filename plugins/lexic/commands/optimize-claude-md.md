---
description: Analyze CLAUDE.md and suggest what to move into Lexic or simplify
argument-hint: ""
---

# Lexic: Optimize CLAUDE.md

Analyze the project's CLAUDE.md and recommend what should stay (always-relevant invariants), what should move to Lexic (persistent knowledge), and what should become on-demand commands.

## Steps

### 1. Read CLAUDE.md

Read the full `CLAUDE.md` from the project root. If it doesn't exist, tell the user and suggest `/lexic:setup` instead.

### 2. Categorize every section

Go through each section/block of the CLAUDE.md and classify it into one of four categories:

**A. Keep in CLAUDE.md (Always-relevant invariants)**
Criteria — the model needs this on EVERY interaction:
- Core tech stack declaration (3-5 lines)
- Data model / hierarchy (if it affects every query)
- Critical "never do" rules (security, billing, auth invariants)
- Code conventions that apply to all code (naming, imports, logging)
- Build/deploy requirements

**B. Move to Lexic knowledge base (Persistent decisions)**
Criteria — valuable institutional knowledge, but not needed every turn:
- Specific architectural decisions with rationale
- "We tried X and it didn't work because Y"
- API-specific patterns (only needed when touching that API)
- Historical context about why things are the way they are

**C. Convert to on-demand commands/skills (Reference patterns)**
Criteria — detailed how-to that's only relevant for specific tasks:
- Framework-specific patterns with code examples (auth, D3, etc.)
- Compliance checklists (GDPR, SOC2, etc.)
- Migration procedures
- Detailed error handling patterns for specific subsystems

**D. Remove entirely**
Criteria — adds tokens without value:
- Duplicated information (same rule stated multiple ways)
- Outdated information (references to removed features/patterns)
- Overly verbose explanations of simple concepts
- Information the model already knows (general framework docs)

**E. Promote to Nexus governance (Constitutional law or process rule)**
Criteria — hard normative rules that should be enforced at run-time, not just remembered:
- "Always" / "never" / "must" rules tied to a specific feature area
- Security or compliance invariants ("never log PII", "all writes require auth check")
- Architectural absolutes ("all migrations must be reversible", "no direct fetch in components")
- Rules already stated in CLAUDE.md but routinely violated by autonomous runs (signal that prose isn't enough)

Promotion runs `rule_simulate` first to catch conflicts with the active constitution, then `rule_promote` if clean. **Always Nexus-scoped via `lexicon_id` from CLAUDE.md's integration block — this command never promotes to system-level governance, which is operator-only.**

### 3. Measure the token impact

Estimate the current CLAUDE.md size in approximate tokens (rough: 1 token per 4 chars).

Calculate the projected size after optimization:
- Category A lines only (what remains in CLAUDE.md)
- Percentage reduction

### 4. Present the analysis

```
## CLAUDE.md Optimization Analysis

**Current size:** ~{X} lines (~{Y} tokens loaded every turn)
**Projected size:** ~{A} lines (~{B} tokens) — {percentage}% reduction

### Keep in CLAUDE.md ({count} sections)

| Section | Lines | Why it stays |
|---------|-------|-------------|
| {name} | {n} | {reason — e.g., "Core stack declaration, affects all code generation"} |

### Move to Lexic knowledge base ({count} sections)

| Section | Lines | Suggested action |
|---------|-------|-----------------|
| {name} | {n} | Store as decision/note with tags: [{tags}] |

These will be retrievable via /lexic:what-do-we-know and will surface
automatically when working in related areas.

### Convert to on-demand commands ({count} sections)

| Section | Lines | Suggested command name |
|---------|-------|----------------------|
| {name} | {n} | /project:{command} — invoked when working on {area} |

### Promote to Nexus governance ({count} sections)

| Section | Lines | Suggested promotion |
|---------|-------|---------------------|
| {name} | {n} | Process rule for `{nexus_name}` (rule_simulate → rule_promote) |

These are hard normative rules that should be enforced at runtime by the constitutional reasoner, not just remembered as prose in CLAUDE.md. Always Nexus-scoped — system-level governance is operator-only.

### Remove ({count} sections)

| Section | Lines | Why |
|---------|-------|-----|
| {name} | {n} | {reason — e.g., "Duplicates rule in line 12", "General React knowledge"} |

### Estimated impact

- Tokens saved per turn: ~{number}
- Over a 20-turn session: ~{number} tokens saved
- Information preserved: 100% (moved to Lexic or commands, not deleted)
```

### 5. Offer to execute

Ask the user:

"Would you like me to execute this optimization? I will:
1. Store the 'Move to Lexic' sections as knowledge notes
2. Create command files for the 'Convert to commands' sections
3. For each 'Promote to governance' section: run `rule_simulate` (Nexus-scoped via lexicon_id) and, if clean, prompt you before calling `rule_promote`
4. Slim down CLAUDE.md to the 'Keep' sections only
5. Keep a backup of the original CLAUDE.md as CLAUDE.md.backup

Or would you like to adjust the categorization first?"

### 6. Execute (if approved)

If the user approves:

1. **Backup**: Copy current CLAUDE.md to CLAUDE.md.backup
2. **Store knowledge**: For each "Move to Lexic" section, call `knowledge_store` with appropriate title, content, and tags
3. **Create commands**: For each "Convert to commands" section, create a `.claude/commands/{name}.md` file with the pattern/reference content
4. **Promote governance**: For each "Promote to governance" section, resolve `lexicon_id` from CLAUDE.md's `<!-- lexic:integration -->` block, call `rule_simulate` with the rule and `lexicon_id`, present results, and on user approval call `rule_promote` (also Nexus-scoped). Skip any section that fails simulation; leave it in CLAUDE.md and report the conflict.
5. **Rewrite CLAUDE.md**: Keep only Category A sections, plus the Lexic integration block
6. **Verify**: Read back the new CLAUDE.md and confirm it's valid

## Design Intent

Most CLAUDE.md files grow by accretion — every bug adds a rule, every decision adds a paragraph. This command helps teams periodically prune their CLAUDE.md to keep it focused on what matters every turn, while preserving everything else in Lexic where it's still searchable but not burning tokens on every interaction.

The optimization is conservative by default. When in doubt, a section stays in CLAUDE.md rather than being moved out. The user always reviews and approves before any changes are made.
