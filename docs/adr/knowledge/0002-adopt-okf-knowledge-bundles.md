---
type: Architecture Decision
title: Adopt the Open Knowledge Format for Zantarix Knowledge Bundles
description: Adopts OKF v0.1 as the standard format for Zantarix knowledge bundles, restructuring ADR libraries as opt-in OKF bundles maintained via an /okf-* skill suite.
tags: [knowledge, okf, adr, skills]
timestamp: 2026-07-24T00:00:00Z
status: Accepted
---

# ADR-0002: Adopt the Open Knowledge Format for Zantarix Knowledge Bundles

## Status

Accepted (2026-07-24)

## Context

Zantarix projects record architectural decisions as flat `docs/adr/NNN-slug.md` files with three-digit numbering and no YAML frontmatter. An ADR's status lives in a `## Status` body section, is mirrored into a hand-maintained `README.md` status table, and is mirrored again into an agent-private `inventory.md` — every ADR change requires a three-way synchronisation. Once an ADR is accepted and committed, it is immutable: only status updates and errata may touch it, and no agent may modify accepted content on its own initiative. The sibling `agent` repository's ADR library is approaching 100 files in a single flat directory, and that single folder is becoming unwieldy to navigate.

The Open Knowledge Format (OKF) v0.1 already exists inside the organisation: the `agent` repository vendors the spec (from upstream `GoogleCloudPlatform/knowledge-catalog`) and maintains a mature working bundle at its `docs/security/` directory — thematic subdirectories, five concept `type` values, and a disciplined `log.md`. OKF's answer to a corpus that has outgrown a single folder is progressive disclosure at the index layer, not filesystem layout alone. That security bundle is maintained entirely by a single agent with direct references to how to deal with OKF; no shared tooling exists in the plugin marketplace for authoring or validating OKF bundles.

Two Claude Code harness behaviours constrain how spec knowledge can be shared across skills and agents: an agent's `skills:` frontmatter field preloads full skill content into its context at startup without any runtime invocation, and the `Skill` tool cannot be scoped to individual skills in an agent's `tools:` list — a grant is all-or-nothing.

## References

