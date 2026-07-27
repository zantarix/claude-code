---
name: plan-adr
description: Enter planning mode to scope a piece of work with the user, then pass the agreed plan to the ADR architect to write an ADR.
---

Enter plan mode immediately, then conduct a dialog with the user to scope and define the work described in $ARGUMENTS.

Start by familiarising yourself with any `CONTEXT.md` or `CONTEXT-MAP.md` file that exists in this repo if you haven't already loaded them.

ADRs are long term commitments to a project direction and must be fully researched. The ADR format will expect a list of references where applicable. Only the smallest most targeted ADRs warrant no references at all. If external projects are involved in the decision then references to external documentation validating claims about that project are required.

During the dialog:

- Interview the user relentlessly about every aspect of this until you reach a shared understanding. Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.
- Ask the questions one at a time, waiting for feedback on each question before continuing. Asking multiple questions at once is bewildering.
- If a fact can be found by exploring the environment (filesystem, tools, etc.), look it up rather than asking the user. The decisions, though, are theirs — put each one to them and wait for their answer.
- Propose options where relevant and push back on choices that seem contradictory or likely to lead to worse outcomes.
- Summarise the agreed decision back to the user before proceeding, and confirm they are happy with it.
- Do not act on it until the user confirms you have reached a shared understanding.
- Ask the user if they want an implementation plan as well or not. Some ADR's may be small enough to implement immediately, but others may be large enough to warrant implementing in parts after the relevant architectural level decisions have been made.

Your plan should explicitly note to not automatically accept the ADR directly after implementation.

Once the user is satisfied with the scope and you have a clear picture of the decision, exit plan mode and delegate to the `@zantarix:adr-architect` subagent to write an ADR capturing the decision. Pass the full context of what was agreed, including the problem, the chosen approach, the alternatives considered, and the reasons for the choice.

If the user asked for an implementation plan as well, then after delegating to the architect, pause and wait for the user to confirm go ahead with the implementation. After user confirmation but before implementing, re-read the ADR to ensure you fully understand the scope of work and that it matches the implementation plan.
