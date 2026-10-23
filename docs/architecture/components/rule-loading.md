---
type: Specification
title: Plugin Rule Loading
description: How each plugin loads its own rules into a consumer's session through its hooks module — which rules enter where, the fallback when instruction files are out of reach, how a consumer sees what loaded, and how the loader's copies are kept identical.
tags: [components, rules, distribution, hooks, loader]
generated: { by: architecture-curator/claude-opus-5-5, at: 2026-10-23T11:15:49Z }
status: stable
sources:
  - { resource: "https://github.com/anthropics/claude-code/issues/14200", id: upstream-gap, title: "Add rules support to Plugins" }
  - { resource: "https://github.com/mcmanussliam/claude-plugin-rules", id: plugin-rules, title: "claude-plugin-rules (MIT)" }
---

# Plugin Rule Loading

The contract by which a Zantarix plugin delivers its own rules, driven by
[ADR-0009](0009-distribute-rules-through-each-plugins-own-hooks-module.md). Claude
Code has no rules component for plugins,[^upstream-gap] so each plugin's hooks
module does the loading itself. The loader's design follows an existing MIT
loader[^plugin-rules] and Anthropic's `agents-md` mod.

## What a plugin loads

A plugin loads every `.md` file under its own `rules/` directory, located through
`$.plugin.root`, and nothing outside it. A rule's `paths:` frontmatter — a block
list, an inline list, or a single string — makes it **scoped**; a rule without one
is **unscoped**, as in `.claude/rules/`. A file whose body is empty once its
frontmatter is removed is not a rule. Files are read once per session and re-read
at the next session start.

## Unscoped rules

Unscoped rules enter through `prompt.context` as instruction files of kind `user`,
placed after any `user` file already present and before the project, local, and
memory files. A project's own rules therefore render after every plugin rule. A rule whose
path is already among the instruction files is not added again. Where a hook
above has rewritten the instruction text, leaving the file list unknown, the
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

Some sessions never run a plugin's `prompt.context` hook, or run it with the file
list unknown. When a turn completes without the hook having added the rules, the
loader treats the session as bypassed and delivers
unscoped rules instead as context on the next submitted prompt and on tool
results, once per agent loop. Detection takes a turn: in a bypassed session, the
first turn carries no unscoped rules.

Where hooks modules do not load at all — the module-loading switch off, or a
settings policy that admits only managed hooks — nothing in this document runs, and
no rule is delivered.

## Seeing what loaded

Each plugin registers a `/<plugin>-rules` command at session start. It lists the
plugin's rules, each scoped rule with its globs, and the delivery mode for
unscoped rules: instruction files, the fallback, or not yet confirmed. A plugin
whose command is missing has not loaded its hooks module.

## Duplicates from the old route

At session start each plugin compares its rules with the files under the
project's `.claude/rules/`, following symlinks, and logs a warning when any rule's
body appears there as well — the trace of the submodule and symlink route this
loader replaces, under which every such rule would be sent twice.

## Failure

Rules gate nothing. Every hook the loader registers passes its event on unchanged
when it fails, so a broken loader costs its rules and never a tool call, prompt, or
session.

## One source, copied

The canonical loader is `plugins/zantarix/hooks/rules-loader/`. Every other plugin
carries byte-identical copies of its source files, made by
`plugins/zantarix/scripts/sync-rules-loader.sh`; with `--check`, the script copies
nothing and exits non-zero naming each copy that has drifted. Tests stay with the
canonical copy. Each plugin's `hooks/hooks.json` names a `register.ts` that calls
the loader. The script names the plugins it copies into, so a new plugin that
ships rules is added to it by hand.

The copies exist because an installed plugin runs from its own installed copy, so
a module cannot count on another plugin's files sitting at any known path beside
it; a symlink or a cross-plugin import would assume exactly that.

[^upstream-gap]: Add rules support to Plugins
[^plugin-rules]: claude-plugin-rules (MIT)
