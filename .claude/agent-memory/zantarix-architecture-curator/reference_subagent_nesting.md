---
name: subagents-can-spawn-subagents
description: Subagents CAN spawn subagents in the current Claude Code harness — reject "no nested subagents" as an outdated premise.
metadata:
  type: reference
---

Subagents can spawn subagents in the current Claude Code harness; the
`/review` fan-out works this way today. "Subagents cannot spawn subagents"
is an **outdated** limitation — a plugin-reviewer Critical built on it
(2026-08-06, ADR-0004 implementation review) forced an unnecessary
orchestration-lifting redesign of the pre-acceptance review path that was
reverted. If a design or review finding rests on nested-spawn being
impossible, verify against current harness behaviour (or ask) before acting
on it. The curator's rule-mandated review step delegating directly to
`@zantarix:architecture-reviewer` works regardless of how the curator itself
was invoked.
