---
type: Specification
title: Maintaining Living Documents
description: How overviews and specifications are kept current — which side yields when a document and the code disagree, and what a document's status asserts about the gap between them.
tags: [knowledge, living-documents, specifications, overviews, conformance]
generated: { by: architecture-curator/claude-opus-5, at: 2026-08-12T12:46:42Z }
status: stable
---

# Maintaining Living Documents

The contract for keeping the living tier current.
[ADR-0004](0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md)
drives it: that decision split immutable records from living documents and
required **every specification edit to cite the decision that drives it**. What
follows is that requirement's consequence when a document and the code disagree.

## The two are maintained differently

The citation requirement binds **specifications only**. An overview describes
where the project stands, so it follows reality by definition: when the code
moves, the overview is simply brought current, and no decision is needed to do
it. A specification states a contract, so changing it changes what the project
has committed to — which is why it cannot be edited without naming the decision
that authorised the change.

That asymmetry, not any difference in tone, is what separates the two in
practice.

## Which side yields

When a specification and the code disagree:

- **A decision authorised the change** → the specification yields. Update it in
  the same operation as the work, citing that decision.
- **No decision authorised it** → the specification stands, and the work is out
  of conformance.

This is what makes the citation requirement load-bearing rather than
bookkeeping: it is the rule that decides who is wrong. If you cannot name the
decision, you may not edit the contract to match the code.

Where the divergence looks *better* than the specification, that is not an
editing judgement — it is a materiality question. Surface it, and let the answer
be a decision or a rejection. Nobody moves a contract by writing code against it.

### A document never launders an unauthorised change

Some specifications are maintained views of something the code owns — a
dependency graph, a generated topology. These cannot simply "stand" when the
code moves, because an inaccurate view is useless. Resync them, and then flag the
undecided change separately: the resync keeps the view honest, and must not be
the act that makes an unauthorised change look settled.

### The carve-out

A document that is factually wrong about its own subject — a miscount, a stale
name, a mislabelled arrow — is just corrected. No decision is involved, because
nothing about the contract changed. The distinction is between a document being
**wrong about its subject** and a document and the code **embodying different
intentions**.

## What `status` asserts

For a living document, `status` states which direction a gap is expected to run:

| `status` | The document says | A divergence means |
|---|---|---|
| `draft` | this is the contract, not yet met | expected; the implementation has not caught up |
| `stable` | this is the contract, and it is met | a defect; the rule above says which side |

**Set it explicitly.** The format defaults `status` to `stable` when the key is
absent, so a specification written ahead of its implementation and left unmarked
silently asserts that the code already conforms — inverting the direction of
every divergence reported against it afterwards.

A specification promoted from `draft` to `stable` as its implementation lands
records the promotion as a `verified` event.
