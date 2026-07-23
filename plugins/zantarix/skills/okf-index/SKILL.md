---
name: okf-index
description: Rebuild one directory's index.md in an OKF (Open Knowledge Format) bundle from its concepts' frontmatter — the bulk-reindex counterpart to okf-curate's per-concept upkeep.
---

Regenerate the `index.md` for one directory of an OKF bundle from the concepts it
contains. Use this after bulk changes or a migration, where per-concept
`/okf-curate` upkeep would be tedious. Perform the steps in order. The target
directory is given in `$ARGUMENTS`.

1. **Load the format rules.** Ensure the `zantarix:okf-guide` reference is in
   context (it may be preloaded); if not, invoke the `zantarix:okf-guide` skill.
   Follow its house style for everything below.

2. **Scan the directory.** List its concept files (every non-reserved `.md`) and
   its immediate subdirectories. Read each concept's frontmatter for `title` and
   `description`.

3. **Group into sections.** Organise entries under `#` headings — by an explicit
   grouping given in `$ARGUMENTS`, otherwise by an obvious semantic grouping (or a
   single section if the directory is small). Include subdirectories as entries
   with a trailing-slash link.

4. **Write `index.md`.** One bullet per entry:
   `* [Title](url) - one-line behavioural summary`, the summary taken from each
   concept's `description` and describing **behaviour, not paths**. Carry
   `okf_version` frontmatter through unchanged **only** if this is the bundle-root
   index; all other `index.md` files have no frontmatter.

5. **Report** the directory reindexed and a short diff of entries added, removed,
   or resummarised. This skill only rewrites `index.md` — it never edits
   concepts or `log.md`.
