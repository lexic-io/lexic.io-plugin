---
description: Check the status of autonomous runs and their tasks
argument-hint: "run-id (optional — shows all runs if omitted)"
---

# Run Status

Show the current state of Lexic workflow runs.

## If `$ARGUMENTS` is a UUID

1. Call `workflow_run_status` with run_id `$ARGUMENTS`.
2. Call `workflow_task_list` with run_id `$ARGUMENTS`.
3. Present a summary:
   - Run name and status
   - Tasks: completed / in-progress / pending / failed / blocked
   - Credits consumed so far
   - For failed tasks: show the error summary for each
   - For in-progress tasks: show what's currently being worked on
   - For blocked tasks: show what they're waiting on

## If `$ARGUMENTS` is empty or not a UUID

1. Call `workflow_list` and `workflow_run_list` in parallel.
2. Present **Workflows** first (if any exist):
   - Table with: name, status, runs count, words consumed / estimated, created date
   - Highlight any workflows that are `running` or `pending`
3. Then present **Standalone Runs** (runs not grouped under a workflow):
   - Table with: name, status, task progress (e.g., "3/5 done"), and words consumed
   - If any runs are `running` or `paused`, highlight them
4. If both lists are empty, tell the user no workflows or runs exist yet and suggest using `/lexic:run` to start one.
5. Offer the user the option to inspect a specific run by ID or check a workflow's detailed status by workflow ID (via `workflow_status`).
