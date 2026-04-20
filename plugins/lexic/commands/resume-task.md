---
description: Resume a task that was blocked on human action.
argument-hint: "task id (optional — auto-detects the blocked task in the current run)"
---

# Resume Blocked Task

Transition a task from `blocked_on_human` back to `pending` and put its run back into `running`. Use this once the human has completed the action that `/lexic:block-on-human` described.

The task's `attempt_count` is preserved (resuming is not a retry). After resume, the task becomes the next candidate for `workflow_task_next`.

## Steps

### 1. Resolve the `task_id`

**If `$ARGUMENTS` is a UUID**: use it directly as `task_id`.

**Otherwise (no argument, or a non-UUID hint)**:
1. Determine the active run_id from the current session context (e.g., the most recent `/lexic:run` output, the run referenced by the last `workflow_task_next` call, or ask the user).
2. Call `workflow_run_status` with that run_id.
3. Read the `blocked_tasks[]` field on the response (populated when the run is paused with `paused_reason` starting with `blocked_on_human:`).
   - If `blocked_tasks` has exactly one entry, use its `task_id`.
   - If it has multiple entries, present the list to the user (title, blocker_reason, blocked_at) and ask which to resume.
   - If it is empty or absent, tell the user there is nothing to resume on this run and stop.
4. If the user passed a non-UUID hint that matches part of a blocked task's title, prefer that match.

### 2. Optionally gather a `resume_note`

If the user mentioned what they did to unblock the task (in `$ARGUMENTS` or conversation), capture it as `resume_note` — it's saved alongside the original block details and is useful audit context.

If no note is obvious, don't prompt for one unless the user clearly has context to share. The note is optional.

### 3. Call `workflow_task_resume`

Invoke the MCP tool with:
- `task_id` — from step 1.
- `resume_note` — from step 2, if provided.

The tool will:
- Flip the task from `blocked_on_human` → `pending`.
- Merge `resume_note` and `resumed_at` into the task's `block_details` (preserving the original block context for auditability).
- If this was the last blocked task on the run and the run's `paused_reason` starts with `blocked_on_human:`, flip the run from `paused` → `running` and clear `paused_reason`.

### 4. Immediately fetch the next task

Call `workflow_task_next` with the same run_id.

Expected: the resumed task is returned as the next candidate (its `task_id` matches the one you just resumed; its `attempt_count` is unchanged from the pre-block value).

Print a short summary:

```
Task resumed.

  Task: {title} ({task_id})
  Run:  {run name} → status: {run status}

  Next up: {task returned by workflow_task_next}
  Attempt count: {n} (preserved)
```

### 5. Hand off

If the caller is inside a `/lexic:run` loop, return control to that loop so it continues execution on the just-returned task.

If the caller is outside a run loop, tell them: `"Run is back to running. Use /lexic:run <run_id> to continue the autonomous loop, or work this task manually."`

## Edge Cases

- **Task is not `blocked_on_human`** (e.g., already `pending`, `done`, or `failed`): the MCP tool will reject with an `INVALID_STATE` error. Report the actual current status to the user and stop.
- **Run is not paused on human action** (run is `running` or `completed` already): the task transition still succeeds; no run-status change happens. Proceed normally.
- **Multiple blocked tasks, user wants to resume all**: resume them one at a time — run the command once per task_id. Do not batch inside a single call.

## Example

**Input**: `/lexic:resume-task` (no argument, inside an active run)

**Flow**:
1. Call `workflow_run_status({run_id: <active run>})`.
2. Find one entry in `blocked_tasks[]` — title `"Add Stripe webhook secret to Vercel"`, task_id `9b1d...`.
3. Call `workflow_task_resume({task_id: "9b1d...", resume_note: "User confirmed env var is set and production redeployed."})`.
4. Call `workflow_task_next({run_id: <same>})` — returns task `9b1d...` with `status: 'pending'` and the original `attempt_count`.
5. Report resume + next task to the user.
