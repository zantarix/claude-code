---
paths:
  - "**/*.res"
  - "**/*.resi"
---

# FFI bindings

Place all FFI bindings in their own module with an explicit `.resi` file documenting the public API; the `.resi` is the single source of truth for that API.

Binding modules are not restricted to raw `external` declarations — colocate general-purpose helpers that operate on the library's data shape (lookup-with-fallback, formatting, normalisation) here rather than re-implementing them at each call site, provided they are reusable rather than call-site-specific.
