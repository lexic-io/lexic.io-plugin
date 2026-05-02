#!/bin/bash
# Guard against destructive SQL. Forces a fresh approval prompt with warning.

INPUT=$(cat)

node -e "
const input = JSON.parse(process.argv[1]);
const query = (input.tool_input?.query || '').replace(/--[^\n]*/g, '').trim();
const destructive = /^\s*(DELETE|UPDATE|DROP|TRUNCATE)\s/i.test(query) ||
                    /\s(DELETE|DROP|TRUNCATE)\s/i.test(query);
if (destructive) {
  const msg = JSON.stringify({
    hookSpecificOutput: {
      hookEventName: 'PreToolUse',
      permissionDecision: 'ask',
      permissionDecisionReason: 'Destructive SQL detected. Confirm the agent has:\\n' +
        '1. Queried Lexic learnings (knowledge_query with include_learnings: true)\\n' +
        '2. Run a SELECT to show affected row count\\n' +
        '3. Used the narrowest possible filter (specific IDs, not broad predicates)\\n\\n' +
        'Query: ' + query.substring(0, 200)
    }
  });
  process.stdout.write(msg);
}
process.exit(0);
" "$INPUT"
