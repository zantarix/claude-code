---
paths:
  - "**/*.res"
  - "**/*.resi"
---

# FFI bindings

Place all FFI bindings in their own module with an explicit `.resi` file that documents the public API. The `.resi` file is the single source of truth for that API.

A binding module can hold more than raw `external` declarations. Colocate general-purpose helpers that operate on the data shape of the library (lookup with fallback, formatting, normalisation) in the binding module. Do not re-implement them at each call site. Colocate a helper only when it is reusable and not specific to one call site.
