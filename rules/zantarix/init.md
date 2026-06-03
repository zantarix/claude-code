# CLAUDE.md and Claude Code rules

## Initialisation

When initialising or updating `CLAUDE.md`, consider the full scope of project rules as well. `CLAUDE.md` should always be stored in the `.claude` folder. `CLAUDE.md` must only contain high level details of the project, it's structure, and things that affect the project as a whole. Details about specific sections of the project should be covered by rules which can be scoped to specific sets of files in the project. File listings must not be more than one significant level deep, eg. `src/foo/` is the limit.

## Project rules versus organisation rules

Project rules are considered to be any rules in `.claude/rules/` which are not included via a symlink. This restriction is important as rules may be included via a symlink as a workaround for Claude Code plugins not including a way to distribute rules. Rules included via a symlink should be categorised as organisation level rules and should be considered immutable.

Project rules are allowed to override or extend organisation rules, however any contradictions should be highlighted to the user.

## Brevity

Long lists of individual items are not relevant. Exploration can provide detail when needed. `CLAUDE.md` should be used to provide enough context to know where to look to find things, not to fully explain everything in the project.

## Rule length

Rules are sets of short, imperative instructions. Express everything as a clear directive: fold any rationale that shapes how or when the rule applies into the instruction itself, and drop pure motivation. Rule files must not exceed 50 lines. If a rule grows beyond this, split it into multiple focused rules, each covering a distinct concern.

## Rule scope

Rules must be scoped to specific files or directories where possible using the `paths` frontmatter field (accepts glob patterns). Only rules that genuinely apply everywhere — style guides, logging conventions, security requirements — should be left unscoped (repo-wide).

## Duplication

Do not duplicate content between `.claude/rules/` files and `.claude/CLAUDE.md` — the harness combines them into a single context, so duplication creates diverging documentation. When a reviewer or task suggests adding to CLAUDE.md a convention already (or soon to be) in a rules file, update only the rules file.

## Current state

`CLAUDE.md` should only describe current state. ADRs are available for historical context, and should be referenced where appropriate. Your initial context only needs current state however.
