---
type: Constraint Ledger
title: Constraint Ledger
description: The consolidated register of standing constraints for the Zantarix Claude Code plugin marketplace, one entry per constraint-admitting decision.
tags: [architecture, constraints, ledger]
generated: { by: architecture-curator/claude-opus-5, at: 2026-08-12T21:58:09Z }
status: stable
---

# Constraint Ledger

This ledger consolidates every standing constraint this project has admitted — inclusive ("adopt X as a requirement") and exclusive ("rule out Y") alike. Each entry names one constraint and cites the Architecture Decision that admitted it.

The materiality gate resolves against this ledger. A change that forecloses an option already foreclosed here proceeds as specification work, citing the entry; a change that newly constrains — foreclosing an option no entry yet covers and some plausible evolution of this project would want — produces a new ADR admitting the constraint before its mechanism lands.

The presence of this concept — a bundle-root `Constraint Ledger` — is this bundle's machine-readable marker that the architecture-documentation regime is in force.

## Knowledge documentation format

Zantarix knowledge bundles, ADR libraries included, are recorded in the Open Knowledge Format (OKF). New and revised knowledge documentation is authored as OKF concepts on the v0.2 house style; other documentation formats are foreclosed for these bundles.

Admitted by [ADR-0002](knowledge/0002-adopt-okf-knowledge-bundles.md); refined to the v0.2 house style by [ADR-0003](knowledge/0003-adopt-okf-v0-2-house-style.md).

## Ratification is interactive

The human-authorisation gates over an architecture bundle — ratifying a decision, adopting the documentation regime, and migrating a corpus into it — run only in a session the architecture curator is driving, with a person present in it. Delegated, scripted, and automated ratification are foreclosed: no path exists by which a decision reaches `Accepted` without a human in the session that marks it.

Admitted by [ADR-0006](knowledge/0006-require-a-curator-session-for-adr-ratification.md).

## A specification's status states conformance

Inside an architecture bundle, a specification's `status` answers the format's lifecycle question about the **contract**: `draft` where the code has not yet met it, `stable` where it has. The field is set explicitly on every specification, and promotion between the two is recorded as a `verified` event. Describing a specification's editorial maturity through `status` is foreclosed — a document still being drafted and a contract awaiting its implementation share one value.

Admitted by [ADR-0007](knowledge/0007-track-specification-conformance-in-status.md).

## Judgment-correcting content stays loaded

Content whose purpose is to correct an agent's in-the-moment judgment is loaded by something other than that judgment: the agent's prompt, a preloaded skill, or a rule the harness puts in scope. Placing it behind a skill the agent must decide it needs is foreclosed, and prompt size is not grounds for the split. Material fired by something checkable against the world, rather than by a trigger the agent has to recognise, stays eligible for an on-demand skill.

Admitted by [ADR-0008](components/0008-keep-judgment-correcting-content-out-of-on-demand-skills.md).
