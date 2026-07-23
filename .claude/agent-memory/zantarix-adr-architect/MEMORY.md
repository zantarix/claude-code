# ADR Architect Memory — Zantarix Claude Code marketplace

Index of my persistent notes for authoring ADRs in this repo.

- [ADR inventory](inventory.md) — every ADR: number, file, title, status. Update on every ADR change.

## Repo-specific notes

- This repo is a Claude Code plugin marketplace: entirely configuration and markdown, no build/test/compiled output. ADRs are decisions about plugin/skill/agent/rule design and orchestration, not code internals.
- ADR numbering here starts at 001 (unlike sibling `cursus`, whose 000 was a special founding-constraints ADR). Three-digit zero-padded.
- Writes under `docs/adr/` are guarded: only the `zantarix:adr-architect` agent may edit them (guard-adr.sh hook).
- `format.sh` auto-runs markdownlint --fix on `.md` after each edit — no manual markdown formatting needed.
- Same-project skill files (SKILL.md) may be cited in References via relative paths (`../../plugins/...`); the "no same-project references" rule applies only to ADRs, not skills.
- ADR-002 (Accepted 2026-07-24): OKF tooling is live, but this repo remains in **legacy** ADR mode — the flip happens only when a human runs `/okf-migrate-adr` and the root `index.md` + `okf_version` marker appears. Until then, keep the legacy README-table + `inventory.md` dual-write.
