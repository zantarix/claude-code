---
paths:
  - "**/*.rs"
  - ".cargo/mutants.toml"
---

# Mutation testing

When working with mutation testing (cargo-mutants), do not add `exclude_re` or `exclude_globs` entries to `.cargo/mutants.toml` to suppress missed mutations. Instead, either add tests or simplify code to make mutations detectable.

Only use `#[mutants::skip]` as a last resort for genuinely untestable code (e.g. `main()`), and confirm with the user first before doing so.

**Why:** Suppressing mutation results hides real coverage gaps. The goal is actual test quality improvements, not a passing mutation score achieved by narrowing the target.
