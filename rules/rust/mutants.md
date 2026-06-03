---
paths:
  - "**/*.rs"
  - ".cargo/mutants.toml"
---

# Mutation testing

When working with mutation testing (cargo-mutants), do not add `exclude_re` or `exclude_globs` entries to `.cargo/mutants.toml` to suppress missed mutations. Instead, add tests or simplify code to make mutations detectable.

Use `#[mutants::skip]` only as a last resort for genuinely untestable code (e.g. `main()`), and confirm with the user first.
