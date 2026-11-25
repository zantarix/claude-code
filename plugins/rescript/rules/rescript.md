---
paths:
  - "**/*.res"
  - "**/*.resi"
---

# ReScript conventions

- Source files use the extensions `.res` (implementation) and `.resi` (interface/public API). The ReScript compiler generates the compiled output as `.res.mjs`, in-source, next to the `.res` files. Git ignores it. Regenerate it with the compiler.
- ReScript has a flat module namespace. Subdirectories are only organisational. They do not affect module names or imports.
- Third-party JavaScript libraries need explicit FFI bindings. There is no implicit interop.
- ReScript cannot express React class components. Write any component that needs class lifecycle methods (for example error boundaries) in JavaScript, and bind it through FFI.
