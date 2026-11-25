---
paths:
  - "docs/adr/**"
  - "docs/architecture/**"
---

# Pre-acceptance architecture review

The `@zantarix:architecture-reviewer` agent must review every ADR before the user accepts it. This rule activates the architecture-curator's rule-mandated domain review step.

After the curator writes or finalises a Proposed ADR, the curator must do these steps in order:

1. Delegate the written file to `@zantarix:architecture-reviewer` with the Agent tool.
2. Add the substantive findings to the document in its own words.
3. Tell the human that the ADR is ready. The human then runs `/accept-adr`.

Specification and overview edits need no dedicated review gate. The ordinary `/zantarix:review` fan-out on the branch that carries them covers these edits.
