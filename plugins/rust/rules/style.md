---
paths: **/*.rs
---

# Code Style

Format code before making any commit. Prefer functional style over imperative.

Uses Rust 2024 edition.

Never write production code that panics. Avoid `unwrap()`, `expect()`, `panic!()`, and `unreachable!()` outside of tests. Use `anyhow::Result`, `context()`, or `bail!()` to propagate errors instead.
