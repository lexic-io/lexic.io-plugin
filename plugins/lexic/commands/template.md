---
description: Browse, create, and use workflow templates for reusable task orchestration
argument-hint: "list | create <run-id> | use <slug-or-id>"
---

# Workflow Templates

Templates let you capture a successful workflow run as a reusable blueprint. Instead of describing the same multi-task workflow from scratch each time, templatize it once and reuse it.

## Routing

Parse `$ARGUMENTS` to determine the action:

### `list` (or no arguments)

1. Call `workflow_template_list`.
2. Present templates in a clean table: name, slug, description, number of tasks, and domain tags.
3. Offer to show details for any template with `/lexic:template use <slug>`.

### `create <run-id>`

1. Validate that the argument after "create" is a UUID.
2. Call `workflow_run_status` with the run_id to confirm the run is `completed`. If not, tell the user only completed runs can be templatized and **STOP**.
3. **Capture the governance baseline** active when the source run completed (Nexus-scoped — always pass `lexicon_id` from CLAUDE.md's integration block):
   - Query the active constitution version that was in effect during the run.
   - Query the active process rules count.
   - Record both as template metadata (`source_constitution_version`, `source_rules_count`) so future uses can detect drift.
4. Call `workflow_template_create_from_run` with the run_id, including the governance metadata from step 3 in the template payload.
5. Present the generated template preview to the user:
   - Template name and description (generated from the run)
   - Task sequence with parameterized fields
   - Domain tags
   - **Governance baseline**: constitution v{N} active at source-run completion
6. Ask the user if they want to adjust anything (name, description, tags) before saving.
7. Call `workflow_template_confirm_create` to finalize.
8. Confirm the template was saved and show its slug for future use.

### `use <slug-or-id>`

1. Call `workflow_template_get` with the slug or ID.
2. **Drift checks** (Nexus-scoped — always pass `lexicon_id`):
   - **Governance drift**: compare the template's `source_constitution_version` to the currently active constitution. If they differ, run `constitution_simulate` with the template's task definitions against the current constitution to surface any new conflicts. Present findings to the user before proceeding.
   - **Code-graph drift** (skip for no-code Nexuses or unindexed codebases): for each code entity referenced in the template's task definitions (function names, file paths, modules), run `code_query` to verify it still exists. Flag any missing entities — the template may be stale.
3. Present the template details to the user:
   - Name, description, domain tags
   - Task sequence with descriptions and acceptance criteria
   - Any parameterized fields that need user input
   - **Drift report** (from step 2): governance compatibility + missing code entities
4. Ask the user to provide values for any parameters and confirm they want to start a run despite any drift findings.
5. Call `workflow_execute` with the template slug and any parameter values.
6. Hand off to the autonomous run protocol — report the new run_id and proceed as if the user had called `/lexic:run <run-id>`.
