---
type: Architecture Decision
title: Migrate the Zantarix OKF House Style to v0.2
description: Migrates the Zantarix OKF house style to the v0.2 canonical form for every bundle including ADRs, with ADRs keeping their mid-document References citation section as the sole divergence.
tags: [knowledge, okf, adr, skills]
generated: { by: adr-architect/claude-opus-4-8, at: 2026-07-31T00:00:00Z }
status: Accepted
---

# ADR-0003: Migrate the Zantarix OKF House Style to v0.2

## Status

Accepted (2026-07-31)

## Context

[ADR-0002](0002-adopt-okf-knowledge-bundles.md) adopted the Open Knowledge Format v0.1 as the Zantarix standard for knowledge bundles and restructured ADR libraries as opt-in OKF bundles. It fixed a five-key concept house style — `type`, `title`, `description`, `tags`, `timestamp` — and distilled that house style, together with body provenance under OKF's `# Citations` heading, into the `okf-guide` skill, which the `okf-*` skill suite enforces. The spec was vendored beside `okf-guide` as `SPEC.md`, carrying its upstream provenance frontmatter.

Zantarix ADRs have never used OKF's `# Citations` heading. Since the format's adoption they cite external material through a mid-document `## References` body section, as [ADR-0001](../orchestration/0001-review-dynamic-workflow.md) and [ADR-0002](0002-adopt-okf-knowledge-bundles.md) both do.

Upstream (`GoogleCloudPlatform/knowledge-catalog`) has released OKF v0.2. Per the spec's own §12 versioning rules it is a minor bump, with two deliberate breaking-but-fallback-compatible changes: `timestamp` is superseded by `generated: { by, at }` (an actor plus an ISO datetime recording the last meaningful content change), and the body `# Citations` list is superseded by a `sources` frontmatter list (each entry carrying credibility signals `author`, `usage_count`, and `last_modified`, framed by a `usage_window` sibling) plus per-claim markdown-footnote attribution keyed to `sources[].id`. v0.2 also adds optional trust and lifecycle families — `verified`, `status` (`draft | stable | deprecated`), and `stale_after` — and a new optional concept type, `Attested Computation`, for sanctioned re-runnable computations. A v0.2 consumer still reads a v0.1 document, falling back to `timestamp` and to a `# Citations` body list. The vendored `SPEC.md` has been bumped in place to v0.2.

OKF v0.2 promotes `status` to a first-class frontmatter field with the vocabulary `draft | stable | deprecated`. [ADR-0002](0002-adopt-okf-knowledge-bundles.md) had already made a frontmatter `status` field canonical for ADRs, using the ADR vocabulary `Proposed | Accepted | Deprecated | Superceded`; the two vocabularies collide on the key name and on the value `deprecated`.

The `docs/adr` bundle currently declares `okf_version: "0.1"` in its root `index.md`. Its accepted ADRs — [ADR-0001](../orchestration/0001-review-dynamic-workflow.md) and [ADR-0002](0002-adopt-okf-knowledge-bundles.md) — carry `timestamp` and are immutable: once accepted and committed, an ADR admits only status changes and errata, and no agent may rewrite accepted content on its own initiative.

## References

