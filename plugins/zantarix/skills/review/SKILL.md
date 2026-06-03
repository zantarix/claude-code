---
name: review
description: |-
  Run all *-reviewer agents concurrently, fix critical/major issues, and report results.
  Re-runs the reviewers after each fix round, stopping only when a run surfaces no new
  critical/major findings to fix. Stores all output under .reviews/.

  Proactively use this skill to review code you've created if you have added or modified more than two functions, or
  whenever you complete an implementation plan.
---

Review the current changes by running all available reviewer agents concurrently, fixing critical/major issues, and looping until no triageable findings remain.

## Step 1: Create review session

Create a timestamped session folder:

```
.reviews/<YYYY-MM-DD-HHMMSS>/
```

> **Note**: `.reviews/` is expected to be in `.gitignore`. If it is not present, add it before proceeding.

Use `date +%Y-%m-%d-%H%M%S` to generate the timestamp.

Initialize a loop counter: `run = 1`, `max_runs = 5`.

## Step 2: Discover reviewers

Find all available, pre-defined agents — using only system context — with a name that ends with `-reviewer`. Do not try to search the file system for reviewers. Each matching agent is a reviewer to launch.

## Step 3: Launch reviewers and collect output

Create the run directory:

```
.reviews/<session>/run-<N>/
```

Launch every discovered reviewer agent **in parallel** using the Agent tool. Pass each agent a prompt describing the scope of the review (e.g., uncommitted changes, recent commits on the branch) and the required output format:

> Please provide your findings in this exact format (return as text):
>
> ```
> # <Your Agent Name> Report
> **Run**: <N>
>
> ## Critical
> - [ ] <finding description> — <file/location>
> - [ ] <finding description> — <file/location>
>
> ## Major
> - [ ] <finding description> — <file/location>
>
> ## Minor / Suggestions
> - [ ] <finding description>
>
> ## No Issues
> <items confirmed clean, or "None">
> ```
>
> Use `- [ ]` for each unchecked finding. Do NOT use HTML comments or other markers.

After all agents return, write each result to a file:

```
.reviews/<session>/run-<N>/<agent-name>.md
```

## Step 4: Triage findings

Read all report files from `run-<N>/`. Triageable items are all findings in the **Critical** and **Major** sections.

Note the triage count for this run **before fixing anything**: the number of Critical + Major findings across this run's reports. This feeds the per-run summary table in Step 7. The loop decision itself is driven by how many of these you actually fix (`fixed_this_run`, recorded in Step 5) — not by re-counting checkboxes after the fact.

**Important**: Minor/Suggestions never trigger loop iterations — they are recorded for the user to review in the final report.

## Step 5: Fix triageable items

For each unchecked `- [ ]` triageable item:

- Apply the fix directly in code or documentation.
- After fixing, update the checkbox in the report file from `- [ ]` to `- [x]`.
- If a fix is ambiguous, risky, or requires user input (e.g., architectural decision), **leave the checkbox as `- [ ]`** and append `*(needs human input)*` to that line.

Do NOT fix minor/suggestions items.

**The `*(needs human input)*` lines in the `run-N` report files are the single source of truth for the "needs human attention" list.** Every downstream view — the `review.md` collation (Step 7) and the inline summary (Step 8) — must reproduce *exactly* that set: same items, same count, same severity heading. Never re-derive, re-classify, or re-count the set downstream; only ever copy it. A Critical that needs human input stays a Critical; a Minor is never in this set.

Record `fixed_this_run` = the number of items you marked `- [x]` in this step. This is the signal that decides whether to loop (Step 6).

## Step 6: Check loop condition

Fixing code in Step 5 can introduce regressions or reveal findings that were hidden behind the issues you just fixed, so **every fix round must be verified by re-running the reviewers against the updated code.** Do NOT treat "I fixed everything in this run" as a reason to stop — that is the most common failure of this skill. You may only finish from a run in which you fixed nothing.

Decide using the values you recorded, not by re-reading and re-counting the (now mutated) checkboxes:

If `fixed_this_run > 0` **AND** `run < max_runs`:

- Increment `run` by 1.
- Return to Step 3. This re-launches all reviewers against the code as it now stands, including your fixes.

Proceed to Step 7 only when either:

- `fixed_this_run == 0` — this run made no fixes, meaning it was clean or its only remaining items are marked `*(needs human input)*`. This is the verifying run that confirms the previous round's fixes hold. (Note: a run whose findings are *all* needs-human-input also stops here — re-running would surface the identical findings on unchanged code.) **Or**
- `run == max_runs` — in this case, annotate any remaining unchecked `- [ ]` triageable items across all run reports with `*(needs human input)*`.

## Step 7: Final collation

First, mechanically extract the authoritative needs-human-input set across **all runs'** reports. Do not eyeball it — run:

