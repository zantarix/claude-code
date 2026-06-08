---
name: review
description: |-
  Run all *-reviewer agents over the current changes — partitioning a large diff into
  cohesive chunks reviewed in parallel — then fix critical/major findings in a single pass.
  Stores all output under .reviews/. There is no re-run loop: the human review (local, or via
  the create-pull-request / create-merge-request skills) is the verifying gate; this skill's
  job is to surface and fix the obvious issues before that gate.

  Proactively use this skill to review code you've created if you have added or modified more
  than two functions, or whenever you complete an implementation plan.
---

Review the current changes by partitioning them into cohesive chunks, running all available reviewer agents over those chunks in parallel, then fixing critical/major findings in a single pass. There is **no re-run loop** — breadth comes from partitioning, not from repeated runs.

## Step 1: Create review session

Create a timestamped session folder using `date +%Y-%m-%d-%H%M%S`:

```
.reviews/<YYYY-MM-DD-HHMMSS>/
```

> **Note**: `.reviews/` is expected to be in `.gitignore`. If it is not present, add it before proceeding.

## Step 2: Determine scope and partition

Establish the review scope from the arguments passed to the skill (e.g. specific files, a commit range, or — by default — `git diff HEAD` plus recent commits on the current branch).

**Cheap pre-check first.** If the scope is small — roughly **≤ 10 changed files or ≤ 500 changed lines** — skip partitioning entirely. Treat the whole scope as a single chunk with id `full`, and go to Step 3.

Otherwise, spawn a **partitioner subagent** (`model: opus`; `sonnet` with high effort is acceptable) to divide the scope into cohesive chunks. Pass it this directive:

> Read the changed code in the given scope (`git diff …`) and group the changed files into cohesive blocks based on the **code's own structure** — module membership, import/call relationships, files that change together.
>
> **Keep each feature's code, its tests, and the artifacts they depend on in the same chunk.** A source file and its test file (and the queries, fixtures, or schemas they exercise) are one unit — never separate them. In particular, **never split a subsystem horizontally** into an implementation chunk and a separate tests chunk: that denies every reviewer the ability to judge whether the tests actually cover the code.
>
> **Default to grouping at the module / subsystem / directory level**, not per individual struct, type, or file. Sibling files under one directory that changed together usually belong in one chunk, and a lone `mod.rs`, a test harness, or an isolated one-file change should fold into its nearest cohesive neighbour rather than stand alone.
>
> **When a single subsystem's change is too large to review in one pass, split it *vertically* into sub-feature slices** — each slice carrying its own code, tests, and artifacts (e.g. split a large GraphQL layer into `comment`/`commit`/`ref-ops` and `pull-request`/`check-run`/`team`, **not** into `impl` and `tests`). Splitting deeper is correct when the volume demands it; just split along feature lines, never along the code-versus-tests line — and this holds even when asked to reduce the chunk count: merge or slice by feature, never by layer.
>
> Do not impose an artificial limit on the number of chunks, and do not over-fragment — aim for chunks each reviewable in one focused pass. You may return a single block if the scope is already cohesive.
>
> **No chunk should be smaller than 5 files.**
>
> **Never leave a single-file or trivially small chunk standing alone** — consolidate bare files, lone test harnesses, or isolated one-file changes into a miscellaneous bucket.
>
> You are **reviewer-remit-agnostic**: do NOT consider which reviewers exist or what file types any reviewer cares about. Group by code cohesion only. Deciding that "no reviewer needs this file" is not your job and will cause silent under-coverage.
>
> Return a list of chunks. Each chunk has a short kebab-case `id` (e.g. `auth-core`, `cli-flags`) and the list of files/hunks it contains.

Record the returned chunks. A single returned chunk is equivalent to the `full` case.

**If the partitioner returns more than 5 chunks, pause and confirm with the user before executing.** Large diffs are exactly where fine-grained automated review is most valuable, so do not silently cap — but a wide fan-out is worth a check. Tell the user the chunk count and the resulting agent estimate — reviewers × (chunks + 1) — and ask whether to proceed as-is or constrain to a lower chunk count. If they give a lower number, re-run the partitioner with that number as a hard maximum and use its result. Five or fewer chunks: proceed without asking.

## Step 3: Discover reviewers

Find all available, pre-defined agents — using only system context — whose name ends with `-reviewer`. Do not search the file system. Each match is a reviewer type to launch.

## Step 4: Launch reviewers as background agents

Launch every reviewer with the Agent tool, **as background agents**, so the slow per-result file writes by each reviewer overlap with other reviews still running. Each spawn is parameterised by a **mode** and a **scope**:

- **Single chunk (`full`)** — for each reviewer type, launch one agent with `mode: full`, scope = the entire review scope. A `full`-mode reviewer does both deep review and cross-boundary analysis itself.
- **Multiple chunks** — for **each chunk**, launch one agent of **each reviewer type** with `mode: partition`, scope = that chunk. Then additionally launch **one agent of each reviewer type** with `mode: cross`, scope = the cross-boundary surface (for declarative reviewers this is the small surface only — e.g. skill `description:` frontmatter, rule bodies, hook definitions — not the full content of every chunk).

