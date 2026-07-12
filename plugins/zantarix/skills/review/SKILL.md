---
name: review
description: |-
  Run all *-reviewer agents over the current changes — each reviewer proposes a partition suited to
  its own remit, then reviews its slices in parallel via a dynamic Workflow — then fix
  critical/major findings in a single pass. Stores all output under .reviews/. There is no re-run
  loop: the human review (local, or via the create-pull-request / create-merge-request skills) is
  the verifying gate; this skill's job is to surface and fix the obvious issues before that gate.

  Proactively use this skill to review code you've created if you have added or modified more
  than two functions, or whenever you complete an implementation plan.
---

Review the current changes with a deterministic two-phase workflow: each discovered reviewer
proposes how it would partition the diff **for its own remit**, then reviews its slices in parallel.
Findings are collated deterministically and the critical/major ones fixed in a single pass. There is
**no re-run loop** — breadth comes from per-reviewer partitioning, not from repeated runs.

## Step 1: Create review session

Create a timestamped session folder using `date +%Y-%m-%d-%H%M%S`:

```
.reviews/<YYYY-MM-DD-HHMMSS>/
```

The folder name — the timestamp `<YYYY-MM-DD-HHMMSS>` — is your `<session>`. The **`session`
argument you pass to the workflow is the full repo-relative path `.reviews/<session>/`, including the
trailing slash**: the workflow prefixes it directly onto audit-file paths and the report header, so
it must already contain `.reviews/` and end in `/`. Every `.reviews/<session>/…` path below uses
that same timestamp `<session>` — never substitute the full path into the `<session>` slot (that
would double the `.reviews/` prefix).

> **Note**: `.reviews/` is expected to be in `.gitignore`. If it is not present, add it before proceeding.

## Step 2: Determine scope

Establish the review scope from the arguments passed to the skill (e.g. specific files, a commit
range, or — by default — `git diff HEAD` plus recent commits on the current branch).

**Cheap pre-check.** If the scope is small — roughly **≤ 10 changed files or ≤ 500 changed lines** —
take the small-scope path in Step 4A (each reviewer reviews the whole scope once, no partitioning).
Otherwise take the two-phase path in Step 4B.

## Step 3: Discover reviewers

Find all available, pre-defined agents — using only **system context** — whose name ends with
`-reviewer`. Do not search the file system. The set is not fixed: it varies per repo with the
enabled plugins plus any project-local reviewers (e.g. a repo-local `security-reviewer`). Collect
their agent-type identifiers exactly as system context names them — this list is passed to the
workflow, which is generic over whatever reviewers you hand it.

## Step 4: Run the review workflow

The workflow script is bundled beside this skill. Invoke the **Workflow** tool with
`scriptPath: ${CLAUDE_SKILL_DIR}/review-workflow.js` — do not re-transcribe the script inline. Every
invocation passes the `scope` and the `session` path (`.reviews/<session>/`, with its trailing
slash); the `propose`/`full` modes additionally pass the discovered `reviewers` list, while the
`review` mode passes a `worklist` instead (see below).

### Step 4A — Small scope (single pass)

Invoke the workflow with `args: { mode: "full", reviewers, scope, session }`. Each reviewer reviews
the whole scope once (deep + cross-boundary). It returns `{ reviewMd, auditFiles, findings, failed }`.
Go to Step 5.

### Step 4B — Large scope (propose → gate → review)

1. **Propose.** Invoke with `args: { mode: "propose", reviewers, scope, session }`. It returns
   `{ proposals: [{ reviewer, alive, chunks }] }` — each reviewer's own partition of the diff.
2. **Fail loud on lost reviewers.** If any proposal has `alive: false`, that reviewer's propose
   agent died — its coverage is missing. Surface it to the user and re-run that reviewer's proposal
   or note the gap explicitly; never silently proceed as if it had nothing to report.
3. **Cost gate.** Compute the projected phase-2 count = the total chunks across all proposals (one
   review agent per chunk). If it exceeds **20**, use `AskUserQuestion` to confirm: *proceed
   as proposed* or *constrain*. On **constrain**, trim the work-list toward a lower cap — drop the
   lowest-value chunks first (prefer dropping `isCross` chunks, then the smallest per-reviewer
   chunks) and **state exactly what was dropped** (never truncate silently). At **≤ 20**, proceed
   without asking.
4. **Review.** Invoke with `args: { mode: "review", worklist, scope, session }`, where `worklist` is
   the (possibly trimmed) `proposals` array — the workflow uses each entry's `reviewer` and `chunks`
   and ignores extra fields. It returns `{ reviewMd, auditFiles, findings, failed }`.

## Step 5: Materialise outputs

From the workflow's return value:

- Write each `auditFiles[i].content` to `auditFiles[i].path` (repo-relative, under the session
  folder).
- Write `reviewMd` **verbatim** to `.reviews/<session>/review.md`. Do not reformat or re-classify it
  — it is generated deterministically and is consumed downstream by `create-pull-request` /
  `post-mr-review`.
- **Fail loud on failed reviews.** If `failed` is non-empty, each entry is a `(reviewer, chunk)`
  whose review agent died — those slices were **not** reviewed. Surface them to the user.

## Step 6: Triage and fix (single pass)

Use the returned `findings`. Triageable items are those with severity **critical** or **major**
(minor/suggestions are recorded for the user, never fixed here).

For each triageable finding:

- Apply the fix directly in code or documentation, then change its checkbox from `- [ ]` to `- [x]`
  in the corresponding line of `review.md`.
- If a fix is ambiguous, risky, or needs a human decision (e.g. an architectural call), **leave the
  checkbox `- [ ]`** and move that line to `review.md`'s `## Needs Human Input` section. Remove it
  from its original section.

There is **no loop**. Once you have triaged every finding once and applied or deferred each fix, go
to Step 7. Post-fix verification is delegated to the human review gate.

## Step 7: Report to user

Present a concise inline summary:

```
## Review Complete

**Session**: `.reviews/<session>/`
**Reviewers run**: <comma-separated agent names>

### Issues Fixed
<numbered list of fixes applied, with file paths>

### Needs Human Input
<numbered list of items moved to Needs Human Input with reason>

### Minor / Suggestions (not actioned)
<brief list or count per reviewer>

### Not reviewed / failed
<any reviewers that failed to propose (Step 4B.2) or slices in `failed` (Step 5), or "None">

**Full report**: `.reviews/<session>/review.md`
```

The **Needs Human Input** list must match `review.md`'s `## Needs Human Input` section exactly —
same items, same count. The session path in your summary lets the `create-pull-request` /
`create-merge-request` skills locate this review.

All findings are logged in the session folder for audit and transparency.
