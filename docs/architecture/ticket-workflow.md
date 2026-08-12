---
type: Specification
title: Ticket-to-Merge Workflow
description: How the shipped skills compose into the intended path from a ticket reference to an open pull or merge request, and the sequencing constraints that path deliberately imposes.
tags: [cross-cutting, workflow, skills, tickets, review, shipping]
generated: { by: architecture-curator/claude-opus-5, at: 2026-08-13T10:12:00Z }
status: stable
---

# Ticket-to-Merge Workflow

Two skills bookend the intended path — `/zantarix:implement-ticket` takes a ticket
reference to an agreed plan, and `/zantarix:upstream` takes finished work to an
open pull or merge request. Between and beneath them, several other skills and a
number of rules fire. This describes how they compose and, more usefully, the
constraints the composition imposes on purpose.

The review stage is [ADR-0001](orchestration/0001-review-dynamic-workflow.md)'s;
see [Where nothing governs](#where-nothing-governs) for the rest.

## The path

| Stage | Driven by | Produces |
|---|---|---|
| Intake | `/implement-ticket` steps 1–3 | ticket context, clarified scope |
| Planning | plan mode, or `/plan-adr` | an approved plan, sometimes an ADR |
| Implementation | the plan | the change |
| Verification | `/verify-code`, `/zantarix:review` | fixed critical and major findings |
| Shipping | `/upstream` | branch, commit, push, PR or MR |

## Intake

The reference is disambiguated first, because GitHub and GitLab share `#N`
notation — inferred from which platform plugin is active, falling back to the
`origin` remote. On GitLab the sigil is honoured strictly: `#` is a work item, `!`
a merge request, `&` an epic, and they can share a number.

The ticket is then fetched **with its comments and linked items**, and on GitLab
moved to `In progress` and assigned to the user.

### Local reads are forbidden until planning begins

Nothing in the repository may be read before plan mode is entered — no source, no
schemas, no ADRs. This is the least obvious constraint in the workflow and the
easiest to erode, and it serves two purposes that a reader of the rule alone would
not recover.

The first is order of influence: the ticket should shape the plan before the code
does. An agent that has already read the implementation arrives at planning with
the existing design's assumptions in hand, and tends to scope the work as a
variation on what exists rather than as what was asked for.

The second is which model does the thinking. Under a split-model configuration —
`opusplan` and its equivalents — plan mode runs a more capable model than ordinary
turns. Exploration is the part of this workflow that most rewards capability, so
the prohibition exists to move the session across that boundary **before** the
expensive thinking starts, rather than spending a weaker model on the survey and
handing plan mode a partial understanding it did not form.

That second reason is why the rule is written as a hard prohibition rather than a
preference. Read as "avoid unnecessary reads", it invites the judgement that a
little orientation first is harmless; the point is not to minimise reading but to
cross into plan mode early, and any read before the boundary has already spent the
wrong model on the work.

## Planning

Plan mode is entered directly. Any `CONTEXT.md` or `CONTEXT-MAP.md` is read first,
so the conversation uses the project's own vocabulary rather than generic terms.

Exploration then happens, and only afterwards is the question asked: does this
work introduce a new architectural surface, require choosing between alternatives
with meaningfully different trade-offs, or commit to a cross-cutting pattern?

### `/plan-adr` is never the entry point

If the answer is yes, `/plan-adr` is invoked *from inside* plan mode, carrying the
ticket context and exploration findings. It is never how planning starts. Entering
through it presupposes the answer to the question exploration exists to settle, and
the criteria cannot be applied against a codebase nobody has looked at yet.

Under the architecture regime `/plan-adr` applies the materiality gate before
scoping an ADR at all: work already covered by a ledger entry is planned as a
specification update delegated to the curator, with no ADR, and contested
materiality goes to the user rather than being settled.

### The plan carries two things forward

A plan must name the ticket it implements, so the number is still in context when a
pull or merge request is created and can become a `Closes #N` footer. It must also
end with `/verify-code` and then `/zantarix:review`.

Where an ADR is involved, the plan states that acceptance is **not** part of
implementation. Ratification is a human gate and the work proceeds while the ADR is
`Proposed`; a plan that schedules acceptance has misunderstood the lifecycle.

## Verification

`/zantarix:review` fans every discovered reviewer over the change and fixes
critical and major findings in one pass. It has **no re-run loop** by design:
breadth comes from per-reviewer partitioning rather than repetition, and the human
review is the verifying gate. The skill's job is to clear the obvious before that
gate, not to converge on its own.

Its output lands under `.reviews/<session>/`, and the session path is surfaced into
the conversation. That handoff is deliberately conversational — downstream skills
read the path from the transcript rather than scanning the filesystem, because
`.reviews/` accumulates folders from every branch and a search would surface a
stale one.

## Shipping

`/zantarix:upstream` runs four steps and stops on any failure.

1. **Branch.** If on `main`, derive a feature branch and say so before continuing.
2. **Commit** via `/zantarix:commit`, which verifies, adds a changeset if the
   change is releasable, stages by name, and writes a Conventional Commit
   summarising *why*. Where the commit completes a ticket it carries a `Closes #N`
   footer.
3. **Push**, never force.
4. **Open the request** — platform determined from the active plugin, falling back
   to the `origin` remote, and asking rather than guessing.

The request-opening skills complete the loop back to verification: on GitHub the
review is posted verbatim as a comment; on GitLab it is reconciled against the
current branch and posted as a batched draft-note review with inline comments.

## Where nothing governs

Only the review stage rests on a decision. The rest of this path — the intake
order, the read prohibition, the planning fork, the shipping sequence — is
established by skill and rule text alone, with no ADR admitting any of it and no
constraint-ledger entry covering it.

That is worth stating plainly rather than leaving implicit. Several of these are
real constraints on how the project works, and the read prohibition in particular
forecloses an approach a plausible evolution might want. They are recorded here as
current behaviour; whether any should be admitted as constraints is a materiality
question nobody has put.
