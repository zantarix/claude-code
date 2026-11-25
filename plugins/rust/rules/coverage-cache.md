---
paths:
  - "**/*.rs"
  - "**/Makefile.toml"
---

# Unexpected coverage fluctuations

Coverage numbers can move in a direction that you cannot explain. Examples: the gate drops on a well-tested branch, line counts exceed the physical file size, or covered counts do not match what the code suggests. In that case, run `cargo clean` and a fresh coverage pass as your first debugging step. Do this before you investigate the source.

`cargo llvm-cov clean --workspace` is not sufficient. It clears coverage artifacts but does not rebuild stale object code. Run a full `cargo clean`.
