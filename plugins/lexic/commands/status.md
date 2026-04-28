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
4. **Governance state** (Nexus-scoped — always pass `lexicon_id` from CLAUDE.md's `<!-- lexic:integration -->` block):
   - Call `knowledge_query` with `tags: ["constitution"]`, `limit: 5` to surface the active constitution version, any drafts awaiting promotion, and recent constitutional reasoning records that blocked tasks.
   - Call `knowledge_query` with `tags: ["sop", "rule"]`, `limit: 10` to surface active process rules and any rules simulated but not yet promoted.
   - Present as:
     ```
     Nexus governance:
       Active constitution: v{N} ({law_count} laws)
       Drafts awaiting promotion: {count} {if non-zero, list titles}
       Active process rules: {count}
       Rules simulated but not promoted: {count} {if non-zero, list titles}
       Recent task blocks by reasoning: {count, last 7 days}
     ```
   - If any drafts or simulated-but-not-promoted rules exist, these are stalled governance threads worth reviewing.
   - **Never** call these without `lexicon_id` — system-level governance state is operator-only and not relevant to a Nexus status briefing.
5. If all lists are empty (no workflows, runs, or governance state), tell the user no workflows or runs exist yet and suggest using `/lexic:run` to start one.
6. Offer the user the option to inspect a specific run by ID or check a workflow's detailed status by workflow ID (via `workflow_status`).
