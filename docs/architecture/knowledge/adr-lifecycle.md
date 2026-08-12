---
type: Specification
title: ADR Lifecycle
description: The stages an architecture decision passes through — drafting, pre-acceptance review, human ratification, and post-acceptance correction — and which of them may change the document.
tags: [knowledge, adr, lifecycle, acceptance, errata]
generated: { by: architecture-curator/claude-opus-5, at: 2026-08-12T10:05:09Z }
status: stable
---

# ADR Lifecycle

The contract for how a decision record moves from draft to permanent, and what may
change it at each stage. The tier split it sits inside — decisions immutable,
living documents current — is
[ADR-0004](0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md)'s;
the ratification rules below are
[ADR-0005](0005-ratify-adrs-in-concert-with-the-human.md)'s and
[ADR-0006](0006-require-a-curator-session-for-adr-ratification.md)'s.

## Stages

| Stage | Who acts | May the body change? |
|---|---|---|
| Drafting | curator, delegated or direct | Yes, freely |
| Pre-acceptance review | architecture-reviewer advises; curator folds | Yes, by the curator |
| Ratification | human, in a curator session | Only as the human directs |
| After acceptance | curator | No — errata and supersession only |

## Drafting

The curator writes the document, in a fixed section order: the skeleton, then
Decision, then the theme overview brought current, then Context, then
Consequences. The order exists because generated prose stays disciplined when it
is checked against a referent already written down, and because current-state
material lands in the overview rather than being regenerated inside the ADR.

A `Proposed` ADR is not yet immutable, so a follow-up that tightens a design the
ADR already owns is folded into its body rather than spawning a successor. This is
not errata; errata are for frozen documents.

Implementation may begin while an ADR is `Proposed`. Nothing about ratification
gates the code, and findings from building the thing are inlined into the document
under the same refinement rule.

## Pre-acceptance review

Every ADR is reviewed by the `zantarix:architecture-reviewer` before it is
ratified. The curator delegates the written file, treats the findings as advisory,
and folds anything substantive into the appropriate section in its own words.

Reviewers do not write errata and do not propose them. A reviewer that finds a
*decision* contradicted raises it as a concern that may warrant a new ADR; one
that finds *current-truth material* — an enumeration, a call shape, a format —
that has drifted raises it as an extraction candidate.

Specifications and overviews have no dedicated gate. They are reviewed by the
ordinary `/zantarix:review` fan-out on the branch that carries them.

## Ratification

The human runs `/accept-adr` in a session the curator is driving. The gate is
theirs: no agent initiates it, and it performs nothing in any other session.

Ratification records that the human accepted the **direction**. It is not a claim
that anything was built, and a conformance gap — a surface that does not yet
comply — is neither a reason to withhold ratification nor something to correct
here.

### When the document is wrong about itself

A document that misstates its own decision, or carries a consequence the project
has since falsified, may be corrected during ratification. The sequence is fixed:

1. The curator surfaces the discrepancy and may propose wording.
2. The human directs the change, or declines it.
3. The curator applies exactly what was directed and shows the result.
4. The human ratifies the text they have now read.

The curator never decides to amend, and never amends silently. What makes this
safe is step 4 rather than any property of step 3: the guarantee ratification
carries is that the human saw the text that froze.

Whether an amendment has widened the reviewed surface enough to warrant re-running
the review is the human's call, made with the reviewer's findings in hand.

### The accompanying sweep

Ratification also sweeps previously accepted ADRs for claims this decision
falsified, writes any errata owed, and — for a constraint admission — records the
ledger entry citing the ADR. A topology decision admits no entry.

## After acceptance

The document is immutable. Two mechanisms carry it forward:

- **Errata** record that a specific passage became functionally incorrect, one
  paragraph each, linking forward to whatever now holds the correct position.
- **Supersession** replaces a decision whose direction has changed; the superseded
  ADR takes no further errata, because the supersession is the treatment.

Errata are owed when the decision that falsifies a claim takes effect, which is
not always at that decision's ratification. Where implementation lands first, the
erratum lands with it — otherwise an accepted ADR describes shipped behaviour
falsely for however long ratification takes. A still-`Proposed` ADR whose own text
schedules the erratum is updated in the same pass, so the corpus stays
self-consistent either way.

Where the incorrect passage is current-truth material rather than a decision, it
is extracted into a specification and the erratum records the extraction and its
destination. The destination is written first, so the forward link is verifiable
when it is written.
