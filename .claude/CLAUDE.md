# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project purpose

This repo is a **Claude Code plugin marketplace** for Zantarix projects. It publishes six plugins (`zantarix`, `github`, `gitlab`, `rescript`, `rust`, plus the `rules` loader they all depend on) that other projects pull in via `extraKnownMarketplaces` in their `.claude/settings.json`. There is no build step or compiled output — the repo is configuration and markdown, plus the small TypeScript rules loader in `plugins/rules/` (tested with `claude plugin test plugins/rules`).

This repo also uses its own plugins: `zantarix`, `github`, and `gitlab` are enabled in `.claude/settings.json`.

## Repository layout

- **`/.claude-plugin/marketplace.json`** — registry root; lists all six plugins with their source paths
- **`/plugins/<name>/`** — one directory per plugin; holds `plugin.json` metadata plus `skills/`, `agents/`, `workflows/`, `rules/`, `hooks/`, and `scripts/` subdirectories
- **`/.claude/skills/`** — project-local skills, not distributed via the plugin system (e.g. `triage-new-memory`)
- **`/.claude/rules/`** — direct `.md` files for project-specific overrides only. Org-level rules are loaded by the enabled plugins themselves, not symlinked (see Rules below)

## Adding or changing content

Each plugin component has a specific format:

- **Skills** — `plugins/<name>/skills/<skill-name>/SKILL.md`; required frontmatter: `name`, `description`; add `disable-model-invocation: true` for harness-driven skills that must not be invoked by the model itself
- **Agents** — `plugins/<name>/agents/<agent-name>.md` defining the agent system prompt
- **Rules** — `plugins/<plugin-name>/rules/<rule-name>.md`, loaded by the `rules` plugin once the plugin registers them (Claude Code has no native plugin rules component yet: [anthropics/claude-code#14200](https://github.com/anthropics/claude-code/issues/14200)); use a `paths:` YAML list to scope to specific globs (omit for repo-wide rules):

  ```yaml
  ---
  paths:
    - "**/*.rs"
  ---
  ```

- **Workflows** — `plugins/<name>/workflows/<workflow-name>.js`; a Workflow script whose `meta.name` makes it addressable as `<plugin>:<name>` (pass that as the Workflow tool's `name`, never a `scriptPath` — the tool rejects paths outside the working directory). Every plugin workflow is also exposed as a `/<plugin>:<name>` command with no way to hide it, so a workflow that is only an internal step of a skill must throw when invoked without the args that skill supplies
- **Hooks** — registered in `plugins/<name>/hooks/hooks.json`: classic command hooks under `hooks` (`PreToolUse`/`PostToolUse`; scripts live in `plugins/<name>/scripts/` and receive the payload as JSON on stdin) and function-hooks modules under `modules`. Every rules-shipping plugin's `register.ts` calls `$.rules.add({ plugin, root })` from `session.start`, after `next(e)`, inline: passing `$` to an imported function fails validation
- **Rules loader** — `plugins/rules/` owns the loader (`hooks/index.ts`, `hooks/rule.ts`) and the `$.rules` contract (`types/index.d.ts`); the other plugins list it under `dependencies` in `plugin.json`, so installing any of them installs it. A new plugin that ships rules needs that dependency and the `register.ts` above. Run the loader's tests with `claude plugin test plugins/rules`

After adding a new plugin component, update the README table for that plugin.

## Memory reconciliation workflow

The `zantarix:memory-reconciliation` skill files GitHub issues (label: `new-memory`) when a project memory looks like it should become a distributed org rule. The project-local `triage-new-memory` skill processes that queue — classifying each issue as accept, merge, reject, or defer — writing rule files only for accepted and merged outcomes. Issues are auto-closed via `Closes #N` commit trailers when the commit lands on `main`.

## Active hooks

The `zantarix` plugin installs two hooks active in this repo:

- **`guard-adr.sh`** (PreToolUse, Edit/Write/MultiEdit) — blocks any agent except `zantarix:architecture-curator` from writing under `docs/adr/` or `docs/architecture/`. Delegate architecture-library edits via the `@zantarix:architecture-curator` agent.
- **`format.sh`** (PostToolUse, Edit/Write) — runs `markdownlint --fix` on `.md` files after every edit automatically; no manual formatting step is needed.

## Commit conventions

`feat(<plugin>): <imperative description>` — e.g. `feat(rust): add mutants rule`. Use `chore:` for repo-housekeeping commits with no plugin-specific scope.
