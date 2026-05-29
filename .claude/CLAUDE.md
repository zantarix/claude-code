# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project purpose

This repo is a **Claude Code plugin marketplace** for Zantarix projects. It publishes five plugins (`base`, `github`, `gitlab`, `rescript`, `rust`) that other projects pull in via `extraKnownMarketplaces` in their `.claude/settings.json`. There is no build step, test suite, or compiled output — the repo is entirely configuration and markdown.

This repo also uses its own plugins: `base`, `github`, and `gitlab` are enabled in `.claude/settings.json`.

## Repository layout

- **`/.claude-plugin/marketplace.json`** — registry root; lists all five plugins with their source paths
- **`/plugins/<name>/`** — one directory per plugin, each containing:
  - `.claude-plugin/plugin.json` — plugin metadata and hook definitions (PreToolUse/PostToolUse shell scripts)
  - `skills/` — skill definitions as markdown files with YAML frontmatter
  - `agents/` — agent prompt files
  - `scripts/` — shell scripts invoked by hooks (formatting, ADR guards)
- **`/rules/`** — rule markdown files distributed with each plugin, mirroring the plugin names as subdirectories

## Adding or changing content

Each plugin component has a specific format:

- **Skills** — `.md` files with `name` and `description` YAML frontmatter followed by numbered step-by-step instructions; live under `plugins/<name>/skills/<skill-name>/SKILL.md`
- **Agents** — `.md` files defining system prompts; live under `plugins/<name>/agents/<agent-name>.md`
- **Rules** — plain markdown guidelines; live under `rules/<plugin-name>/<rule-name>.md`
- **Hooks** — registered in `.claude-plugin/plugin.json` under `PreToolUse`/`PostToolUse`; reference scripts via `${CLAUDE_PLUGIN_ROOT}/scripts/`

After adding a new plugin component, update the README table for that plugin.
