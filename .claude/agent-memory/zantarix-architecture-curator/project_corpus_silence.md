---
name: corpus-silence-is-not-an-open-question
description: This repo's ADR corpus postdates most of what it governs, so an unadmitted constraint is as likely to be settled-but-unrecorded as genuinely open
metadata:
  type: project
---

The decision records here are younger than the project. It ran on undocumented
decisions for a long time, and the first ADR was written only when a piece of work
got deep enough into design to need one. Workflow decisions — how the skills
compose, how planning is sequenced — were largely made and shipped before any
were being recorded.

**Why:** it inverts what silence means. In a mature corpus an unadmitted
constraint is usually one nobody committed to; here it is as often one committed
to before there was anywhere to write it down. Reading the absence as "open"
produces two errors — treating a settled convention as available to change, and
proposing an ADR for something already decided in practice.

**How to apply:**

- When the materiality gate finds no ledger entry and no ADR, do not conclude the
  question is open. Check whether the behaviour is already enforced in prompts,
  rules, or hooks; if it is, this is a **backfill gap**, and the honest framing is
  "admit a commitment already in force", not "decide something new".
- The shape for that is ADR-0006: dated today, Context stating plainly that no
  decision names it, Consequences honest that nothing is built by accepting it and
  that rejecting it means removing the enforcement rather than leaving things as
  they are.
- **Do not backfill in bulk.** The project converges on demand everywhere else —
  OKF compliance arrives by writing, a legacy corpus converges one erratum at a
  time — and backfill follows the same rule: write the missing decision when
  something needs to lean on it. A wholesale sprint would mean inventing
  alternatives for decisions nobody deliberated, which manufactures false history.
- The running list of known-unadmitted constraints lives in the living tier, not
  in memory: `docs/architecture/ticket-workflow.md` closes with the workflow ones,
  and `knowledge/overview.md` explains the gap.

See [[promoting-memory-to-prompts]] for the related hazard of writing down a rule
without the scope its origin supplied.
