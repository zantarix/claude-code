# Components

The kinds of thing a plugin ships — skills, agents, rules, and hooks — how they reach a consumer project, and what each costs in context.

* [Overview](overview.md) - what each component kind is good for, decided by when its content must be in context; how plugins and rules reach a consumer; and what mechanically enforces anything.
* [Plugin Rule Loading](rule-loading.md) - how plugins register their rules with the shared loader, which rules enter a consumer's session where, the fallback when instruction files are out of reach, and how a consumer sees what loaded.
* [0008 - Keep Judgment-Correcting Content Out of On-Demand Skills](0008-keep-judgment-correcting-content-out-of-on-demand-skills.md) - admits the standing rule that content existing to correct an agent's in-the-moment judgment is loaded by something other than that judgment, foreclosing its move behind a skill the agent must decide to invoke as a way of managing prompt size.
* [0009 - Distribute Rules Through Plugin Hooks Modules](0009-distribute-rules-through-plugin-hooks-modules.md) - each plugin carries its rules and they reach a consumer's session through plugin hooks modules, replacing the git-submodule and symlink route and making rule delivery depend on Claude Code's early-access hooks-module API.
* [0010 - Load Every Plugin's Rules Through a Shared Rules Plugin](0010-load-every-plugins-rules-through-a-shared-rules-plugin.md) - one plugin owns the rules loader and every rules-shipping plugin depends on it and registers with it, so a loader change ships once as a release of that plugin.
