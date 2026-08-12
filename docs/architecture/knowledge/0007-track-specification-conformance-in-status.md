---
type: Architecture Decision
title: Track Specification Conformance in Status
description: Narrows the format's lifecycle status on an architecture specification to the contract's realisation in code, requires the field to be set explicitly, and records promotion to stable as a verified event.
tags: [knowledge, living-documents, specifications, conformance, okf]
generated: { by: architecture-curator/claude-opus-5, at: 2026-08-13T14:52:20Z }
verified: { by: human:mscharley, at: 2026-08-12T21:58:09Z }
status: Accepted
---

# ADR-0007: Track Specification Conformance in Status

## Status

Accepted (2026-08-13)

## Context

[ADR-0004](0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md)
parked this question when it created the regime, naming specification-level
implementation tracking an open problem explicitly out of scope and recording
that whether a contract is realised in code is untracked by design.

Its citation requirement has since been worked through into a rule that assigns
fault: where a specification and the code disagree, the specification yields if a
decision authorised the change and otherwise stands, leaving the work out of
conformance ([knowledge overview](overview.md)). A rule that calls every
divergence somebody's fault has to know whose, and nothing on the document tells
it — a contract not yet built and a contract that has been broken read
identically. Neither is hypothetical: ratification is decoupled from
implementation, so specifications are routinely written ahead of the code, and
the bundle has produced such documents since the regime was adopted.

OKF v0.2 supplies `status` as a lifecycle vocabulary and `verified` as a record
of confirmation events, and defines no field for a document's relationship to
code. The spec admits arbitrary extension keys; the house style adopted by
[ADR-0003](0003-adopt-okf-v0-2-house-style.md) declines to invent them.

## References

- [OKF SPEC (vendored, v0.2)](../../../plugins/zantarix/skills/okf-guide/SPEC.md)
- [okf-guide skill](../../../plugins/zantarix/skills/okf-guide/SKILL.md)

## Decision

In an architecture bundle, a specification's `status` answers the format's
lifecycle question **about the contract**: `draft` says the contract is not yet
true of the system, so a divergence is expected; `stable` says it is, so a
divergence is a defect and the conformance rule decides which side yields.

This narrows the general meaning rather than replacing it: a contract the code
does not meet is not settled by any reading, so `stable` goes on claiming
everything it claims elsewhere and adds that the system matches the document.
[Maintaining Living Documents](living-documents.md) carries the reading value by
value and keeps it current as the vocabulary changes.

### The field is set explicitly

Every specification sets `status`. Silence is not neutral — the format reads an
absent value as `stable`, and under this reading that settles the code too.

### Promotion is a verification event

A specification promoted from `draft` to `stable` as its implementation lands
records the promotion as a `verified` event naming the actor that confirmed it,
on the usual actor convention. There the record says the code met the contract,
where on a decision it says who ratified the direction.

### The value follows the contract, not the code

A specification returns to `draft` only where a decision authorised a change it
has not caught up to. An unauthorised divergence is never resolved by
relabelling the document, which is the laundering the conformance rule already
forbids.

### Scope

The narrowing applies only where a contract exists to be met: inside an
architecture bundle, to specifications. Elsewhere — another bundle family, and an
overview or the constraint ledger within this one, both of which describe reality
rather than binding it — the general meaning stands unnarrowed.

## Consequences

### Positive

- A divergence becomes actionable by whoever finds it: the expected direction is
  read off the document rather than reconstructed, on fields every concept
  already carries.
- Writing a contract ahead of its implementation stops being self-falsifying,
  which is what the regime's sequencing asks for — a specification can land with
  the ratified decision without claiming the code already follows it.
- Promotion leaves a dated, attributed record that the code met the contract, a
  claim about the system that previously had nowhere to live.
- Nothing outside the regime has to learn anything. Narrowed rather than
  redefined values leave a general reader — an `okf-*` skill, another bundle's
  conventions — never wrong about an architecture specification, only less
  specific.

### Negative

- The narrowing is invisible in the field itself. A reader who knows only the
  general meaning takes `stable` for a settled document without learning it also
  claims the system matches, and reads a `verified` event as a check on the text
  rather than on the code — thinner than intended in both cases, if not wrong.
- `stable` is unverifiable. Nothing checks the code against the contract, so a
  specification whose implementation regresses goes on claiming conformance until
  somebody notices, and the claim cannot be withdrawn without either fixing the
  code or deciding to change the contract.
- The claim is all-or-nothing. A `stable` specification extended under a new
  decision misstates one side or the other until the extension lands, because per
  document granularity cannot say "met, except the clause added last week".
- `draft` no longer says why. A document still being written and a contract
  waiting on its implementation now carry the same value, distinguishable only
  from the prose around it — the price of folding both into one field instead of
  answering them separately.

### Neutral

- Withdrawing the reading is cheap: one specification and values every concept
  already sets carry it, so abandoning it is an edit rather than a migration.
- Conformance still is not a property of a decision. An ADR remains ratified or
  not, and how much of it has been built is read from the specifications it
  drives.

## Alternatives Considered

### Leave conformance untracked

Hold [ADR-0004](0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md)'s
position and let the relationship between a specification and the code stay
unstated. Rejected because the rule that assigns fault on a divergence is already
in force and cannot be applied without the direction, so the question is answered
in practice on every report whether or not a document answers it — silently, by
whoever is reading, and differently each time.

### A dedicated conformance key

Add a frontmatter key stating the code relationship and leave `status` its
general lifecycle meaning, on the reading that these are two independent facts
deserving two fields. Rejected because they are not independent: a contract the
code does not meet has not settled, so the second key would split one question
across two values and licence them to disagree. It also invents a key the house
style declines to invent, and leaves the default hazard in place — `status` would
go on reading as `stable` when absent, claiming settlement beside a conformance
key that said nothing.

### A conformance note in the specification body

State where the code stands in prose, at the head of the document, and touch no
frontmatter at all. Rejected because it is the only one of these options a reader
can skip: the claim would sit inside the document making the claim, invisible to
an index, a sweep, or anything reading concepts by their metadata, and it would
leave the format's `stable` default asserting conformance underneath the prose
that denied it.

### Track conformance clause by clause

Mark individual contract clauses rather than the document, so a partly built
specification is described precisely. Rejected because the contract is what
binds and the clause is not addressable: this is the sub-decision addressability
[ADR-0004](0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md)
already rejected inside ADRs, at a bookkeeping cost that scales with every edit.

### Leave the judgement to the reviewer

Let the `architecture-reviewer` work out from the driving decision and the
repository's history whether a gap was expected. Rejected because it reconstructs
an intention the author knew at the time of writing, which is precisely the work
the living tier exists to make unnecessary, and because it serves one reader: a
human comparing a specification against the code gets nothing.
