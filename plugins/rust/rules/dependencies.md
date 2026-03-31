---
paths:
- **/Cargo.toml
- **/Cargo.lock
---

# Adding new dependencies

* **After adding a new crate dependency, always run `cargo deny check`** to verify licenses, check for advisories, and ensure supply chain security.
