# Architecture Decision Register

Big decisions are documented in ADR format. To see what ADRs exist, consult the library's canonical index: `docs/adr/README.md` for a legacy library, the bundle-root `index.md` for an OKF bundle (marked by `okf_version` frontmatter), or `docs/architecture/index.md` under the architecture-documentation regime (marked by a bundle-root `constraints.md` of type `Constraint Ledger`).

Any change under `docs/adr/` or `docs/architecture/` — ADRs, overviews, specifications, the constraint ledger — must be delegated to the `@zantarix:architecture-curator` agent.

When reading an ADR file, always read the whole file. Errata appear at the end of the file which may change the context of the content.

## ADR statuses

- **Proposed** ADRs are still under discussion. Implementation may proceed while an ADR is Proposed.
- **Accepted** ADRs have been ratified by a human — a commitment to the direction, independent of implementation state.
- **Deprecated** ADRs are no longer relevant, but were not specifically replaced with new decisions.
- **Superceded** ADRs are no longer relevant, but have been replaced with a new decision.

## Write an ADR before structural changes

When proposing structural changes (new modules, new patterns, cross-cutting infrastructure), write an ADR first before creating an implementation plan, via the `architecture-curator` agent. In a regime bundle, apply the `zantarix:materiality-gate` skill first: work already covered by a constraint-ledger entry is a specification update (still delegated to the curator), not an ADR.

## Verify existing implementation before scoping ADR work

An ADR that consolidates or formalises existing behaviour usually needs no code changes. Before planning implementation work for such an ADR, check the code for each behaviour it codifies — anything already present needs documentation only — and state the outcome explicitly: "Verified — already implemented; no code changes needed."

## Accepting ADRs

Acceptance is a **human-only gate**: the user runs `/accept-adr` themselves. Never invoke it, suggest invoking it as an automation, or include it as a step in an implementation plan or commit workflow. Acceptance ratifies the ADR **as written** — it changes only the `verified` and `status` frontmatter and the `## Status` line, never the body; refinements happen in the ordinary Proposed flow before the gate. It also records the constraint-ledger entry for constraint admissions in a regime bundle.

Once an ADR has been marked accepted and committed to git, it is immutable. The only exceptions are status updates and the addition of an Errata section at the end with notes about smaller changes affecting the ADR, each linking forward to the ADR that made the change.

## Related Projects

When writing ADRs that reference cursus or other related Zantarix projects, check the ADRs of those related projects for relevant context and prior decisions. Related Zantarix project repositories can be found as siblings of the current project folder (e.g., `../cursus`). The Related Projects section of the library's canonical index lists the known related projects.

## Errata

Errata are the sole responsibility of the `@zantarix:architecture-curator` agent. No other agent or skill should add or suggest errata.

Reviewer agents (`*-reviewer`) must not suggest adding errata to accepted ADRs. If an ADR's *decision* is contradicted, flag it as an architectural concern that may need a new ADR; if *current-truth material* baked into an ADR (call signatures, enumerations, formats, layouts) has drifted, flag it as an extraction candidate for the curator's errata-driven extraction instead — never as a new ADR. Reviewers may, however, flag implementation discrepancies against a `Proposed` ADR — those are inlined into the ADR before acceptance.

## When to skip an ADR

Do not assume a trait-signature change automatically requires an ADR. If the fix is a straightforward bug repair — no new architectural surface, no alternative designs with meaningfully different trade-offs, just restoring intended behaviour — skip the ADR and go straight to an implementation plan. Before invoking `/zantarix:plan-adr`, ask: does this decision introduce a new pattern, reject a plausible alternative, or affect contracts beyond the immediate fix? If not, propose a direct implementation plan instead.

## ADR-only commits and changesets

When a commit only modifies files under the architecture library (errata sweeps, ADR body edits, status changes, specification or overview updates), no changeset is required — this documentation is internal and never ships.
