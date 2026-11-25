# ADR exemptions

## When to skip an ADR

Do not assume that a trait-signature change needs an ADR. Skip the ADR and go straight to an implementation plan when the fix is a straightforward bug repair. A straightforward repair has no new architectural surface and no alternative designs with meaningfully different trade-offs. It restores the intended behaviour.

Before you invoke `/zantarix:plan-adr`, ask these questions:

- Does this decision introduce a new pattern?
- Does it reject a plausible alternative?
- Does it affect contracts beyond the immediate fix?

If the answer to all three is no, propose a direct implementation plan.

## ADR-only commits and changesets

A commit that changes only files in the architecture library needs no changeset. This covers errata sweeps, ADR body edits, status changes, and specification or overview updates. This documentation is internal and never ships.
