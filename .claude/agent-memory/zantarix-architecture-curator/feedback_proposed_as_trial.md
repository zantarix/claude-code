---
name: proposed-as-trial
description: Proposed status as a trial period — write the ADR now for a decision they are not ready to commit to, rather than deferring the write until they are sure.
metadata:
  type: feedback
---

When a decision is real but provisional — "this is something that needs testing
out in practice" — write the ADR immediately and leave it `Proposed`. Do not
defer writing it, and do not suggest ratification.

**Why:** `Proposed` already means "under discussion", and the regime decouples
ratification from implementation, so the status carries provisionality with no
extra machinery. Deferring the write leaves the living tier quietly asserting an
answer with no decision behind it, which is exactly the unadmitted-decision
failure the materiality gate exists to catch.

**How to apply:** Say so in the theme overview's "In flight" section, precisely —
name what carries the reading (usually the bundle) and what does not yet (usually
the distributed prompts). Keep the Decision section unhedged; the status does the
hedging. Where the decision would earn a ledger entry, note that the entry and
any owed errata fall due when it takes effect, and leave the contested call to
the human at ratification. See [[human-gates]] for why the ratification step is
never yours to take.
