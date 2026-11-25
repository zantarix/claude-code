---
paths:
  - "src/**/*.res"
  - "src/**/*.resi"
---

# Named type aliases for domain collections

When a primitive collection (`array`, `string`, tuple) carries domain meaning within a module, define a named `type t = ...` alias. Use it in the signatures of the module. Do not inline the primitive everywhere. For example, `~list: t` conveys intent when you read it with the module path. Inline `array<string>` does not.

Example:

```rescript
module LabelList = {
  type t = array<string>
  let canAdd: (~list: t, ~raw: string) => bool
}
```

Use this by default when you extract helpers around a primitive collection. Skip it for one-shot locals and for arrays with no domain meaning.
