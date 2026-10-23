---
type: Overview
title: Components
description: The kinds of thing a Zantarix plugin ships — skills, agents, rules, hooks, and workflows — what each is good for, how they reach a consumer project, and what each costs in context.
tags: [components, plugins, skills, rules, agents, hooks, workflows, distribution]
generated: { by: architecture-curator/claude-opus-5-5, at: 2026-10-23T11:38:29Z }
status: stable
---

# Components

This marketplace publishes five plugins — `zantarix`, `github`, `gitlab`,
`rescript`, `rust` — built from five kinds of component. Choosing between them is
the most common design question here, and the axis that decides it is **when the
content needs to be in context**.

Today the corpus is 32 skills, 5 agents, 47 rules, a hooks module in every
plugin, command hooks in two, and one workflow.

## The five kinds

### Rules — always loaded, so always paying

A rule is markdown directives at `plugins/<plugin>/rules/<name>.md`, injected into context
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

Skills may ship files beside them — `review` bundles a materialisation script —
and those are addressed through `${CLAUDE_SKILL_DIR}`.

`disable-model-invocation: true` removes a skill from the model's reach while
leaving it available to the user. It carries three distinct meanings here,
described in the [orchestration overview](../orchestration/overview.md): a human
authorisation gate, a procedure that only makes sense once the human has done
something out of band, or reference prose nobody invokes at all, kept off every
agent's skill listing because it is there to be preloaded.

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

That framing has a limit. **Content that exists to correct in-the-moment
judgment is not gated behind in-the-moment judgment**
([ADR-0008](0008-keep-judgment-correcting-content-out-of-on-demand-skills.md)):
a fixed authoring order or a checklist against a predictable failure stays
loaded however large it grows, and only material fired by something the agent can
check rather than recognise may be left on demand.

The curator is where this bites. Roughly two thirds of its prompt is ADR-authoring
and errata apparatus that does not fire when it edits a specification or an
overview — which under the regime is the common case — so the saving from
splitting it is real, and the prompt stays whole anyway.

### Hooks — the only mechanical enforcement

Hooks come in two forms, both registered in the plugin's `hooks/hooks.json`; no
plugin registers hooks in `plugin.json`. A **command hook** is a script listed
under that file's `hooks` key for `PreToolUse` or `PostToolUse`, receiving the
tool payload as JSON on stdin. A **hooks module** is a TypeScript module the same
file names under `modules`, written against Claude Code's early-access function-hooks API: it hooks engine
events directly and reaches everything else through the engine interface, with no
filesystem or Node access of its own. Hooks are the only component that can *stop*
something: prompt text is advisory, and a sufficiently distracted model will talk
itself past it.

Two plugins ship command hooks. `zantarix` guards the architecture bundle's
authorship and formats markdown after every edit; `rust` carries its own
formatter. A `PreToolUse` hook denies by returning a structured decision with a
reason the model can act on, which is why the guard's denial names both routes to
compliance rather than just refusing.

Every plugin ships a hooks module, and today each one does a single job: loading
that plugin's rules, described below. None of them gates anything.

### Workflows — scripts the Workflow tool runs by name

A workflow is a script in a plugin-root `workflows/` directory, run by the
Workflow tool and addressed by name as `<plugin>:<name>` rather than by path — the
tool refuses a script path outside the working directory, so a path into a
plugin's install directory cannot reach it. `zantarix` ships one,
`review-fanout`, which the `review` skill drives.

The harness also exposes every plugin workflow as a user-invocable
`/<plugin>:<name>` command, and there is no `disable-model-invocation`
equivalent to withhold it. A workflow meant only as a skill's engine therefore
guards itself: `review-fanout` throws unless it receives a mode argument that
only its skill supplies.

## How any of it reaches a consumer

Plugins are pulled in through `extraKnownMarketplaces` in a consumer's
`.claude/settings.json`, and skills, agents, hooks, workflows, and rules arrive with
them.

Rules arrive by a route of the plugins' own, because the plugin harness still has
no rules component — the gap is tracked upstream at
[anthropics/claude-code#14200](https://github.com/anthropics/claude-code/issues/14200).
Each plugin keeps its rules in its own `rules/` directory and loads them with its
hooks module, as [ADR-0009](0009-distribute-rules-through-each-plugins-own-hooks-module.md)
decides; [Plugin Rule Loading](rule-loading.md) carries the loader's contract. The
loader has one canonical copy in `zantarix`, and a sync script copies it into the
other four plugins and can check that the copies have not drifted. That route is
built, in all five plugins; ADR-0009 is still Proposed.

Rules therefore depend on hooks modules loading at all. The API is early access,
and whether a module loads depends on a switch in Claude Code rather than on
anything the plugin ships: with it off, a plugin loads no rules and says nothing in
the conversation. Each plugin
registers a command that lists the rules it loaded, which is the way to tell.

The route it replaced had consumers add this repository as a git submodule and
symlink `rules/<plugin>/` directories into their own `.claude/rules/`. A consumer
still set up that way receives each rule twice, and each plugin warns at session
start when it finds its own rules duplicated there.

This repository has left the old route: its own `.claude/rules/` holds only the
project override `changesets.md`. It enables `zantarix`, `github`, and `gitlab`
from the installed — that is, pushed — plugin versions, so its sessions receive
organisation rules only from what those versions deliver, and the pushed versions
do not yet carry the loader.

A consumer distinguishes organisation rules from its own by origin: a rule a
plugin loaded is org-level and immutable locally, while a file in `.claude/rules/`
is the project's own and may override — with contradictions surfaced rather than
blended.

## Consequences worth knowing before adding something

- **The repository has no build or compile step, and little is tested.** The
  rules loader's pure parsing and matching logic has unit tests, run with
  `claude plugin test plugins/zantarix`, and the sync script's `--check` catches a
  drifted copy; the engine-facing half of the loader and every other component —
  configuration and markdown — are validated only by reading. The
  `plugin-reviewer` agent exists for this, and it is the check that catches
  contradiction-at-a-distance between a prompt and the rules around it.
- **Distributed prompts are self-contained.** This bundle is not distributed, so a
  consumer project's agent never reads it. These documents explain *why* the
  prompts say what they say; the operative instruction always lives in the prompt.
- **Component names share one namespace per kind.** Two plugins both publish a
  `code-reviewer`, which discovery-by-suffix surfaces as two agents with matching
  bare names in a repository enabling both.
