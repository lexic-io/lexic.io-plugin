---
description: Generate a structured implementation prompt for an autonomous workflow from a feature description
argument-hint: "feature description"
---

# Prompt Engineer

Generate a detailed, structured implementation prompt from a high-level feature description. The server analyzes your request and returns a prompt ready for use with `/lexic:run`.

## Steps

### 1. Validate input

If `$ARGUMENTS` is empty, ask the user to describe the feature they want to implement. A good description includes what the feature does and why it matters.

### 2. Call the prompt engineer

Call `prompt_engineer` with the user's feature description from `$ARGUMENTS`.

### 3. Present the result

Display the structured prompt returned by the server. This includes the task breakdown, dependencies, acceptance criteria, and any project-specific context the server assembled.

### 4. Offer next steps

Ask the user:

```
What would you like to do with this prompt?

  1. Start a run — kick off /lexic:run with this prompt
  2. Save to file — write to .claude/prompts/{feature-slug}.md
  3. Edit first — make changes before running or saving
```

**If "Start a run":**
- Save the prompt to `.claude/prompts/{feature-slug}.md` first (create the directory if needed).
- Hand off to `/lexic:run` with the prompt content.

**If "Save to file":**
- Slugify the feature name (lowercase, hyphens, no special chars).
- Create `.claude/prompts/` if it doesn't exist.
- Write to `.claude/prompts/{feature-slug}.md`.
- Confirm the file path.

**If "Edit first":**
- Ask what they want to change. Apply edits and re-present.
