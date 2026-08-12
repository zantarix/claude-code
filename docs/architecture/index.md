---
okf_version: "0.2"
---

# Architecture

This bundle holds the architecture documentation for the Zantarix Claude Code plugin marketplace: immutable **Architecture Decision Records (ADRs)** capturing why the project changed direction, over living documents — theme overviews and specifications — recording where it currently stands, consolidated by a root constraint ledger.

Each ADR describes the context behind a decision, the decision itself, the alternatives that were considered, and the consequences — both positive and negative. Once an ADR is accepted and committed, it is treated as immutable; if a decision is later reversed, a new ADR supersedes it. Living documents are edited in place as the system evolves.

# Constraints

* [Constraint Ledger](constraints.md) - the consolidated register of standing architectural commitments, one entry per constraint-admitting decision.

# Themes

* [Orchestration](orchestration/) - how skills coordinate multi-agent work: fan-out, gating, and collation of subagent results.
* [Knowledge](knowledge/) - knowledge and documentation formats: how decisions and reference material are structured, indexed, and maintained.
* [Components](components/) - the kinds of thing a plugin ships, how they reach a consumer project, and what each costs in context.

# Related Projects

* [Cursus](https://github.com/zantarix/cursus) - release and publish tooling; its ADRs live at [`docs/adr/`](https://github.com/zantarix/cursus/blob/main/docs/adr/README.md).
