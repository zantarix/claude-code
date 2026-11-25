---
paths:
  - "**/*.rs"
---

# Rust modules guidelines

* Keep every module under 1000 lines. If a `module.rs` grows past this limit, split it into a `module/mod.rs` with topic-specific modules as siblings.
  * When you split a module, first move any `tests` submodule for unit tests into its own file.
  * For a particularly large test suite, split the `tests` submodule into topic modules.
