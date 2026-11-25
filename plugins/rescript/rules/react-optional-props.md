---
paths:
  - "src/**/*.res"
  - "src/**/*.resi"
---

# React optional prop annotation asymmetry

For an optional `@react.component` prop with no default value, the annotation differs by file:

- **`.resi`**: `~prop: T=?`. The `=?` already implies `option<T>`, so write the base type. Writing `option<T>=?` here causes a props-type mismatch.
- **`.res`**: `~prop: option<T>=?`. Annotate it explicitly. With no default, the compiler cannot infer the type, and `T=?` gives a type error.

Contrast `~exact: bool=false`. The default makes `bool` unambiguous.
