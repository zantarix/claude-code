---
okf_version: "0.1"
---

# Architecture Decision Records

This bundle contains the Architecture Decision Records (ADRs) for the Zantarix Claude Code plugin marketplace.

ADRs are short documents that capture significant architectural decisions made during the development of this project. Each record describes the context behind a decision, the decision itself, the alternatives that were considered, and the consequences — both positive and negative. They serve as a historical log for current and future contributors to understand why the system is shaped the way it is.

Once an ADR is accepted and committed, it is treated as immutable. If a decision is later reversed or revised, a new ADR is created and the original's status is updated to reflect the change.

# Orchestration

* [Orchestration](orchestration/) - how skills coordinate multi-agent work: fan-out, gating, and collation of subagent results.
* [Orchestrate the `/review` Skill with a Two-Phase Dynamic Workflow](orchestration/0001-review-dynamic-workflow.md) - re-architects the /review skill around a deterministic two-phase dynamic Workflow with remit-aware per-reviewer partitioning under a hard cost cap.

# Knowledge

* [Knowledge](knowledge/) - knowledge and documentation formats: how decisions and reference material are structured, indexed, and maintained.
* [Adopt the Open Knowledge Format for Zantarix Knowledge Bundles](knowledge/0002-adopt-okf-knowledge-bundles.md) - adopts OKF v0.1 as the standard format for Zantarix knowledge bundles, restructuring ADR libraries as opt-in OKF bundles maintained via an /okf-* skill suite.

# Related Projects

* [Cursus](https://github.com/zantarix/cursus) - release and publish tooling; its ADRs live at [`docs/adr/`](https://github.com/zantarix/cursus/blob/main/docs/adr/README.md).
