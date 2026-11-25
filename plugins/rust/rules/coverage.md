---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
---

# Coverage tooling

`cargo llvm-cov` collects coverage. It injects `--cfg coverage` (always) and `--cfg coverage_nightly` (on a nightly toolchain). Do the two steps below to use it correctly.

## unexpected_cfgs registration

Register both cfgs in `[lints.rust]`. Then normal `build`, `test`, and `clippy -- -D warnings` runs do not fail on an unknown cfg name:

```toml
[lints.rust]
unexpected_cfgs = { level = "warn", check-cfg = [
    "cfg(coverage)",
    "cfg(coverage_nightly)",
] }
```

`cargo llvm-cov` sets both cfgs during collection, and `-D warnings` otherwise rejects them as unknown cfg names. Source code uses only `coverage_nightly` as a guard. Register `coverage` only to suppress the warning. Do not use it directly.

## Excluding untestable bootstrap code

Gate the nightly attribute at the crate level so that stable builds stay clean:

```rust
#![cfg_attr(coverage_nightly, feature(coverage_attribute))]
```

Then annotate genuinely untestable process-bootstrap code with:

```rust
#[cfg_attr(coverage_nightly, coverage(off))]
```

This attribute does nothing on non-coverage builds. Apply it only to code that tests cannot exercise: server and worker run loops, signal handlers, global initialisation, and background supervisors. Do not use it to hide testable code that is only inconvenient to cover. See the thresholds in `non-functional.md`.
