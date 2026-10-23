---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
---

# Coverage tooling

Coverage is collected with `cargo llvm-cov`, which injects `--cfg coverage` (always) and `--cfg coverage_nightly` (on a nightly toolchain). Two things must be in place to use it correctly.

## unexpected_cfgs registration

Register both cfgs in `[lints.rust]` so normal `build`/`test`/`clippy -- -D warnings` runs don't fail on an unknown cfg name:

```toml
[lints.rust]
unexpected_cfgs = { level = "warn", check-cfg = [
    "cfg(coverage)",
    "cfg(coverage_nightly)",
] }
```

Both are registered because `cargo llvm-cov` sets both cfgs during collection and `-D warnings` would otherwise reject them as unknown cfg names. Only `coverage_nightly` is used as a guard in source code; `coverage` is registered solely to suppress the warning and is not intended for direct use.

## Excluding untestable bootstrap code

Gate the nightly attribute at the crate level so stable builds remain clean:

```rust
#![cfg_attr(coverage_nightly, feature(coverage_attribute))]
```

Then annotate genuinely-untestable process-bootstrap code with:

```rust
#[cfg_attr(coverage_nightly, coverage(off))]
```

This attribute is inert on non-coverage builds. Apply it only to code that genuinely cannot be exercised by tests: server/worker run loops, signal handlers, global initialisation, background supervisors. Do not use it to paper over testable code that is merely inconvenient to cover — see the thresholds in `non-functional.md`.