- [Open Knowledge Format (GoogleCloudPlatform/knowledge-catalog)](https://github.com/GoogleCloudPlatform/knowledge-catalog)
- [Claude Code: Create custom subagents](https://code.claude.com/docs/en/sub-agents)

## Decision

We will adopt the Open Knowledge Format (OKF) v0.1 as the standard format for Zantarix knowledge bundles, and restructure ADR libraries as OKF bundles on an opt-in, per-project basis. This ADR records how Zantarix uses OKF; the format itself is defined by the spec, which will be vendored into the plugin (preserving its upstream provenance frontmatter) rather than re-explained here.

### The `/okf-*` skill suite

The `zantarix` plugin will gain five authoring/maintenance skills:

- `okf-init` — scaffold a new bundle: root `index.md` with `okf_version` frontmatter plus the directory skeleton.
- `okf-curate` — the core write ritual: create or update a concept, reconcile that directory's `index.md` one-liner, and append a dated `log.md` entry, as one operation.
- `okf-index` — rebuild a single directory's `index.md` bullets from its concepts' frontmatter; used for bulk reindexing during migration.
- `okf-validate` — a read-only conformance report: frontmatter parseability, non-empty `type` on every non-reserved `.md`, `index.md`/`log.md` structure, and advisory broken-link detection. Broken links inside `log.md` are exempt from reporting — log entries are never reconciled, so stale links there are expected. It performs no writes.
- `okf-migrate-adr` — the human-only migration ritual for converting an existing legacy ADR library into an OKF bundle (see "Migrating an existing ADR library" below). It sets `disable-model-invocation: true`.

### The `okf-guide` reference skill

A single canonical reference skill, `okf-guide`, will carry a concise distillation of the OKF essentials plus the Zantarix house style (five-key concept frontmatter, index one-liners that describe behaviour rather than paths, reverse-chronological never-reconciled `log.md` entries, `okf_version` on the bundle root only). The full spec is vendored beside it as a supporting file, `plugins/zantarix/skills/okf-guide/SPEC.md`, for depth and citation. It will be a normal, model-invocable skill with a narrowly-worded description so it is not auto-invoked on unrelated turns.

The guide is consumed through two paths, keeping one canonical source with no duplication:

- Agents that work with bundles preload it via the `skills:` frontmatter field, so its content is always in their context without runtime invocation.
- When a human runs an `/okf-*` skill directly, each skill body opens by loading `zantarix:okf-guide` via the main agent's `Skill` tool.

### Agent access

- `adr-architect` gains the `Skill` tool and preloads `zantarix:okf-guide`, letting it run `/okf-curate` and its siblings while authoring.
- `documentation-reviewer` preloads `[zantarix:okf-guide, zantarix:okf-validate]`. It remains read-only: it does not receive the `Skill` tool, and instead executes the preloaded `okf-validate` procedure by hand with its existing read-only tools.

### ADR libraries as OKF bundles, opt-in per project

A project opts its ADR library into OKF mode with a self-describing marker: a bundle-root `docs/adr/index.md` that exists and carries any `okf_version` frontmatter. When the marker is absent, tooling and agents operate in the legacy flat-file mode unchanged. The existing ADR workflow surfaces — the organisation ADR rule, the acceptance ritual, and the architect agent's own authoring instructions — dispatch on the same marker, resolving the canonical index and status location for whichever mode the library is in. `claude-code` will pilot the tooling end to end before other projects opt in.

### Segmentation and numbering

In OKF mode, ADRs live in thematic subdirectories (for example `sandbox/`, `permissions/`). The OKF layout uses four-digit numbering (`0001`) throughout as a deliberate clean break from the legacy scheme: legacy flat libraries stay three-digit, migration re-pads existing numbers to four digits, and new OKF-mode ADRs are minted four-digit. Numbering remains globally sequential across themes. Cross-references between ADRs in different themes use relative links with directory navigation (`../theme/0084-foo.md`).

### Migrating an existing ADR library

Converting an existing ADR library into an OKF bundle is a one-time, content-preserving format lift: ADR bodies are carried over verbatim, and only paths, links, numbering width, and the added frontmatter change. The migration also rewrites inbound cross-bundle links — references from other bundles in the same repository (such as a security bundle citing `docs/adr/` paths) that would otherwise break when files move into theme subdirectories.

Because an accepted ADR library is immutable, the sanction to perform this lift is conferred only by a human invoking the `okf-migrate-adr` skill inside an `adr-architect` session. The skill is not model-invocable, so the model can neither trigger a migration nor authorise itself to mutate accepted ADRs. Two layers enforce this: the skill's leading check requires the `adr-architect` session (the UX layer), and the `guard-adr.sh` hook remains the hard backstop on all writes under `docs/adr/`.

### Index and metadata

In OKF mode, `docs/adr/index.md` becomes the single canonical index, retiring both the legacy `README.md` status table and the agent-private `inventory.md`. Each ADR gains OKF frontmatter — `type: Architecture Decision` plus title, description, tags, timestamp, and status — with the frontmatter `status` field as the canonical machine-readable location. The ADR body template (Status, Context, References, Decision, Consequences, Alternatives Considered, Errata) is otherwise unchanged.

## Consequences

### Positive

- One canonical index per bundle replaces the three-way status synchronisation (body section, `README.md` table, `inventory.md`) with the single `okf-curate` ritual.
- ADR status and metadata become machine-readable from frontmatter, so indexes and tooling no longer parse ADR bodies.
- Thematic subdirectories give the index meaningful sections, so progressive disclosure actually pays off as a library approaches 100 ADRs.
- One canonical spec-plus-house-style source (`okf-guide`) serves both agent preloads and main-agent skill runs, with no duplicated or drifting copies.
- The opt-in marker is self-describing: each project migrates on its own schedule, and legacy-mode ADR libraries keep working untouched.
- The immutability guarantee on accepted ADRs gains an explicit, human-gated exception boundary: the migration format lift preserves bodies verbatim and can only be sanctioned by a human invoking `okf-migrate-adr` — never by the model on its own initiative.
- `documentation-reviewer` gains bundle-conformance checking without gaining any write capability.

### Negative

- Existing ADR libraries face a one-time migration: theme assignment, file moves, four-digit re-padding, and link rewriting. Because the re-pad renames every file, every inbound link churns — cross-bundle references within the repository are rewritten by the migration, but references from outside the repository go stale.
- The `claude-code` pilot (a two-ADR library) proves the tooling mechanics but not segmentation at scale. Cross-theme link rewriting, theme assignment for cross-cutting ADRs, and bulk reindexing are only exercised by a dry-run against a scratch copy of the `agent` repository's ADR library, not by the pilot itself.
- Because the `Skill` grant is all-or-nothing, `adr-architect` can invoke any available skill, not just the `/okf-*` suite.
- Theme assignment for cross-cutting ADRs requires judgment, and a wrong assignment is costly to correct later because moving the file churns its links.

### Neutral

- Legacy and OKF-mode libraries use different numbering widths (three- versus four-digit), so the width itself signals which mode a library is in. Numbering stays globally sequential, but a number no longer determines a path; resolving one requires the index or a filename search — no worse than today, where descriptive slugs already force a lookup.
- Retiring `README.md` costs nothing on GitLab, which renders `index.md` as a directory landing page the same way it renders `README.md` (verified during the security bundle's adoption). GitHub's handling of `index.md` is untested; the worst case is that readers click into `index.md` from the file listing.
- The ADR body template is unchanged; the `## Status` body section remains, with the frontmatter `status` field as the canonical copy.
- `okf-guide` is model-invocable; auto-invocation on unrelated turns is mitigated by its narrow description rather than a hard flag.
- The `guard-adr.sh` hook already matches `docs/adr/` recursively, so ADRs in thematic subdirectories remain architect-only with no hook change.

## Alternatives Considered

### Flat ADR files with a rich grouped index

Keep the flat `NNN-slug.md` layout and express all thematic grouping purely in the index's sections. This preserves the number-to-path mapping and every existing inbound link; no file ever moves. It would also have avoided the inbound cross-bundle link churn that thematic subdirectories and the four-digit re-pad introduce. Rejected in favour of filesystem-level thematic grouping — a deliberate choice: subdirectories make the themes visible in the tree itself, matching the reference security bundle's shape. The cost is a one-time migration (theme assignment, file moves, link rewriting); the ongoing lookup cost is no worse than today, where descriptive slugs already force a filename lookup to resolve an ADR number.

### Segment ADRs by status

Subdirectories named for status (`accepted/`, `proposed/`, `deprecated/`). Rejected: status is mutable. Accepting an ADR would move its file, churning its concept identity and breaking every inbound link — the opposite of the stable, immutable record an ADR is supposed to be.

### Numeric bucket subdirectories

Century shards such as `00/01-foo.md`, `01/23-bar.md`. This is OKF-legal and requires no judgment calls during migration, but it is semantically empty: the index's grouped sections would degrade to "ADRs 001–099", wasting the progressive-disclosure layer that is OKF's actual answer to a large corpus.

### Harness-only `okf-guide` (`disable-model-invocation: true`)

Mark the guide skill `disable-model-invocation: true` so only explicit skill runs can load it, eliminating any auto-invocation risk. Rejected: the harness cannot preload a skill that sets this flag — preload draws from the same set the model may invoke — so this design is self-cancelling with the agent-preload requirement. A normal skill with a narrowly-worded description is the documented pattern; auto-invocation risk is mitigated by the description, not a flag.

### Shared spec file referenced from each `/okf-*` skill

Keep one copy of the spec elsewhere in the plugin and have every `/okf-*` skill body point at it via `${CLAUDE_PLUGIN_ROOT}`. Rejected: that variable does not expand inside a skill body (only `${CLAUDE_SKILL_DIR}` and `${CLAUDE_PROJECT_DIR}` do), so cross-skill file references cannot resolve. Vendoring the spec as a supporting file of the single `okf-guide` skill achieves one canonical copy without the broken indirection.
