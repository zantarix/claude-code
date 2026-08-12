---
name: erratum-timing-at-the-gate
description: When a living document already carries a Proposed ADR's reading, the erratum it owes an accepted ADR is overdue — land it at ratification and delete the ADR's scheduling bullet rather than rewording it.
metadata:
  type: feedback
---

An ADR that schedules its own erratum ("owed when this takes effect, not at
ratification") is usually wrong about itself when a specification in the bundle
already carries the new reading. That specification landing *is* the decision
taking effect, so the erratum has been overdue since that date — not pending.
Surface it at the gate, and when the human agrees, **delete the scheduling
bullet** rather than rewriting it into a truer one.

**Why:** confirmed by `human:mscharley` at ADR-0007's ratification (2026-08-13),
where `living-documents.md` had carried the `draft`/`stable` conformance table
since 2026-08-12. ADR-0004's "untracked by design" record had been reading
falsely for a day. The bullet was scheduling, not decision content — nothing was
lost by removing it, and rewording would have frozen a fact about bookkeeping
into an immutable record. The competing "is it in force yet?" framing is a trap;
the operative test is bar test #5 — would a reader of the body *and its errata*
conclude something false today.

**How to apply:** during `/accept-adr` step 1, check whether any living document
already implements the ADR being ratified. If one does, treat any
erratum-deferral language in the ADR as a step-1 discrepancy, propose deleting
it, and write the erratum in the same pass.

The check is whether a **living document** already carries the reading — never
whether a *prompt* implements it. Prompts lagging is a plain conformance gap: it
neither defers the erratum, nor withholds ratification, nor licenses relabelling
the specification that states the contract. `stable` is what correctly calls that
gap a defect; flipping it to `draft` would excuse the prompts, and doing so
mid-gate is an unauthorised edit besides. I made exactly that error at ADR-0007's
ratification and reverted it. See [[proposed-as-trial]] for the converse case,
where an ADR is deliberately left `Proposed`.
