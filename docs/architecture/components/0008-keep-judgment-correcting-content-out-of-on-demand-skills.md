---
type: Architecture Decision
title: Keep Judgment-Correcting Content Out of On-Demand Skills
description: Admits the standing rule that content existing to correct an agent's in-the-moment judgment is loaded by something other than that judgment, foreclosing its move behind a skill the agent must decide to invoke as a way of managing prompt size.
tags: [components, agents, skills, prompts, context-cost]
generated: { by: architecture-curator/claude-opus-5, at: 2026-08-13T15:55:00Z }
verified: { by: human:mscharley, at: 2026-08-12T21:58:09Z }
status: Accepted
---

# ADR-0008: Keep Judgment-Correcting Content Out of On-Demand Skills

## Status

Accepted (2026-08-13)

## Context

The [components overview](overview.md) sets out how this project chooses between component kinds, and why preloading is not a saving: a preloaded skill costs exactly what prompt text costs, so only skills that fire *sometimes* save anything by being left on demand.

The curator is the clearest candidate for that saving, since most of its prompt is authoring apparatus that does not fire on the work it is asked for most often ([components overview](overview.md)). Measured against the preloading test, the split was available, worthwhile on the arithmetic, and declined.

No decision records why. The overview states the limit as current shape, which is what an overview is for; it admits nothing, and the [constraint ledger](../constraints.md) is silent on how prompt material is apportioned.

The temptation is live rather than theoretical. Every agent pays its prompt on every invocation, the arithmetic that made the curator a candidate will recur for the next agent that outgrows its own, and decomposition into an on-demand skill is the remedy this project reaches for elsewhere by design.

## References

- [architecture-curator agent](../../../plugins/zantarix/agents/architecture-curator.md)

## Decision

Content whose purpose is to correct an agent's in-the-moment judgment is loaded by something other than that judgment. Its homes are the agent's prompt, a preloaded skill, and a rule the harness puts in scope; what it may never sit behind is a skill the agent has to decide it needs.

### What counts

The test is what the content is for, not how long it is. A fixed authoring order, a checklist against a predictable failure, a bar the agent sets too low unaided: each exists because instinct is wrong at that moment, so the decision to load it would be taken by the faculty it compensates for.

### What may still move

Material stays eligible for an on-demand skill where the thing that fires it is checkable against the world rather than asserted — a file path, a named artefact, a rule already in context whose scope matches the work. A trigger the agent has to recognise it is standing in, or that reaches it as a claim from whoever called it, is not checkable, and material behind one is judgment-correcting content under another name.

### What it costs

Prompt size is not grounds for a split.

## Consequences

### Positive

- The prompt-size question has a stable answer instead of being re-argued for each agent that outgrows its prompt; growth in a corrective apparatus is accepted rather than treated as debt.
- The rule becomes visible to the materiality gate, so a later split has to argue against a stated position rather than arrive as an optimisation.
- The safe criterion is named beside the foreclosure, so decomposition stays available where it is sound instead of stalling on caution.

### Negative

- Agents whose remit is largely corrective carry a floor on prompt size and pay it on work that never reaches the corrected task. Splitting the remit across two agents remains available and is the only route left to lowering the floor.
- Whether a piece of content is corrective or merely procedural is a reading made by whoever is editing, with nothing mechanical to check it, so a plausible misreading moves material that should have stayed.
- Deferrals that would have been harmless in practice are ruled out with the rest, because the rule is stated on purpose rather than on measured failure.

### Neutral

- This admits a rule already in force; nothing is built by accepting it, and rejecting it would mean splitting prompts that are currently whole rather than leaving things as they are.
- The scope is where existing content lives, not whether it should exist. An agent carrying corrective material it does not need is a separate problem, neither created nor solved here.

## Alternatives Considered

### Leave it as an overview note

Keep the paragraph in the [components overview](overview.md) and admit nothing, on the grounds that nobody is arguing with it and the prompt is whole. Rejected because the pressure recurs by construction: context cost is the axis every component choice here turns on, so the question returns whenever anyone measures a prompt. An unadmitted rule is also invisible to the materiality gate, which is the one mechanism that would make a later split argue against a stated position rather than present itself as an optimisation.

### Delegate the trigger to a scoped rule

Move the apparatus into an on-demand skill and add a short always-loaded rule naming the trigger — the pattern this project already uses to buy reliability without paying for a skill's bulk. Rejected because that pattern's reliability comes from a trigger matchable without judgment: a file glob, a user phrase, a named artefact. The trigger here is a classification of the work the agent was handed, and the apparatus is part of what corrects that classification, so the rule would have to carry the discrimination the skill was extracted to hold.

### Have the caller declare the mode

Let the delegating agent state whether it wants decision authoring or a living-document edit, so the load is decided outside the agent that would otherwise have to classify its own work. Rejected because the caller is not better placed: the materiality gate exists because work handed over as a documentation update routinely turns out to constrain the project, and a caller that already knew would not need the gate. It also makes a correctness-critical load depend on an unversioned message between prompts rather than on either prompt's text.
