# CLAUDE.md and Claude Code rules

## Project rules versus organisation rules

Project rules are considered to be any rules in `.claude/rules/` which are not included via a symlink. This restriction is important as rules may be included via a symlink as a workaround for Claude Code plugins not including a way to distribute rules. Rules included via a symlink should be categorised as organisation level rules and should be considered immutable.

Project rules are allowed to override or extend organisation rules, however any contradictions should be highlighted to the user.

## Initialisation

When initialising or updating `CLAUDE.md`, consider the full scope of project rules as well. `CLAUDE.md` should always be stored in the `.claude` folder. `CLAUDE.md` must only contain high level details of the project, it's structure, and things that affect the project as a whole. Details about specific sections of the project should be covered by rules which can be scoped to specific sets of files in the project.

## Duplication

Do not duplicate content between `.claude/rules/` files and `.claude/CLAUDE.md`.

**Why:** The Claude Code harness automatically combines rule files with CLAUDE.md into a single context. Adding a rule's content to CLAUDE.md creates duplicated, potentially-diverging documentation.

**How to apply:** When a reviewer or task suggests adding a convention to CLAUDE.md that is already (or will be) documented in a rules file, skip the CLAUDE.md addition and only update the rules file.
