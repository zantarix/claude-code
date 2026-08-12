---
name: okf-guide
description: Canonical OKF (Open Knowledge Format) reference and Zantarix house style. Loaded by the other okf-* skills and preloaded into OKF-aware agents; not a standalone action.
---

The Open Knowledge Format (OKF) is a directory of markdown *concepts* with YAML
frontmatter — a self-describing, tooling-free knowledge bundle. The full v0.2
spec is vendored beside this skill at `${CLAUDE_SKILL_DIR}/SPEC.md`; read it for
anything not covered here. This guide distills the rules the okf-* skills enforce
plus the **Zantarix house style** layered on top of the spec.

Every bundle — ADR bundles included — uses the same v0.2 house style, with one
structural carve-out for how ADRs cite sources; see "ADR bundles" below.

## Conformance — the hard rules

A bundle is conformant when:

1. Every non-reserved `.md` file has a parseable YAML frontmatter block.
2. Every such block carries a **non-empty `type`**.
3. Reserved files (`index.md`, `log.md`) follow the structure below.

Consumption is permissive: never reject a bundle for missing optional fields,
unknown `type` values, unknown keys, broken cross-links, or a missing `index.md`.

## Concept frontmatter — the v0.2 house style

Every concept uses these base keys, in this order:

```yaml
---
type: <Title-Cased Human String>    # REQUIRED; e.g. "Architecture Decision", "Security Boundary"
title: <Human-readable display name>
description: <One sentence summarising the concept>
tags: [<tag>, <tag>]                 # inline YAML list of short slugs
generated: { by: <actor>, at: <ISO-8601 with Z> }   # last meaningful content change
---
```

`type` is a descriptive human string, not an enum — it usually mirrors the
concept's directory (a `boundaries/` file is a `Security Boundary`). Keep
`description` to a single sentence; it is what `index.md` bullets and search
snippets show. Do not invent extra keys unless a bundle already establishes one.

`generated` replaces the legacy `timestamp` key: `generated.at` is the ISO-8601
datetime of the concept's last meaningful change, and `generated.by` is an actor
— `<producer>/<version>` for an agent or tool, `human:<id>` for a person,
`process:<id>` for an automated process.

**Stamp every frontmatter instant from a real `date -u`**, never a nominal
local-noon `T12:00:00Z`. For a user in a UTC+ timezone the true instant often
reads a day behind the human-facing date, and that skew is honest; rounding
forward to the local date stamps the event in the future — which matters most
for `verified`, the one field a human may later rely on to establish when they
confirmed something. Human-facing dates in body text — an ADR's `## Status`
line, `log.md` date headings, erratum titles — stay on the local date.

Add the following families where they carry meaning for the concept; none are
required:

- **`sources`** — provenance, replacing a body `# Citations` heading. A list of
  `{ resource, id, title, author, usage_count, last_modified }` entries
  (`resource` is the only required key per entry); a sibling
  `usage_window: { from, to }` frames every `usage_count`. Attribute a specific
  claim with a markdown footnote whose label is a `sources[].id`:

  ```markdown
  Recognized revenue sums `amount` over booked rows.[^rev-policy]

  [^rev-policy]: Revenue recognition policy
  ```

- **`verified`** — a list of `{ by, at }` confirmation events (or a single bare
  mapping for one verifier). Consumers derive a trust tier from it: no key ⇒
  unverified, non-`human:` actors only ⇒ machine-confirmed, any `human:<id>` ⇒
  human-reviewed.
- **`status`** — `draft | stable | deprecated`; defaults to `stable` when absent.
- **`stale_after`** — an absolute `YYYY-MM-DD`; the concept is stale on or after
  that date.

## Writes bring a concept to full v0.2 compliance

Whenever you write a concept — a new one, or a permitted edit to an existing
one — write it as if authored fresh today: full v0.2 form, no legacy field
(`timestamp`, a body `# Citations` list) carried forward out of habit. Never
bulk-rewrite untouched content merely to bump its metadata; a v0.1-shaped
concept you are not otherwise touching stays as-is; a v0.2 consumer reads it
through the spec's fallbacks. A bundle converges on v0.2 as its concepts are
naturally rewritten, not through a mass migration.

## ADR bundles: two divergences

ADR bundles adopt the general v0.2 house style above in full — `generated` replaces
`timestamp`, and `verified`/`stale_after` are available where they carry
meaning for a decision record (in practice, rarely: acceptance is already
recorded by `status`, and an obsolete ADR is superseded rather than
time-expired). Two things diverge from the general house style:

- **Citations.** ADRs cite external material through their existing
  mid-document `## References` body section, not `sources` frontmatter or
  footnote attribution. This is the sole structural carve-out.
- **The `status` vocabulary.** ADRs keep the ADR vocabulary (`Proposed |
  Accepted | Deprecated | Superceded`), distinct from the OKF lifecycle
  vocabulary above despite the shared key name — this is a semantic
  distinction, not a format freeze.

Apply these two divergences whenever the bundle is an ADR library (`docs/adr/`
or equivalent); apply the general v0.2 house style, citations included,
everywhere else.

## Architecture bundles: the architecture-documentation regime

A project MAY adopt the architecture-documentation regime.
The marker is self-describing: a **bundle-root concept of type `Constraint
Ledger`** (`constraints.md`); the conventional path is `docs/architecture/`
(the path is human convention — tooling trusts the ledger). Regime bundles are
ordinary OKF bundles with a fixed working type vocabulary:

- **`Architecture Decision`** — immutable, four-digit numbered; the ADR
  divergences above apply. Acceptance adds a `verified: { by:
  human:<forge-username>, at }` event.
- **`Overview`** — living; one per theme (conventionally `overview.md`),
  describing the theme's current shape.
- **`Specification`** — living; named, not numbered; contracts and compact
  rationale notes. Every edit cites the driving Architecture Decision.
- **`Constraint Ledger`** — the root singleton; one entry per
  constraint-admitting decision, citing it.

Living concepts follow the general v0.2 house style in full, `sources` and
trust families included. Index conventions: the bundle-root `index.md` is
**targeted** — direct descendants (themes, the ledger) plus a few prominent
children — with the per-concept roll-call living in theme indexes; a theme
index lists its overview first, then living documents, then decisions.

Regime *policy* — the materiality gate, the citation discipline, the writing
procedure — lives in the `architecture-curator` and `architecture-reviewer`
agents and the `zantarix:materiality-gate` skill, not in the general `okf-*`
skills. Adoption is human-invoked only, via `/adopt-architecture`.

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
- **House discipline — never reconcile a log entry once it has been committed.**
  Landed entries are a historical record; do not retro-edit them when paths
  later go stale. A broken link in an old log entry is expected, not a defect.
  An entry you added earlier in the same uncommitted change is not yet history
  and may still be corrected in place.

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

General bundles cite through the `sources` frontmatter family and footnote
attribution described above, not a body heading. `sources[].resource` may point
to a URL, a bundle-relative path, or a path into a `references/` subdirectory
that mirrors the source as a first-class concept; keep source entries short —
the detail lives in the referenced material, not the citation. A legacy v0.1
concept still using a trailing `# Citations` list is not forced to migrate; a
v0.2 consumer falls back to reading it. ADR bundles cite via `## References`
instead — see "ADR bundles" above.
