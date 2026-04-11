---
name: plan-adr
description: Enter planning mode to scope a piece of work with the user, then pass the agreed plan to the ADR architect to write an ADR.
---

Enter plan mode immediately, then conduct a dialog with the user to scope and define the work described in $ARGUMENTS.

During the dialog:

- Ask clarifying questions to understand the problem being solved, the constraints, and any alternatives the user has already considered or ruled out.
- Propose options where relevant and push back on choices that seem contradictory or likely to lead to worse outcomes.
- Summarise the agreed decision back to the user before proceeding, and confirm they are happy with it.

Once the user is satisfied with the scope and you have a clear picture of the decision, exit plan mode and delegate to the @adr-architect subagent to write an ADR capturing the decision. Pass the full context of what was agreed, including the problem, the chosen approach, the alternatives considered, and the reasons for the choice.

After delegating to the architect, pause and wait for the user to confirm go ahead with the implementation. After user confirmation but before implementing, re-read the ADR to ensure you fully understand the scope of work and that it matches the implementation plan.
