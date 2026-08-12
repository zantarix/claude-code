---
type: Architecture Decision
title: Require a Curator Session for ADR Ratification
description: Admits the standing commitment that the human-authorisation gates over an architecture bundle run only in a session driven by the architecture curator, foreclosing delegated and non-interactive ratification.
tags: [knowledge, adr, acceptance, human-gate, agents]
generated: { by: architecture-curator/claude-opus-5, at: 2026-08-12T10:05:09Z }
verified: { by: human:mscharley, at: 2026-08-12T11:09:41Z }
status: Accepted
---

# ADR-0006: Require a Curator Session for ADR Ratification

## Status

Accepted (2026-08-12)

## Context

The tooling already behaves this way. All three human-authorisation gates refuse to run outside a curator session, and the hook guarding the bundle admits the curator whether it was delegated to or started directly ([orchestration overview](../orchestration/overview.md)). Two of the gates have carried the check since before the regime existed; the third gained it while the surrounding prompts were being revised.

No decision names it. [ADR-0004](0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md) made ratification a human gate and gave it `disable-model-invocation`, which establishes that a model may not invoke the skill — a different and weaker claim than that only one kind of session may run it. The [constraint ledger](../constraints.md) carries one entry, for the knowledge format, and says nothing about how decisions are ratified.

The gap surfaced through [ADR-0005](0005-ratify-adrs-in-concert-with-the-human.md), which relies on the human being reachable mid-ratification and is unsound without it. A decision resting on a constraint the project has never admitted is resting on a convention that any later change could remove without noticing what it broke, which is the condition the ledger exists to prevent.

What is foreclosed is real rather than theoretical: acceptance driven from a script, from CI, or from a general session delegating to the curator are all plausible things a project might later want, and each is ruled out here.

## References

- [accept-adr skill](../../../plugins/zantarix/skills/accept-adr/SKILL.md)
- [guard-adr.sh hook](../../../plugins/zantarix/scripts/guard-adr.sh)

## Decision

A human-authorisation gate over an architecture bundle runs only in a session the architecture curator is driving. Reached any other way it performs nothing and returns a redirect carrying the attempted invocation, so the human's next action both opens a curator session and re-runs what they asked for.

The commitment is to **an interactive human gate**, and it forecloses the alternatives deliberately: ratification cannot be delegated to a subagent, scripted, or run from automation, and no path exists by which an ADR reaches `Accepted` without a person present in the session that marks it.

This covers the gates that mutate accepted, immutable records — ratification, regime adoption, and format migration. It does not reach ordinary curation, which is delegated to the curator as a subagent in the usual way.

## Consequences

### Positive

- Ratification keeps a participant who can be asked, which is what lets a discrepancy be resolved rather than merely reported.
- The commitment becomes visible to the materiality gate, so a later change that would remove it has to argue against a stated position instead of silently reinterpreting a convention.
- The redirect makes the constraint cost the human one paste rather than a lookup, because it carries the invocation they attempted.

### Negative

- Ratifying several ADRs means a curator session each time, or one session held open across them; neither is as cheap as accepting from wherever the work already is.
- Any future automation over acceptance is foreclosed, including uses that would be uncontroversial — batch status reconciliation after a long review, for instance.
- The constraint lives in prompt text and is therefore advisory at the point of check. The bundle's write hook is the backstop, but it guards *writes to the bundle*, not the act of ratifying, so a sufficiently determined path around the skill is not mechanically stopped.

### Neutral

- This admits a commitment the tooling already enforces; nothing is built by accepting it, and rejecting it would mean removing the guards rather than leaving things as they are.
- The scope is the bundle's human-authorisation gates. Ordinary curation continues to be delegated to the curator as a subagent, which the guarding hook admits equally.

## Alternatives Considered

### Leave it as convention

Keep the guards in the skills and admit nothing, on the grounds that the behaviour is already uniform and nobody is arguing with it. Rejected because [ADR-0005](0005-ratify-adrs-in-concert-with-the-human.md) makes it load-bearing: a decision that relaxes the ratification freeze is sound only while the human is reachable at the gate, so the reachability has to be something the project has committed to rather than something three prompts happen to agree on. An unadmitted constraint is also invisible to the materiality gate, which is the one mechanism that would otherwise catch its removal.

### Allow delegated ratification, and rely on the write hook

Let `/accept-adr` run anywhere and delegate to the curator as a subagent, trusting the bundle's write hook to keep authorship correct. This is the arrangement that preceded the guards and it costs the human nothing. Rejected because the hook enforces *who writes*, not *who is present*, so it permits exactly the topology that makes a discrepancy unresolvable: the subagent finds a defect, cannot ask, and reports upward into a session that has to rebuild the finding. The property this decision needs is presence, and no hook expresses it.

### Gate on interactivity rather than on the agent

Require only that a human be reachable — any session with a person in it — rather than naming the curator specifically. This is the narrower constraint and would leave batch curation from a general session available. Rejected because the gate's work is curatorial: it sweeps the corpus for falsified claims and writes errata, which the curator's own procedure and the bundle's write hook both assume. A gate that admits a non-curator session would either have to delegate that work, reintroducing the boundary, or perform it without the prompt that governs it.
