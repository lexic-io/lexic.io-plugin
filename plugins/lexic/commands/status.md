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

1. Call `workflow_run_list` to get recent runs.
2. Present a table of runs with: name, status, task progress (e.g., "3/5 done"), and credits consumed.
3. If any runs are `running` or `paused`, highlight them.
4. Offer the user the option to inspect a specific run by ID.
