---
name: human-gates-never-auto-chain
description: Never design one human-gated (disable-model-invocation) skill to fire or inline-execute another — stop cleanly and direct the user instead.
metadata:
  type: feedback
---

When a skill or agent design would have a `disable-model-invocation` (human-gated)
skill trigger another one — via the Skill tool (impossible) or by reading the
sibling SKILL.md and executing its steps (possible but wrong) — stop cleanly and
tell the user how to proceed, mirroring the "STOP and tell the user, verbatim"
shape the migration skills use for identity checks.

**Why:** The user overruled my read-and-execute workaround for
`adopt-architecture` → `okf-migrate-adr` (2026-08-06) in favour of the reviewer's
stop-and-instruct fix. A human gate exists to keep the human in the loop for
each authorised mutation; "skills should chain where appropriate" does not
extend across human gates, and inlining a gated skill's steps circumvents the
gate's spirit even when the letter permits it.

**How to apply:** any time a designed workflow reaches a `disable-model-invocation`
skill it did not itself enter through, the correct behaviour is: make no
changes, name the skill the user must run (with the `claude --agent ...`
invocation if agent-restricted), and say to re-run the current skill afterward.
