---
paths:
  - "src/**/*.res"
  - "src/**/*.resi"
---

# React optional prop annotation asymmetry

When a `@react.component` receives an optional prop with no default value, the annotation must differ between files:

- **`.resi`**: `~prop: T=?` — `=?` already implies `option<T>` at the interface; write the base type
- **`.res`**: `~prop: option<T>=?` — annotate explicitly as `option<T>` because there is no default to derive the type from; this gives `option<T>` inside the function body

The asymmetry is required — without explicit `option<T>` on the impl side the compiler cannot infer the type. Contrast with `~exact: bool=false` where the default makes `bool` unambiguous.

**Why:** Non-obvious; easy to get wrong in both directions (`option<int>=?` in `.resi` causes a props-type mismatch; `int=?` in `.res` gives a type error with no default).

**How to apply:** For any optional prop with no default — `T=?` in `.resi`, `option<T>=?` in `.res`.
