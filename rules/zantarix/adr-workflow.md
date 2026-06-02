# ADR workflow

## Write an ADR before structural changes

When proposing structural changes (new modules, new patterns, cross-cutting infrastructure), write an ADR first before creating an implementation plan. Use the `adr-architect` agent. The user wants architectural decisions documented and reviewed before code is written.

## Scan Proposed ADRs before designing a new feature

When designing a new feature, scan `docs/adr/` for ADRs with status `Proposed` (not just `Accepted`) that touch overlapping subsystems. The new design must either depend on them, work around them, or explicitly note the conflict. Check `git log docs/adr/` and the README index to surface recent additions.

**Why:** Proposed ADRs are upcoming commitments. Ignoring them produces designs that immediately rot when the proposed decision lands.

## Pause before accepting an ADR

After completing an ADR implementation (code + tests + verify-code + reviewers), pause and report. Do NOT immediately delegate to the adr-architect to run `/accept-adr`, and do NOT commit. The user reviews first. The "accept just before commit" ordering is correct but the user is the trigger.

## Verify existing implementation before scoping ADR work

When planning an ADR that consolidates or formalises existing behaviour, verify that each codified rule is already implemented in the code before scoping implementation work. ADRs that document existing behaviour usually need zero code changes. State the verification result explicitly: "Verified — already implemented; no code changes needed."

## ADR-only commits and changesets

When a commit only modifies files under `docs/adr/` (errata sweeps, ADR body edits, status changes), no changeset is required. This applies to projects that track releases via changesets — ADRs are internal documentation and never ship.
