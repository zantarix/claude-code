---
paths:
  - "**/*.rs"
---

# Documentation links

When you link to docs.rs (in `specifiedByURL` on custom scalars, doc comments, or documentation), use the `/latest/` alias, not a pinned version: `https://docs.rs/<crate>/latest/<crate>/`. Version-pinned URLs go stale on every dependency bump.
