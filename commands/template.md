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
3. Offer to show details for any template with `/Lexic:template use <slug>`.

### `create <run-id>`

1. Validate that the argument after "create" is a UUID.
2. Call `workflow_run_status` with the run_id to confirm the run is `completed`. If not, tell the user only completed runs can be templatized and **STOP**.
3. Call `workflow_template_create_from_run` with the run_id.
4. Present the generated template preview to the user:
   - Template name and description (generated from the run)
   - Task sequence with parameterized fields
   - Domain tags
5. Ask the user if they want to adjust anything (name, description, tags) before saving.
6. Call `workflow_template_confirm_create` to finalize.
7. Confirm the template was saved and show its slug for future use.

### `use <slug-or-id>`

1. Call `workflow_template_get` with the slug or ID.
2. Present the template details:
   - Name, description, domain tags
   - Task sequence with descriptions and acceptance criteria
   - Any parameterized fields that need user input
3. Ask the user to provide values for any parameters and confirm they want to start a run.
4. Call `workflow_execute` with the template slug and any parameter values.
5. Hand off to the autonomous run protocol — report the new run_id and proceed as if the user had called `/Lexic:run <run-id>`.
