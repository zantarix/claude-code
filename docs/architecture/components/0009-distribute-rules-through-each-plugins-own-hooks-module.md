---
type: Architecture Decision
title: Distribute Rules Through Each Plugin's Own Hooks Module
description: Each Zantarix plugin carries its rules inside its own directory and loads them into a consumer's session through its own hooks module, replacing the git-submodule and symlink route and making rule delivery depend on Claude Code's early-access hooks-module API.
tags: [components, rules, distribution, hooks, plugins]
generated: { by: architecture-curator/claude-opus-5-5, at: 2026-10-23T11:15:49Z }
status: Proposed
---

# ADR-0009: Distribute Rules Through Each Plugin's Own Hooks Module

## Status

Proposed (2026-10-23)

## Context

Rules are the component meant to shape behaviour without anyone deciding to consult it ([components overview](overview.md)), and the plugin harness has no way to ship them: a plugin can carry skills, agents, hooks, and workflows, but no rules component, and the upstream request for one remains open.

Consumers have worked around the gap by adding this repository as a git submodule and symlinking its `rules/<plugin>/` directories into their own `.claude/rules/`. That route sits outside the plugin system entirely. A consumer sets it up by hand per repository, updates it separately from the plugins it belongs to, so the rules in force can lag or lead the plugin version installed beside them, and can enable a plugin without its rules or link rules for a plugin it never enabled. It is also what tells organisation rules from project rules: the distributed `rules` rule defines an organisation rule as one reached through a symlink.

Claude Code now offers a function-hooks API, in early access, through which a plugin's hooks module can add instruction files to a session's context and attach context to tool results and prompts. That makes it possible for a plugin to deliver rules without upstream support for them, and third-party loaders built on the API already exist. The API may change between releases without notice, and whether an installed plugin's hooks module loads at all depends on a switch in Claude Code rather than on anything the plugin ships.

## References

- [Add rules support to Plugins (anthropics/claude-code#14200)](https://github.com/anthropics/claude-code/issues/14200)
- [rafal-one/plugin-rules](https://github.com/rafal-one/plugin-rules)
- [claude-plugin-rules on npm](https://www.npmjs.com/package/claude-plugin-rules)

## Decision

Every Zantarix plugin will carry its own rules and deliver them itself. A plugin's rules will live inside the plugin, at `plugins/<plugin>/rules/`, and the plugin will load them into a consumer's session through its own hooks module — the function-hooks module that the plugin's `hooks/hooks.json` names under `modules`, in Claude Code's early-access hooks-module API. Each plugin's module will load only its own rules. A consumer will take no step for a plugin's rules beyond installing the plugin.

### Organisation and project rules

A rule is an organisation rule when a plugin loaded it, and a project rule when it is a file in the project's own `.claude/rules/`. Wherever the API lets the loader choose, a plugin's unscoped rules will be placed ahead of the project's own instruction files, the position from which a project's rules have always overridden organisation rules.

### Visibility

Each plugin will report what it loaded, so a consumer can tell a working install from one whose hooks module never ran.

The loader's full contract lives in [Plugin Rule Loading](rule-loading.md).

## Consequences

### Positive

- A consumer's rules follow the plugins it has enabled, at the version it has installed; the per-repository submodule, its symlinks, and their separate updating disappear.
- Rules sit beside the skills and agents they support, so a change to a plugin and to its rules ships as one version.
- Each plugin depends on nothing but itself, so enabling a single plugin is enough for its rules, and no plugin's rules wait on another being installed or loaded first.

### Negative

- Rule delivery now rests on an early-access API that may change between releases without notice; a breaking change silently stops every plugin's rules until the loader is updated and re-released.
- Where hooks modules do not load — the switch off, or a policy admitting only managed hooks — no rule arrives and the conversation shows nothing. The listing command makes this discoverable, but only to someone who thinks to run it.
- A marketplace of configuration and markdown takes on executable TypeScript in every plugin, kept identical by a sync step ([Plugin Rule Loading](rule-loading.md)) that has to be remembered whenever the loader changes; a copy left behind fails only in the plugin that was missed.
- Rules reach the model through a loader rather than through the harness's own rule handling, so any difference between the two — what a scoped rule attaches on, how a fallback session sees unscoped rules — is behaviour this project owns and has to keep correct itself. Scoped rules, and unscoped rules in a fallback session, arrive as context after the project's instruction files rather than ahead of them.
- Consumers still on the submodule route receive every rule twice until they remove it; the session-start warning names the duplication but cannot undo it.

### Neutral

- The distributed definition of an organisation rule, and every document describing the submodule route, change with this decision.
- If the harness gains a rules component, the loaders become removable; whether the rules can stay where they are depends on the shape that component takes.

## Alternatives Considered

### Keep the submodule route until upstream ships rules

Leave rules outside the plugins and wait for the harness to gain a rules component. Rejected because the request has no commitment or date attached, and every cost of the route — the hand setup per repository, the version skew between plugins and their rules, rules enabled without their plugin or the reverse — recurs in every consumer for as long as the wait lasts.

### One central loader plugin

Ship a single plugin whose hooks module finds every installed Zantarix plugin, by reading Claude Code's record of installed plugins, and loads all their rules. Rejected because that record's location and format are undocumented, so the loader would break on an internal change with no notice, and because a consumer would have to install the loader as well as the plugins whose rules it wants.

### A shared dependency plugin

Have each plugin depend on a common plugin that adds a rules noun to the engine interface, which the dependants call to register their rules directories. Rejected because it relies on the dependency loading before its dependants, an ordering this project could not verify, and a wrong order would drop rules silently.

### Adopt a third-party loader

Install an existing published mod — [rafal-one/plugin-rules](https://github.com/rafal-one/plugin-rules), or the [claude-plugin-rules](https://www.npmjs.com/package/claude-plugin-rules) package — rather than writing one. Rejected on supply-chain trust: either would run third-party code on every consumer's machine, in every session, under a mechanism whose job is putting text in front of the model, with no review of each release before consumers receive it. The loader this project writes instead follows the design of `claude-plugin-rules`, which is MIT licensed.
