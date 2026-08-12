---
name: architecture-vocabulary
description: The ubiquitous language of the architecture-documentation regime — decision, constraint, current truth, conformance gap, and the living-tier terms. Preloaded into the architecture-curator and architecture-reviewer so both use one wording; reference material, never an action.
disable-model-invocation: true
---

# Architecture vocabulary

These terms are load-bearing: they decide where material lands, what earns a
ledger entry, and which side of a divergence is wrong. Use them exactly, and
prefer them over the near-synonyms listed — an imprecise term that reads as
compatible with the precise one is how two documents come to disagree without
either looking wrong.

This defines what the words *mean*. Structural conventions for the concept types
— numbering, filenames, one-overview-per-theme, index and log shapes — live in
`okf-guide`, and the materiality test itself lives in `materiality-gate`.

## The decision tier

**Decision**
: A choice recorded in a numbered, immutable Architecture Decision. A decision
  that forecloses an option admits a constraint; many decide something else
  entirely and admit none.
: *Avoid*: commitment, decision surface.

**Constraint**
: An option the project has foreclosed, whether by requiring something or by
  ruling something out. Every constraint has exactly one entry in the constraint
  ledger, citing the decision that admitted it.
: *Avoid*: commitment.

"Commitment" is retired because it was used for both, leaving a topology-shaped
decision a commitment by one reading and not by another. A decision is *about*
whatever it is about — a boundary, a layering, a workflow — and that subject is
description, not a category the taxonomy turns on.

## The living tier

**Living document**
: A concept edited in place as the project changes, as opposed to a decision,
  which is frozen when ratified. Overviews, specifications, and the constraint
  ledger are its kinds.

**Overview**
: A theme's orientation — what the theme holds and how its parts fit, as things
  currently stand. It describes reality, defects included, and never asserts a
  commitment that is still in flight.

**Specification**
: One named subject in depth: a contract, a vocabulary, or a maintained view of
  something the code owns. Separated from an overview by **scope**, not by
  whether it binds.
: *Avoid*: architecture reference.

## Terms that cross both tiers

**Current truth**
: A statement about how the system stands whose falsification would not mean the
  decision was wrong — an enumeration, a format, a parameter, a layout. It
  belongs in the living tier, wherever it is currently written.
: *Avoid*: current-state material.

  The test is what matters, not the examples. "We will use X" stays true until
  reversed; "the variants are A, B and C" goes false when D is added, and nothing
  about the decision was mistaken. The second is current truth, and a concrete
  parameter inside a decision usually is too.

**Conformance gap**
: A divergence between what the project has decided or specified and what the
  code does. Names a mismatch with something specific, where drift names a
  direction.

**Drift**
: Movement of the codebase toward an architectural concern nobody has decided
  about. A trajectory, not a mismatch with any particular decision.
