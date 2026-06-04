---
name: implement-ticket
description: Work a ticket reference to completion — fetch the issue, clarify intent with the user, then plan or implement via plan mode or /plan-adr.
---

Work the ticket reference in $ARGUMENTS (e.g. `#14`, `org/repo#14`, or a full issue URL). If no reference is provided, ask the user for one before proceeding.

**No local codebase reads are permitted before Step 4.** Steps 1–3 are exclusively remote context (ticket data, git remotes, platform CLI/MCP calls). Do not read source files, schemas, configs, or local ADR files at any point before calling `EnterPlanMode`.

## Step 1: Disambiguate the platform

GitHub and GitLab share the `#N` notation. Infer the platform from project context (which platform plugin's rules and MCP are present, CI config, etc.). If inconclusive, check the `origin` remote. On GitLab, honour the reference sigil per the `ref-notation` rule (`#` issue, `!` MR, `&` epic).

## Step 2: Fetch and read the ticket

Fetch the **referenced issue** with its **comments** and any **linked/related items**. Read everything before forming a plan — the ticket content shapes all subsequent decisions.

On GitLab:

- Also fetch the title and description of any related/linked/child/parent issues for additional context.
- Set the work item's status to `In progress` per the `status` rule. If you updated the status, then also assign the ticket to `@self` for the user.

## Step 3: Clarify with the user

Before planning, surface anything that needs the user's input based on the ticket content alone:

- Ask about scope or priority if the ticket is ambiguous.
- Flag conflicts between the ticket and decisions that are visible from the ticket description (referenced ADRs, stated constraints).

Keep questions focused; don't ask about things you can resolve by reading the ticket or project context.

## Step 4: Enter plan mode

Call `EnterPlanMode` directly — do **not** invoke any skill at this step. `/plan-adr` must not be used as the entry point into planning.

Inside plan mode:

1. Explore the codebase to understand scope and existing patterns.
2. Based on what you find, assess whether the work warrants `/plan-adr`: does it introduce a new architectural surface, require choosing between alternatives with meaningfully different trade-offs, or commit to a cross-cutting pattern? Apply the criteria from the `adr` rule.
   - **If yes**: invoke the `/plan-adr` skill with the ticket context and exploration findings as the starting point.
   - **If no**: complete the implementation plan here and present it to the user for approval. The plan must include a note identifying the ticket being implemented (e.g. "This plan implements #N") so that when a PR/MR is created later, the issue number is available in context.

The `/plan-adr` invocation, if warranted, comes *after* exploration — never before.

## Step 5: Follow through

Work the agreed path through to the user's stated goal. The goal may be planning only rather than full implementation — deliver what was actually asked for and stop there.
