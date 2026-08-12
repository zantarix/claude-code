---
type: Architecture Decision
title: Split Architecture Documentation into Immutable ADRs and Living Documents
description: Replaces the single immutable ADR shape with per-project architecture bundles of immutable ADRs over living overviews, specifications, and a root constraint ledger — gated by a shared materiality test, written by a sole curator, policed by a distributable reviewer, and accepted only through a human ratification gate.
tags: [knowledge, adr, okf, architecture, agents, skills]
generated: { by: adr-architect/claude-fable-5, at: 2026-08-06T00:00:00Z }
verified: { by: human:mscharley, at: 2026-08-06T00:00:00Z }
status: Accepted
---

# ADR-0004: Split Architecture Documentation into Immutable ADRs and Living Documents

## Status

Accepted (2026-08-06)

## Context

### One immutable shape carries every kind of architectural writing

Zantarix projects document architecture exclusively through per-project ADR libraries — OKF bundles since [ADR-0002](0002-adopt-okf-knowledge-bundles.md), on the v0.2 house style since [ADR-0003](0003-adopt-okf-v0-2-house-style.md) — holding a single concept type, the Architecture Decision. Every ADR is immutable once accepted: the only permitted changes are status updates and errata. Acceptance rides the commit workflow — `/accept-adr` runs automatically inside `/zantarix:commit` when implementation lands — and the project rules define `Accepted` as "has been implemented". The `adr-architect` agent is each library's sole writer, enforced by a guard hook.

### The largest corpus shows the shape under strain

The private agent project's corpus holds 111 ADRs averaging roughly 4,100 words (median 3,555; eleven under 2,000), against the one-to-two-page record the ADR literature describes. Human reviewers report struggling with documents at this length.

Supersession is nearly absent while errata are pervasive: 4 of the 111 are Superceded, 77 carry errata, and several carry ten or more entries. The errata are dominated by one pattern — an accepted ADR embedded an enumeration (an event vocabulary, a field list, a file layout), the enumeration grew, and each growth produced a paragraph ending "only the enumeration no longer holds as written". That corpus's saved-session ADR (Agent ADR-0022) carries four errata of exactly this kind. Older ADRs sit half-obsolete with no representable status: a later decision can only adjudicate a predecessor's parts in prose — its event-stream ADR (Agent ADR-0110) devotes a section to declaring "two of its sub-decisions are superseded" while a third "survives and is finally implemented" — and cross-references have begun addressing units smaller than a file ("ADR-0100 Decision 7") that the format does not define.

### Four kinds of writing are being forced into the one shape

The oversized documents decompose into distinguishable kinds. Agent ADR-0022 bundles a feature's every choice — persistence strategy, serialisation format, record vocabulary, metadata placement, directory layout, session identity, locking mechanism — into one document, alongside the enumerations those choices produce. Agent ADR-0110's Context is a multi-thousand-word audit of the codebase's present state, assembled fresh from the code because no maintained description of the system's shape exists for it to cite. Mechanism-level choices with local blast radius receive the same full apparatus as project-defining commitments. Only one of these kinds — the decision itself — has properties immutability serves; the others change with the system, and the errata channel is where that change escapes.

### Living documents and constraint decisions already exist, unnamed

The pressure has produced informal artefacts. The agent bundle contains `workspace-structure.md` — a crate-dependency graph documented as "kept current", carrying a locally coined type `Architecture Reference` with no defined standing. The agent project's architecture reviewer holds a hand-written project-context section summarising the intended shape of the codebase, which goes stale like any copy; that reviewer exists in one project and has been judged too project-specific to distribute.

Constraint decisions, meanwhile, land implicitly. The agent project ruled out Windows support by adopting POSIX signal handling inside a feature decision; no document names the commitment, and later unix-only choices have nothing to cite. Materiality is demonstrably project-relative: a filesystem dependency is unremarkable in the agent project, while the private API project deliberately backs cursus's filesystem traits with an in-memory GitHub API implementation, making the same dependency contested ground there.

### What the format and tooling afford

OKF v0.2 ([ADR-0003](0003-adopt-okf-v0-2-house-style.md)) provides `generated`, `verified`, `status`, and `stale_after`; ADRs have to date rarely used `verified`, their acceptance being carried by `status` alone. A concept's `type` is a descriptive string, not an enum. The spec restricts frontmatter on the bundle-root `index.md` to `okf_version` alone — indexes are otherwise frontmatter-free as a spec consideration — and `/okf-index` rebuilds a directory index wholesale from concept frontmatter. The `okf-*` skills are general bundle tooling serving multiple bundle families: the agent project's `docs/security/` bundle is curated by its own owner agent through the same skills.

