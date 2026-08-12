---
type: Overview
title: Components
description: The kinds of thing a Zantarix plugin ships — skills, agents, rules, and hooks — what each is good for, how they reach a consumer project, and what each costs in context.
tags: [components, plugins, skills, rules, agents, hooks, distribution]
generated: { by: architecture-curator/claude-opus-5, at: 2026-08-12T10:05:09Z }
status: stable
---

# Components

This marketplace publishes five plugins — `zantarix`, `github`, `gitlab`,
`rescript`, `rust` — built from four kinds of component. Choosing between them is
the most common design question here, and the axis that decides it is **when the
content needs to be in context**.

Today the corpus is 31 skills, 5 agents, 47 rules, and hooks in two plugins.

## The four kinds

### Rules — always loaded, so always paying

A rule is markdown directives at `rules/<plugin>/<name>.md`, injected into context
whenever it is in scope. That makes a rule the right home for something that must
shape behaviour without anyone deciding to consult it, and the wrong home for
anything long: rules are capped at 50 lines, and one that outgrows the cap is
split by concern rather than trimmed.

Because a rule is always paying, scope is the main lever. A `paths:` frontmatter
list of globs restricts it to matching files; 21 of the 47 rules are scoped this
way, and only genuinely universal concerns — style, security, workflow — are left
repo-wide. Rules are directives, not explanations: rationale is folded into the
instruction where it changes how the rule applies, and dropped where it does not.

### Skills — loaded on demand, so they can be long

A skill is a procedure at `plugins/<name>/skills/<skill>/SKILL.md`, loaded only
when invoked. That inverts the rule's economics: a skill can carry a long recipe,
a worked example, or a shell incantation, because nobody pays for it until they
need it.

Skills may ship files beside them — `review` bundles a workflow script and a
materialisation script — and those are addressed through `${CLAUDE_SKILL_DIR}`.

`disable-model-invocation: true` removes a skill from the model's reach while
leaving it available to the user. It carries two distinct meanings here, described
in the [orchestration overview](../orchestration/overview.md): a human
authorisation gate, or a procedure that only makes sense once the human has done
something out of band.

The common failure is writing as a skill what a rule should carry. A skill that
must fire *reliably* on some trigger is only as reliable as the model's decision to
invoke it, so the pattern in use is a short scoped rule that names the trigger and
delegates to the skill for the procedure — the rule pays a few lines always, the
skill's bulk is paid on use.

### Agents — a separate context with its own remit

An agent at `plugins/<name>/agents/<name>.md` is a system prompt for a subagent
with its own context window and tool grants. Agents are for work that wants
isolation, a narrower toolset, or a voice of its own — the four `-reviewer` agents
and the architecture curator.

An agent's frontmatter can **preload** skills, and three agents do. Preloading is
worth understanding precisely: a preloaded skill costs exactly what prompt text
costs, because it is in context from the first turn. It buys shared authorship —
one wording used by several agents — not context. Only skills that fire
*sometimes* save anything by being left on demand.

### Hooks — the only mechanical enforcement

A hook is a script registered in `plugin.json`, receiving the tool payload as
JSON on stdin. Hooks are the only component that can *stop* something: prompt
text is advisory, and a sufficiently distracted model will talk itself past it.

Two plugins ship hooks. `zantarix` guards the architecture bundle's authorship and
formats markdown after every edit; `rust` carries its own. A `PreToolUse` hook
denies by returning a structured decision with a reason the model can act on,
which is why the guard's denial names both routes to compliance rather than just
refusing.

## How any of it reaches a consumer

Plugins are pulled in through `extraKnownMarketplaces` in a consumer's
`.claude/settings.json`, and skills, agents, and hooks arrive with them.

**Rules do not.** The plugin harness has no mechanism to distribute them, so
consumers add this repository as a git submodule and symlink `rules/<plugin>/`
directories into their own `.claude/rules/`. This repository does the same to
dogfood its own rules. The limitation is tracked upstream at
[anthropics/claude-code#14200](https://github.com/anthropics/claude-code/issues/14200);
the split between `rules/` and `plugins/` exists only because of it and would not
survive a fix.

A consumer distinguishes organisation rules from its own by that symlink: anything
reached through one is org-level and immutable locally, while a plain file in
`.claude/rules/` is the project's own and may override — with contradictions
surfaced rather than blended.

## Consequences worth knowing before adding something

- **The repository has no build, test, or compile step.** It is configuration and
  markdown, so nothing mechanically validates a component; correctness is a
  reading. The `plugin-reviewer` agent exists for this, and it is the check that
  catches contradiction-at-a-distance between a prompt and the rules around it.
- **Distributed prompts are self-contained.** This bundle is not distributed, so a
  consumer project's agent never reads it. These documents explain *why* the
  prompts say what they say; the operative instruction always lives in the prompt.
- **Component names share one namespace per kind.** Two plugins both publish a
  `code-reviewer`, which discovery-by-suffix surfaces as two agents with matching
  bare names in a repository enabling both.
