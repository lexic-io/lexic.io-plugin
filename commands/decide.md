---
description: Record an architectural or technical decision with full context
argument-hint: "brief description of what was decided"
---

# Log Decision

Record a technical decision so future sessions and autonomous runs can follow it.

## Steps

1. Parse `$ARGUMENTS` to understand the decision.
2. Ask the user clarifying questions if needed:
   - What feature or component does this relate to?
   - What alternatives were considered?
   - Under what conditions should this be revisited?
3. Call `dev_log_decision` with:
   - `feature`: The feature or component name
   - `decision`: What was decided (use `$ARGUMENTS` as the starting point)
   - `rationale`: Why this choice was made
   - `alternatives`: Other options considered and why they were rejected (if provided)
   - `revisit_if`: Conditions that would trigger reconsidering (if provided)
4. Confirm the decision was recorded and show the user what was saved.
