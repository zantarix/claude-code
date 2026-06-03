---
paths:
  - "src/**/*.res"
  - "src/**/*.resi"
---

# Named type aliases for domain collections

When a primitive collection (`array`, `string`, tuple) carries domain semantics within a module, define a named `type t = ...` alias and thread it through the module's signatures rather than inlining the primitive everywhere — `~list: t` read alongside the module path conveys intent where inline `array<string>` does not.

Example:

```rescript
module LabelList = {
  type t = array<string>
  let canAdd: (~list: t, ~raw: string) => bool
}
```

Default to this when extracting helpers around a primitive collection; skip for one-shot locals or arrays with no domain meaning.
