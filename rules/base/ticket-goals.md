# Ticket-driven goals

When the user initiates a goal that references a ticket — issue notation like `#14`, `org/repo#14`, or a full issue URL — follow this workflow before doing any planning or implementation. When following this workflow, explicitly state that you are and follow all instructions as written.

## 1. Disambiguate the platform

GitHub and GitLab share the `#N` issue notation. Infer the platform from project context (which platform plugin's rules and MCP are present, CI config, etc.). If that is inconclusive, check the `origin` remote to disambiguate. On GitLab, honour the reference sigil per the `ref-notation` rule (`#` issue, `!` MR, `&` epic).

## 2. Pull and review the ticket

Fetch the referenced issue along with its comments and any attachments, then read them in full before forming a plan. Use the platform's preferred tooling (see the GitHub and GitLab plugin rules; on GitLab prefer the GitLab MCP).

On GitLab only, also fetch the title and description of any related/linked issues for additional context, and set the work item's status to `In progress` per the `status` rule before moving on to planning. GitHub has no equivalent for either, so skip both there.

**Do not explore the local codebase** — no Bash, Read, or file-search calls against the working tree — until you are inside planning mode. Gathering remote ticket context (steps 1–2, including `git remote -v` and the platform CLI/MCP) is permitted.

## 3. Choose a planning path by size

- If the goal requires a significant or architectural decision — a long-term commitment to project direction worth recording — run the `/plan-adr` skill.
- Otherwise, enter planning mode to scope the implementation.

## 4. Follow through

Work the chosen path through to the user's stated goal. That goal may be planning only rather than full implementation — deliver what was actually asked for and stop there.
