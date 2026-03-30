---
paths: "**/*.rs"
---

# Clippy exceptions

Documented here are the only valid reasons to apply an allow rule bypassing clippy linting:

* The user explicitly asks for it.
* `clippy::too_many_lines` may be allowed for functions that are pure dispatch functions, that is they are match
  statements (potentially nested) where each final match arm is a log, simple function call, or object creation with no additional logic.
