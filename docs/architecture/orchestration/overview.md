---
type: Overview
title: Orchestration
description: How this marketplace's plugins coordinate multi-agent work today — remit-aware review fan-out under a cost cap, sole-writer delegation enforced by a hook, and human authorisation gates.
tags: [orchestration, subagents, review, human-gates, hooks]
generated: { by: architecture-curator/claude-opus-5, at: 2026-08-12T09:50:49Z }
status: stable
---

# Orchestration

This repository ships no runtime. Its plugins coordinate work by arranging *other*
agents — so orchestration here is expressed in three places only: agent and skill
prose, two hook scripts, and a single workflow script. There is no scheduler, no
queue, and no state that survives a session.

Three shapes are in use, and they are chosen for different reasons.

## Fan-out over a discovered agent set

`/zantarix:review` is the one place work is spread across many agents at once. It
runs as a deterministic two-phase dynamic Workflow, decided in
[ADR-0001](0001-review-dynamic-workflow.md) and built as described there.

Reviewers are **discovered, not enumerated**: the skill scans system context for
agents whose name ends in `-reviewer` and passes that list to the workflow, which
hardcodes no names. Four ship from this marketplace — `rust:code-reviewer`,
`rescript:code-reviewer`, `zantarix:architecture-reviewer`, and
`zantarix:documentation-reviewer` — and a consumer repository's own reviewers join
the same fan-out automatically. Discovery deliberately never touches the
filesystem.

Phase 1 asks each reviewer how it would partition the diff **for its own remit**;
phase 2 fans out one agent per (reviewer, chunk). Between them sits a cost gate:
the projected phase-2 count is summed, and above a cap of **20** the user is asked
whether to proceed or constrain. A small scope — roughly 10 changed files or 500
changed lines — skips phase 1 entirely and reviews the whole scope once per
reviewer. Findings return schema-validated, and the workflow renders `review.md`
deterministically rather than having a model transcribe it, because that document
is a downstream contract: `github:create-pull-request` posts it verbatim and
`gitlab:post-mr-review` parses it structurally.

One as-built detail the decision does not mention: the Workflow tool cannot write
files, so the workflow returns its rendered markdown as strings and a companion
`materialize-review.sh`, bundled beside the skill, writes them under
`.reviews/<session>/`. Reviewers are also invoked directly, outside the skill, and
carry no skill-coupling sections that would make standalone use awkward.

## Sole-writer delegation, enforced by a hook

Where a body of documentation needs one consistent authorial voice, this
marketplace assigns it to a single agent and enforces the assignment mechanically
rather than by convention. The architecture bundle is the case in point: every
write under `docs/adr/` or `docs/architecture/` is the
`zantarix:architecture-curator`'s, and `guard-adr.sh` — a `PreToolUse` hook on
`Edit`, `Write`, and `MultiEdit` — denies the write otherwise, returning a
structured message naming both routes to compliance.

The hook accepts the curator whether it was reached by delegation from another
session or started directly with `claude --agent`. Both are in use: ordinary work
delegates, while the human-gated skills below require the direct form. The hook
also still accepts the pre-rename `zantarix:adr-architect` identity, a transitional
allowance its own comment marks for removal once no consumer pins the old name.

A second hook, `format.sh`, runs `markdownlint --fix` on every edited `.md` file.
It is a formatter rather than a linter by design — it always exits zero and
reports nothing — so it silently normalises markdown but never gates a change.

## Human gates

Some actions are authorised by a person choosing to take them, and the mechanism
is `disable-model-invocation: true`, which removes a skill from the model's reach
while leaving it available to the user. The flag serves two distinct purposes,
which is worth knowing when adding one:

- **Authorisation gates**, where running the skill *is* the permission —
  `/accept-adr`, `/adopt-architecture`, `/okf-migrate-adr`. Each mutates accepted,
  immutable ADRs, so no agent may grant itself the right.
- **Human-initiated cadence**, where the skill only makes sense after something
  happens out of band — `/rust:analyse-mutations` needs a manual `cargo mutants`
  run to have produced a report, and `/zantarix:memory-reconciliation` is a
  periodic triage requiring explicit approval per item.

Gates do not chain. A gate that finds its precondition unmet stops and directs the
user to the other gate rather than firing it —
[ADR-0004](../knowledge/0004-split-architecture-documentation-into-immutable-adrs-and-living-documents.md)
fixes this for the adoption path, and it holds generally: one human authorisation
never implies another.

All three authorisation gates additionally require the session itself to be the
curator, refusing with a copy-pasteable `claude --agent …` command that carries the
attempted invocation as the new session's initial prompt. This keeps ratification a
conversation: a discrepancy found while accepting can be put to the human directly,
where a subagent could only report it upward and lose the context that found it.

## Known gaps

- **What happens when acceptance meets a discrepancy is only half-settled.** The
  gate ratifies a document as written, changing status and verification and nothing
  else. With the session guard in place a needed refinement can be made in front of
  the human and acceptance re-run over the corrected text, but whether the curator
  may amend during the acceptance operation itself is not decided, and the skills
  currently say it may not.
- **The workflow script has no lint or format coverage.** `format.sh` handles `.md`
  only, and `review-workflow.js` is the sole JavaScript artifact in a repository
  otherwise made of configuration and markdown. [ADR-0001](0001-review-dynamic-workflow.md)
  accepted this knowingly.
- **Reviewer names can collide across plugins.** `rust` and `rescript` both publish
  a `code-reviewer`; discovery is by suffix, so a repository enabling both sees two
  agents whose bare names match.
