---
paths:
  - "**/*.rs"
  - "**/Makefile.toml"
---

# Unexpected coverage fluctuations

When coverage numbers move in an unexplainable direction — gate drops on a
well-tested branch, line counts that exceed physical file size, or covered counts
that don't match what the code suggests — run `cargo clean` and a fresh coverage
pass as the first debugging step before investigating the source.

`cargo llvm-cov clean --workspace` is not sufficient — it clears coverage artifacts
but does not rebuild stale object code. A full `cargo clean` is required.
