---
name: review
description: |-
  Run all *-reviewer agents concurrently, fix critical/major issues, and report results.
  Loops until no triagable findings remain. Stores all output under .reviews/.

  Proactively use this skill to review code you've created if you have added or modified more than two functions, or
  whenever you complete an implementation plan.
---

Review the current changes by running all available reviewer agents concurrently, fixing critical/major issues, and looping until no triagable findings remain.

## Step 1: Create review session

Create a timestamped session folder:
```
.reviews/<YYYY-MM-DD-HHMMSS>/
```

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

Read all report files from `run-<N>/`. Classify each finding by urgency:

| Agent | Triagable Items |
|-------|----------|
| `code-reviewer` | 🔴 Critical + 🟠 Major sections |
| `security-reviewer` | 🔴 Critical + 🟠 Major sections |
| `documentation-reviewer` | All findings (all severity levels are actionable) |
| Any other `*-reviewer` | 🔴 Critical + 🟠 Major sections, or any findings with "Critical", "Error", "Must fix", "Required" keywords |

**Important**: Minor/Suggestions never trigger loop iterations — they are recorded for the user to review in the final report.

## Step 5: Fix triagable items

For each unchecked `- [ ]` triagable item:
- Apply the fix directly in code or documentation.
- After fixing, update the checkbox in the report file from `- [ ]` to `- [x]`.
- If a fix is ambiguous, risky, or requires user input (e.g., architectural decision), **leave the checkbox as `- [ ]`** and append ` *(needs human input)*` to that line.

Do NOT fix minor/suggestions items.

## Step 6: Check loop condition

Read all report files from `run-<N>/`. Count the triagable items that were found in this run (items in Critical and Major sections).

If any triagable items were found (excluding those marked "needs human input") in the latest run **AND** `run < max_runs`:
- Increment `run` by 1.
- Return to Step 3.

Do not exit the loop if you fixed all the triagable items. Otherwise (no triagable items found, or max runs reached), proceed to Step 7.

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
