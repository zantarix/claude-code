# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project purpose

This repo is a **Claude Code plugin marketplace** for Zantarix projects. It publishes five plugins (`base`, `github`, `gitlab`, `rescript`, `rust`) that other projects pull in via `extraKnownMarketplaces` in their `.claude/settings.json`. There is no build step, test suite, or compiled output — the repo is entirely configuration and markdown.

This repo also uses its own plugins: `base`, `github`, and `gitlab` are enabled in `.claude/settings.json`.

## Repository layout

- **`/.claude-plugin/marketplace.json`** — registry root; lists all five plugins with their source paths
- **`/plugins/<name>/`** — one directory per plugin, containing:
  - `.claude-plugin/plugin.json` — plugin metadata and hook definitions
  - `skills/` — skill `.md` files with YAML frontmatter
  - `agents/` — agent prompt files
  - `scripts/` — shell scripts invoked by hooks
- **`/rules/<name>/`** — rule markdown files for each plugin; kept separate from `plugins/` and distributed alongside skills and agents
- **`/.claude/skills/`** — project-local skills not part of any plugin (e.g. `triage-new-memory`)
- **`/.claude/rules/`** — symlinks to `rules/<plugin>/` for org-level rules; direct `.md` files for project-specific overrides

## Adding or changing content

Each plugin component has a specific format:

- **Skills** — `plugins/<name>/skills/<skill-name>/SKILL.md`; required frontmatter: `name`, `description`; add `disable-model-invocation: true` for harness-driven skills that must not be invoked by the model itself
- **Agents** — `plugins/<name>/agents/<agent-name>.md` defining the agent system prompt
- **Rules** — `rules/<plugin-name>/<rule-name>.md`; use `paths:` frontmatter to scope to specific file globs
- **Hooks** — registered in `plugins/<name>/.claude-plugin/plugin.json` under `PreToolUse`/`PostToolUse`; scripts live in `plugins/<name>/scripts/`

After adding a new plugin component, update the README table for that plugin.

## Active hooks

The `base` plugin installs two hooks active in this repo:

- **`guard-adr.sh`** (PreToolUse, Edit/Write/MultiEdit) — blocks any agent except `base:adr-architect` from writing under `docs/adr/`. Delegate ADR edits via the `@base:adr-architect` agent.
- **`format.sh`** (PostToolUse, Edit/Write) — runs `markdownlint --fix` on `.md` files after every edit automatically; no manual formatting step is needed.

## Commit conventions

`feat(<plugin>): <imperative description>` — e.g. `feat(rust): add mutants rule`. Use `chore:` for repo-housekeeping commits with no plugin-specific scope.
