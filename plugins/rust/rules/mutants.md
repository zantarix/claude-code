---
paths:
  - "**/*.rs"
  - ".cargo/mutants.toml"
---

# Mutation testing

When you work with mutation testing (cargo-mutants), do not add `exclude_re` or `exclude_globs` entries to `.cargo/mutants.toml` to suppress missed mutations. Instead, add tests or simplify the code so that the mutations are detectable.

Use `#[mutants::skip]` only as a last resort, for code that is genuinely untestable (for example `main()`). Confirm with the user first.