Reviewers self-filter: a `partition`/`full` agent handed a chunk with nothing in its remit returns `No Issues` and stops cheaply — it does not manufacture findings. A `partition`-mode agent must report **only on its assigned chunk** and must not assert anything (clean or otherwise) about code it was not given.

**Spawn every reviewer up front, then end your turn.** Launch them all; do not throttle, wave, or count them yourself. Do **not** call `ScheduleWakeup`, sleep, or poll to wait for them — background agents are harness-tracked, so each completion re-invokes you automatically. (Never schedule a wakeup carrying an autonomous-loop prompt to "check back" — that starts a self-perpetuating loop.) Once every reviewer has written its report, continue to Step 5.

Pass each agent the required output format:

> Provide your findings in this exact format and write it to `.reviews/<session>/<reviewer-name>/<chunk-id>.md`:
>
> ```
> # <Your Agent Name> Report
> **Chunk**: <chunk-id>
> **Mode**: <mode>
> **Scope**: <scope>
>
> ## Critical
> - [ ] <finding> — <file/location>
>
> ## Major
> - [ ] <finding> — <file/location>
>
> ## Minor / Suggestions
> - [ ] <finding> — <file/location>
>
> ## No Issues
> <items confirmed clean within your scope, or "None">
> ```
>
> Use `- [ ]` for each unchecked finding. Do NOT use HTML comments or other markers.

## Step 5: Collation

Spawn a generic subagent with `model: haiku`. Substitute `<session>` as the **repo-relative** path `.reviews/<YYYY-MM-DD-HHMMSS>/` (never absolute — `review.md` is shared). The template is **mandatory and exact** — emit exactly these sections, in this order, with these heading texts verbatim. Do not rename, reorder, merge, split, or add sections. Do not append counts to any heading.

> Read all reviewer report files under `.reviews/<session>/*/*.md`. Write a consolidated review to `.reviews/<session>/review.md` reproducing this skeleton **exactly** — fill in the placeholders, change nothing else:
>
> ```markdown
> # Consolidated Review
>
> **Session**: `.reviews/<session>/`
>
> ## Summary Table
>
> | Reviewer | Chunk | Critical | Major | Minor |
> |----------|-------|----------|-------|-------|
> | <agent-name> | <chunk-id> | <count> | <count> | <count> |
> | **Total** | — | <sum> | <sum> | <sum> |
>
> ## Needs Human Input
>
> None
>
> ## Other findings
>
> ### Critical
>
> - [ ] <finding> — <file:line> (chunk <id>)
>
> ### Major
>
> - [ ] <finding> — <file:line> (chunk <id>)
>
> ### Minor / Suggestions
>
> - [ ] <finding> — <file:line> (chunk <id>)
> ```
>
> Rules for filling it in:
>
> - One Summary Table row per (reviewer, chunk) pair; the final `**Total**` row sums every cell above it.
> - Under `## Other findings`, place each finding under the **exact** severity heading it carries in its source file — never re-classify. Show its `[ ]`/`[x]` status and originating chunk. Drop the whole line, do not edit it. (A Minor finding may quote the marker mid-line in prose — keep those.)
> - `## Needs Human Input`: write `None`. This section is populated during Step 7 triage — not by the collation agent.
> - If a section has no items, keep its heading and write `None` below it. Never omit a heading.

## Step 6: Triage and fix (single pass)

Read the summary report. Triageable items are all findings in the **Critical** and **Major** sections. (Minor/Suggestions are never fixed here — they are recorded for the user.)

For each unchecked `- [ ]` triageable item:

- Apply the fix directly in code or documentation, then change its checkbox from `- [ ]` to `- [x]` in `review.md`.
- If a fix is ambiguous, risky, or needs a human decision (e.g. an architectural call), **leave the checkbox `- [ ]`** and move it to `review.md`'s `## Needs Human Input` section. Remove it from the original section.

There is **no loop**. Once you have triaged every report once and applied or deferred each fix, go to Step 7. Post-fix verification is delegated to the human review gate.

## Step 7: Report to user

Present a concise inline summary:

```
## Review Complete

**Session**: `.reviews/<session>/`
**Reviewers run**: <comma-separated agent names>
**Chunks**: <chunk count> (<chunk ids>)

### Issues Fixed
<numbered list of fixes applied, with file paths>

### Needs Human Input
<numbered list of items moved to Needs Human Input with reason>

### Minor / Suggestions (not actioned)
<brief list or count per reviewer>

**Full report**: `.reviews/<session>/review.md`
```

The **Needs Human Input** list must match `review.md`'s `## Needs Human Input` section exactly — same items, same count.

All findings are logged in the session folder for audit and transparency.
