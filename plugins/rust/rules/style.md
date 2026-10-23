---
paths:
  - "**/*.rs"
---

# Code Style

Format code before making any commit. Prefer functional style over imperative.

Uses Rust 2024 edition.

Never write production code that panics. Avoid `unwrap()`, `expect()`, `panic!()`, and `unreachable!()` outside of tests. Use `anyhow::Result`, `context()`, or `bail!()` to propagate errors instead.

# Visibility convention

Use the narrowest visibility that still lets callers reach what they need, in order from broadest to narrowest:

* `pub` — only for items actually reachable from outside the crate. The `unreachable_pub` lint (see `clippy.md`) enforces this automatically.
* `pub(crate)` — crate-internal sharing across modules.
* `pub(in path::)` — subtree-scoped; use when `pub(super)` is too narrow but `pub(crate)` is too broad (e.g. `pub(in super::super)`, `pub(in crate::some::module)`).
* `pub(super)` — visible within the parent module (equivalent to `pub(in super)`).
* private (no qualifier) — confined to the declaring module.

Do not use `pub` as a default. When splitting a module into submodules, re-export only what the parent's callers actually need.
