---
paths:
  - "**/*.res"
  - "**/*.resi"
---

# FFI bindings

All FFI bindings should be placed in their own module with an explicit `.resi` file documenting the public API expected to be exposed by the binding.

FFI binding modules are not restricted to raw `external` declarations. They may (and should) also host general-purpose helpers that operate on the library's data shape, provided the helpers are reusable rather than call-site-specific.

**Why:** Keeping domain knowledge about a third-party library (e.g. "how to derive a display colour for a language") inside the binding module avoids duplicating the library's data shape across consumers. When the library's shape changes, the blast radius is one file. The binding's `.resi` remains the single source of truth for its public API.

**How to apply:** When designing a binding module, consider what cross-cutting operations consumers will need. If a helper (lookup-with-fallback, formatting, normalisation) would otherwise be re-implemented by multiple callers, colocate it in the binding module's `.res`/`.resi`.
