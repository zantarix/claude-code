---
paths:
  - "**/*.rs"
---

# Tests live in dedicated module files

Every test (`#[test]` / `#[tokio::test]`) must live in a dedicated `tests` submodule **file** — either sibling or parent to the module it tests. Inline `#[cfg(test)] mod tests { ... }` blocks in production source files are forbidden.

Both layouts are acceptable:

- **Sibling** — for `src/foo/mod.rs`, the tests live in `src/foo/tests.rs` referenced by `#[cfg(test)] mod tests;`.
- **Parent** — for `src/foo/bar.rs` and `src/foo/baz.rs`, the tests live under `src/foo/tests/` (e.g. `src/foo/tests/bar.rs`, `src/foo/tests/baz.rs`) referenced from `src/foo/mod.rs` by `#[cfg(test)] mod tests;` and a `src/foo/tests/mod.rs`. This is the layout used by the GraphQL integration suite under `src/graphql/tests/*`.

Pick whichever level keeps the tests close enough to the code they exercise that a reader can find them quickly, without forcing every leaf module to grow its own `tests.rs`.

**Forbidden:**

```rust
// inside src/foo.rs
fn production() { ... }

#[cfg(test)]
mod tests {
    use super::*;
    #[tokio::test]
    async fn test_something() { ... }
}
```

**Correct** (`src/foo/mod.rs`):

```rust
pub fn production() { ... }

#[cfg(test)]
mod tests;
```

with the test bodies in `src/foo/tests.rs` (or in `src/foo/tests/<topic>.rs` if the suite is split across topics).

**Why:** Production files stay focused on production logic; module sizes stop ballooning under the org's 1000-line limit (`.claude/shared/rules/rust/modules.md`); and large test suites can be split into topical submodules under `tests/` without disrupting production code layout. Inline `mod tests { ... }` blocks defeat all of these.

**Out of scope.** This rule applies only to test cases. Non-test `#[cfg(test)]` items — crate-wide test helpers, fixture builders, or types that must be `pub(crate)`-visible to multiple test files — may remain in production files when no sensible test-module home exists. Crate-level integration tests under `tests/` follow Cargo's own layout, not this rule.
