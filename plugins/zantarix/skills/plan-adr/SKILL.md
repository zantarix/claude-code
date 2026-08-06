---
name: plan-adr
description: Enter planning mode to scope a piece of work with the user, then pass the agreed plan to the architecture curator to write an ADR.
---

Enter plan mode immediately.

Start by familiarising yourself with any `CONTEXT.md` or `CONTEXT-MAP.md` file that exists in this repo if you haven't already loaded them — this gives you the project's terminology before you start asking questions, so you speak the same language as the user rather than interviewing them in generic terms.

If the project's architecture bundle is under the architecture-documentation regime (a bundle-root `constraints.md` of type `Constraint Ledger`, conventionally at `docs/architecture/`), apply the materiality gate before scoping an ADR at all: invoke the `zantarix:materiality-gate` skill via the Skill tool and test the work against the bundle's constraint ledger and overviews. Work that does not newly constrain the project is specification work — plan it as a delegation to the `@zantarix:architecture-curator` agent to update the relevant specification (citing its covering ledger entry), with no ADR. Surface contested materiality to the user rather than settling it.

ADRs are long term commitments to a project direction and must be fully researched. The ADR format will expect a list of references where applicable. Only the smallest most targeted ADRs warrant no references at all. If external projects are involved in the decision then references to external documentation validating claims about that project are required.

Then invoke the `zantarix:deep-dive` skill via the Skill tool to scope and define the work described in $ARGUMENTS with the user.

Once `zantarix:deep-dive` reports back the shared understanding, ask the user if they want an implementation plan as well or not. Some ADR's may be small enough to implement immediately, but others may be large enough to warrant implementing in parts after the relevant architectural level decisions have been made.

Your plan should explicitly note that the ADR is never accepted as part of implementation: acceptance is a human-only gate via `/accept-adr`, and implementation may proceed while the ADR is still Proposed.

Once the user is satisfied with the scope and you have a clear picture of the decision, exit plan mode and delegate to the `@zantarix:architecture-curator` subagent to write an ADR capturing the decision. Pass the full context of what was agreed, including the problem, the chosen approach, the alternatives considered, and the reasons for the choice.

If the user asked for an implementation plan as well, then after delegating to the curator, pause and wait for the user to confirm go ahead with the implementation. After user confirmation but before implementing, re-read the ADR to ensure you fully understand the scope of work and that it matches the implementation plan.
