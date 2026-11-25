# Implementation plans

* The final step of every implementation plan is verification of the changes with the `/verify-code` skill.
* After verification, the plan must include a self-review with the `/zantarix:review` skill. Do this before you return control to the user.
* Never commit the results of an implementation plan automatically. Commit only when the user asks, for example in a multi-phase implementation plan.

## Surfacing alternatives

When you weigh implementation options and a standard or idiomatic option exists in the dependency tree or platform conventions, ask the user about it explicitly. Do not dismiss it silently in the plan's "alternatives considered" section. Check each claimed objection against the upstream documentation or source. Treat an objection as a deciding reason only after that check.

## Scope discipline

Sometimes you cut or defer one deliverable for a reason, such as "no consumer in v1", YAGNI, or too speculative. Before you finalize scope, apply the same test to every sibling item in the same change. After a scope cut, restate its criterion. Check the remaining in-scope items against it. Put all items that fail the criterion into the one deferral.

A subsystem can be designed on purpose as a provider-neutral abstraction but have only one concrete implementation today. In that case, write new work against the abstraction, not against the single current backend. This applies to tool surfaces, trait extensions, ADR narrative, and security-bundle text. Name the concrete backend only as today's implementation detail.
