---
name: implement-ticket
description: Work a ticket reference to completion — fetch the issue, clarify intent with the user, then plan or implement via plan mode or /plan-adr.
---

Work the ticket reference in $ARGUMENTS (e.g. `#14`, `org/repo#14`, or a full issue URL). If no reference is provided, ask the user for one before proceeding.

## Step 1: Disambiguate the platform

GitHub and GitLab share the `#N` notation. Infer the platform from project context (which platform plugin's rules and MCP are present, CI config, etc.). If inconclusive, check the `origin` remote. On GitLab, honour the reference sigil per the `ref-notation` rule (`#` issue, `!` MR, `&` epic).

## Step 2: Fetch and read the ticket

Fetch the referenced issue with its comments and any linked/related items. Read everything before forming a plan — the ticket content shapes all subsequent decisions.

On GitLab:
- Also fetch the title and description of any related/linked issues for additional context.
- Set the work item's status to `In progress` per the `status` rule.

Do not explore the local codebase until after this step. Remote ticket context (including `git remote -v` and platform CLI/MCP calls) is permitted here.

## Step 3: Clarify with the user

Before planning, surface anything that needs the user's input:

- Ask about scope or priority if the ticket is ambiguous.
- Flag conflicts between the ticket and existing decisions (ADRs, architecture, constraints visible from the ticket description).
- If the ticket references a significant or architectural decision — a long-term commitment to project direction — confirm with the user whether to run `/plan-adr` instead of regular plan mode.

Keep questions focused; don't ask about things you can resolve by reading the ticket or project context.

## Step 4: Choose a planning path

- **Architectural decision**: run the `/plan-adr` skill. Pass the ticket context as the starting point for the scoping dialog.
- **Implementation work**: enter planning mode. Explore the codebase now to scope the work. Ask clarifying questions within plan mode as needed.

## Step 5: Follow through

Work the agreed path through to the user's stated goal. The goal may be planning only rather than full implementation — deliver what was actually asked for and stop there.
