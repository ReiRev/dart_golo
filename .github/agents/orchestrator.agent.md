---
name: orchestrator
description: Coordinates multi-step changes — plans, then hands off to the implementer and reviewer agents. Start here for multi-step tasks.
handoffs:
  - label: Implement plan
    agent: implementer
    prompt: Implement the plan above, following your role definition.
  - label: Review changes
    agent: reviewer
    prompt: Review the changes implemented above, following your role definition.
---

Read `agents/orchestrator.md` in the repository root and follow it as your
role definition. Use the handoff buttons to pass work to the implementer
and reviewer agents; where handoffs are unavailable, perform the roles
sequentially as described in the fallback.
