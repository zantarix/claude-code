# Log

## 2026-08-06

* **Acceptance**: marked [ADR-0004](knowledge/0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md) Accepted — ratified by `human:mscharley`. The errata sweep of prior accepted ADRs found none affected: ADR-0004's rename of `adr-architect` to `architecture-curator` is a nomenclature change, not a functional incorrectness, and ADR-0004 is a topology decision, so it admits no constraint-ledger entry.
* **Initialization**: adopted the architecture-documentation regime — moved the bundle from `docs/adr` to `docs/architecture`, scaffolded the root [Constraint Ledger](constraints.md) (seeded with the OKF knowledge-format commitment from [ADR-0002](knowledge/0002-adopt-okf-knowledge-bundles.md), refined to v0.2 by [ADR-0003](knowledge/0003-adopt-okf-v0-2-house-style.md)), retargeted the root index to the themes and the ledger, and rewrote the sole inbound cross-bundle link (the `okf-guide` skill's reference to ADR-0003).
* **Update**: refined [ADR-0004](knowledge/0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md)'s Acceptance wording — the gate ratifies the document as written, changing only status and verification, so the reviewed text is exactly what freezes.
* **Update**: refined [ADR-0004](knowledge/0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md)'s Adoption wording — a pre-OKF corpus stops adoption cleanly with direction to run `/okf-migrate-adr` first, rather than one human-gated migration firing another.
* **Creation**: proposed [ADR-0004](knowledge/0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md) — split architecture documentation into immutable ADRs (constraint admissions and topology decisions, named as commitments) and living documents (overviews, specifications, and a root constraint ledger that doubles as the regime marker) in per-project `docs/architecture` bundles; adds a shared materiality-gate skill, renames `adr-architect` to `architecture-curator`, distributes a generalised `architecture-reviewer`, and turns `/accept-adr` into a human ratification gate writing `verified`.
* **Update**: added the missing [ADR-0003](knowledge/0003-adopt-okf-v0-2-house-style.md) bullet to the knowledge theme index while reconciling it for ADR-0004.

## 2026-07-31

* **Acceptance**: marked [ADR-0003](knowledge/0003-adopt-okf-v0-2-house-style.md) Accepted once the `okf-*` skills and the adr-architect OKF-mode guidance were updated to the v0.2 house style.
* **Update**: added an erratum to [ADR-0002](knowledge/0002-adopt-okf-knowledge-bundles.md) recording that its v0.1 five-key / `# Citations` house style is superseded by [ADR-0003](knowledge/0003-adopt-okf-v0-2-house-style.md).
* **Creation**: proposed [ADR-0003](knowledge/0003-adopt-okf-v0-2-house-style.md) — migrate the Zantarix OKF house style to the v0.2 canonical form (`generated`, `sources`, trust/lifecycle families) across every bundle including ADRs, with ADRs keeping the mid-document `## References` citation section as the sole divergence; the `docs/adr` bundle marker bumps to `okf_version: "0.2"`.

## 2026-07-24

* **Initialization**: migrated the legacy flat ADR library into an OKF bundle per [ADR-0002](knowledge/0002-adopt-okf-knowledge-bundles.md) — themed subdirectories (`orchestration/`, `knowledge/`), four-digit numbering, frontmatter on every ADR, and this index/log pair replacing the `README.md` table and agent-private inventory.
