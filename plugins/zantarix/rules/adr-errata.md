# ADR errata

Only the `@zantarix:architecture-curator` agent owns errata. No other agent or skill adds or suggests errata.

Reviewer agents (`*-reviewer`) must not suggest errata for accepted ADRs. Instead, use these rules:

- If an ADR's *decision* is contradicted, flag an architectural concern. It may need a new ADR.
- If *current-truth material* in an ADR (call signatures, enumerations, formats, layouts) is out of date, flag an extraction candidate for the curator's errata-driven extraction. Never flag it as a new ADR.
- A reviewer can flag implementation discrepancies against a `Proposed` ADR. The curator inlines those into the ADR before acceptance.
