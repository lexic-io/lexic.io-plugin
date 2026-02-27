---
name: lexic-workflow-hygiene
description: >
  Proactively manage workflow lifecycle: suggest templates after successful runs,
  check for stale or paused runs when resuming sessions, search templates before
  starting new workflows from scratch, and guide users toward the right capture
  tool (learn vs save). Activate when: (1) a run completes successfully,
  (2) a session starts or the user says "where were we", (3) the user describes
  a workflow that sounds like something done before, (4) the user wants to capture
  something and the right tool (learn vs save) isn't obvious.
---

# Workflow Hygiene

This skill teaches you to keep Lexic's workflow system healthy and useful over time. These are behaviors you should do **automatically** without being asked.

## After a Successful Run Completes

When a run finishes with all tasks completed (no failures):

1. Tell the user: "This run completed cleanly. Want to save it as a template so you can reuse this workflow later? Just say `/Lexic:template create <run-id>`."
2. Only suggest this once per run. Don't nag.
3. Skip the suggestion if the run had fewer than 2 tasks — single-task runs aren't worth templatizing.

## When a Session Starts or Resumes

When the user starts a new session and their first message suggests continuing prior work (phrases like "where were we", "let's pick up", "continue", "back to work on X"):

1. Call `workflow_run_list` to check for active runs.
2. If there are runs with status `running`, `paused`, or `blocked`:
   - List them briefly: name, status, task progress.
   - For `paused` runs: ask if the user wants to resume.
   - For `blocked` runs: explain what they're waiting on.
   - For `running` runs that are stale (no task progress in the context): flag them as potentially abandoned and ask if the user wants to continue or cancel.
3. If there are no active runs, proceed normally — don't mention it.

## Before Starting a New Run from Scratch

When the user describes a workflow that sounds like it could match an existing template (phrases like "do the same thing we did for X", "set up auth again", "another migration like last time"):

1. Call `workflow_template_list` to check for matching templates.
2. If a template looks like a match, suggest it: "There's a template called '<name>' that looks similar. Want to start from that instead of building from scratch? `/Lexic:template use <slug>`"
3. If no templates match, proceed with creating a new run normally.
4. Don't over-match. If the user's request is clearly different from available templates, don't force a connection.

## Learn vs Save Guidance

When the user wants to capture information and uses the wrong tool, or when it's ambiguous:

**Redirect to `/Lexic:learn` when:**
- The insight came from debugging or implementation work
- It describes a "gotcha" or unexpected behavior
- It would change how a future task approaches a problem
- The user says things like "next time we should...", "watch out for...", "the trick is..."

**Redirect to `/Lexic:save` when:**
- The content is reference material (meeting notes, specs, research)
- It's a factual record rather than an insight
- It wouldn't change how an autonomous run works

**How to redirect:** Don't lecture. Just say: "That sounds like a run-level learning — want me to use `/Lexic:learn` so it gets surfaced in future runs? Or is this more of a reference note for `/Lexic:save`?" Let the user decide.
