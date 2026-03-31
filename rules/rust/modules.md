---
paths:
  - "**/*.rs"
---

# Rust modules guidelines

* All modules should be less than 1000 lines. If a `module.rs` gets longer than this it should be split into a `module/mod.rs` with various topic specific modules as siblings.
  * When splitting modules, the first step is to split any `tests` submodule for unit tests into their own file.
  * For particularly large test suites, the `tests` submodule may itself need to be split into topic modules.