- [Open Knowledge Format (GoogleCloudPlatform/knowledge-catalog)](https://github.com/GoogleCloudPlatform/knowledge-catalog)
- [OKF SPEC (vendored, v0.2)](../../../plugins/zantarix/skills/okf-guide/SPEC.md)

## Decision

We will adopt OKF v0.2 as the Zantarix standard and migrate the house style to its v0.2 canonical form across every bundle, ADR bundles included. ADRs follow the same v0.2 house style as any other bundle; the sole ADR-specific structural divergence is that they keep citing sources through a mid-document `## References` body section. The format itself is defined by the vendored spec; this ADR records only how Zantarix profiles it.

### The general OKF v0.2 house style

Every knowledge bundle — and the tooling that authors them (`okf-guide`, `okf-init`, `okf-curate`, `okf-index`, `okf-validate`, `okf-migrate-adr`) — uses the v0.2 canonical frontmatter and body conventions:

#### `generated` replaces `timestamp`

A concept records its last meaningful content change as `generated: { by, at }` rather than a bare `timestamp`. `generated.at` is an ISO 8601 datetime; `generated.by` is an actor in the spec's convention — `<producer>/<version>` for agents and tools, `human:<id>` for a person, and `process:<id>` for an automated process.

#### `sources` replaces the body `# Citations` heading

Provenance moves into frontmatter as a `sources` list, each entry carrying `resource` (the only per-entry required field) plus the optional `id`, `title`, and the credibility signals `author`, `usage_count`, and `last_modified`. A `usage_window: { from, to }` sibling frames every `usage_count`. A claim in the body is attributed with a markdown footnote whose label is a `sources[].id`, so attribution is keyed rather than positional and survives the list being reordered.

#### Trust and lifecycle families become available and recommended where applicable

`verified` (a list of `{ by, at }` verification events, from which consumers derive the unverified / machine-confirmed / human-reviewed trust tier), `status` (`draft | stable | deprecated`, defaulting to `stable`), and `stale_after` (an absolute `YYYY-MM-DD` staleness date) are used on concepts where they carry meaning.

#### New bundles are scaffolded at v0.2

`okf-init` writes `okf_version: "0.2"` into the bundle-root `index.md` marker for every newly scaffolded bundle.

### ADR bundles follow the general house style, with two divergences

ADR bundles adopt the general v0.2 house style in full — `generated` replaces `timestamp`, and the trust and lifecycle families are available where they carry meaning for a decision record, exactly as [ADR-0002](0002-adopt-okf-knowledge-bundles.md) framed the ADR library as one OKF bundle among others. Two things diverge from the general house style:

- **Citations.** ADRs cite external material through their existing mid-document `## References` body section, not `sources` frontmatter or footnote attribution. This is the sole structural carve-out.
- **The `status` vocabulary.** The `status` key retains the ADR vocabulary — `Proposed`, `Accepted`, `Deprecated`, `Superceded` — which is not the OKF lifecycle vocabulary (`draft | stable | deprecated`). The two share a key name and the value `deprecated` but mean different things; a v0.2 consumer tolerates the ADR values as unknown enum members under permissive conformance. This is a semantic distinction, not a freeze on the format.

In practice an ADR seldom carries `verified` or `stale_after`: its acceptance is already recorded by `status`, and an obsolete ADR is superseded rather than expired on a date. Nothing freezes those families out; they simply rarely apply to a decision record.

### Writes bring a concept to full v0.2 compliance

Whenever a concept is written — a new concept, or a permitted edit to an existing one — it is written as if authored fresh today: full v0.2 form, with no legacy field carried forward out of habit. For an ADR a permitted write is a new ADR, or the rare status-only or errata edit that immutability allows. Content that is not touched is never bulk-rewritten merely to bump its metadata; existing v0.1-shaped concepts stay in place, and a v0.2 consumer reads them through the spec's fallbacks — a legacy `timestamp` when `generated` is absent, and a legacy `# Citations` body list when `sources` is absent. A bundle therefore converges on v0.2 as its concepts are naturally rewritten, with no disruptive mass migration.

### The `docs/adr` bundle marker bumps to v0.2

The `docs/adr` bundle-root `index.md` marker is set to `okf_version: "0.2"`. The bundle now contains at least one v0.2-featured concept — this ADR, which carries `generated` — and is authored against the v0.2 house style, so `"0.2"` is the honest declaration of its feature ceiling. Its remaining v0.1-shaped ADRs stay consumable under the same-marker fallbacks.

### Attested Computation is available but out of scope

The v0.2 `Attested Computation` concept type — with its `runtime`, `parameters`, `computation`, `executor`, and `attester` keys and the conventional `# Computation` body heading — is available in the vendored spec. Zantarix builds no tooling for it as part of this change and has no bundle that uses it; it is noted as available only.

## Consequences

### Positive

- Machine-written knowledge concepts become self-describing about provenance and trust: `generated` records who produced the content and when, `sources` records what it derived from with objective credibility signals, and `verified` records who confirmed it — none of which the v0.1 shape could express.
- Keyed footnote attribution is robust to the constant rewriting agents do to these documents; a stable `sources[].id` survives list reordering where a positional citation would misattribute silently.
- Staleness and lifecycle become answerable from frontmatter (`stale_after`, `status`), so consumers can flag or gate content without reading the body.
- One house style now spans every bundle, ADRs included, save the single citation carve-out, so contributors and tooling learn one shape rather than two profiles.
- The "writes bring a concept to full compliance" rule converges the corpus on v0.2 as concepts are naturally rewritten, without a disruptive mass migration and without violating the immutability of accepted ADRs.

### Negative

- Within a bundle, concepts written before and after this change coexist in different shapes — a legacy `timestamp` on untouched concepts (including accepted ADRs) alongside `generated` on freshly written ones — so consumers and tooling must handle both keys until the corpus fully converges.
- The v0.2 `sources` and trust families add frontmatter surface that authors and the `okf-*` skills must learn and apply correctly; a partly-populated `sources` entry or a mis-formed actor string is easy to get wrong.
- ADRs still diverge from the general house style on citations, so ADR-authoring paths must special-case the `## References` body section instead of `sources`.

### Neutral

- The `status` key means one thing in ADR bundles (the ADR lifecycle) and another in general bundles (the OKF lifecycle). Permissive conformance makes this safe — a v0.2 consumer tolerates the ADR values as unknown enum members — but the shared key name is a deliberate, documented overload.
- ADRs rarely populate `verified` or `stale_after`: an ADR's acceptance is captured by `status`, and an obsolete ADR is superseded rather than time-expired. The families are available, not mandated.
- `Attested Computation` is available in the vendored spec but unused; adopting it later is a separate decision requiring its own tooling.

## Alternatives Considered

### Stay on OKF v0.1

Keep the vendored spec and the house style pinned at v0.1: no `generated`, no `sources`, no trust or lifecycle families. Rejected because the upstream standard has moved and the v0.2 additions — provenance with credibility signals, a generation actor, verification events, and staleness dates — are exactly the questions an agent-maintained knowledge corpus needs answerable from frontmatter. Staying on v0.1 would leave every future knowledge bundle unable to record where a machine-written concept came from or how much to trust it, for no benefit beyond avoiding a one-time house-style edit.

### Adopt `sources` frontmatter for ADRs too

Have ADRs cite through `sources` frontmatter with per-claim footnote attribution, dropping the `## References` body section, so ADRs match the general house style exactly. Rejected on Maddy's explicit and re-confirmed instruction to keep `## References`, and reinforced by ADR-specific facts: the `## References` mid-document section is already established in [ADR-0001](../orchestration/0001-review-dynamic-workflow.md) and [ADR-0002](0002-adopt-okf-knowledge-bundles.md), reads well inline, and needs none of `sources`' credibility machinery for the handful of external links a decision record cites. ADRs adopt the rest of the v0.2 house style; this alternative concerns only the citation mechanism.

### Bulk-migrate every existing ADR to v0.2

Rewrite all existing ADRs into full v0.2 form — `generated`, plus the trust families where applicable — as part of this change. Rejected because accepted ADRs are immutable and there is no value in churning frozen decision records merely to bump metadata. The "writes bring a concept to full compliance" rule converges the corpus on v0.2 as concepts are naturally rewritten, achieving the same end without violating immutability or producing a large, link-churning diff.

### Keep the `docs/adr` bundle marker at v0.1

Leave the marker at `"0.1"` on the grounds that most ADRs in the bundle remain v0.1-shaped. Rejected because the bundle now contains a v0.2-featured concept and is authored against the v0.2 house style, so `"0.1"` would understate its feature ceiling and mislead a reader into not expecting `generated`. The marker declares what the bundle targets, not the lowest common denominator of its legacy concepts.

### Fold the change into ADR-0002 as errata

Record the v0.2 migration as an erratum on the accepted [ADR-0002](0002-adopt-okf-knowledge-bundles.md). Rejected because errata are reserved for noting that a specific part of an accepted ADR has become functionally incorrect, in at most a paragraph. This migration introduces new frontmatter families, a new available concept type, a scaffold-default version change, and a deliberate ADR-versus-general-bundle divergence — a new decision surface that warrants its own record, not a clarification of the old one.
