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

3. **Write the concept.** Give it the base 5-key frontmatter
   (`type`/`title`/`description`/`tags`/`timestamp`) — set `timestamp` to now in
   ISO-8601 `Z` form. **Also set, and on update never drop, any additional key the
   bundle already establishes for this concept type** — e.g. an ADR bundle's
   `status`. Favour structural markdown (headings, lists, tables) in the body; use
   conventional headings (`# Schema`, `# Examples`, `# Citations`) where they
   apply. Keep cross-links in whatever style the bundle already uses.

4. **Reconcile the directory `index.md`.** In the concept's own directory index,
   ensure a bullet links to the concept under the right section, with a one-line
   summary drawn from its `description` that describes **behaviour, not paths**.
   Add it on create; correct it on update only if the behaviour summary changed.
   (For a bulk rebuild of an index, use `/okf-index` instead.)

5. **Append to `log.md`.** Add an entry to the bundle-root `log.md` (create it if
   absent) under today's `## YYYY-MM-DD` heading, newest date first, led by a
   bolded verb (`**Creation**`, `**Update**`, `**Deprecation**`). Describe the
   change and link the concept. **Never** edit existing log entries.

6. **Report** the concept path, the index section touched, and the log entry
   added.
