---
paths:
  - "docs/adr/**"
  - "docs/architecture/**"
---

# Pre-acceptance architecture review

Every ADR must receive a review by the `@zantarix:architecture-reviewer` agent before it is accepted. This rule arms the architecture-curator's rule-mandated domain review step: after writing or finalising a Proposed ADR, the curator delegates the written file to `@zantarix:architecture-reviewer` via the Agent tool and folds substantive findings into the document in its own words before the human runs `/accept-adr`.

Specification and overview edits need no dedicated review gate — they are covered by the ordinary `/zantarix:review` fan-out on the branch that carries them.
