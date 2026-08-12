---
name: accept-adr
description: Human ratification gate for ADRs — marks a Proposed ADR Accepted, recording who ratified it. Human-invoked only, in a curator session; acceptance ratifies the text the human reads and amends the body only as they direct.
disable-model-invocation: true
---

**Guard — this skill runs only in a curator session.** If you are not the
`zantarix:architecture-curator` agent, stop here: make no edits, and do not
delegate to the curator as a subagent. Report exactly this, substituting the
arguments you were given:

> This is not a curator session. Please start one with
> `claude --agent zantarix:architecture-curator '/accept-adr $ARGUMENTS'`

Ratification is a conversation: a discrepancy found mid-acceptance has to be put
to the human, which a subagent cannot do without losing the context that found
it.

Acceptance is a **human decision**: running this skill is the act of
ratification, and no agent may perform it on its own initiative or as a step in
a workflow or implementation plan. The ADR being accepted must currently be
`Proposed`.

The guarantee acceptance carries is that **the human saw the text that froze**.
The document may therefore be corrected during ratification — but only where the
human directs the correction and then reads the result. You never decide to amend,
and you never amend silently.

Resolve the ratifier's identity first: the invoking user's username on the
project's forge (GitHub/GitLab), taken from their per-user `CLAUDE.md` when
stated there, otherwise from `gh api user --jq .login` (GitHub) or
`glab api user | jq -r .username` (GitLab). This id is recorded as
`human:<forge-username>` — never a display name.

Then carry out the following steps in order, for the ADR named in `$ARGUMENTS`.

1. **Confirm it is `Proposed`, and read it in full.** Amendment answers a document
   that is wrong **about itself** — a Decision that misstates what was decided, or
   a Consequence the project has since falsified. Where you find one, follow this
   sequence and no other:

   1. Surface the discrepancy to the human. You may propose wording.
   2. The human directs the change, or declines it.
   3. Apply exactly what was directed, and show the result.
   4. Ratify the text the human has now read.

   If they decline, ratify the document as it stands — the decision is theirs, not
   yours. Whether an amendment has widened the reviewed surface enough to warrant
   re-running the architecture review is also their call.

   A **conformance gap is not grounds to amend or to stop.** That the code has not
   caught up, or that some surface does not comply, says nothing about whether the
   decision is the right one; confirm the gap is tracked and proceed. An ADR is
   ratified as a *decision*, with the understanding that gaps exist.

2. **Sweep previously accepted ADRs** for any whose decisions or consequences
   this one renders functionally incorrect. Start from the canonical index —
   `docs/adr/README.md` and your inventory in legacy mode, the bundle-root
   `index.md` in OKF and regime modes — and read candidates in full, since
   errata change context. To find the sweep set:

   - Grep the corpus for this decision's **mechanism vocabulary**, then run a
     second, **orthogonal** grep to settle "no others"; classify each hit as
     descriptive or contractual.
   - Sweep the **behavioural axis** as well as the text axis. A relocation or
     timing change surfaces from no grep at all; the trigger is this ADR's own
     Consequences saying the old behaviour was X and now is not-X, at which
     point you open the ADR that *owns* that behaviour and check whether it
     stated X as a design property.
   - Where ownership moved, grep for **placement phrasing** and for **rejected
     placement alternatives**, not merely the ADRs this one cites — the clearest
     errata are usually the ones the new ADR never name-drops.
   - Grep other ADRs' **errata entries**, not only their bodies.
   - Where a list of likely-affected ADRs was pre-computed — carried in the ADR
     body, in the ticket, or in your memory — treat it as wrong in both
     directions, and let the files decide.

3. **Write the errata**, following the rules in `rules/zantarix/adr.md` and your
   own Errata section, applying errata-driven extraction where the erratum
   concerns an enumeration or other current-truth passage. Skip ADRs whose
   status is `Deprecated` or `Superceded`. Where several ADRs are falsified by
   one change, correct them all — a partial fix leaves a sibling still
   affirming the guarantee you just retired, which reads worse than deferring
   the whole set. Where
   an erratum was already landed alongside the implementation, verify it exists
   rather than adding a duplicate.

4. **Record the ratification** — in an OKF or regime bundle, `verified: { by:
   human:<forge-username>, at: <now> }` in the frontmatter, stamped from a real
   `date -u`.

5. **Write the ledger entry.** In a regime bundle, if this is a constraint
   admission, record it in `constraints.md` citing the ADR, in the same
   operation. Carry over the decision's exclusions and nothing else — the ledger
   takes no conformance notes.

6. **Mark it `Accepted`** — the `status` frontmatter and the `## Status` body
   line, edited directly. This step touches nothing else in the document — any
   correction was made and read at step 1. Then update the
   index and history per your mode: `docs/adr/README.md` plus your inventory in
   legacy mode, or the bundle-root `index.md`/`log.md` in OKF and regime modes.

   Use `/okf-curate` for the **index and log only** here. Its normal contract
   rewrites the concept into full current-house-style compliance, which is
   exactly what acceptance must not do to a document a human has just ratified;
   this is the one flow where that step is skipped.

If no prior ADRs are affected, say so explicitly rather than inventing errata to
justify the search.
