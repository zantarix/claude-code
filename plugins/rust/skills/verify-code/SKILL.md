---
name: verify-code
description: Use to fully verify changes made to Rust code using cargo (clippy, coverage, fmt).
---

Verify the current changes pass all quality checks. Run these steps in order, attempting to fix any failures or stop if
you are unable to fix the failures:

1. **Lint** the code: `cargo clippy --all-targets --all-features -- -D warnings`
2. **Validate** module lengths: `cargo make check-module-size`
3. **Check documentation**: `cargo doc --no-deps --workspace --document-private-items`
4. **Test and check Coverage** check: `cargo make coverage` (must meet 90% threshold, including 80% branch coverage)
5. **Format** the code: `cargo fmt`

Report a summary of results for each step. If any step fails, diagnose the issue and suggest a fix.
