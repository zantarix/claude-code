# Implementation plans

* The final step of an implementation plan should be verification of the changes using the `/verify-code` skill.
* After verification, a plan should explicitly specify to use the `/review` skill in order to do a self-review before returning control to the user.
* When executing an implementation plan, you should never automatically commit the results unless the user explicitly asks for it, for instance in a multi-phase implementation plan.

## Surfacing alternatives

When weighing implementation options, if a standard or idiomatic option exists in the dependency tree or platform conventions, raise it as an explicit question to the user rather than silently dismissing it in the plan's "alternatives considered" section. Verify claimed objections against actual upstream docs/source before treating them as load-bearing.
