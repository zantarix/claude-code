# Architecture Decision Records

This directory contains the Architecture Decision Records (ADRs) for the Zantarix Claude Code plugin marketplace.

ADRs are short documents that capture significant architectural decisions made during the development of this project. Each record describes the context behind a decision, the decision itself, the alternatives that were considered, and the consequences — both positive and negative. They serve as a historical log for current and future contributors to understand why the system is shaped the way it is.

Once an ADR is accepted and committed, it is treated as immutable. If a decision is later reversed or revised, a new ADR is created and the original's status is updated to reflect the change.

## Index

| ADR | Title | Status |
|-----|-------|--------|
| [ADR-001](001-review-dynamic-workflow.md) | Orchestrate the `/review` Skill with a Two-Phase Dynamic Workflow | Accepted |
| [ADR-002](002-adopt-okf-knowledge-bundles.md) | Adopt the Open Knowledge Format for Zantarix Knowledge Bundles | Accepted |

## Related Projects

- [Cursus](https://github.com/zantarix/cursus) — release and publish tooling; its ADRs live at [`docs/adr/`](https://github.com/zantarix/cursus/blob/main/docs/adr/README.md).
