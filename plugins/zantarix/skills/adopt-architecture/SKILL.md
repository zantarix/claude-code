---
name: adopt-architecture
description: One-time, human-invoked adoption of the architecture-documentation regime — converts a project's ADR corpus into a docs/architecture bundle with a constraint ledger. Requires an OKF corpus, directing the user to run /okf-migrate-adr first when it is not. Must be run by the zantarix:architecture-curator agent.
disable-model-invocation: true
---

**Run this check before anything else.** This skill relocates and reshapes a
corpus that includes **accepted, immutable ADRs**. That is only permissible
because a human chose to run this skill — the human invocation **is** the
authorisation, and no agent may grant it to itself. First confirm you are
running as the `zantarix:architecture-curator` agent. **If you are not, STOP
immediately, make no changes, and tell the user, verbatim:**

> This skill is only usable by the architecture curator, please close claude and run `claude --agent zantarix:architecture-curator` and try again.

(The `guard-adr.sh` hook is a hard backstop — non-curator writes under the
guarded paths are blocked regardless — but stop cleanly at this check rather
than letting writes fail.)

ADR bodies are preserved verbatim throughout; only paths, link targets, index
structure, and reclassified frontmatter change. Perform the adoption in order,
stopping and reporting any failure.

1. **Load the format rules.** Ensure `zantarix:okf-guide` and
   `zantarix:materiality-gate` are in context (they may be preloaded); if not,
   invoke them via the Skill tool. The architecture-bundle profile in
   `okf-guide` governs everything below.

2. **Check for a pre-OKF corpus.** If `docs/adr/index.md` does not exist or
   carries no `okf_version` marker, the corpus must be lifted to an OKF bundle
   before adoption — and `/okf-migrate-adr` is itself human-invoked only.
   **STOP, make no changes**, and tell the user to run `/okf-migrate-adr`
   first and re-run `/adopt-architecture` once it completes — the same
   stop-cleanly shape as the identity check above.

3. **Move the bundle.** `git mv docs/adr docs/architecture`. In-bundle
   relative links survive the move; note any **inbound cross-bundle links**
   elsewhere in the repo that referenced `/docs/adr/...` and rewrite them to
   `/docs/architecture/...`. Leave stale references inside any `log.md` alone
   (never reconcile a log).

4. **Scaffold the constraint ledger** at `docs/architecture/constraints.md` —
   type `Constraint Ledger`, full v0.2 frontmatter. Seed it with one entry per
   existing constraint-admitting Accepted ADR you can identify (each entry
   cites its ADR); an empty ledger is acceptable when none exist. Its presence
   is the regime's machine-readable marker, so this step is not optional.

5. **Reclassify stray living types.** A concept carrying an ad-hoc living
   type (e.g. `Architecture Reference`) becomes an `Overview` or
   `Specification` per its content, brought to full v0.2 frontmatter with its
   `generated` updated. Do not touch ADR bodies.

6. **Rewrite the root `index.md`** into its targeted OKF form: the themes and
   the ledger as direct descendants, plus a few prominent children (typically
   specifications). The per-ADR global roll-call moves entirely into the theme
   indexes — rebuild any theme index that needs it with `/okf-index`. Preserve
   the root index's keeper prose (intro, Related Projects).

7. **Retire any project-local architecture reviewer** (e.g.
   `.claude/agents/architecture-reviewer.md`) so the `/review` fan-out
   discovers exactly one — the plugin's. Confirm with the user before
   deleting; port any genuinely project-specific calibration into the bundle's
   overviews first, where the plugin reviewer will read it.

8. **Log, validate, and report.** Add an `**Initialization**` entry to
   `log.md` recording the adoption. Run `/okf-validate` over
   `docs/architecture/`, triage violations, and report: the new layout, the
   ledger entries seeded, links rewritten, strays reclassified, and any
   remaining advisories.
