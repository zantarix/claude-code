---
name: triage-new-memory
description: Triage the open `new-memory` GitHub issue queue — for each proposal, classify it (accept / accept-with-edits / merge-into-existing / reject / defer) and, after approval, apply the resolution.
disable-model-invocation: true
---

The `/zantarix:memory-reconciliation` skill files issues against this repo with the `new-memory` label whenever a user-level memory looks like it should become a distributed org rule. This skill is the receiving end: it walks the open queue, classifies each issue against the current rules tree, and — after explicit user approval — writes the rule files (or closes the issues) and updates the README plugin tables.

## Step 1: Fetch the queue

Run:

```sh
gh issue list --label new-memory --state open --limit 50 --json number,title,body,url,author,createdAt
```

If the result is empty, stop and report "No open `new-memory` issues."

## Step 2: Parse each issue

Memory-reconciliation issues follow a predictable template. Extract per issue:

- **Plugin target** — from the `**Plugin:** \`<name>\`` line.
- **Suggested filename / location** — from the `**Suggested filename:**` or `**File:**` line. Note when it says "addendum to `<existing-file>`" — that signals a merge, not a new file.
- **Rule body** — everything between the metadata header and the `:robot:` footer (or end of body). Discard the `## Proposed rule` heading and the metadata line.
- **Why** — the `**Why:**` paragraph, if separate.

If an issue does not follow this template (e.g. a human-filed proposal), extract whatever you can and flag it in the triage table for the user to review more carefully.

## Step 3: Validate against the current repo

For each issue, gather signals before classifying:

1. **Plugin exists?** Confirm `plugins/<target>/` is present. If not, the proposal implies a new plugin — flag for user discussion (likely Defer).
2. **Filename collision?** Check whether `rules/<plugin>/<suggested-name>.md` already exists.
3. **Topic overlap?** Grep `rules/<plugin>/` for keywords from the rule body. Read any file that looks related — the proposal may already be covered or may belong as an extension to an existing rule.
4. **Length budget.** Rules must not exceed 50 lines (`rules/zantarix/init.md`). If the proposed body would push an existing file past 50 lines, the merge becomes a split decision.
5. **Contradictions.** Skim other rules in the same plugin for direct conflicts with the proposal.

## Step 4: Classify each issue

Choose **one** outcome per issue. Outcomes describe *what happens next*.

Issue bodies contain the **raw memory** as the user wrote it — memories have no `paths:` mechanism, so the source never carries scope frontmatter. Almost every accept needs at least a `paths:` decision before it becomes a usable rule, so **Outcome B is the default**; Outcome A is reserved for genuinely repo-wide rules that need no other edits.

For every accept, decide the scope:

- **Repo-wide** (no `paths:` frontmatter) — only for cross-cutting concerns like style, security, attribution, agent role.
- **Scoped** (`paths:` glob) — anything tied to a language, framework, file type, directory, or tooling surface. Most language- and tool-specific rules fall here. Read sibling rules in the same plugin to match the existing glob style.

### A — Accept as new rule (verbatim)

Create `rules/<plugin>/<name>.md` from the issue body verbatim. Pick when:

- The proposal is a clean fit for a new file, no existing rule covers the topic, the body is well-formed, **and** the rule is genuinely repo-wide so no `paths:` is needed.

### B — Accept with edits

Create `rules/<plugin>/<name>.md` with adjustments. Pick when (any of):

- A `paths:` frontmatter needs to be added (the common case).
- The suggested filename needs renaming for clarity or convention.
- The body needs a `# Title` header, light rewording, or trimming to fit the 50-line cap.
- The proposal mixes two concerns and one belongs elsewhere.

Show the diff between the issue body and what would be written before the user approves.

### C — Merge into existing rule

Append to or modify an existing `rules/<plugin>/<existing>.md` rather than creating a new file. Pick when:

- The issue itself says "addendum to …".
- An existing rule covers the same topic and the proposal genuinely extends it (without breaking the 50-line cap).

### D — Reject

Close the issue without action. Pick when:

- An existing rule already says the same thing.
- The proposal is project-specific to the source repo and would not apply across Zantarix projects.
- The repo's current state contradicts the proposal (verify before assuming this).
- The proposal is too vague to act on and no clarification is available.

Always include a one- to two-sentence reason that will be posted as a closing comment.

### E — Defer

Leave the issue open. Pick when:

- The proposal needs a discussion the user has not yet had, depends on a not-yet-existing plugin, or conflicts with another open `new-memory` issue that should be resolved first.
- Optionally draft a comment asking for the missing input.

## Step 5: Present the triage table for approval

Render one row per issue:

| # | Title | Plugin | Outcome | Target file | Notes |
|---|-------|--------|---------|-------------|-------|
| 9 | trait-signature bug fixes don't warrant ADR | zantarix | C — merge | `rules/zantarix/adr.md` | append as new paragraph; +6 lines (within 50) |
| 6 | no mutation-test exclusions | rust | B — edit | `rules/rust/mutants.md` | add `paths: .cargo/mutants.toml, **/*.rs`; otherwise verbatim |
| 5 | named type aliases for domain collections | rescript | B — edit | `rules/rescript/type-aliases.md` | rename from suggested `domain-types.md`; add `paths: src/**/*.res` |
| 7 | never claim "known issue" without evidence | zantarix | A — accept | `rules/zantarix/investigation.md` | new file, genuinely repo-wide so no `paths:` |
| 4 | binding modules may expose domain helpers | rescript | C — merge | `rules/rescript/ffi-bindings.md` | extends existing rule, +9 lines |
| 3 | @react.component optional-prop asymmetry | rescript | B — edit | `rules/rescript/react-optional-props.md` | add `paths: src/**/*.{res,resi}`; add `# Title` header |
| 8 | read clippy help: hint before manually fixing | rust | D — reject | — | already covered by `rules/rust/clippy.md` |

