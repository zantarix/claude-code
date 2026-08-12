---
name: okf-curate
description: Author or revise one concept in an OKF (Open Knowledge Format) bundle, keeping its directory index.md and the bundle log.md in sync in the same operation.
---

Create or update a single concept in an OKF bundle and reconcile the bundle's
index and log **in one operation** — never leave the index or log stale. Perform
the steps in order, stopping and reporting any failure. The target concept and
the change to make are given in `$ARGUMENTS`.

1. **Load the format rules.** Ensure the `zantarix:okf-guide` reference is in
   context (it may be preloaded); if not, invoke the `zantarix:okf-guide` skill.
   Follow its house style for everything below.

2. **Locate the bundle and concept.** Find the bundle root (the ancestor
   directory whose `index.md` carries `okf_version`). Determine the concept's
   file path and whether this is a **create** or an **update**. If updating, read
   the existing concept in full first.

3. **Write the concept in full v0.2 form — write it as if authored fresh
   today.** Skip this step, proceeding directly to step 4, when `$ARGUMENTS`
   explicitly requests **index-and-log-only** — the mode `/accept-adr` uses for
   its post-ratification bookkeeping, where rewriting the document to current
   house style would corrupt the text the human just ratified. Otherwise: use
   `type`/`title`/`description`/`tags`/`generated` (`generated.at`
   set to now, `generated.by` the acting actor), plus `sources`/`verified`/
   `status`/`stale_after` where they carry meaning for this concept. On an
   **update**, upgrade any legacy key the existing concept still carries
   (`timestamp` → `generated`, a body `# Citations` list → `sources`) rather
   than preserving it — a write always brings the concept to current
   compliance; only untouched concepts stay in their old shape. **Also set,
   and never drop, any additional key the bundle already establishes for this
   concept type.** Favour structural markdown (headings, lists, tables) in the
   body; use conventional headings (`# Schema`, `# Examples`) where they
   apply, and attribute claims via footnotes keyed to `sources[].id` rather
   than a body `# Citations` list. Keep cross-links in whatever style the
   bundle already uses.

   **If this is an ADR bundle**, apply the ADR divergences from the house
   style instead (citations, `status` vocabulary) — see `okf-guide`.

4. **Reconcile the directory `index.md`.** In the concept's own directory index,
   ensure a bullet links to the concept under the right section, with a one-line
   summary drawn from its `description` that describes **behaviour, not paths**.
   In an architecture bundle — one whose root holds a `Constraint Ledger`
   concept, not merely one holding numbered ADRs — an `Architecture Decision`
   entry labels its link `[0007 - Title]`, four-digit padded to match the
   filename, per `okf-guide`; every other concept type, and every other bundle
   family, keeps a bare title.
   Add it on create; correct it on update only if the behaviour summary changed,
   or if the number label is missing from a decision's own bullet.
   (For a bulk rebuild of an index, use `/okf-index` instead.)

   **Touch only this concept's own bullet.** Never add, remove, or "correct" a
   sibling's bullet, and never infer a sibling's summary or status from
   recency, from the log, or from its current wording — an edit made on
   inference silently misreports the corpus. If a sibling entry genuinely looks
   wrong, read that concept's frontmatter directly, and even then raise it with
   the user rather than editing it here.

5. **Append to `log.md`.** Add an entry to the bundle-root `log.md` (create it if
   absent) under today's `## YYYY-MM-DD` heading, newest date first, led by a
   bolded verb (`**Creation**`, `**Update**`, `**Deprecation**`). Describe the
   change and link the concept.

   **Never edit a log entry that has already landed** — past entries are a
   historical record, and a stale link in one is expected rather than a defect.
   That discipline protects committed history, not the block you are writing in
   this same change: if an entry you added earlier in this uncommitted pass would
   now ship as a false statement, edit it in place. A forward-correcting bullet
   is for a prior commit's entry.

6. **Report** the concept path, the index section touched, and the log entry
   added.
