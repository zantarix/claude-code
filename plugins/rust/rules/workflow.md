---
paths:
  - "**/*.rs"
  - "**/Makefile.toml"
---

# Cargo Make for repeatable maintenance steps

When a plan includes a periodic maintenance step, prefer a `cargo make <task>` entry in `Makefile.toml`. Examples are refreshing a vendored schema and regenerating fixtures. Do not write a README or runbook that documents the equivalent shell command.

You can discover tasks with `cargo make --list-all-steps`. They run identically in CI and locally, and they outlast README rot.
