---
paths:
  - "**/*.rs"
---

# Tests live in dedicated module files

Put every test (`#[test]` / `#[tokio::test]`) in a dedicated `tests` submodule **file**. The file is either a sibling or a parent of the module under test. Do not write inline `#[cfg(test)] mod tests { ... }` blocks in production source files.

Both layouts are acceptable:

- **Sibling**: for `src/foo/mod.rs`, put the tests in `src/foo/tests.rs`. Reference them with `#[cfg(test)] mod tests;`.
- **Parent**: for `src/foo/bar.rs` and `src/foo/baz.rs`, put the tests under `src/foo/tests/` (for example `src/foo/tests/bar.rs` and `src/foo/tests/baz.rs`). Reference them from `src/foo/mod.rs` with `#[cfg(test)] mod tests;` and a `src/foo/tests/mod.rs`. The GraphQL integration suite under `src/graphql/tests/*` uses this layout.

Pick the level that keeps tests close enough to the code they exercise, so that a reader finds them quickly. Do not force every leaf module to have its own `tests.rs`.

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

with the test bodies in `src/foo/tests.rs` (or `src/foo/tests/<topic>.rs` if the suite is split across topics).

This rule applies only to test cases. Non-test `#[cfg(test)]` items may stay in production files when no sensible test-module home exists. Examples are crate-wide test helpers, fixture builders, and types that must be `pub(crate)`-visible to several test files. Crate-level integration tests under `tests/` follow the layout of Cargo, not this rule.
