---
name: memory-reconciliation
description: Review accumulated memories for the current project and triage each into discard, keep, promote-to-project-rule, or promote-to-org-rule.
disable-model-invocation: true
---

Memories accumulate quickly and are scoped to a single user. Over time some become stale, some are really project conventions that belong in committed rules, and some are universal practices that other projects in the org would also benefit from. This skill walks through every memory for the current project, classifies each by **what happens next**, and — after explicit user approval — carries out the actions.

## Step 1: Locate the memory directory

The memory directory for the current project is at:

```
~/.claude/projects/<slug>/memory/
```

`<slug>` is the current working directory with `/` replaced by `-` (the leading `/` becomes a leading `-`). For example, `/home/user/Code/zantarix/claude-code` → `-home-user-Code-zantarix-claude-code`.

If `MEMORY.md` does not exist there, stop and report "No memories recorded for this project."

## Step 2: Read all memories

Read `MEMORY.md` and every memory file it references. Note any files in the directory that are not linked from the index — surface those as orphans in the final report rather than triaging them.

## Step 3: Categorise each memory by outcome

For each memory, choose **one** of the four outcomes below. Outcomes describe *what happens next*; the bullets under each describe the different situations that lead to the same action.

### Outcome A — Discard

Remove the memory. Situations that lead here:

- **Once-off feedback** that does not generalise — the correction was tied to a specific task that is now done.
- **Already covered by an existing rule** in `.claude/rules/`, `rules/`, or `CLAUDE.md` — the memory is redundant.
- **Contradicted by the current code or workflow** — verify against the repo before assuming this; if the code disagrees with the memory, the memory is the one that is wrong.
- **Decayed beyond use** — the "why" is no longer recoverable and the rule no longer makes obvious sense on its own. Flag these explicitly for user confirmation rather than discarding silently.

### Outcome B — Keep as user memory

Leave the memory in place. Situations that lead here:

- The memory is genuinely about *this user* — their role, communication preferences, tooling habits, how they want to be addressed.
- Another developer on the same project would not benefit from it.

### Outcome C — Promote to a project rule

Write the memory's content as a rule committed to the repo, then discard the memory. Situations that lead here:

- The memory describes a convention, workflow, or constraint that applies to *this project* specifically.
- Anyone working on the project would benefit from it, not just the current user.

### Outcome D — Promote to an org rule

File an issue against `zantarix/claude-code` proposing a new rule under the appropriate plugin (`base`, `github`, `gitlab`, `rescript`, or `rust`), then discard the memory. Situations that lead here:

- The memory describes a practice that applies to *every* Zantarix project, not just this one.

Distinguishing C from D is the hardest call. If unclear, ask the user directly: "Does this apply only to *<current project>* or to every project you work on?" Do not guess.

## Step 4: Present the triage table for approval

Render a table to the user, one row per memory:

| Memory              | Type     | Outcome          | Reason / notes |
|---------------------|----------|------------------|----------------|
| `feedback-testing`  | feedback | C — project rule | propose `.claude/rules/testing.md` |
| `user-role`         | user     | B — keep         | — |
| `feedback-old-flag` | feedback | A — discard      | references removed `--legacy` flag |
| `feedback-pin-shas` | feedback | D — org rule     | propose under `plugins/github/`; user confirmed scope |

Below the table, list:

- Orphan files found in Step 2.
- Any rows where the user broke a C-vs-D tie, so the decision is auditable.

**Stop here and wait for explicit approval.** The user may reclassify, override, or skip individual rows. Do not proceed to Step 5 without approval.

## Step 5: Execute approved actions

Process each row in order:

1. **Outcome A (Discard)** — delete the memory file and remove its line from `MEMORY.md`.
2. **Outcome B (Keep)** — no action.
3. **Outcome C (Project rule)**:
   - Before writing, grep `.claude/rules/`, `rules/`, and `CLAUDE.md` for the topic to confirm no existing rule covers it. If one does, reclassify as Outcome A and tell the user.
   - Write `.claude/rules/<name>.md`. Use the memory's **Why** and **How to apply** structure as the body. Add `paths:` frontmatter if the rule is scoped to specific files; leave unscoped only if it applies repo-wide.
   - Delete the source memory and update `MEMORY.md`.
4. **Outcome D (Org rule)**:
   - Draft an issue body that:
     - Quotes the memory verbatim.
     - Proposes which plugin's `rules/` directory it belongs under.
     - Suggests a filename and a short description.
     - Ends with your required sign off.
   - Show the drafted body and the proposed `gh issue create --repo zantarix/claude-code --label new-memory ...` command, then wait for the user to approve before running it. The `new-memory` label is mandatory so these proposals can be triaged together. If the user prefers to post manually, hand them the body and remind them to apply the `new-memory` label.
   - After the issue is created, delete the source memory, update `MEMORY.md`, and record the issue URL in the final report.

## Step 6: Finalise documentation

Skip this step if no Outcome C rows ran (no new project rules were written).

Otherwise:

1. Invoke the `/init` skill to refresh `CLAUDE.md` against the new rule set. This catches any high-level project description that should now defer to a freshly written rule.
2. After `/init` completes, run a single pass of the `@base:documentation-reviewer` agent over the changes. Pass it the list of rule files written in Step 5 plus any `CLAUDE.md` edits from `/init`, and ask it to flag any other documentation (docs site, ADRs, `CONTRIBUTING.md`) that should be updated to match. Do not loop — one pass is enough; surface its findings in the final report for the user to action.

## Step 7: Report

Summarise:

- Total memories reviewed.
- Counts per outcome (A/B/C/D).
- Files written, files deleted, and links to any issues filed.
- `/init` and documentation-reviewer findings, if Step 6 ran.
- Any rows the user deferred for a future run.
