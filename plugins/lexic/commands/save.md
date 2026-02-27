---
description: Save a finding, insight, or note to Lexic's knowledge base
argument-hint: "what to remember"
---

# Save Knowledge

Quickly capture something worth preserving in the knowledge base.

## Steps

1. Take `$ARGUMENTS` as the content to save.
2. Infer a concise title from the content.
3. Call `knowledge_store` with:
   - `title`: A short, descriptive title
   - `content`: The full content from `$ARGUMENTS`, formatted in markdown if appropriate
4. Confirm what was saved and show the generated title.

If `$ARGUMENTS` is vague or very short, ask the user to elaborate — knowledge entries are more valuable with specific details and context.
