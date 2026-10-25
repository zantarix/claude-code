---
type: Architecture Decision
title: Load Every Plugin's Rules Through a Shared Rules Plugin
description: One plugin, `rules`, owns the rules loader; every rules-shipping Zantarix plugin depends on it and registers its own rules directory with it at session start, so a loader change ships once as a release of that plugin.
tags: [components, rules, distribution, hooks, plugins, dependencies]
generated: { by: architecture-curator/claude-opus-5-5, at: 2026-10-25T02:27:52Z }
status: Proposed
---

# ADR-0010: Load Every Plugin's Rules Through a Shared Rules Plugin

## Status

Proposed (2026-10-25)

## Context

[ADR-0009](0009-distribute-rules-through-plugin-hooks-modules.md) has every Zantarix plugin carry its own rules and deliver them through hooks modules. Loading rules is the same job whichever plugin's rules are loaded, so the question is where that one job runs when many plugins need it done.

The plugin harness constrains the answer in three ways:

- An installed marketplace plugin runs from its own cached copy, so a hooks module cannot import from another plugin's directory.
- A plugin's version, where neither its manifest nor its marketplace entry pins one, is the commit of its own directory, and this marketplace pins none. A consumer receives a new copy of a plugin only when that version changes.
- A plugin may name other plugins of its marketplace as dependencies. Installing it installs any that are missing, as do `/reload-plugins` and a marketplace auto-update; the documentation does not list a manual `claude plugin update` among them. A plugin is disabled whenever one of its dependencies is disabled or absent. A version constraint on a dependency resolves against release tags and checks the dependency's manifest version, and this marketplace neither tags releases nor sets versions.

The hooks-module API also lets a module add a noun to the engine interface that every module's hooks receive, and lets a plugin declare that noun's type for others to type-check against. Two behaviours a cross-plugin design would rest on are undocumented: whether a call made through such a noun runs in the caller's context, and so can read the caller's own files, and the order in which different plugins' modules start. Both hold on Claude Code 2.1.308: with `rules`, `zantarix`, `github`, and `gitlab` loaded through `--plugin-dir`, the loader's listing command showed all three dependants' rule sets, which requires every module to have extended the engine interface before any `session.start` hook ran.

## References

- [Plugin dependencies](https://code.claude.com/docs/en/plugins/dependencies)
- [Plugin loading reference](https://code.claude.com/docs/en/plugins/loading)
- [Share files within a marketplace with symlinks](https://code.claude.com/docs/en/plugins/host-marketplace#share-files-within-a-marketplace-with-symlinks)

## Decision

One plugin, `rules`, will own the rules loader. Every Zantarix plugin that ships rules will list `rules` under `dependencies` in its `plugin.json`, so that installing the plugin installs the loader with it, and its hooks module will register with the loader at session start, handing over the plugin's name and directory through a `rules` namespace that the loader adds to the engine interface. The loader will read each registered plugin's `rules/` directory and deliver every registered plugin's rules under the contract in [Plugin Rule Loading](rule-loading.md).

A plugin that ships rules will not be usable without `rules` enabled beside it. A session will run one loader whatever the number of plugins registering with it, and a consumer will see what loaded through one listing, grouped by the plugin that registered each rule.

## Consequences

### Positive

- A loader change ships once, as a new version of `rules`, and reaches every consumer at their next update regardless of whether any other plugin changed; there is no copying step to remember and no drift to check for.
- Each session runs one loader: one listing of what loaded, one detection of sessions whose instruction files are out of reach, and one duplicate check per registering plugin, rather than a loader, listing, and detector for every plugin.
- A new plugin that ships rules needs a dependency entry and a few lines of registration, and nothing in `rules` names it.

### Negative

- That the `rules` namespace exists by the time a dependant registers is observed, not documented. If a release of Claude Code changes how modules start, registration fails, the failure is caught, and the affected plugins' rules are dropped without a word in the conversation; only the listing would show them missing.
- Registration depends on a cross-plugin call running in the caller's context, so that the loader can read a directory belonging to another plugin. That too is observed behaviour of an early-access API.
- A consumer who disables or uninstalls `rules` loses every plugin that depends on it entirely, not only their rules.
- An existing install updated to a version that first declares the dependency gets `rules` through `/reload-plugins` or a marketplace auto-update; a manual `claude plugin update` is not documented to install it, and until something does, the updated plugin stays disabled.
- One loader is one point of failure. While the marketplace neither versions nor tags its plugins no constraint on `rules` can be expressed, so a `rules` release that breaks its own registration contract reaches every plugin at once, by the same route that delivers a fix.
- The `rules` plugin name, the `rules` noun, and the event that answers it are unqualified names in namespaces every installed plugin shares, and third-party rule loaders exist that could claim the same ones. Only the listing command, `/zantarix-rules`, carries a qualifier: plugin commands are not prefixed with their plugin's name, and a command name cannot contain the `:` that would add one.

### Neutral

- The marketplace publishes a sixth plugin, which exists to be installed as a dependency.
- The registration itself is a few identical lines repeated in every plugin that ships rules; what is shared is the loader, not the call into it.
- If the harness gains a rules component, the removal [ADR-0009](0009-distribute-rules-through-plugin-hooks-modules.md) anticipates is one plugin and a registration call in each dependant.

## Alternatives Considered

### Copy the loader into every plugin

Keep one canonical loader and copy it byte for byte into each plugin that ships rules, with a script that makes the copies and a check that fails when one has drifted. Rejected because every loader change has to be repeated into every plugin, the step that does so has to be remembered and the plugin list it covers maintained by hand, and a copy left behind fails only in the plugin that was missed. Every session also runs one loader per plugin — one listing command, one bypass detector, and one duplicate check each — for what is a single job.

### Symlink the loader into every plugin

Keep the loader in one plugin and link it into the others, relying on the marketplace dereferencing a link to a sibling plugin when it copies a plugin into the cache. Rejected because a plugin's version is the commit of its own directory: a commit that changes only the loader leaves every linking plugin's version unchanged, so consumers keep their cached copies of the old loader until something else in each plugin happens to change.

### Discover installed plugins from one loader

Ship one loader plugin that finds every installed Zantarix plugin by reading Claude Code's record of installed plugins, and loads all their rules without any plugin taking part. Rejected because that record is the harness's own bookkeeping, documented for diagnosing an install rather than offered as an interface, and because the loader would have to decide which installed plugins' `rules/` directories count, where registration lets each plugin opt in for itself.
