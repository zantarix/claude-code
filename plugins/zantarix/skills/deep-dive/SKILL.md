---
name: deep-dive
description: Interview the user one question at a time to reach a shared understanding of an ambiguous topic, decision, or finding — proposing recommended answers and looking up discoverable facts before asking. Proactively invoke whenever investigating an issue with the user where multiple viable interpretations or decisions exist.
---

Conduct a dialog with the user to reach a shared understanding of $ARGUMENTS.

Start by familiarising yourself with any relevant context already available — `CONTEXT.md` / `CONTEXT-MAP.md`, related code, prior ADRs, ticket or finding descriptions — if you haven't already loaded them.

During the dialog:

- Interview the user relentlessly about every aspect of $ARGUMENTS until you reach a shared understanding. If it branches into multiple decisions, walk down each branch one-by-one, resolving dependencies between them. If it's a single narrow question, ask that one question — don't manufacture branches that don't exist. For each question, provide your recommended answer.
- Ask questions one at a time, waiting for the user's answer before continuing. Asking multiple questions at once is bewildering.
- If a fact can be found by exploring the environment (filesystem, tools, etc.), look it up rather than asking the user. The decisions, though, are theirs — put each one to them and wait for their answer.
- Propose options where relevant and push back on choices that seem contradictory or likely to lead to a worse outcome.
- Summarise the agreed understanding back to the user before concluding, and confirm they are happy with it.
- Do not act on the decision until the user confirms the shared understanding — reaching it is this skill's job, not implementing it.

Once confirmed, report the shared understanding back to whatever invoked this skill (another skill's workflow, an implementation plan, or the user directly) so it can proceed with the next step.
