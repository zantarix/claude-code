---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
---

# Enabled lints

Enable these lints org-wide in `Cargo.toml`:

* `unreachable_pub = "warn"` (`[lints.rust]`): flags `pub` items that are not reachable from the crate root. Under `cargo clippy -- -D warnings` this becomes an error. It enforces the visibility convention in `style.md` automatically.
* `clippy::excessive_nesting = "warn"` (`[lints.clippy]`): flags deeply nested code. Set the threshold in `clippy.toml`.
* `clippy::too_many_lines = "warn"` (`[lints.clippy]`): flags overly long functions. Set the threshold in `clippy.toml`.

# Clippy exceptions

This section is the baseline for the Zantarix organisation. Allow a clippy lint only in these cases:

* The user explicitly asks for it.
* Allow `clippy::too_many_lines` for a pure dispatch function. A pure dispatch function is a match statement (possibly nested). Each final match arm is a log, a simple function call, or an object creation with no additional logic.

Fix all other clippy lint failures, including failures from other rules.

# Reading clippy output

When clippy flags an issue, read the full output, including the `help:` section, before you try a manual fix. Clippy often shows the exact code change that you need, for example collapsing a nested `if` into `&& let`. Apply the suggested fix first. Restructure manually only when there is no suggestion or the suggestion does not apply cleanly.
