---
type: Architecture Decision
title: Orchestrate the `/review` Skill with a Two-Phase Dynamic Workflow
description: Re-architects the /review skill around a deterministic two-phase dynamic Workflow with remit-aware per-reviewer partitioning under a hard cost cap.
tags: [orchestration, review, dynamic-workflow, subagents]
timestamp: 2026-07-13T00:00:00Z
status: Accepted
---

# ADR-0001: Orchestrate the `/review` Skill with a Two-Phase Dynamic Workflow

## Status

Accepted (2026-07-13)

## Context

The `zantarix:review` skill (`plugins/zantarix/skills/review/SKILL.md`) fans out every
`*-reviewer` agent over a set of changes, collates their findings into a single `review.md`, and
fixes the critical and major findings in one pass. Today both the fan-out and the collation are
model-driven: the model decides how to spawn reviewers and a `haiku`-model subagent parses each
reviewer's freeform markdown back into the consolidated document.

Because the model owns orchestration, the skill has to carry two large blocks of defensive prose
whose only purpose is to keep that model-driven flow on the rails. One block warns the model to
spawn every reviewer up front and to avoid throttling, waving, `ScheduleWakeup`, sleeping, or
polling. The other is a roughly 35-line collation skeleton marked "mandatory and exact", enforced
so tightly precisely because a weak model is transcribing markdown into the contract-bearing
`review.md`. This prose is compensation, not design.

The orchestration model also imposes a structural limit: the skill can only apply a **single global
partition** shared across every reviewer. A dedicated partitioner subagent slices the diff once, and
that one slicing is a compromise applied to all reviewers regardless of remit. The original intent
was **remit-aware partitioning** — each reviewer slicing the changes the way that makes sense for
its own review case. Expressing that required a reviewer to spawn its own sub-reviewers, i.e.
nesting subagents, which the repository cannot depend on.

Claude Code dynamic workflows now provide deterministic multi-stage orchestration: a JavaScript
script fans work across subagents, keeps intermediate results in script variables rather than the
model's context, and returns only the final result. A stage's output can become the next stage's
work-list, and passing a JSON Schema to a spawned agent forces it into a validated structured-output
call instead of freeform prose. This makes remit-aware partitioning expressible as a flat two-phase
pipeline without any subagent nesting, and lets an orchestrator see every proposed unit of work
before committing to it — the basis for a hard cost cap. Adopting it makes the skill hard-depend on
the `Workflow` tool, which is reliably present in the environments this marketplace targets.

Four constraints shape the design:

### Arbitrary, dynamic reviewer set

The set of reviewers is not fixed. It is discovered per consumer repository from the enabled plugins
plus any project-local reviewers (for example a repo-local `security-reviewer`). Discovery works by
scanning system context for pre-defined agents whose name ends with `-reviewer`; it must not scan the
filesystem. Any redesign has to preserve this discovery verbatim and stay generic over whatever
reviewer list a given repository yields.

### The `review.md` contract is consumed downstream

`review.md` is not an internal artifact. `github:create-pull-request` posts it **verbatim** as a PR
comment, and `gitlab:post-mr-review` parses it structurally to reconcile findings against the current
branch and stage inline draft notes. Both depend on its exact shape: a Summary Table with a per
(reviewer, chunk) row and a `**Total**` row, a `## Needs Human Input` section, severity headings, the
`[ ]`/`[x]` checkbox markers, and each finding carrying `file:line`, its reviewer, and its chunk id.
The document's structure cannot change.

### The session-path handoff is conversational

Downstream skills locate the review by reading its session path (`.reviews/<session>/review.md`) from
the conversation transcript, never by scanning the filesystem — `.reviews/` accumulates folders from
many branches and a filesystem search would surface stale reviews. The session path must therefore be
surfaced into the transcript after review completes.

### Reviewers are also invoked standalone

Every `*-reviewer` is invoked directly, outside `/review`. The `## Review modes` and `## Output
Format` sections currently in each reviewer agent exist only to serve this skill — the agent text
says so explicitly, instructing the reviewer to emit an exact structure "so the skill can parse
results" and to write its own file under `.reviews/`. When invoked standalone those sections are
noise, and one distributed reviewer (`documentation-reviewer`) is told to write its own report yet
holds no `Write` tool grant.

## References

