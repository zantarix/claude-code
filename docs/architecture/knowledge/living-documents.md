---
type: Specification
title: Maintaining Living Documents
description: How overviews and specifications are kept current — what separates the two, which side yields when a document and the code disagree, and what a specification's status asserts about where the code stands against it.
tags: [knowledge, living-documents, specifications, overviews, conformance]
generated: { by: architecture-curator/claude-opus-5, at: 2026-08-13T14:52:20Z }
status: stable
---

# Maintaining Living Documents

The contract for keeping the living tier current.
[ADR-0004](0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md)
drives it: that decision split immutable records from living documents and
required **every specification edit to cite the decision that drives it**. What
follows is what separates the two kinds, and that requirement's consequence when
a document and the code disagree.

## What separates the two

The separator is **scope**, not whether a document binds. A specification is one
named subject in depth — a contract, a vocabulary, or a maintained view of
something the code owns. An overview is a theme's whole orientation, which links
out to that depth rather than restating it.

How each is maintained follows from that scope. A contract about one subject
states what the project has committed to, so changing it changes what the project
is held to — which is why a specification cannot be edited without naming the
decision that authorised the change. A theme's orientation is not a contract; it
describes where the project stands and so follows reality by definition, and when
the code moves the overview is simply brought current with no decision needed.

The citation requirement therefore binds **specifications only** — as a
consequence of what a specification is, not as the test for telling the two
apart.

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

On a specification, `status` answers the format's lifecycle question about the
**contract** and not only about the prose carrying it: a contract the code does
not meet is not settled either, so the regime's reading narrows the general one
instead of replacing it
([ADR-0007](0007-track-specification-conformance-in-status.md)). The value
therefore states the direction a gap is expected to run:

| `status` | The document says | A divergence means |
|---|---|---|
| `draft` | this is the contract, not yet met | expected; the implementation has not caught up |
| `stable` | this is the contract, and it is met | a defect; the rule above says which side |
| `deprecated` | this contract has been retired | nothing; it binds nobody |

**Set it explicitly.** The format defaults `status` to `stable` when the key is
absent, so a specification written ahead of its implementation and left unmarked
silently asserts that the code already conforms — inverting the direction of
every divergence reported against it afterwards.

A specification promoted from `draft` to `stable` as its implementation lands
records the promotion as a `verified` event, naming who confirmed the code met
the contract and when.

**The value follows the contract, not the code.** A specification returns to
`draft` only where a decision authorised a change it has not yet caught up to —
the same authorisation any other edit to it requires. Where the code has simply
diverged, the divergence is the defect; relabelling the document is the
laundering forbidden above.

An overview and the constraint ledger carry `status` as well, but they describe
reality rather than binding it, so the general lifecycle reading stands on them.
