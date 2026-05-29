---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
---

# Enabled lints

Enable the following lints org-wide via `Cargo.toml`:

* `unreachable_pub = "warn"` (`[lints.rust]`) — flags `pub` items not reachable from the crate root. Under `cargo clippy -- -D warnings` this becomes an error, automatically enforcing the visibility convention in `style.md`.
* `clippy::excessive_nesting = "warn"` (`[lints.clippy]`) — flags deeply nested code; configure the threshold in `clippy.toml`.
* `clippy::too_many_lines = "warn"` (`[lints.clippy]`) — flags overly long functions; configure the threshold in `clippy.toml`.

# Clippy exceptions

Documented here are the baseline rule for handling Clippy for the Zantarix organisation.

* The user explicitly asks for it.
* `clippy::too_many_lines` may be allowed for functions that are pure dispatch functions, that is they are match statements (potentially nested) where each final match arm is a log, simple function call, or object creation with no additional logic.

Other clippy lint failures, including from other rules, must be fixed.
