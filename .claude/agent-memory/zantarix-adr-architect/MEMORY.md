# ADR Architect Memory — Zantarix Claude Code marketplace

Index of my persistent notes for authoring ADRs in this repo.

## Repo-specific notes

- This repo is a Claude Code plugin marketplace: entirely configuration and markdown, no build/test/compiled output. ADRs are decisions about plugin/skill/agent/rule design and orchestration, not code internals.
- Writes under `docs/adr/` are guarded: only the `zantarix:adr-architect` agent may edit them (guard-adr.sh hook).
- `format.sh` auto-runs markdownlint --fix on `.md` after each edit — no manual markdown formatting needed. It is deliberately a **formatter, not a linter** (Maddy-confirmed): always exits 0, swallows all lint errors and even a missing markdownlint binary. Unfixable defaults like MD025 (multi-`#` OKF indexes) and MD013 (long ADR lines) fire if run manually — these are expected house-style conflicts, never something to "fix" by restructuring bundle files.
- Same-project skill files (SKILL.md) may be cited in References via relative paths (from a theme dir: `../../../plugins/...`); the "no same-project references" rule applies only to ADRs, not skills.
- **This repo's ADR library is an OKF bundle** (migrated 2026-07-24 via `/okf-migrate-adr`, per ADR-0002). Operate in OKF mode: four-digit numbering (next is 0003), themes `orchestration/` and `knowledge/`, canonical index `docs/adr/index.md` + history `docs/adr/log.md`, maintained via `/okf-curate`. No README table, no inventory.md. Bundle link convention is **relative** links (not bundle-root-absolute), matching ADR-0002's cross-theme `../<theme>/NNNN-*.md` rule.
- ADR numbering is globally sequential across themes; it started at 001 in legacy mode (unlike sibling `cursus`, whose 000 was a founding-constraints ADR) and was re-padded to 0001+ in the migration.
