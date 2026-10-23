---
paths:
  - "**/*.rs"
  - "**/Makefile.toml"
---

# Cargo Make for repeatable maintenance steps

When a plan calls for a periodically-rerun maintenance step (refreshing a vendored schema, regenerating fixtures, etc.), prefer adding a `cargo make <task>` entry to `Makefile.toml` over writing a README/runbook documenting the equivalent shell command.

Tasks are discoverable via `cargo make --list-all-steps`, executable identically in CI and locally, and outlast README rot.
