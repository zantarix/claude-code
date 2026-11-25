---
paths:
  - "**/*.rs"
---

# Error handling

## Prefer `anyhow::Result<Outcome>` over an outcome enum with a `Failure` variant

When you design handler or outcome types in which one case is "the work errored", prefer `anyhow::Result<Outcome>` over an enum with a `Failure(anyhow::Error)` variant. Handler code can then use `?` naturally. A failure variant inside the enum forces a manual conversion on every call.

Use an in-enum failure variant only when the failure carries domain-specific structured fields that the runner must branch on.
