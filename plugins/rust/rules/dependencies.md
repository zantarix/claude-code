---
paths:
  - "**/Cargo.toml"
  - "**/Cargo.lock"
  - "**/*.rs"
---

# Adding new dependencies

Ask the user before you add a crate that the workspace does not already use. Crates that other workspace crates use as direct dependencies are preapproved. A new dependency changes the dependency tree and the lock file, and the user wants control over those.

After you add a new crate dependency, always run `cargo deny check`. It verifies licenses, checks for advisories, and ensures supply chain security.

## Proc-macro version mismatch errors

`cargo test` can produce spurious `error[E0463]: can't find crate` or proc-macro version mismatch errors, especially in doctests. If code changes do not explain them, run `cargo clean` before you diagnose further. Toolchain updates (nightly bumps, proc-macro crate updates) can leave the build cache inconsistent without invalidating it correctly.
