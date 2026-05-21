---
name: accept-adr
description: Use when asked to accept a particular ADR
---

Delegate to the `@base:adr-architect` subagent and pass the following prompt:

> Accept ADR $ARGUMENTS. Carry out the following steps in order:
>
> 1. Review the implementation of $ARGUMENTS for completeness and inline any minor updates that emerged during implementation directly into the ADR (it is still `Proposed`, so inline edits are appropriate).
> 2. Before marking it accepted, search back through previously accepted ADRs for any whose decisions or consequences are now functionally incorrect because of $ARGUMENTS. Use `docs/adr/README.md` and your inventory as the starting point; read the candidates in full (errata can change context).
> 3. For each affected accepted ADR, add a single erratum following the rules in `rules/base/adr.md` and your own Errata section: one paragraph, introduced by a `### YYYY-MM-DD: <title>` markdown title, describing the *specific* error introduced by $ARGUMENTS and linking forward to it. Skip ADRs whose status is `Deprecated` or `Superceded`.
> 4. Mark $ARGUMENTS as `Accepted` and update both `docs/adr/README.md` and your inventory.
>
> If no prior ADRs are affected, say so explicitly in your report rather than inventing errata to justify the search.
