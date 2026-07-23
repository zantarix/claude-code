---
name: okf-migrate-adr
description: One-time migration of an existing ADR library into an OKF (Open Knowledge Format) bundle. Human-invoked only; must be run by the zantarix:adr-architect agent.
disable-model-invocation: true
---

**Run this check before anything else.** This skill mutates **accepted, immutable
ADRs** as a one-time, content-preserving format lift. That is only permissible
because a human chose to run this skill — the human invocation **is** the
authorisation, and no agent may grant it to itself. First confirm you are running
as the `zantarix:adr-architect` agent. **If you are not, STOP immediately, make
no changes, and tell the user, verbatim:**

> This skill is only usable by the ADR architect, please close claude and run `claude --agent zantarix:adr-architect` and try again.

(The `guard-adr.sh` hook is a hard backstop — non-architect writes under
`docs/adr/` are blocked regardless — but stop cleanly at this check rather than
letting writes fail.)

Once confirmed as the architect: for the duration of this migration, treat every
ADR — including accepted ones — as in-scope to reshape. Bodies are preserved
verbatim; only paths, link targets, numbering width, and added frontmatter change.

Perform the migration in order, stopping and reporting any failure.

1. **Load the format rules.** Ensure the `zantarix:okf-guide` reference is in
   context (it may be preloaded); if not, invoke the `zantarix:okf-guide` skill.
   Follow its house style.

2. **Decide the theme taxonomy** (human judgment — confirm with the user). Read
   every ADR's title and summary and cluster them into ~8–15 themes; assign each
   ADR, including cross-cutting ones, a single primary theme. This is the one
   non-mechanical step; do not automate it away.

3. **Derive frontmatter** for each ADR: `type: Architecture Decision`, `title`
   from the H1, `status` and its date parsed from the `## Status` section,
   `timestamp`, `tags` (theme plus topics), and a one-sentence `description`. For
   a large library, fan out **read-only** proposer agents to draft
   `{title, description, theme, tags}` per ADR in parallel and apply their output
   yourself — read-only agents raise no `guard-adr.sh` conflict.

4. **Move, re-number, and re-link.**
   - `git mv` each ADR into its theme subdirectory.
   - **Re-pad the number 3-digit → 4-digit** (`042` → `0042`) in the filename, the
     `# ADR-NNNN:` H1, and every in-body `ADR-NNN` reference — the OKF clean break.
   - Rewrite cross-references: same-theme links stay bare filenames; cross-theme
     links become `../<theme>/<file>.md`.
   - Rewrite **inbound cross-bundle links** elsewhere in the repo that referenced
     `/docs/adr/NNN-…` (e.g. from a sibling OKF bundle) to the new path and width.
     Leave stale references inside any `log.md` alone (never reconcile a log).

5. **Build the OKF scaffolding** (once, at the end): a bundle-root
   `docs/adr/index.md` with `okf_version` and themed sections, plus a per-theme
   `index.md`, using `/okf-index`. Fold the old `README.md`'s keeper content — its
   intro prose and any "Related Projects" section — into the root `index.md` body.
   Add a `docs/adr/log.md` with a single `**Initialization**` entry recording this
   migration.

6. **Retire the legacy indexes.** `index.md` is now the sole canonical index, so:
   - Delete the whole `docs/adr/README.md` file (its keeper content moved into
     `index.md` in step 5).
   - Delete the agent-private
     `.claude/agent-memory/zantarix-adr-architect/inventory.md`, and update that
     agent's `MEMORY.md` to drop its `inventory.md` pointer (the inventory no
     longer exists in OKF mode).

7. **Validate and report.** Run `/okf-validate` over `docs/adr/`, triage any
   violations, and report the theme layout, the number range re-padded, links
   rewritten (in-bundle and inbound cross-bundle), and any remaining advisories.
