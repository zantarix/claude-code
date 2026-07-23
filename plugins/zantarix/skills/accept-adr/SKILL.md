---
name: accept-adr
description: Use when asked to accept a particular ADR
---

Delegate to the `@zantarix:adr-architect` subagent and pass the following prompt:

> Accept ADR $ARGUMENTS. Carry out the following steps in order:
>
> 1. Review the implementation of $ARGUMENTS for completeness and inline any minor updates that emerged during implementation directly into the ADR (it is still `Proposed`, so inline edits are appropriate).
> 2. Before marking it accepted, search back through previously accepted ADRs for any whose decisions or consequences are now functionally incorrect because of $ARGUMENTS. Use the canonical ADR index as the starting point — `docs/adr/README.md` and your inventory in legacy mode, or `docs/adr/index.md` in OKF mode; read the candidates in full (errata can change context).
> 3. For each affected accepted ADR, add a single erratum following the rules in `rules/zantarix/adr.md` and your own Errata section: one paragraph, introduced by a `### YYYY-MM-DD: <title>` markdown title, describing the *specific* error introduced by $ARGUMENTS and linking forward to it. Skip ADRs whose status is `Deprecated` or `Superceded`.
> 4. Mark $ARGUMENTS as `Accepted` and update the index and status per your mode rules — both `docs/adr/README.md` and your inventory in legacy mode, or the `status` frontmatter plus `docs/adr/index.md`/`log.md` (via `/okf-curate`) in OKF mode.
>
> If no prior ADRs are affected, say so explicitly in your report rather than inventing errata to justify the search.