The `adr-architect`'s authoring procedure already writes sections in a fixed order — Decision before Context, one section per edit — adopted because generated text stays disciplined when checked against a referent that already exists on the page, where in-the-moment judgment during writing does not.

## References

- [Documenting Architecture Decisions — Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [MADR — Markdown Architectural Decision Records](https://adr.github.io/madr/)
- [Design Docs at Google](https://www.industrialempathy.com/posts/design-docs-at-google/)
- [OKF SPEC (vendored, v0.2)](../../../plugins/zantarix/skills/okf-guide/SPEC.md)

## Decision

Zantarix projects will document their architecture in a single OKF bundle at `docs/architecture`, holding two tiers of concept: **immutable ADRs** and **living documents** carrying current truth. An ADR records why the project changed direction, dated and frozen; the living documents record where the project stands, edited in place. Answering "what is true now" will be a read of the living tier, never a walk of the delta chain.

### Four concept types

#### Architecture Decision — the records

ADRs keep their established profile: four-digit globally sequential numbering, the existing body template and status vocabulary, immutability from acceptance. What changes is their subject. An ADR is one of two kinds:

- A **constraint admission** — the adoption of a standing commitment, inclusive ("adopt POSIX as a requirement") or exclusive ("rule out Windows support"). Ruling something out constrains the project exactly as ruling something in does, so exclusions are admitted with the same ceremony.
- A **topology decision** — a structural arrangement: a boundary, a layering, a canonical flow.

ADRs are named as commitments. The feature that occasions a constraint is Context material; the mechanism that exploits it is specification material. Each ADR covers exactly one decision surface, so a future reversal supersedes one file.

#### Overview — the shape

A living, named concept (conventionally `overview.md`, one per theme) recording the current shape of its theme: the pre-existing facts about the system that an ADR's Context would otherwise have to establish. Overviews are grown on demand — created the first time a decision needs one — and use the project's domain language without redefining it.

#### Specification — the contracts

Living, named concepts carrying the theme's current contracts: formats, vocabularies, invariants, protocols, and enumerations — the material that grows as the system does — plus compact **rationale notes** recording the reasoning behind non-obvious mechanism choices. Every specification edit cites the ADR that drives it.

#### Constraint Ledger — the consolidation

A singleton, `constraints.md` at the bundle root, consolidating every standing commitment: one entry per constraint-admitting ADR, citing it, exclusions included. The ledger is the reference the materiality gate resolves against, and its presence — a bundle-root concept of type `Constraint Ledger` — is the bundle's machine-readable regime marker. The `docs/architecture` path is the human-facing convention; tooling trusts the ledger.

### The materiality gate

A change **newly constrains** when it forecloses an option that (a) the ledger does not already foreclose, and (b) some plausible evolution of this project would want — judged from the bundle's overviews and the project's stated goals, never from general practice, because materiality is project-relative. Work that newly constrains produces an ADR naming the commitment before its mechanism lands in a specification. Work covered by an existing ledger entry proceeds as specification work, citing the entry, with the reasoning kept as a rationale note. The tiebreaker: a rationale note that grows an alternatives analysis is claiming to be a decision, and is promoted to an ADR. Contested or unclear materiality is surfaced to the human, and the resolution — in either direction — lands in the ledger so it is never re-litigated.

The gate ships as a dedicated skill, preloaded into both the curator and the reviewer, so both apply one wording and drift is structurally impossible.

### The writing procedure

Authoring an ADR gains one ordered step: **the theme overview is brought current before Context is written**. Context then contains only the pressures specific to the decision, plus citations into the overview. This extends the established Decision-first ordering mechanism with a second pre-existing referent, so current-state material is captured in its living home the first time it is written rather than regenerated inside every ADR that needs it.

### Two agents

#### `architecture-curator`

The `adr-architect` agent, renamed to match its widened remit, remains the **sole writer of the bundle**: ADRs, overviews, specifications, and the ledger all route through it, and implementing agents delegate exactly as they do for errata today. Regime policy — the materiality gate, the citation discipline, the overview step, ledger upkeep — lives in the curator's definition and the shared gate skill; the general `okf-*` skills keep their bundle-agnostic mechanics, gaining only an additive architecture-profile section in `okf-guide`. The curator stays dual-mode, continuing to serve un-migrated `docs/adr` bundles unchanged. The `generated.by` actor becomes `architecture-curator/<model>`, leaving `adr-architect/*` on untouched concepts as a visible pre-regime era marker.

#### `architecture-reviewer`

A generalisation of the agent project's architecture reviewer, distributed in the `zantarix` plugin. It is language- and project-agnostic by construction: it reads the bundle root (ledger and index) and the overviews and specifications of every theme a change touches, and takes **all** project specifics — vocabulary, load-bearing structures, calibration — from the bundle rather than from a hand-written prompt section. Its trajectory remit (drift, parallel structure, responsibility accretion) carries over, and it gains the regime's gate-policing duty in both directions: a specification edit that newly constrains without an admitting ADR, and an ADR carrying enumerations that belong in a specification. Contested calls route to the human per its existing severity conventions.

### Acceptance is human ratification

`/accept-adr` becomes a human gate: it leaves the commit workflow, carries `disable-model-invocation`, and is run by a person. Acceptance records verification on the ADR — `verified: { by: human:<forge-username>, at: ... }`, where the id is the user's username on the project's forge — and, for a constraint-admitting ADR, writes the ledger entry in the same operation. The gate ratifies the document **as written**: acceptance changes the ADR's status and verification record and nothing else, so what the human reviewed is exactly what freezes. **`Accepted` means a human has ratified the direction.** Implementation proceeds independently, possibly while the ADR is still `Proposed`, with review findings inlined into the proposed ADR under the existing refinement rule. Immutability begins at acceptance, unchanged. Implementation is not a property of an ADR at all: a commitment is ratified, and implementations leverage or are bound by it, with current truth read from the living tier.

### Reviews

ADRs receive a dedicated pre-acceptance review by the `architecture-reviewer`, armed through the curator's existing rule-mandated-review step by a project rule shipped with this regime. Specification and overview edits receive no dedicated gate: they land in the branch alongside the change that motivated them and are reviewed by the same reviewer in the existing `/review` fan-out.

### Adoption and legacy corpora

Adoption is a **human-invoked skill**, in the same authorisation class as `/okf-migrate-adr` — never initiated by an agent. It scaffolds `constraints.md` (empty if need be, so the marker and the gate's reference exist from minute one), moves the corpus to `docs/architecture`, rewrites the root `index.md` into its targeted OKF form — direct descendants plus a few prominent children — reclassifies stray living types (the agent project's `Architecture Reference` becomes an `Overview`), and retires any project-local architecture reviewer so the `/review` fan-out discovers exactly one. Run against a pre-OKF corpus, it stops cleanly and directs the human to run `/okf-migrate-adr` first — both migrations are human gates, and one does not fire the other. `okf-init` continues to scaffold plain bundles; regime adoption belongs to the adoption skill in every case.

Un-migrated corpora converge by **errata-driven extraction**: when an erratum on an accepted ADR would record that an enumeration or other current-truth passage no longer holds as written, the passage is extracted into a specification and the erratum records the extraction and its destination. Accepted content is never bulk-rewritten; a legacy corpus converges one erratum at a time, exactly as bundles converge on OKF v0.2 ([ADR-0003](0003-adopt-okf-v0-2-house-style.md)).

### Index conventions

Under the regime the bundle-root `index.md` takes the targeted form the OKF spec envisions: its own direct descendants — the themes and the ledger — plus a few prominent children, any overview and then typically specifications, rarely ADRs. A theme's `index.md` lists the overview as its first bullet, then the living documents, then the ADRs.

### Scope

Three neighbouring tiers are named and left where they are. The **domain model** (`CONTEXT.md`, maintained by the `domain-modelling` skill) pins words, sits outside the bundle, and is untouched by this decision: overviews describe shape in the domain model's language. **Specification-level implementation tracking** — whether a spec's contract is realised in code — is an open problem explicitly out of scope. **Per-language reviewer calibration rules** in the language plugins remain an available option not taken; calibration comes from project-level bundle documentation.

## Consequences

### Positive

- ADRs shrink to their decision core — the commitment, its forces, its alternatives — restoring the short-record length the format was designed for and making pre-acceptance human review of every ADR practical.
- Partial supersession dissolves rather than being solved: a single-surface ADR is superseded whole, enumerations live where editing is legal, and the dominant erratum class (enumeration growth) becomes an ordinary specification edit citing its driving ADR.
- "What is true now" gets a direct answer. The living tier is read in place of chasing an accepted ADR through its errata and successors.
- The per-ADR context tax drops. Current-state material is written once into an overview and cited thereafter, with the ordered writing step capturing it procedurally rather than relying on in-the-moment judgment.
- Constraints become named, citable decisions. Implicit foreclosures of the ruled-out-Windows kind get a document, an alternatives analysis, and a ledger entry — and the ledger makes the materiality gate resolvable against the project's own commitments rather than anyone's general intuitions.
- The architecture reviewer becomes distributable. With intended shape read from the bundle instead of a hand-written prompt section, one language-agnostic reviewer serves every adopting project and cannot go stale against its own project summary.
- Acceptance becomes a meaningful human gate on a short, targeted document committing the project to a direction, recorded as a `verified` event naming who ratified it.
- The regime is self-describing and spec-legal: the ledger concept doubles as the marker, so tooling detects the regime without new reserved files or index frontmatter.
- The `generated.by` shift to `architecture-curator/*` doubles as a per-concept era marker, distinguishing pre- and post-regime content with no bulk rewrite.

### Negative

- The two-tier split introduces a synchronisation duty that is discipline, not mechanism: a hook can guard a path but not a citation, so nothing structural prevents a specification drifting from its ADRs — the curator's workflow and the reviewer are the only enforcement.
- The single narrative fragments. A legacy ADR of the saved-sessions kind tells a whole design in one sitting; under the regime that story spans an ADR, specifications, and an overview, and the reader reassembles it.
- The due-diligence forcing function weakens below the gate. Mechanism choices that previously carried a full alternatives matrix now carry a compact rationale note; the tiebreaker promotes contested cases, but uncontested mechanism reasoning is recorded more thinly than before.
- Living documents can rot. `generated`, `verified`, and `stale_after` make staleness visible and the reviewer checks shape against code trajectory, but these are mitigations, not guarantees.
- The sole-writer model makes the curator a bottleneck for specification edits during implementation, serialising what could otherwise proceed in parallel.
- Decoupling acceptance from implementation makes a ratified-but-never-implemented ADR representable, detectable only as divergence between the ADR and the living tier — a reviewer concern, not a status.
- The change carries real tooling cost — a new skill for the gate, a new reviewer agent, an adoption skill, guard-hook and rule updates, and the curator rename rippling through every reference to `adr-architect`.

### Neutral

- Legacy corpora are untouched until a human runs adoption; `docs/adr` and `docs/architecture` regimes coexist across the organisation, each self-describing, and un-migrated corpora converge incrementally through errata-driven extraction.
- The domain-model tier is unaffected: words stay in `CONTEXT.md` under the `domain-modelling` skill, and overviews consume that language.
- Whether a specification's contract is realised in code is untracked by design; implementation status at the ADR level is not a coherent notion for a commitment, and specification-level tracking is an open future problem.
- The general `okf-*` skills keep their bundle-agnostic mechanics; all regime policy concentrates in the curator, the reviewer, and the shared gate skill, with `okf-guide` gaining only a profile section.
- The security bundle's dual-role owner (reviewer and curator in one agent) is unchanged; the architecture bundle's split of those roles is a deliberate asymmetry serving pre-acceptance review independence.
- Acceptance writing `verified` inverts the prior observation that ADRs rarely carry it; under the regime every accepted ADR carries exactly one verification event from its ratifier.

## Alternatives Considered

### Keep the single immutable ADR shape

Retain one concept type and address length through authoring discipline alone. Rejected because the corpus evidence shows the problem is categorical, not stylistic: enumerations, current-state description, and mechanism rationale change with the system, and housing them in immutable documents routes every change through errata — producing the 77-of-111 erratum rate, the near-absence of clean supersession, and the multi-thousand-word Context sections observed. Discipline cannot make a specification stop growing.

### Make sub-decisions addressable within an ADR

Give decision points inside an ADR numbered identity and per-part status, so a later ADR can supersede "ADR-0022/D3" without restating the rest. This formalises what cross-references like "ADR-0100 Decision 7" already do informally. Rejected because it complicates the status model (one document, many lifecycles) while leaving every other pressure intact — the length, the frozen enumerations, the regenerated context. Single-surface ADRs reach the same addressability with file-granular supersession and no new machinery.

### A sibling specification bundle beside the ADR bundle

Keep `docs/adr` for decisions and add a separate `docs/spec` bundle for living documents. Rejected because entangled material belongs together: a theme's decisions, contracts, and shape form one chapter, and splitting them across bundles doubles the front doors, splits the guardian's remit across two roots, and severs the theme-level co-location that keeps cross-citation cheap.

### Overviews as introductory sections of each theme's `index.md`

Inline the overview where the forge already renders a landing page. Rejected on the format's own terms: indexes are frontmatter-free by spec consideration, so an inlined overview loses concept-hood — no `generated` staleness signal, no type, nothing citable — and it sits in the blast radius of `/okf-index`'s wholesale rebuild. Overview-scale material would also bury the listing the index exists to be. The landing-page benefit is approximated by listing the overview as the theme's first bullet.

### A `profile` frontmatter key on the bundle-root index as the regime flag

Mark the regime the way `okf_version` marks the bundle. Rejected because the OKF spec restricts root-index frontmatter to `okf_version` alone — indexes carry no frontmatter as a spec consideration, with that single carve-out — so a second key would violate the spec this house style profiles. The ledger concept, which may carry arbitrary frontmatter and must exist under the regime anyway, provides an equally machine-readable marker spec-legally.

### One dual-role agent, following the security bundle

Merge curation and review into a single owner agent, as `security-reviewer` does for `docs/security/`. Rejected for this bundle because acceptance under the regime is a ratification gate whose review must be independent of the document's author; a self-reviewing curator would put the same context window on both sides of that gate. The security bundle's dual role stands where no such gate exists.

### Keep acceptance inside the commit workflow

Continue marking ADRs accepted automatically when implementation lands. Rejected because "implemented" is not coherent for a decision record under the regime: a constraint admission has no implementation — code leverages or is bound by it — and topology decisions may be realised across many changes while the ADR is still under discussion. Tying `Accepted` to a commit conflates ratifying a direction with landing code, and it removes the human from precisely the gate the regime makes short enough to be reviewable.

### Mandatory overviews at theme creation

Require every new theme to open with an overview. Rejected because a theme with one small ADR has nothing worth consolidating, and a mandatory stub is the kind of document that rots first and then poisons trust in the whole living tier. The ordered writing step creates the overview at the first moment there is real material for it.

### Bake regime policy into the general `okf-*` skills

Teach `okf-curate` the citation discipline and `okf-index` the regime's index forms directly. Rejected because those skills serve every bundle family — the security bundle among them — and regime policy embedded in general mechanics would leak architecture rules into bundles with different owners and conventions. Policy concentrates in the curator and reviewer definitions and the shared gate skill; the general skills stay bundle-agnostic.

## Errata

### 2026-08-12: Ratification may now change the document

The Decision's "Acceptance is human ratification" section states that acceptance "changes the ADR's status and verification record and nothing else, so what the human reviewed is exactly what freezes." The "and nothing else" half is no longer correct: [ADR-0005](0005-ratify-adrs-in-concert-with-the-human.md) permits ratification to amend the body where the ratifying human directs the change in session. The guarantee that clause exists to deliver is unaffected and was reaffirmed rather than weakened — the ratified text is still the text the human read — but it is now delivered by their reading the final document rather than by the document being unchangeable at the gate. Every other property stated in that section, including human-only initiation, the `verified` record, the ledger entry for a constraint admission, and immutability from acceptance onward, stands as written.

### 2026-08-13: Specification conformance is now tracked

The Neutral consequence that "whether a specification's contract is realised in code is untracked by design" and that "specification-level tracking is an open future problem" is no longer correct, and neither is the matching "open problem" wording in the Decision's Scope section. [ADR-0007](0007-track-specification-conformance-in-status.md) narrows a specification's `status` to answer the format's lifecycle question about the contract — `draft` where the code has not yet met it, `stable` where it has, with promotion between them recorded as a `verified` event — and [Maintaining Living Documents](living-documents.md) carries that reading value by value and keeps it current. What those passages get right survives: this ADR did not decide the question and did not purport to, so the scope exclusion stands. Only the claim that the question remains undecided has gone false.
