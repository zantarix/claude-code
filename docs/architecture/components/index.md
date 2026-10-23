# Components

The kinds of thing a plugin ships — skills, agents, rules, and hooks — how they reach a consumer project, and what each costs in context.

* [Overview](overview.md) - what each component kind is good for, decided by when its content must be in context; how plugins and rules reach a consumer; and what mechanically enforces anything.
* [Plugin Rule Loading](rule-loading.md) - how each plugin loads its own rules into a consumer's session, which rules enter where, the fallback when instruction files are out of reach, and how a consumer sees what loaded.
* [0008 - Keep Judgment-Correcting Content Out of On-Demand Skills](0008-keep-judgment-correcting-content-out-of-on-demand-skills.md) - admits the standing rule that content existing to correct an agent's in-the-moment judgment is loaded by something other than that judgment, foreclosing its move behind a skill the agent must decide to invoke as a way of managing prompt size.
* [0009 - Distribute Rules Through Each Plugin's Own Hooks Module](0009-distribute-rules-through-each-plugins-own-hooks-module.md) - each plugin carries its rules and loads them into a consumer's session itself, replacing the git-submodule and symlink route and making rule delivery depend on Claude Code's early-access hooks-module API.
