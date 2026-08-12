---
type: Overview
title: Knowledge
description: How this project structures the knowledge it keeps — OKF bundles, the two-tier architecture regime, the shape of the ADR lifecycle, and the routes by which rules and memories become distributed content.
tags: [knowledge, okf, adr, regime, rules, distribution]
generated: { by: architecture-curator/claude-opus-5, at: 2026-08-12T21:58:09Z }
status: stable
---

# Knowledge

This theme covers the shape of the project's written knowledge: the format it is
recorded in, the tiers it is divided into, and the paths by which something
learned becomes something distributed.

## Everything is an OKF bundle

Knowledge bundles are directories of markdown *concepts* carrying YAML
frontmatter, self-describing and needing no tooling to read
([ADR-0002](0002-adopt-okf-knowledge-bundles.md)). The house style is OKF v0.2
([ADR-0003](0003-adopt-okf-v0-2-house-style.md)): `generated` records who last
meaningfully changed a concept and when, `sources` carries provenance through
footnote attribution, and `verified`/`status`/`stale_after` carry trust and
lifecycle where they mean anything.

Compliance arrives by writing, not by migration. Any concept written or edited is
brought to full current form; untouched concepts stay as they are and a reader
falls back through the spec's legacy keys. Two ADRs in this bundle still carry the
pre-v0.2 `timestamp` for exactly that reason, and are not defects.

ADRs diverge from the general style in two ways only, both deliberate: they cite
through a mid-document `## References` section rather than `sources` frontmatter,
and their `status` uses the ADR vocabulary (`Proposed`/`Accepted`/`Deprecated`/
`Superceded`) rather than OKF's lifecycle words.

## Two tiers, four types

This bundle operates under the architecture-documentation regime
([ADR-0004](0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md)),
which splits architectural writing by whether it changes:

- **Architecture Decision** — immutable, four-digit numbered, globally sequential
  across themes. Records why direction changed, then freezes.
- **Overview** — living, one per theme. Records the theme's current shape.
- **Specification** — living, named rather than numbered. Carries contracts and
  compact rationale notes; every edit cites its driving decision.
- **Constraint Ledger** — the root singleton, one entry per constraint-admitting
  decision. Its presence at the bundle root is the regime's marker.

The division of labour is that **ADRs document decisions and living documents
document reality**: answering "what is true now" is a read of the living tier, not
a walk of the decision chain. A living document therefore tracks what has landed
in the code, including code implementing a decision the human has not yet
ratified.

Because a specification binds, it can disagree with the code, and
[Maintaining Living Documents](living-documents.md) carries the rule that decides
which side is wrong: the specification yields where a decision authorised the
change, and stands otherwise, leaving the work out of conformance. The rule
assigns a fault on every divergence, and it does so in a bundle where
specifications are routinely written the moment a decision is ratified, ahead of
anything being built.

Which tier a piece of work belongs to is settled by the materiality gate: work
that newly forecloses an option the ledger does not already foreclose needs a
decision first, and everything else is specification work citing the entry that
covers it.

The ledger currently holds four entries — the OKF knowledge-format constraint,
the requirement that ratification be interactive, the reading a specification's
`status` carries, and the rule keeping judgment-correcting content loaded rather
than on demand. Themes are `orchestration/`, `knowledge/`, and `components/`;
cross-links within the bundle are relative. One
specification, the [ticket-to-merge workflow](../ticket-workflow.md), sits at the
bundle root instead of inside a theme: its subject runs across skills, rules, and
several plugins, so filing it under any one theme misdescribed it.

## The ADR lifecycle as it stands

An ADR is drafted by the `zantarix:architecture-curator`, the sole writer of this
bundle — mechanically, not by convention; see the
[orchestration overview](../orchestration/overview.md) for the hook that enforces
it. Every ADR then receives a pre-acceptance review from the
`zantarix:architecture-reviewer`, whose substantive findings the curator folds
into the body in its own words. Specifications and overviews get no dedicated
gate; they ride the ordinary `/zantarix:review` fan-out on the branch carrying
them.

Ratification is a human act, performed through `/accept-adr` — one of the
authorisation gates whose mechanics the
[orchestration overview](../orchestration/overview.md) describes. **Accepted means
the human ratified the direction**, not that anything was built: implementation
runs independently and may precede ratification. From acceptance the document is
immutable, and correction becomes additive rather than editorial.

[ADR-0005](0005-ratify-adrs-in-concert-with-the-human.md) has ratification amend a
document that is wrong about itself, where the human directs the change in
session, and [ADR-0006](0006-require-a-curator-session-for-adr-ratification.md)
admits the curator-session requirement that makes it safe. The
[ADR lifecycle](adr-lifecycle.md) carries the resulting contract, stage by stage:
what each step may change, what ratification records, and how an accepted document
is corrected afterwards.

## How knowledge becomes distributed content

This repository publishes five plugins. Two routes carry knowledge into them:

- **Rules** are markdown directives under `rules/<plugin>/`, kept outside
  `plugins/` because the plugin harness does not distribute them. Consumers add
  this repository as a git submodule and symlink the relevant rule directories
  into their own `.claude/rules/`; this repository does the same to dogfood them.
  The workaround is tracked upstream at
  [anthropics/claude-code#14200](https://github.com/anthropics/claude-code/issues/14200).
- **Memories** promote through review, not automatically.
  `/zantarix:memory-reconciliation` triages accumulated project memories and files
  a GitHub issue when one looks like it should become a distributed rule; the
  project-local `triage-new-memory` skill works that queue, writing rule files only
  for accepted and merged outcomes.

Because prompts are distributed and this bundle is not, a consumer project's
curator never reads these documents. The bundle explains **why the distributed
prompts say what they say**; the prompts themselves stay self-contained.

## What the corpus does not yet cover

The decision records postdate much of what they describe. This project ran for a
while before it kept ADRs at all, and the first
([ADR-0001](../orchestration/0001-review-dynamic-workflow.md)) was written when a
piece of work got deep enough into design to need one. Earlier decisions — and
most decisions about the project's own workflows, as opposed to its code — were
made and implemented without a record.

**The corpus's silence therefore does not mean a question is open.** In a mature
bundle an unadmitted constraint is usually one nobody has committed to; here it is
as often one committed to before there was anywhere to write it down. The
[ticket-to-merge workflow](../ticket-workflow.md) names several: the
prohibition on reading the codebase before planning, the ordering of intake, the
planning fork. Each is enforced and none is admitted.

Backfilling is owed but is not a migration. The bundle converges the way it
converges elsewhere — OKF compliance arrives by writing, and a legacy corpus
converges one erratum at a time — so a missing decision is written when something
needs to lean on it, in the shape of
[ADR-0006](0006-require-a-curator-session-for-adr-ratification.md):
admitting a constraint already in force, honest that nothing is built by accepting
it. Reconstructing a decision nobody is currently relying on risks inventing
deliberation that never happened.

## Decided but not yet built

[ADR-0007](0007-track-specification-conformance-in-status.md) narrows a
specification's `status` to the contract's realisation in code — a reading that
extends the format's lifecycle meaning rather than replacing it, since a contract
the code does not meet is not settled either.
[Maintaining Living Documents](living-documents.md) carries it value by value.

Only the bundle carries it so far; no distributed prompt implements it. The
curator's definition asks for `status` on every living document rather than the
narrower specifications-only claim, and neither the `verified` event on promotion
nor the rule that the value follows the contract appears in any prompt. The
prompts are therefore out of conformance with the reading that specification
states; closing the gap is prompt work, not a change to the specification.

Every other decision in this theme is accepted and implemented.
