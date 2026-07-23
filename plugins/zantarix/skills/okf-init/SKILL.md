---
name: okf-init
description: Scaffold a new, empty OKF (Open Knowledge Format) knowledge bundle — a root index.md carrying the okf_version marker plus an initial directory skeleton.
---

Scaffold a new OKF bundle at the path given in `$ARGUMENTS`. Perform the steps in
order, stopping and reporting any failure.

1. **Load the format rules.** Ensure the `zantarix:okf-guide` reference is in
   context (it may be preloaded); if not, invoke the `zantarix:okf-guide` skill.
   Follow its house style for everything below.

2. **Resolve the bundle.** Determine the bundle root directory and a human title
   from `$ARGUMENTS`. If the directory already contains an `index.md` with an
   `okf_version` frontmatter key, STOP — it is already a bundle; do not
   re-initialise it.

3. **Write the root `index.md`.** This is the only `index.md` permitted
   frontmatter, and it carries **only** `okf_version`:

   ```markdown
   ---
   okf_version: "0.1"
   ---

   # <Bundle title>

   <One-paragraph statement of what this bundle captures.>

   # <Section>

   * [<Concept or subdirectory>](<url>) - <one-line behavioural summary>
   ```

   Leave section stubs the producer will fill in; every entry's one-liner must
   describe behaviour, not paths.

4. **Create requested subdirectories.** For each initial subdirectory the user
   named, create it with its own `index.md` (no frontmatter) titled for the
   section, ready to receive concepts.

5. **Report** the bundle root, the files created, and the next step (author
   concepts with `/okf-curate`).
