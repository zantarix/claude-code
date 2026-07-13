# Refining a Proposed ADR

When a follow-up decision tightens or refines the design an existing **Proposed** ADR
already owns, fold it into that ADR as a body update via the `@zantarix:adr-architect`
agent — do not spawn a new ADR. Proposed ADRs are not yet immutable (only Accepted ones
are), so a body edit is correct, and it is *not* errata.

Reserve a new ADR for a genuinely new decision surface; reserve errata for changes to
Accepted (immutable) ADRs. Before scoping ADR work for a ticket, check whether the decision
refines an existing Proposed ADR.
