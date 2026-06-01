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

Spawn a generic subagent with `model: haiku` using the Agent tool. Pass this prompt:

> Read all reviewer report files under `.reviews/<session>/`. Create a consolidated review at `.reviews/<session>/review.md` with:
>
> 1. **Summary table**: rows = reviewer agents, columns = run number and finding count per run. Show how many critical, major, and minor findings each reviewer reported in each run.
> 2. **Findings by Severity**: Group all findings (across all runs and reviewers) by severity (Critical, Major, Minor). For each, show the `[ ]` or `[x]` status and which run it appeared in.
> 3. **Auto-Fixed Items**: List all findings marked `[x]`.
> 4. **Needs Human Input**: List findings marked "needs human input" — these were not auto-fixed.
> 5. **Minor / Suggestions Not Actioned**: Summary of all minor/suggestions that were never looped on.
>
> Format as clean markdown. Include counts and cross-references to the original reports in `run-N/` folders.

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

All findings and iterations are logged in the session folder for audit and transparency.