```
grep -rh '\*(needs human input)\*[[:space:]]*$' .reviews/<session>/run-*/ | sed 's/[[:space:]]*\*(needs human input)\*[[:space:]]*$//'
```

Two details matter:

- **Anchor to end of line (`…$`).** Step 5 *appends* the marker, so a real annotation is always the last thing on its line. When this skill reviews itself a finding may quote the marker in its prose (e.g. `` `*(needs human input)*` `` inside a code span), but that sits mid-line with a closing backtick after it — `$` excludes it. Matching the marker anywhere on the line caused false positives.
- **`-h` plus the `sed`.** `-h` drops the filename prefix so the session's absolute, username-bearing audit path never leaks into the shared `review.md`; the `sed` then strips the marker itself — internal jargon, meaningless to an external PR/MR reviewer. The run-N source files keep their markers for the drop rule below.

Scan **all** runs (`run-*/`), not just the last one: the reviewer agents are non-deterministic, so an item flagged in one run may be absent from another. Duplication across runs is acceptable here — a repeated needs-human item is harmless, but a dropped one is not. Record the output line count as `needs_human`. These exact lines are the canonical list; paste them into the prompt below so the collation **copies** them rather than re-deriving them.

Spawn a generic subagent with `model: haiku` using the Agent tool. Pass this prompt with the grep output substituted in, and substitute `<session>` as the **repo-relative** path `.reviews/<YYYY-MM-DD-HHMMSS>/` (never an absolute path — `review.md` is shared). The template below is **mandatory and exact** — emit exactly these sections, in this order, with these heading texts verbatim. Do not rename, reorder, merge, split, or add sections (no `## Summary`, no `## No Issues`, no run-count in the title). Do not append finding counts to any heading.

> Read all reviewer report files under `.reviews/<session>/run-*/`. Write a consolidated review to `.reviews/<session>/review.md` reproducing this skeleton **exactly** — fill in the placeholders, change nothing else:
>
> ```markdown
> # Consolidated Review
>
> **Session**: `.reviews/<session>/`
> **Runs**: <highest run number>
>
> ## Summary Table
>
> | Reviewer | Run | Critical | Major | Minor |
> |----------|-----|----------|-------|-------|
> | <agent-name> | <n> | <count> | <count> | <count> |
> | **Total** | — | <sum> | <sum> | <sum> |
>
> ## Needs Human Input
>
> <canonical lines, pasted verbatim>
>
> ## Other findings
>
> ### Critical
>
> - [ ] <finding> — <file:line> (run <n>)
>
> ### Major
>
> - [ ] <finding> — <file:line> (run <n>)
>
> ### Minor / Suggestions
>
> - [ ] <finding> — <file:line> (run <n>)
>
> ### Auto-Fixed Items
>
> - [x] <finding> — <file:line>
> ```
>
> Rules for filling it in:
>
> - One Summary Table row per (reviewer, run) pair; the final `**Total**` row sums every cell above it.
> - Under `## Other findings`, in `### Critical`, `### Major`, `### Minor / Suggestions`: place each finding under the **exact** severity heading it carries in its source `run-N` file — never re-classify. Show its `[ ]`/`[x]` status and originating run. **Omit entirely any line that *ends with* the `*(needs human input)*` marker** — drop the whole line, do not edit it. (Match only the marker at end of line: a Minor finding may quote the marker mid-line in its prose — keep those.) The dropped findings already appear in the `## Needs Human Input` section above; dropping them here keeps each finding in exactly one section. The marker exists only in the run-N source files — it never appears in `review.md`.
> - `### Auto-Fixed Items` (under `## Other findings`): every finding marked `[x]`, across all runs.
> - `## Needs Human Input`: reproduce these lines verbatim — do not add, drop, re-label, or change the severity of any. This section must contain exactly <needs_human> items: <paste the grep output here>
> - If a section has no items, keep its heading and write `None` on the line below it. Never omit a heading.

## Step 8: Report to user

Present a concise inline summary:

```
## Review Complete

**Session**: `.reviews/<session>/`
**Runs**: <N> / <max_runs>
**Reviewers run**: <comma-separated agent names>

### Issues Fixed
<numbered list of fixes applied, with file paths>

### Needs Human Attention
<numbered list of items marked "needs human input" with reason>

### Minor / Suggestions (not actioned)
<brief list or count per agent>

**Full report**: `.reviews/<session>/review.md`
```

The **Needs Human Attention** list must contain exactly the `needs_human` items from Step 7 — the same lines, the same count, with their original severity. It is a copy of the canonical set, not a fresh judgement. Before presenting, re-run the Step 7 grep and confirm its line count equals both this list's count and `review.md`'s Needs Human Input count. If the three diverge, the `run-N` files win — recount from them and correct the summary before reporting.

All findings and iterations are logged in the session folder for audit and transparency.
