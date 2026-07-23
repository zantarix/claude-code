# Architecture Decision Register

Big decisions are documented in ADR format in the `docs/adr/` folder. To see what ADRs exist, their titles, statuses, and summaries, consult `docs/adr/README.md` — or `docs/adr/index.md` when the library is an OKF bundle (its root `index.md` carries an `okf_version` marker and `README.md` is retired).

Any changes to the `docs/adr/` folder should be handled by delegating to the `@zantarix:adr-architect` agent.

When reading an ADR file, always read the whole file. Errata appear at the end of the file which may change the context of the content.

## ADR statuses

- **Proposed** ADRs are still under discussion and haven't been implemented yet.
- **Accepted** ADRs have been implemented.
- **Deprecated** ADRs are no longer relevant, but were not specifically replaced with new decisions.
- **Superceded** ADRs are no longer relevant, but have been replaced with a new decision.

## Write an ADR before structural changes

When proposing structural changes (new modules, new patterns, cross-cutting infrastructure), write an ADR first before creating an implementation plan. Use the `adr-architect` agent. The user wants architectural decisions documented and reviewed before code is written.

## Verify existing implementation before scoping ADR work

When planning an ADR that consolidates or formalises existing behaviour, verify that each codified rule is already implemented in the code before scoping implementation work. ADRs that document existing behaviour usually need zero code changes. State the verification result explicitly: "Verified — already implemented; no code changes needed."

### Accepting ADRs

After implementation, an ADR must be marked accepted using the `/accept-adr` skill. This happens automatically as part of the `/zantarix:commit` skill — do not invoke `/accept-adr` manually or include it as a step in an implementation plan.

Once an ADR has been marked accepted and committed to git, it is immutable. The only exceptions to this is further updates to it's status or the addition of an Errata section at the end of the ADR with notes about smaller changes that affect this ADR with a forward link to the ADR that made the change.

## Related Projects

When writing ADRs that reference cursus or other related Zantarix projects, check the ADRs of those related projects for relevant context and prior decisions. Related Zantarix project repositories can be found as siblings of the current project folder (e.g., `../cursus` for the cursus project). The Related Projects section of @docs/adr/README.md (or `docs/adr/index.md` in an OKF-mode library) lists the known related projects and their GitHub URLs.

## Errata

Errata are the sole responsibility of the `@zantarix:adr-architect` agent. No other agent or skill should add or suggest errata.

Reviewer agents (`*-reviewer`) must not suggest adding errata to accepted ADRs. If a code change contradicts an accepted ADR, flag it as an architectural concern that may need a new ADR. Reviewers may, however, flag implementation discrepancies against a `Proposed` ADR — those are inlined into the ADR before acceptance.

## When to skip an ADR

Do not assume a trait-signature change automatically requires an ADR. If the fix is a straightforward bug repair — no new architectural surface, no alternative designs with meaningfully different trade-offs, just restoring intended behaviour — skip the ADR and go straight to an implementation plan.

Before invoking `/zantarix:plan-adr`, ask: does this decision introduce a new pattern, reject a plausible alternative, or affect contracts beyond the immediate fix? If the answer is "no, it just restores intended behaviour by mirroring an existing pattern," propose a direct implementation plan instead.

## ADR-only commits and changesets

When a commit only modifies files under `docs/adr/` (errata sweeps, ADR body edits, status changes), no changeset is required. This applies to projects that track releases via changesets — ADRs are internal documentation and never ship.