Below the table, surface:

- The full body of any **Outcome B** row, with a clearly marked diff between the issue body and what would be written.
- The exact insertion point and surrounding context for any **Outcome C** row.
- The closing comment that would be posted for any **Outcome D** row.
- Any issues that did not match the template (template parse failure) — call these out so the user can confirm interpretation.

**Stop here and wait for explicit user approval.** Users may reclassify rows, edit proposed bodies, or skip individual rows. Do not proceed to Step 6 without approval.

## Step 6: Execute approved actions

Process rows in order. Outcomes A, B, and C each produce **one commit per issue** with `Closes #<n>` in the trailer — GitHub auto-closes the issue when the commit lands on the default branch, so do not run `gh issue close` for these. Outcome D has no commit, so it closes via the CLI. Outcome E stays open.

Before starting, confirm the working tree is clean so per-row commits stay isolated.

### Per-commit conventions

- Subject line: `feat(<plugin>): <imperative description>` (matches recent history; see `git log --oneline -10`).
- Body: short rationale if non-obvious.
- Trailer block. Fill in `{{MODEL_NAME}}` with your own display name and version (e.g. `Claude Sonnet 5`, `Claude Opus 4.8`), taken from your system prompt's model identification — never the bare word `Claude`:
  ```
  Closes #<n>

  Assisted-By: {{MODEL_NAME}}
  ```
- Stage only the files for this row (the rule file plus the relevant README row). Never `git add -A`.
- Use a HEREDOC for the message to preserve formatting (mirroring `/zantarix:commit`).
- Do not skip hooks, do not force-push, do not amend.

### Per-outcome actions

1. **Outcome A — Accept (verbatim, repo-wide):**
   - Write `rules/<plugin>/<name>.md` with the rule body. Add a `# Title` heading if absent. No `paths:` frontmatter.
   - Insert a row into the plugin's table in `README.md`, alphabetical within the Rule section.
   - Stage both files and commit with `Closes #<n>`.

2. **Outcome B — Accept with edits:**
   - Write the file with the edits the user approved in Step 5 (paths frontmatter, rename, header, trimming, etc.) — not the raw issue body.
   - Update the README row to reflect the final filename and a one-line description.
   - Before committing, post a comment on the issue listing the edits made and why (e.g. "Added `paths: src/**/*.res` to scope the rule to ReScript sources; renamed from `domain-types.md` to `type-aliases.md` for clarity."). Sign off with the `:robot:` line. This preserves the audit trail of what changed between the raw memory and the committed rule, since the commit itself just shows the final form.
   - Commit with `Closes #<n>`; the body can stay brief since the comment carries the rationale.

3. **Outcome C — Merge into existing rule:**
   - Edit the target file in-place. Preserve existing structure; new content usually goes at the end or under the most relevant subheading.
   - Re-check the file is ≤50 lines after the edit. If it would exceed, stop and ask the user to reclassify as B with a new file.
   - README typically needs no change, but verify the existing row still describes the rule accurately and update it if not.
   - Commit with `Closes #<n>`; the subject should signal extension, e.g. `feat(<plugin>): extend <existing> rule with <addition>`.

4. **Outcome D — Reject:**
   - No commit. Close via the CLI:
     ```sh
     gh issue close <#> --reason "not planned" --comment "<one- to two-sentence reason from the table>

     ---
     :robot: Submitted by Claude Code on behalf of this user."
     ```

5. **Outcome E — Defer:**
   - Leave open. If a clarifying comment was drafted in Step 5, post it now with the same `:robot:` sign-off. No commit.

After each commit, run `git status` to confirm the tree is clean before moving to the next row.

## Step 7: Refresh documentation

Skip this step if no A, B, or C row ran (no rule files changed).

Otherwise:

1. Invoke the `/init` skill to refresh `CLAUDE.md` against the new rule set.
2. Run the `/review` skill over all changed files. This runs all reviewer agents concurrently, auto-fixes critical/major findings, and loops until clean — follow its full workflow rather than surfacing findings for manual action.
3. If `/init` made any edits, commit them as a single trailing `chore: refresh CLAUDE.md after rule additions` commit. Do not bundle these changes into a per-issue commit — they reflect the whole batch, not any one issue.

## Step 8: Report

Summarise:

- Total issues triaged, counts per outcome (A/B/C/D/E).
- Per-row commit hashes and subjects (A/B/C), with the linked issue number.
- Issues closed via the CLI (D) and issues left open (E), with links.
- `/init` and `/review` findings, if Step 7 ran.
- Any rows the user deferred for a future run.

The issues closed via `Closes #<n>` trailers remain *open* on GitHub until the commit reaches the default branch — flag this in the report so the user knows the final close happens at merge time.
