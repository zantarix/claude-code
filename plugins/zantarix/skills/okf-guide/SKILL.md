---
name: okf-guide
description: Canonical OKF (Open Knowledge Format) reference and Zantarix house style. Loaded by the other okf-* skills and preloaded into OKF-aware agents; not a standalone action.
---

The Open Knowledge Format (OKF) is a directory of markdown *concepts* with YAML
frontmatter — a self-describing, tooling-free knowledge bundle. The full v0.1
spec is vendored beside this skill at `${CLAUDE_SKILL_DIR}/SPEC.md`; read it for
anything not covered here. This guide distills the rules the okf-* skills enforce
plus the **Zantarix house style** layered on top of the spec.

## Conformance — the hard rules

A bundle is conformant when:

1. Every non-reserved `.md` file has a parseable YAML frontmatter block.
2. Every such block carries a **non-empty `type`**.
3. Reserved files (`index.md`, `log.md`) follow the structure below.

Consumption is permissive: never reject a bundle for missing optional fields,
unknown `type` values, unknown keys, broken cross-links, or a missing `index.md`.

## Concept frontmatter — the 5-key house style

Every concept uses exactly these keys, in this order:

```yaml
---
type: <Title-Cased Human String>    # REQUIRED; e.g. "Architecture Decision", "Security Boundary"
title: <Human-readable display name>
description: <One sentence summarising the concept>
tags: [<tag>, <tag>]                 # inline YAML list of short slugs
timestamp: <ISO-8601 with Z>         # e.g. 2026-07-23T00:00:00Z; last meaningful change
---
```

`type` is a descriptive human string, not an enum — it usually mirrors the
concept's directory (a `boundaries/` file is a `Security Boundary`). Keep
`description` to a single sentence; it is what `index.md` bullets and search
snippets show. Do not invent extra keys unless a bundle already establishes one.

## Reserved files

### `index.md` — progressive disclosure

- **No frontmatter**, with one exception: the **bundle-root** `index.md` MAY carry
  a frontmatter block containing **only** `okf_version` (this doubles as the
  bundle's opt-in/version marker).
- Body is one or more `#`-heading sections, each grouping concepts as bullets:

  ```markdown
  # Section heading
  * [Concept title](/abs/path.md) - one-line behavioural summary
  * [Subdirectory](subdir/) - what the subdirectory holds
  ```

- **House rule — one-liners describe behaviour, not paths or mechanisms.** A good
  one-liner survives a code/file refactor untouched. Pull the wording from the
  concept's `description`.

### `log.md` — update history

- **No frontmatter.** Reverse-chronological, newest date first:

  ```markdown
  ## 2026-07-23
  * **Creation**: established the [trust model](/trust-model.md).
  * **Update**: renumbered citations in [tool-call gating](/boundaries/tool-call-gating.md).
  ```

- `## YYYY-MM-DD` date headings; each entry leads with a bolded verb
  (`**Creation**`, `**Update**`, `**Deprecation**`, …) — convention, not required.
- **House discipline — never reconcile old log entries.** Past entries are a
  historical record; do not retro-edit them when paths later go stale. A broken
  link in an old log entry is expected, not a defect.

## Cross-linking

- The spec **recommends absolute, bundle-root links** (`/tables/orders.md`,
  leading `/`) because they survive a concept moving within its subdirectory.
- Relative links (`./sibling.md`, `../other-theme/file.md`) are also valid; some
  bundles adopt them by convention. Follow whatever the bundle you are editing
  already uses.
- **Two roots coexist:** a leading `/` resolves to the *bundle* root, while a
  cross-bundle reference like `/docs/adr/0001-foo.md` resolves at the *repo* root.
- Directory links end in a trailing slash (`/boundaries/`).

## Citations

External sources backing a claim go under a trailing `# Citations` heading,
numbered `[1]`, `[2]`, … Links may be URLs, bundle-relative paths, or paths into
a `references/` subdirectory that mirrors the source as first-class concepts. Citations
must be kept short — the detail lives in the referenced documentation, not as part
of the citation.
