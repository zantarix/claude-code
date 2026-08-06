---
name: accept-adr
description: Human ratification gate for ADRs — marks a Proposed ADR Accepted, recording who ratified it. Human-invoked only; acceptance ratifies the document as written and never modifies its body.
disable-model-invocation: true
---

Acceptance is a **human decision**: running this skill is the act of
ratification, and no agent may perform it on its own initiative or as a step in
a workflow or implementation plan. The ADR being accepted must currently be
`Proposed`, and acceptance ratifies it **as written** — this skill changes the
ADR's frontmatter (`verified`, `status`) and its `## Status` line, and nothing
else in the document. Refinements belong in the ordinary Proposed-ADR flow
*before* this gate; if the document needs changes, it is not ready to accept.

Resolve the ratifier's identity first: the invoking user's username on the
project's forge (GitHub/GitLab), taken from their per-user `CLAUDE.md` when
stated there, otherwise from `gh api user --jq .login` (GitHub) or
`glab api user | jq -r .username` (GitLab). This id is recorded as
`human:<forge-username>` — never a display name.

Then delegate to the `@zantarix:architecture-curator` subagent and pass the
following prompt, substituting the ADR reference and the resolved identity:

> The human has ratified ADR $ARGUMENTS (forge identity: `human:<forge-username>`). Carry out the following steps in order:
>
> 1. Confirm $ARGUMENTS is `Proposed`. Acceptance ratifies the document **as written**: make no edits to its body. If reading it convinces you the body needs changes, STOP without accepting and report what needs to change — the refinement happens in the ordinary Proposed flow, and the human re-runs `/accept-adr` afterward.
> 2. Search back through previously accepted ADRs for any whose decisions or consequences are now functionally incorrect because of $ARGUMENTS. Use the canonical ADR index as the starting point — `docs/adr/README.md` and your inventory in legacy mode, or the bundle-root `index.md` in OKF and regime modes; read the candidates in full (errata can change context).
> 3. For each affected accepted ADR, add a single erratum following the rules in `rules/zantarix/adr.md` and your own Errata section — applying errata-driven extraction where the erratum concerns an enumeration or other current-truth passage. Skip ADRs whose status is `Deprecated` or `Superceded`.
> 4. In an OKF or regime bundle, record the ratification on $ARGUMENTS as `verified: { by: human:<forge-username>, at: <now> }` in its frontmatter.
> 5. In a regime bundle, if $ARGUMENTS is a constraint admission, write its constraint-ledger entry (citing the ADR) in the same operation.
> 6. Mark $ARGUMENTS as `Accepted` — the `status` frontmatter and the `## Status` body line — and update the index and history per your mode rules: `docs/adr/README.md` plus your inventory in legacy mode, or the bundle-root `index.md`/`log.md` (via `/okf-curate`) in OKF and regime modes.
>
> If no prior ADRs are affected, say so explicitly in your report rather than inventing errata to justify the search.
