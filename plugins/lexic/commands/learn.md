---
description: Record a learning that will be served as context in future autonomous runs
argument-hint: "what you learned and why it matters"
---

# Record Learning

Capture a specific, actionable learning that should influence future autonomous runs. This is different from `/lexic:save` — saved knowledge is for general reference, while learnings are actively assembled into the context package when runs work on related features.

Use this when you've figured something out **outside** of a run and want future runs to benefit from it.

## Steps

1. Take `$ARGUMENTS` as the raw learning.
2. Assess the quality against these criteria:
   - **Specific**: Does it name concrete things (files, functions, error messages, versions)?
   - **Actionable**: Could a future task change its approach based on this?
   - **Scoped**: Is it clear when this learning applies and when it doesn't?

3. If the learning is vague (e.g., "auth is complicated" or "watch out for the database"), ask the user to add specifics. Prompt with:
   - What exactly happened?
   - What file, function, or system was involved?
   - What should a future task do differently because of this?

4. Once the learning is specific enough, ask the user:
   - What feature or component does this relate to? (used for context matching)
   - How important is this? (`critical` = must always surface, `useful` = surface when relevant)

5. Call `workflow_learning_create` with:
   - `content`: The learning, formatted clearly
   - `feature_refs`: Array of feature or component names this relates to (e.g. `["billing", "oauth"]`)
   - `category`: The type of learning (e.g. `gotcha`, `best_practice`, `security`, `general`)
   - `context_tags`: Array of tags for context matching (e.g. `["supabase", "rls"]`)
   - `confidence`: 1.0 for critical learnings, 0.5 for useful ones

6. Confirm what was recorded.

7. **Suggest governance promotion (Nexus-scoped only):** if `confidence` is 1.0 (critical) AND the learning reads as normative ("always X", "never Y", "must Z", "from now on"), ask:

   > "This is a critical normative learning for `{nexus_name}`: '{learning}'.
   > Promote to a process rule so future runs can't ignore it? (will run `rule_simulate` first)"

   If the user accepts:
   - Resolve `lexicon_id` from CLAUDE.md's `<!-- lexic:integration -->` block.
   - Call `rule_simulate` with the proposed rule and `lexicon_id` (always pass it — this command never targets system-level governance).
   - Present verdict and any conflicts; on clean simulation, offer `rule_promote` (also Nexus-scoped).

   For non-critical or non-normative learnings, skip silently.

## When to Use Learn vs Save

| Situation | Use |
|-----------|-----|
| "Supabase RLS silently fails if you join auth.users" | `/lexic:learn` — this should change how future runs write RLS policies |
| "Meeting notes from the API design review" | `/lexic:save` — reference material, not a run-level insight |
| "The billing webhook needs idempotency keys" | `/lexic:learn` — future runs touching billing should know this |
| "List of competitor features we analyzed" | `/lexic:save` — research, not an implementation learning |