- [Orchestrate subagents at scale with dynamic workflows](https://code.claude.com/docs/en/workflows)
- [Introducing dynamic workflows in Claude Code](https://claude.com/blog/introducing-dynamic-workflows-in-claude-code)
- [review skill](../../../plugins/zantarix/skills/review/SKILL.md)
- [create-pull-request skill](../../../plugins/github/skills/create-pull-request/SKILL.md)
- [create-merge-request skill](../../../plugins/gitlab/skills/create-merge-request/SKILL.md)
- [post-mr-review skill](../../../plugins/gitlab/skills/post-mr-review/SKILL.md)

## Decision

We will re-architect `/review` around a dynamic Workflow that performs remit-aware, per-reviewer
partitioning as a two-phase flat pipeline under a hard cost cap. Reviewer discovery, the fix pass,
the report, the `.reviews/` audit trail, and the `review.md` contract are preserved; the model-driven
fan-out and the haiku collation are replaced.

### Reviewer discovery stays inline

The skill discovers reviewers inline, before invoking the workflow, using the existing system-context
scan for agents whose name ends with `-reviewer`. The discovered agent-type list is passed to the
workflow as `args`. The workflow script hardcodes no reviewer names and is generic over whatever list
it receives.

### Phase 1 — partition proposals

The workflow spawns one agent of each discovered reviewer type in a `parallel` barrier. Each reads the
whole review scope and returns a structured partition proposal for its own remit, shaped as
`{ chunks: [...] }`. A proposal may include an optional `cross` chunk covering that reviewer's own
cross-boundary surface — signature, rename, and contract consistency across its chunks — to be
reviewed like any other chunk in phase 2. The `parallel` barrier is deliberate: the cost gate needs
every proposal in hand to compute the projected total.

### Cost gate between phases

The orchestration is split into two workflow invocations with the gate inline in the main loop
between them. The first invocation runs phase 1 and returns the per-reviewer proposals. The main loop
sums the projected phase-2 subagent count across all proposals. If the total is at most the cap of
**20**, it launches the second invocation directly. If the total exceeds the cap, it asks the user via
`AskUserQuestion` to proceed as proposed or constrain to a lower cap; on a constraint the main loop
trims the chunk list itself before launching the second invocation. The second invocation receives the
possibly-trimmed reviewer-to-chunks list as `args` and runs phase 2 only.

### Phase 2 — review

Given the reviewer-to-chunks work-list, the workflow fans out one review agent per (reviewer, chunk):
each reviews exactly its assigned files in depth and reports only on them. Across reviewers this runs
in parallel; within a reviewer its chunks run concurrently. Each agent returns findings validated
against a shared JSON Schema.

### The findings schema carries the full contract surface

Passing the schema to each spawned agent forces a validated structured-output call, so the workflow
returns clean, schema-validated structured data to the orchestrator. The schema carries the per-finding
fields — severity, the finding text, and `file:line` — and represents a clean result explicitly, so
that a reviewer which finds nothing is recorded as a distinct "no issues" outcome. The workflow annotates
each finding with its reviewer and chunk id as it collates, completing the field set the `review.md`
contract needs. This explicit clean-result representation is what lets a zero-finding reviewer still
render its own no-issues section and its zero-count Summary Table row.

### Deterministic collation in the workflow

The workflow renders the per-reviewer audit files and the consolidated `review.md` as markdown strings
from the schema-validated findings, and returns those strings alongside the structured findings. The
main loop writes them verbatim under `.reviews/<session>/` — the audit files to `<reviewer>/<chunk>.md`
and `review.md` to the session root — and uses the structured findings for the fix pass. `review.md`
is emitted with its existing skeleton exactly — the same Summary Table with per (reviewer, chunk) rows
and a `**Total**` row, `## Needs Human Input` section, severity headings, `[ ]`/`[x]` markers, and
`file:line`/reviewer/chunk annotations — now generated deterministically from validated data rather than
transcribed by a model. The subsequent single-pass triage/fix and the report to the user run as they do
today, and the main loop surfaces the session path into the transcript.

### Small-scope pre-check

For a small scope — roughly at most 10 changed files or 500 changed lines — the workflow skips phase 1
and runs each reviewer once over the whole scope, returning schema'd findings directly. This stays well
under the cap and needs no gate, and gives cross-boundary coverage for free from the single whole-scope
pass. This mirrors the skill's existing cheap pre-check.

### Reviewer agents become standalone

The `## Review modes` and `## Output Format` sections are removed from each distributed reviewer agent,
along with any language instructing a reviewer to emit an exact structure for the skill or to write its
own file. Each reviewer becomes a plain, focused agent that reviews the changes it is given, with only
light "group findings by severity" guidance for standalone readability. Their existing `Write(.reviews/**)`
tool grants are retained: removing a tool grant from a distributed agent is a contract change, and the
grants are harmless when unused.

## Consequences

### Positive

- Remit-aware partitioning replaces the single global partition: each reviewer slices the changes for
  its own review case, and the orchestrator sees every proposed chunk and can cap the fan-out.
- The defensive prose disappears — both the fan-out throttling warnings and the mandatory-and-exact
  collation skeleton — because orchestration and collation are deterministic rather than model-driven.
- Collation no longer depends on a weak model transcribing markdown; `review.md` is generated from
  schema-validated data, removing a class of contract-drift failures.
- The pre-existing inconsistency where `documentation-reviewer` was told to write its own report
  without a `Write` grant is resolved, because no reviewer writes its own report under the new model.
- Each distributed reviewer becomes a cleaner standalone agent once the skill-coupling sections are
  removed.

### Negative

- The workflow script is the first `.js` artifact in a repository otherwise described as entirely
  configuration and markdown. It falls outside the automated formatting path, which runs markdownlint
  on `.md` files only, so the script has no lint or format coverage.
- The cost gate requires two workflow invocations rather than one, adding a proposal round-trip on
  large diffs — the slow, expensive case where that round-trip is comparatively cheap.
- Removing the `mode:`/output protocol from distributed agents would break any consumer that built
  independent tooling on it. The risk is low because the agent text ties those sections explicitly to
  this skill, but it is a change to a distributed contract.

### Neutral

- The skill hard-depends on the `Workflow` tool, raising the portability floor. This is acceptable
  because the tool is reliably present in the environments this marketplace targets.
- Workflow correctness does not depend on editing the reviewer agents: the schema forces a
  structured-output call regardless of an agent's system prompt, so the structured returns work even
  before the agents are simplified. The agent cleanup is a decoupled simplification, not a correctness
  prerequisite.
- Reviewer discovery, the small-scope pre-check, the single-pass triage/fix, the report, and the
  `.reviews/` audit trail are preserved unchanged in behaviour.

## Alternatives Considered

### Route A — subagent nesting

Each reviewer autonomously spawns its own sub-reviewers to achieve remit-aware partitioning. Rejected
on two grounds. First, it depends on the subagent-nesting harness feature, whose availability the
repository will not rely on. Second, each reviewer would decide its own fan-out width, making the total
cost model-driven and unbounded — surrendering the exact backstop this design needs. Route B delivers
the same remit-aware partitioning while keeping every proposed chunk visible to a capping orchestrator.

### Status quo — model-driven global partition

Keep the current model-driven fan-out and haiku collation. Rejected because it retains the defensive
prose it exists to compensate for, and can only ever apply one partition shared across all reviewers —
the compromise this change removes.

### File-writing reviewers with the workflow owning only fan-out shape

Let the workflow own only the fan-out shape while reviewers continue to write their own report files
and a collator consolidates them. Rejected because it loses the deterministic-collation benefit — the
haiku collator and its enforcement prose survive — keeps the cost cap coarse, and does not resolve the
`documentation-reviewer` missing-`Write`-grant inconsistency. A schema-validated structured return
addresses all three.

### Single workflow with resume

Run the whole pipeline in one workflow invocation that early-returns a `pendingConfirmation` marker
when the projected count exceeds the cap, then resume it via `resumeFromRunId` after the user responds.
This would save one background-task launch on large diffs. Rejected because the gate branch re-fires on
resume unless a workflow argument is mutated, and it leans on two semantics that are not verified: that
`resumeFromRunId` applies to a run that completed normally rather than one that errored, and that
changing an argument preserves the phase-1 cache prefix. Two separate invocations with the gate inline
between them are strictly simpler on every path and carry no such assumptions. Collapsing to one
workflow remains a valid future optimisation if both semantics are later confirmed cheaply.
