---
name: init
description: |-
  Audit the repository and write or update `CLAUDE.md` so future runs start with project context.

  This skill describes a workflow and you should only run it when the user asks you to initialise the repository
  or generate an `CLAUDE.md`. It is only a list of instructions.
---

# Initialisation

## Task

1. Read the current `.claude/CLAUDE.md`, if it exists, in order to preserve any custom sections
2. Check for any README.md files in the repository and read them as an initial point of context
3. Read a sampling of any documentation you find which appears most relevant to the high level architecture
4. Scan any obvious source code folders and probe into them briefly
5. Write an updated `.claude/CLAUDE.md` to the root of the working folder. After writing, read back your work and review it to make sure that formatting and other important details are correct.
6. Give a brief summary to the user about what has changed

When writing `CLAUDE.md`, consider the full scope of project rules as well. `CLAUDE.md` must only contain high level details of the project, it's structure, and things that affect the project as a whole. Details about specific sections of the project should be covered by rules or skills which can be scoped to specific sets of files in the project. Do not include file listings at all.

## Purpose

The `.claude/CLAUDE.md` file is loaded into your system context as a project reference. This allows you to understand the shape of a project faster and with less exploration. You should not echo anything in your system prompt - this will always be available.

**Describe current state only**: `CLAUDE.md` is for current development, it is not a historical document.

## Brevity

You must keep `.claude/CLAUDE.md` under 40KB.

Long lists of individual items are not relevant. Keep file listings to 1 significant level of depth, eg. `src/foo`. Exploration can provide further detail when needed. `.claude/CLAUDE.md` should be used to provide enough context to know where to look to find things, not to fully explain everything in the project.

Where possible you should reference documentation in other places. This file is a quickstart, not a comprehensive reference.

## Suggested headings

You should maintain any custom sections in an existing `.claude/CLAUDE.md`. The following is a suggested list for new files:

* **Project description** - a short synopsis describing the purpose of the project and who the intended user base might be. Include an explicit reference to `CONTEXT.md` or `CONTEXT-MAP.md` if it exists.
* **Platform** - short dot point list of important technologies in use by the project
* **Project structure** - a high level breakdown of the codebase
* **Project architecture** - 2-3 paragraphs about important architectural patterns in the project
* **Conventions** - Any important conventions the project follows

Stay focused on information which will help future you, within the set of tools and abilities you have access to.

## User context

If the user has provided any specific instructions for this run, they will appear below and override the above; if nothing appears, perform a whole-repo audit.

## Duplication

Do not duplicate content between `.claude/rules/` files and `.claude/CLAUDE.md` — the harness combines them into a single context, so duplication creates diverging documentation. When a reviewer or task suggests adding to CLAUDE.md a convention already (or soon to be) in a rules file, update only the rules file.
