---
description: Record an architectural or implementation decision to Lexic
argument-hint: "brief description of the decision"
---

# Lexic: Log Decision

Record a significant decision so future sessions don't re-litigate it.

## When to Use

- Chose one library/approach over another
- Made an architectural call (caching strategy, auth method, data model shape)
- Decided NOT to do something (and the rationale matters)
- Established a convention that future code should follow
- Discovered a constraint that limits future options

## Steps

### 1. Gather decision details

If the user provided a brief description as the argument, use that as the starting point. Ask clarifying questions ONLY if critical context is missing:

- **What was decided?** (the argument usually covers this)
- **What were the alternatives considered?** (if not obvious, ask)
- **Why this choice?** (the rationale — this is the most valuable part)
- **What would trigger revisiting this?** (optional but valuable)

Do NOT over-interview. If the user gave a clear description like "Use Redis for session storage instead of PostgreSQL because of read latency", that contains the decision, alternative, and rationale — just log it.

### 2. Identify the feature area

Determine which area of the project this decision relates to. Common categories:
- Architecture, Database, API, Authentication, Frontend, Testing, Deployment, Performance, Security, Tooling

### 3. Store the decision

Call `dev_log_decision` with:
- **feature**: The feature area identified in step 2
- **decision**: What was decided (clear, imperative statement)
- **rationale**: Why this choice was made
- **alternatives**: What else was considered (array of strings)
- **revisit_when**: Conditions that would trigger reconsidering (optional)

### 4. Confirm storage

Report back to the user:

```
Decision logged to Lexic.

  Feature: {area}
  Decision: {what}
  Rationale: {why}
  Alternatives considered: {list}
  Revisit when: {conditions, or "no conditions set"}

  This will surface automatically in future sessions when working on {area}.
```

## Examples

**Input**: "Use Tailwind instead of CSS modules for styling"
**Logged as**:
- Feature: Frontend
- Decision: Use Tailwind CSS for all component styling
- Rationale: Team consistency, utility-first approach reduces context switching, built-in responsive design
- Alternatives: CSS Modules, Styled Components, vanilla CSS
- Revisit when: Bundle size exceeds 200KB for styles, or team grows past 5 and naming collisions increase

**Input**: "Don't add GraphQL, REST is fine for now"
**Logged as**:
- Feature: API
- Decision: Continue with REST API, do not add GraphQL layer
- Rationale: Current API surface is small enough that REST is simpler. GraphQL adds complexity without proportional benefit at current scale
- Alternatives: GraphQL (Apollo), tRPC
- Revisit when: API consumers need to fetch deeply nested data regularly, or mobile clients need bandwidth optimization

## What This Command Does NOT Do

- Does not enforce the decision (that's CLAUDE.md's job for hard rules)
- Does not block future changes (decisions can always be revisited)
- Does not require consensus — this logs what ONE person decided, for visibility
