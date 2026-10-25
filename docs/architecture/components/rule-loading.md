---
type: Specification
title: Plugin Rule Loading
description: How the shared `rules` plugin loads the rules every Zantarix plugin registers with it — how a plugin registers, which rules enter where, the fallback when instruction files are out of reach, and how a consumer sees what loaded.
tags: [components, rules, distribution, hooks, loader, dependencies]
generated: { by: architecture-curator/claude-opus-5-5, at: 2026-10-25T02:27:52Z }
status: stable
sources:
  - { resource: "https://github.com/anthropics/claude-code/issues/14200", id: upstream-gap, title: "Add rules support to Plugins" }
  - { resource: "https://github.com/mcmanussliam/claude-plugin-rules", id: plugin-rules, title: "claude-plugin-rules (MIT)" }
  - { resource: "https://code.claude.com/docs/en/plugins/dependencies", id: plugin-deps, title: "Plugin dependencies" }
---

# Plugin Rule Loading

The contract by which a Zantarix plugin's rules reach a consumer's session. Claude
Code has no rules component for plugins,[^upstream-gap] so each plugin carries its
rules and they arrive through hooks modules
([ADR-0009](0009-distribute-rules-through-plugin-hooks-modules.md)); one plugin,
`rules`, does the loading for all of them
([ADR-0010](0010-load-every-plugins-rules-through-a-shared-rules-plugin.md)). The
loader's design follows an existing MIT loader[^plugin-rules] and Anthropic's
`agents-md` mod.

## Registration

The `rules` plugin owns the loader, in its hooks module, and the type of the
`rules` namespace it adds to the engine interface when the engine is created. That
namespace has one call, `add`, taking the registering plugin's name and its
directory.

Every plugin that ships rules lists `rules` under `dependencies` in its
`plugin.json`, so installing the plugin installs the loader with it.[^plugin-deps]
Its own hooks module registers from a `session.start` hook, after the rest of the
session has started, by calling `$.rules.add` with `$.plugin.name` and
`$.plugin.root`. A new plugin that ships rules needs that dependency and that hook,
and nothing in `rules` names it.

The loader answers `add` with a hook of its own, which runs in the caller's context
and so reads the caller's directory. Registered rules are kept by plugin name: a
plugin that registers again replaces its earlier rules rather than adding to them.

## What is loaded

For each registered plugin the loader reads every `.md` file under that plugin's
`rules/` directory, and nothing outside it. A rule's `paths:` frontmatter — a block
list, an inline list, or a single string — makes it **scoped**; a rule without one
is **unscoped**, as in `.claude/rules/`. A file whose body is empty once its
frontmatter is removed is not a rule. Files are read when the plugin registers, and
so are read again at the next session start.

## Unscoped rules

Unscoped rules enter through `prompt.context` as instruction files of kind `user`,
placed after any `user` file already present and before the project, local, and
memory files. A project's own rules therefore render after every plugin rule. A
rule whose path is already among the instruction files is not added again. Where a
hook above has rewritten the instruction text, leaving the file list unknown, the
loader leaves the instruction files alone and the session is handled as one whose
instruction files are out of reach, below.

## Scoped rules

A scoped rule attaches, as context on the result, when a successful `Read` or an
`@`-mention reaches a file inside the project whose project-relative path matches
one of its globs. A glob without a `/` matches the file name at any depth. Each
rule attaches once per agent loop: a forked subagent inherits its parent's record,
and compaction or `/clear` resets it so the rule can attach again.

Writes, searches, and files outside the project attach nothing.

## Fallback when instruction files are out of reach

Some sessions never run the loader's `prompt.context` hook, or run it with the file
list unknown. When a turn completes without the hook having added the rules, the
loader treats the session as bypassed and delivers every registered plugin's
unscoped rules instead as context on the next submitted prompt and on tool results,
once per agent loop. Detection takes a turn: in a bypassed session, the first turn
carries no unscoped rules.

Where hooks modules do not load at all — the module-loading switch off, or a
settings policy that admits only managed hooks — nothing in this document runs, and
no rule is delivered.

## Seeing what loaded

The loader registers one `/zantarix-rules` command at session start. It lists each
registered plugin with its rules, each scoped rule with its globs, and the delivery
mode for unscoped rules: instruction files, the fallback, or not yet confirmed.

A missing `/zantarix-rules` command means the `rules` plugin's hooks module did not load. A
plugin missing from the listing did not register: its own hooks module did not run,
or its registration failed.

## Duplicates from the old route

When a plugin registers, the loader compares that plugin's rules with the files
under the project's `.claude/rules/`, following symlinks, and logs a warning naming
the plugin when any rule's body appears there as well — the trace of the submodule
and symlink route ADR-0009 replaces, under which every such rule would be sent
twice.

## Failure

Rules gate nothing. Every plugin's registration hook, and every hook the loader
registers but one, passes its event on unchanged when it fails, so a failed
registration or a broken loader costs rules and never a tool call, prompt, or
session.

The exception is the hook that adds the `rules` namespace when the engine is
created, which the engine gives no way to recover from: its failure fails the
`rules` plugin's module load. No rule from any plugin is then delivered, `/zantarix-rules`
is missing, and each dependant's registration fails and is passed over like any
other failed registration.

## Tests

The loader's pure parsing and matching logic has unit tests beside it in the
`rules` plugin, run with `claude plugin test plugins/rules`. Its engine-facing half
has no automated test.

[^upstream-gap]: Add rules support to Plugins
[^plugin-rules]: claude-plugin-rules (MIT)
[^plugin-deps]: Plugin dependencies
