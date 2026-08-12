---
type: Architecture Decision
title: Ratify ADRs in Concert with the Human
description: Permits ratification to amend an ADR's body when the ratifying human directs it in session, replacing the freeze-before-the-gate mechanism with visibility of the final text.
tags: [knowledge, adr, acceptance, human-gate, workflow]
generated: { by: architecture-curator/claude-opus-5, at: 2026-08-12T09:50:49Z }
verified: { by: human:mscharley, at: 2026-08-12T11:09:41Z }
status: Accepted
---

# ADR-0005: Ratify ADRs in Concert with the Human

## Status

Accepted (2026-08-12)

## Context

[ADR-0004](0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md) made ratification a human gate and fixed how it behaves: acceptance changes an ADR's status and verification record "and nothing else, so what the human reviewed is exactly what freezes." The clause states a guarantee and a mechanism together. The guarantee is that the ratified text is the text the human read; the mechanism is that the document cannot change at the gate at all.

Freezing the document delivers that guarantee under any topology, and when ratification ran across a delegation boundary it was the only thing that could: a subagent finding a defect mid-acceptance could ask no one. Every gate now runs in a session the human shares with the curator ([orchestration overview](../orchestration/overview.md)), so a discrepancy can be put to the person ratifying while the reasoning that found it is still live, and the guarantee has a second route.

What the freeze still costs is ceremony. A human wanting to ratify a document with one sentence corrected must abandon the gate, have the correction made, and start again — and the pressure is not hypothetical, because the acceptance read is the first end-to-end read a decision gets after implementation has taught the project something. Falsified claims surface there, and the discipline that an ADR is judged on what it decides has such a claim deleted rather than repaired: a body edit at precisely the moment the gate forbids one.

## References

- [accept-adr skill](../../../plugins/zantarix/skills/accept-adr/SKILL.md)
- [architecture-curator agent](../../../plugins/zantarix/agents/architecture-curator.md)

## Decision

Ratification may amend the ADR it ratifies, when the ratifying human directs the amendment in the same session. The guarantee ratification carries is that **the human saw the text that froze** — satisfied by their reading the final document, not by the document having been frozen before the gate opened.

### What the human directs, the curator writes

An amendment originates with the human. The curator may surface a discrepancy and propose wording; it may not decide to amend, and an amendment the human did not direct and has not seen is forbidden here as anywhere else. The sequence this implies is the [ADR lifecycle](adr-lifecycle.md)'s.

### What this leaves of the freeze

[ADR-0004](0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md) stated the guarantee and its mechanism in one clause: acceptance changes status and verification "and nothing else, so what the human reviewed is exactly what freezes." The guarantee survives unchanged and is the reason this decision holds. The mechanism does not: the document may change at the gate. Every other property of that gate — human-only initiation, `verified` recording the ratifier, the ledger entry for a constraint admission, immutability from acceptance — stands as written.

### Scope

Amendment answers a document that is wrong **about itself**: a Decision that misstates what was decided, or a Consequence the project has since falsified. Where instead the world has not caught up with the document — a surface that does not yet comply — nothing is amended and nothing is withheld, because an ADR is ratified as a decision and the code catching up is separate work ([ADR-0004](0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md)). Errata are unaffected: they are additive records on a frozen document, and a decision whose direction has changed is superseded rather than amended.

## Consequences

### Positive

- A discrepancy found at the gate is resolved where it was found, at the cost of the sentence it concerns, instead of costing an abandoned gate and a restart that reaches the same text by a longer road.
- The document a human ratifies can be correct. Under the freeze, a defect found at the gate could only be ratified as-is or not at all, so the corpus took a known-wrong sentence into permanence whenever the restart was judged not worth it.

### Negative

- The human becomes the only check on what changed. Nothing in the bundle records that the ratified text differs from the text the review saw — git does, where the Proposed draft was committed, but that is outside the record a reader of the ADR consults.
- Ratification stops being mechanical, so "accepted" no longer implies the body is exactly what the reviewer read — and the judgement it now requires is asked for at the end of a long session, on a document the human has already decided to accept.

### Neutral

- The pre-acceptance review is unchanged. Whether an amendment has widened the reviewed surface enough to warrant re-running it is the ratifying human's call, made with the reviewer's findings in hand; this decision waives no review.
- Nothing here touches immutability after acceptance. The window is the ratification act itself; a frozen document is corrected by erratum or replaced by supersession exactly as before.
- This decision is unsound without a human reachable at the gate, a constraint [ADR-0006](0006-require-a-curator-session-for-adr-ratification.md) admits rather than this one.

## Alternatives Considered

### Keep the freeze and refine in the Proposed flow

Leave the gate mechanical: a discrepancy stops acceptance, the curator corrects the document as an ordinary Proposed-ADR refinement, and the human re-runs the gate over the corrected text. With the session guard in place this no longer loses context, so the cost is only the ceremony of stopping and restarting. Rejected because the ceremony is the whole of it: the same person, in the same session, reads the same correction and approves it either way, and the restart records nothing the amendment does not. It also preserves a distinction the reader cannot see — a document corrected one turn before ratification and one corrected one turn after are indistinguishable in the artefact.

### Report a diff and apply it on a second run

Forbid amendment at the gate, but have the curator return the exact replacement text for the human to approve; a second invocation applies that text verbatim and ratifies. This is strictly stronger on paper — the human approves literal text rather than an intent — and needs no change to the freeze. Rejected because the strength is nominal once the human is in the session: they see the literal text in either design, and the second invocation exists only to satisfy the letter of the mechanism. It also degrades as the correction grows, since a multi-sentence repair is reviewed more clearly in place than as a quoted block.

### Verify that the review ran, and ratify without reading

Make the gate cheap by construction: check that the pre-acceptance review happened and that the document has not changed since, then flip the fields without a fresh read. Defects would surface in review, where they are cheapest. Rejected because it removes the last read before permanence in order to protect a mechanism, and that read is not redundant — it is the first end-to-end read after implementation, and implementation is what falsifies claims.
