---
paths:
  - "**/*.rs"
---

# Documentation links

When linking to docs.rs (in `specifiedByURL` on custom scalars, doc comments, or documentation), use the `/latest/` alias rather than a pinned version: `https://docs.rs/<crate>/latest/<crate>/`. Version-pinned URLs go stale on every dependency bump.
