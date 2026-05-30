---
paths:
  - "src/**/*.res"
  - "src/**/*.resi"
---

# Named type aliases for domain collections

When a primitive collection (`array`, `string`, tuple) carries domain semantics within a module, define a named `type t = ...` alias and thread it through the module's signatures rather than inlining the primitive everywhere.

Example:

```rescript
module LabelList = {
  type t = array<string>
  let canAdd: (~list: t, ~raw: string) => bool
}
```

**Why:** `~list: t` read alongside the module path immediately conveys what the value represents. Inline `array<string>` is indistinguishable from any unrelated string array.

**How to apply:** When extracting helpers around a primitive collection, default to `type t = ...` and thread it through signatures and consumer types. Skip for one-shot locals or arrays with no domain meaning.
