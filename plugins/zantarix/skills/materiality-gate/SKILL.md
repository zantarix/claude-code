---
name: materiality-gate
description: Shared materiality test for architecture-regime bundles — decides whether a change newly constrains the project and therefore needs an ADR, or proceeds as specification work. Preloaded into the architecture-curator and architecture-reviewer agents so both apply one wording; not a standalone action.
---

# The materiality gate

One question decides where architectural work is recorded: **does this change
newly constrain the project?**

A change **newly constrains** when it forecloses an option that:

1. the bundle's **constraint ledger** (`constraints.md` at the bundle root)
   does not already foreclose, **and**
2. some plausible evolution of **this project** would want — judged from the
   bundle's overviews and the project's stated goals, never from general
   software practice.

Materiality is project-relative. A dependency that is an obvious requirement in
one project is a deliberate, contested commitment in another; the ledger and
overviews of *this* bundle are the only admissible reference.

## Routing

- **Newly constrains** → an ADR naming the commitment comes first; the
  mechanism lands in a specification citing that ADR. Exclusions are
  first-class: ruling something out ("rule out Windows support") constrains
  the project exactly as ruling something in does, and is admitted with the
  same ceremony.
- **Already covered by a ledger entry** → proceed as specification work, citing
  the covering entry, with the reasoning kept as a compact rationale note in
  the specification.
- **Tiebreaker** — a rationale note that grows an alternatives analysis is
  claiming to be a decision: promote it to an ADR.
- **Contested or unclear** → surface it to the human; never settle it yourself.
  The resolution — in either direction — lands in the ledger so the question
  is never re-litigated.

## Worked examples

- **First POSIX-only mechanism** (signal handling) in a client CLI: the ledger
  is silent on platforms, and Windows support is a plausible want for a CLI —
  *newly constrains* → ADR "Adopt POSIX as a requirement"; the signal-handling
  mechanics are specification material.
- **`flock` in the same project, later**: the ledger already carries the POSIX
  commitment, and advisory locking forecloses nothing further — *covered* →
  specification work, with a rationale note (e.g. `flock` over a PID lockfile)
  citing the POSIX entry.
- **An on-disk cache in a service whose ledger rules out filesystem
  dependence**: general practice says "obviously fine"; this project's ledger
  forecloses it — *contested* → surface to the human; the likely outcomes are
  a superseding ADR or a rejection, and either lands in the ledger.

## For the reviewer

Police the gate in both directions, flagging findings as **Major**:

- a specification or overview edit that newly constrains without an admitting
  ADR — an unadmitted decision smuggled into a living document;
- an ADR carrying enumerations, format tables, or other current-truth material
  that belongs in a specification — including a pre-regime **accepted** ADR
  whose current-truth material (call signatures, enumerations, formats) has
  since drifted. Flag this as an **extraction candidate** for the curator's
  errata-driven extraction, not as a documentation gap. This is a gate
  finding, not an erratum suggestion — you never write the erratum yourself —
  and it is **never** a reason to ask for a new ADR: only a contradicted
  *decision*, not stale current-truth material, warrants one.
