---
paths:
  - "src/**/*.res"
  - "src/**/*.resi"
---

# React optional prop annotation asymmetry

For an optional `@react.component` prop with no default value, the annotation differs by file:

- **`.resi`**: `~prop: T=?` — `=?` already implies `option<T>`; write the base type. (`option<T>=?` here causes a props-type mismatch.)
- **`.res`**: `~prop: option<T>=?` — annotate explicitly; with no default the compiler cannot infer the type, and `T=?` gives a type error.

Contrast `~exact: bool=false`, where the default makes `bool` unambiguous.
