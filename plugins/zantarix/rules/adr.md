# Architecture Decision Register

Document architectural decisions in ADR format. To see which ADRs exist, read the library's canonical index. Use the file for your library type:

- `docs/adr/README.md` for a legacy library.
- The bundle-root `index.md` for an OKF bundle, marked by `okf_version` frontmatter.
- `docs/architecture/index.md` under the architecture-documentation regime, marked by a bundle-root `constraints.md` of type `Constraint Ledger`.

Delegate any change under `docs/adr/` or `docs/architecture/` to the `@zantarix:architecture-curator` agent. This covers ADRs, overviews, specifications, and the constraint ledger.

Always read an ADR file in full. Errata appear at the end of the file and can change the meaning of the content.

## ADR statuses

- **Proposed** ADRs are under discussion. Implementation can proceed while an ADR is Proposed.
- **Accepted** ADRs record a human's ratification. They commit to the direction, independent of implementation state.
- **Deprecated** ADRs are no longer relevant. No new decision replaced them.
- **Superceded** ADRs are no longer relevant. A new decision replaced them.

## Write an ADR before structural changes

When you propose structural changes (new modules, new patterns, cross-cutting infrastructure), write an ADR first through the `architecture-curator` agent. In a regime bundle, apply the `zantarix:materiality-gate` skill first. A constraint-ledger entry can already cover the work. In that case the work is a specification update, not an ADR. The curator still performs the update.

## Verify existing implementation before scoping ADR work

An ADR that consolidates or formalises existing behaviour usually needs no code changes. Before you plan implementation work for such an ADR, check the code for each behaviour that the ADR codifies. Behaviour that already exists needs documentation only. State the outcome explicitly: "Verified — already implemented; no code changes needed."

## Accepting ADRs

Acceptance is a **human-only gate**. The user runs `/accept-adr` in a curator session, and the skill enforces this. Never include it as a step in an implementation plan or commit workflow.

After an ADR is marked accepted and committed to git, it is immutable. There are two exceptions:

- Status updates.
- An Errata section at the end of the file, with notes about smaller changes that affect the ADR. Each note links forward to whatever now carries the correct position. That is the ADR that made the change. If no decision drove the change, it is the living document or work item that carries the position.

## Related Projects

When you write ADRs that reference other related projects, check the ADRs of those projects for relevant context and prior decisions. The Related Projects section of the library's canonical index lists the known related projects.
