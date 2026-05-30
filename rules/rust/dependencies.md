---
paths:
  - "**/Cargo.toml"
  - "**/Cargo.lock"
  - "**/*.rs"
---

# Adding new dependencies

Before running `cargo add` or adding crate entries to `Cargo.toml`, ask the user first. Adding dependencies changes the dependency tree and lock file, which the user wants control over.

After adding a new crate dependency, always run `cargo deny check` to verify licenses, check for advisories, and ensure supply chain security.

## Proc-macro version mismatch errors

When `cargo test` produces spurious `error[E0463]: can't find crate` or proc-macro version mismatch errors (especially in doctests) that are not explained by code changes, run `cargo clean` before diagnosing further. Toolchain updates (nightly bumps, proc-macro crate updates) can leave the build cache inconsistent without properly invalidating it.
