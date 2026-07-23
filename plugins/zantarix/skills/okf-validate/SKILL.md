---
name: okf-validate
description: Read-only OKF (Open Knowledge Format) conformance check for a bundle — reports frontmatter/type violations, reserved-file structure problems, and broken cross-links. Makes no changes.
---

Report on the conformance of the OKF bundle given in `$ARGUMENTS` (default: the
bundle enclosing the current directory). This skill is **read-only** — it writes
nothing and fixes nothing; it produces a report the caller acts on.

1. **Load the format rules.** Ensure the `zantarix:okf-guide` reference is in
   context — it may already be preloaded; if not, and you have the Skill tool,
   invoke the `zantarix:okf-guide` skill. Judge against its conformance rules.

2. **Enumerate the bundle.** Find the bundle root (the `index.md` carrying
   `okf_version`) and list every `.md` file beneath it.

3. **Check concepts (hard rules).** For every non-reserved `.md`:
   - It has a parseable YAML frontmatter block — else a **violation**.
   - The block carries a non-empty `type` — else a **violation**.
   Note (advisory, not a violation) missing recommended keys
   (`title`/`description`/`tags`/`timestamp`).

4. **Check reserved files.** `index.md` files carry no frontmatter except a
   bundle-root `okf_version`; `log.md` uses `## YYYY-MM-DD` headings newest-first.
   Flag deviations.

5. **Check cross-links (advisory).** Report bundle-internal links whose target
   file does not exist. Broken links are permitted by the spec — list them as
   advisories, **except** those inside `log.md` (stale log links are expected and
   must not be reported).

6. **Report** grouped as **Violations** (breaks conformance — must fix) and
   **Advisories** (permitted but worth attention), each naming the exact file and
   problem. State "conformant" explicitly when there are no violations.
