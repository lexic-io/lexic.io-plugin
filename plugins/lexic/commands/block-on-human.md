---
description: Pause a task waiting on a human step (not a failure).
argument-hint: "what the human needs to do"
---

# Block Task on Human

Pause the current in-progress task because it requires a human action to proceed (dashboard toggle, DNS change, webhook secret, external approval, DB migration that needs a human to run it, etc.).

Use this **instead of** `workflow_task_fail` when the approach is correct but execution is waiting on a human step. Blocking preserves `attempt_count`, does not decrement learning confidence, and does not fire a failure-attribution event — so the autonomous run's success signal stays clean.

## When to Use This vs `workflow_task_fail`

| Situation | Tool |
|-----------|------|
| Need a human to toggle a Supabase setting, add a Vercel env var, set DNS, approve in Stripe, run a one-off script with prod credentials | `/lexic:block-on-human` |
| The code didn't compile, the test failed, the approach was wrong, a retry with a different angle might work | `workflow_task_fail` with `should_retry: true` |
| The task is fundamentally unbuildable (missing spec, hard blocker, wrong repo) | `workflow_task_fail` with `should_retry: false` |

**Guardrail:** If a different implementation approach could finish the task without human intervention, that is a `workflow_task_fail`, not a block. Do not use this command to dodge hard tasks.

## Steps

### 1. Identify the task to block

If the caller is inside a `/lexic:run` loop, the current in-progress task is obvious — use the most recent `workflow_task_next` result's `task_id`.

If that is ambiguous:
- Call `workflow_run_status` on the active run.
- Find the task with `status = 'in_progress'`.
- If there is exactly one, use that `task_id`.
- If there are zero or more than one, ask the user which `task_id` to block before proceeding.

### 2. Gather block details

The MCP tool requires three fields and accepts two optional fields. Gather them from `$ARGUMENTS` and conversation context. Ask the user ONLY for fields that cannot be inferred.

Required:
- **blocker_reason**: What the human needs to do, in plain English. One sentence. Example: `"Webhook secret needs to be added to Vercel production env."`
- **required_action**: Concrete steps the human should take. Bullet-style or numbered. Example: `"1. Open https://vercel.com/.../settings/environment-variables  2. Add STRIPE_WEBHOOK_SECRET = whsec_...  3. Redeploy production."`
- **resume_condition**: The signal that tells the next autonomous run the human action is complete. Example: `"The env var is visible in Vercel production and the deploy hash changes."` or `"User confirms here that the toggle is on."`

Optional (include when known):
- **external_ref**: A URL or dashboard link the human will need.
- **estimated_wait**: Human-readable wait estimate, e.g. `"~2 minutes"` or `"depends on Stripe review"`.

If `$ARGUMENTS` already contains a clear block description (like the argument-hint suggests), use it to draft `blocker_reason` + `required_action` and confirm with the user before calling the tool. Do not over-interview.

### 3. Call `workflow_task_block_on_human`

Invoke the MCP tool with:
- `task_id` — from step 1.
- `blocker_reason`, `required_action`, `resume_condition` — from step 2.
- `external_ref`, `estimated_wait` — if available.

The tool will:
- Transition the task to `blocked_on_human` (does NOT touch `attempt_count`).
- Store the block details on the task row.
- Auto-flip the run to `paused` with `paused_reason = 'blocked_on_human:<task title>'` if no other tasks are in progress.
- Skip the failure-learning and attribution side effects.

### 4. Report to the user

Print a compact summary:

```
Task blocked on human action.

  Task: {task title} ({task_id})
  Run:  {run name} → status: {run status}
  Reason: {blocker_reason}

  Human needs to:
    {required_action}

  Resume when: {resume_condition}
  {If external_ref:}  Link: {external_ref}
  {If estimated_wait:} Estimate: {estimated_wait}

  To resume: run `/lexic:resume-task` in this session (or pass the task_id explicitly).
```

Do not proceed to the next task. The run is paused — `workflow_task_next` will return the distinctive blocked-task message until `/lexic:resume-task` is called.

## Example

**Input**: `/lexic:block-on-human "add Stripe webhook secret to Vercel production env"`

**Call**:
```
workflow_task_block_on_human({
  task_id: "9b1d...",
  blocker_reason: "Stripe webhook secret must be present in Vercel production env before the webhook route can be tested end-to-end.",
  required_action: "1. Go to https://vercel.com/{team}/{project}/settings/environment-variables\n2. Add STRIPE_WEBHOOK_SECRET with the value from the Stripe dashboard (Developers → Webhooks → your endpoint → Signing secret).\n3. Redeploy production.",
  resume_condition: "The env var shows up in Vercel production and a fresh deploy exists.",
  external_ref: "https://vercel.com/{team}/{project}/settings/environment-variables",
  estimated_wait: "~2 minutes"
})
```

**Then report the block and how to resume.**
