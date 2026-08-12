# Zantarix Claude Code Marketplace

The domain language of this repository. Claude Code's own vocabulary — skill,
agent, rule, hook, marketplace — is used as the platform defines it and is not
redefined here.

## Language

### Architecture documentation

The regime's vocabulary is **organisation-level, not local to this repository**:
every project adopting the architecture-documentation regime uses the same terms,
so they are distributed with the plugin rather than defined here.

They live in
[`plugins/zantarix/skills/architecture-vocabulary/SKILL.md`](./plugins/zantarix/skills/architecture-vocabulary/SKILL.md)
— covering *decision*, *constraint*, *living document*, *overview*,
*specification*, *current truth*, *conformance gap*, and *drift*.

Read that file directly. It carries `disable-model-invocation`, so it cannot be
invoked as a skill; it is preloaded into the `architecture-curator` and
`architecture-reviewer` agents, and any other agent needs to open the path above.

### Marketplace

No terms are recorded yet. This section fills as a marketplace-specific term
becomes contested — not pre-emptively, since vocabulary nobody is arguing about
is how imprecise definitions enter the corpus.
