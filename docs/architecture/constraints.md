---
type: Constraint Ledger
title: Constraint Ledger
description: The consolidated register of standing architectural commitments for the Zantarix Claude Code plugin marketplace, one entry per constraint-admitting decision.
tags: [architecture, constraints, ledger]
generated: { by: architecture-curator/claude-opus-4-8, at: 2026-08-06T00:00:00Z }
---

# Constraint Ledger

This ledger consolidates every standing architectural commitment this project has admitted — inclusive ("adopt X as a requirement") and exclusive ("rule out Y") alike. Each entry names one commitment and cites the Architecture Decision that admitted it.

The materiality gate resolves against this ledger. A change that forecloses an option already foreclosed here proceeds as specification work, citing the entry; a change that newly constrains — foreclosing an option no entry yet covers and some plausible evolution of this project would want — produces a new ADR naming the commitment before its mechanism lands.

The presence of this concept — a bundle-root `Constraint Ledger` — is this bundle's machine-readable marker that the architecture-documentation regime is in force.

## Knowledge documentation format

Zantarix knowledge bundles, ADR libraries included, are recorded in the Open Knowledge Format (OKF). New and revised knowledge documentation is authored as OKF concepts on the v0.2 house style; other documentation formats are foreclosed for these bundles.

Admitted by [ADR-0002](knowledge/0002-adopt-okf-knowledge-bundles.md); refined to the v0.2 house style by [ADR-0003](knowledge/0003-adopt-okf-v0-2-house-style.md).
