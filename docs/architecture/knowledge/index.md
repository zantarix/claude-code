# Knowledge

Knowledge and documentation formats: how decisions and reference material are structured, indexed, and maintained.

* [Overview](overview.md) - how the project structures the knowledge it keeps: OKF bundles, the two-tier regime, the ADR lifecycle, and the routes by which rules and memories become distributed content.
* [ADR Lifecycle](adr-lifecycle.md) - the stages a decision record passes through and which of them may change the document.
* [Maintaining Living Documents](living-documents.md) - which side yields when a document and the code disagree, and what a document's status asserts about the gap.
* [Adopt the Open Knowledge Format for Zantarix Knowledge Bundles](0002-adopt-okf-knowledge-bundles.md) - adopts OKF v0.1 as the standard format for Zantarix knowledge bundles, restructuring ADR libraries as opt-in OKF bundles maintained via an /okf-* skill suite.
* [Migrate the Zantarix OKF House Style to v0.2](0003-adopt-okf-v0-2-house-style.md) - migrates the OKF house style to the v0.2 canonical form (generated, sources, trust families) for every bundle including ADRs, with ADRs keeping their mid-document References section as the sole divergence.
* [Split Architecture Documentation into Immutable ADRs and Living Documents](0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md) - replaces the single immutable ADR shape with architecture bundles of immutable ADRs over living overviews, specifications, and a root constraint ledger, gated by a shared materiality test and accepted only through a human ratification gate.
* [Ratify ADRs in Concert with the Human](0005-ratify-adrs-in-concert-with-the-human.md) - permits ratification to amend an ADR's body when the ratifying human directs it in session, replacing the freeze-before-the-gate mechanism with visibility of the final text.
* [Require a Curator Session for ADR Ratification](0006-require-a-curator-session-for-adr-ratification.md) - admits the standing commitment that the human-authorisation gates run only in a session driven by the architecture curator, foreclosing delegated and non-interactive ratification.
