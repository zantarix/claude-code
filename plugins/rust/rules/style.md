---
paths:
  - "**/*.rs"
---

# Code Style

Format code before every commit. Prefer functional style over imperative style.

Use the Rust 2024 edition.

Never write production code that panics. Avoid `unwrap()`, `expect()`, `panic!()`, and `unreachable!()` outside of tests. Use `anyhow::Result`, `context()`, or `bail!()` to propagate errors instead.

# Visibility convention

Use the narrowest visibility that lets callers reach what they need. The list below goes from broadest to narrowest:

* `pub`: only for items that code outside the crate reaches. The `unreachable_pub` lint (see `clippy.md`) enforces this automatically.
* `pub(crate)`: crate-internal sharing across modules.
* `pub(in path::)`: subtree-scoped. Use it when `pub(super)` is too narrow but `pub(crate)` is too broad (for example `pub(in super::super)` or `pub(in crate::some::module)`).
* `pub(super)`: visible within the parent module (equivalent to `pub(in super)`).
* private (no qualifier): confined to the declaring module.

Do not use `pub` as a default. When you split a module into submodules, re-export only what the callers of the parent need.
