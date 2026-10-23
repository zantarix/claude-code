---
paths:
  - "**/*.rs"
---

# Error handling

## Prefer `anyhow::Result<Outcome>` over an outcome enum with a `Failure` variant

When designing handler or outcome types where one of the cases is "the work errored", prefer `anyhow::Result<Outcome>` over an enum with a `Failure(anyhow::Error)` variant. This lets handler code use `?` naturally; folding failure into the enum forces per-call manual conversion.

Reserve in-enum failure variants for cases where the failure carries domain-specific structured fields the runner must branch on.
