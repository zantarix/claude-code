---
name: post-mr-review
description: |-
  Reconcile a prior code review against the current branch state, then publish it to the
  GitLab MR as a single batched review: inline diff comments for findings in files the MR
  changed, and a summary comment (table + findings in untouched files) for the rest.
  Use after a review's fixes have been applied and you want to post the review to the MR.
---

Publish an existing review (e.g. `.reviews/<session>/review.md`) to the current branch's
GitLab merge request as one cohesive review.

## Key fact: post a *review*, not loose comments

GitLab supports batched reviews via **draft notes** (its "Merge Request Reviews" feature).
Stage every comment as a draft, then publish the whole batch at once so it lands as a single
review with one notification — not N disconnected comments.

- `mcp__gitlab__manage_draft_notes` action `create` — stage a draft. With a `position` it is an
  inline diff comment; without a `position` it is a general MR-level note.
- `mcp__gitlab__manage_draft_notes` action `publish_all` — submit the entire batch as one review.

Do **not** use `mcp__gitlab__manage_mr_discussion` (`comment`/`thread`) for this — those post
immediately and individually, which is the opposite of a review.

## Why reconciliation is mandatory

The review was produced against an *earlier* state of the code. Since then, fixes have been
applied, so:

- **Line numbers have drifted.** A finding citing `foo.rs:272` may now live at `foo.rs:427`
  because lines were inserted above it. Never trust the cited line number — re-locate the code.
- **Findings may be incidentally resolved.** A fix for one finding (or an unrelated edit) can
  silently resolve another. The review's `[x]`/`[ ]` markers reflect the moment of writing, not
  now. Re-read the current code for every finding you intend to post.

## Step 1: Identify the MR and its diff refs

```bash
git branch --show-current
```

Get the MR for this branch and capture `diff_refs` (`base_sha`, `start_sha`, `head_sha`):

- `mcp__gitlab__browse_merge_requests` action `get`, `branch_name: <branch>`.

`head_sha` is the **pushed** commit the MR points at. If you have local commits that are not
yet pushed, the MR diff is from the pushed `head_sha`, not your working tree. Either push first,
or reconcile line numbers against the pushed `head_sha` (`git show <head_sha>:<path>`), not the
working copy. State which you did.

**The head may have advanced.** Between when the review was written and now, the branch was very
likely pushed again (the fixes!), so `head_sha` is newer than what the review saw. Always re-fetch
`diff_refs` here and map every line number against the *current* `head_sha` — never reuse refs or
line numbers from an earlier point in the session. The draft-note API also overrides any stale
`head_sha` you pass with the MR's current one, so a mismatch silently anchors to the wrong place.

**MR state does not block this.** Draft notes stage and `publish_all` succeeds even on a **merged**
or closed MR — the diff and its line codes still resolve. Posting after merge is fine (it lands as
a normal review on the merged MR); just say so in the summary note so readers know it is a
for-the-record review rather than a merge gate.

## Step 2: List the MR's changed files (these define what's anchorable)

An inline note can attach to **any line of a file the MR changed** — not just lines inside a
hunk. GitLab's UI exposes this by letting you expand the diff up/down to an unchanged line, and
the API accepts the same: a position far outside any hunk is fine as long as the `line_code` is
valid (see Step 4). The real boundary is the **file**, not the hunk — a line in a file the MR did
*not* touch cannot be anchored at all and must go in the summary comment (Step 5).

```bash
git diff <base_sha>..<head_sha> --name-only      # files that CAN carry inline notes
git diff <base_sha>..<head_sha> --unified=0       # hunk headers, kept for the line mapping in Step 4
```

Keep the `--unified=0` output: the `@@ -oldStart,oldCount +newStart,newCount @@` headers are what
you use to translate a current (new-file) line number into its base (old-file) line number when a
finding lands on an unchanged line (Step 4).

## Step 3: Reconcile each finding

For every finding in the review, classify it:

1. **Re-locate** the cited code in the current tree (grep the symbol/text the finding describes,
   not the stale line number). Record the current `path:line`.
2. **Re-verify** the issue still exists by reading the current code. If a later fix resolved it,
   mark it **resolved** and drop it — even if the review marked it open.
3. **Classify location**: is the current line in a file the MR changed (Step 2 `--name-only`)?
   - Still-unresolved **and** in a changed file → inline draft note (Step 4), wherever in the
     file it sits (hunk or not).
   - Still-unresolved **and** in a file the MR did not touch → goes in the summary comment
     (Step 5); GitLab cannot anchor it to this MR.
   - Resolved → omit entirely.

Report the tally (posted inline / deferred to summary / dropped-as-resolved) so the human can
sanity-check.

## Step 4: Stage inline draft notes (unresolved findings in changed files)

For each, `mcp__gitlab__manage_draft_notes` action `create` with a `position`:

```
position: {
  base_sha, start_sha, head_sha,   # from Step 1
  new_path: "<file>",
  position_type: "text",
  new_line: <line>,                # the new-file line number
}
```

**Line-code gotcha (this will bite you):** the kind of line decides which fields are required.
GitLab computes a `line_code` from them; get it wrong and it rejects with
`400 ... Note {:line_code=>["must be a valid line code"]}`.

- **Added** line (a `+` line in a hunk) → `new_line` only.
- **Unchanged** line — *whether or not it sits in a hunk* → you MUST pass BOTH `old_path`+`old_line`
  AND `new_path`+`new_line`. This is the case for most reconciled findings, since they usually
  point at code the MR didn't itself change.
- **Deleted** line (a `-` line) → `old_path` + `old_line` only.

Computing `old_line` from a current `new_line`: walk the file's `--unified=0` hunk headers
(Step 2). For every hunk located **entirely above** the target line, accumulate
`delta += newCount - oldCount`. Then `old_line = new_line - delta` (so before the first hunk,
`old_line == new_line`). Verify by spot-checking that `git show <base_sha>:<path>` line `old_line`
is the same source text as the current line.

**Head caveat:** the API anchors the position against the MR's **current** head commit and will
override a stale `head_sha` you pass. So always reconcile line numbers against whatever is pushed
as the MR head right now — if you push more commits, the head advances and every `new_line` must
match the new head's version of the file. Re-fetch `diff_refs` (Step 1) after any push.

Keep each note's text faithful to the original finding (severity, reviewer, rationale). To offer
a committable code suggestion, embed a GitLab ```` ```suggestion ```` fenced block in the inline
note body — `manage_draft_notes` has no separate suggestion action, so a fenced block on a
positioned draft is how a review carries one.

## Step 5: Stage the summary draft note (general, no position)

One `create` with **no** `position`. Include:

- The review's summary table (reviewer / chunk / severity counts), verbatim.
- The still-unresolved findings that fell **outside** the diff (Step 3), so they are not lost —
  note explicitly that they concern pre-existing code not changed by this MR.
- Optionally a one-line note of how many findings were posted inline vs. dropped as resolved.

End with the attribution sign-off required by the org agent-role rule:

```
---
:robot: Submitted by Claude Code on behalf of this user.
```

## Step 6: Publish the review

`mcp__gitlab__manage_draft_notes` action `publish_all` for the MR. Confirm the published note
count matches what you staged, and report the MR URL.

If publishing fails partway, list remaining drafts with `mcp__gitlab__browse_mr_discussions`
action `drafts` (inspect one with action `draft`) — draft enumeration lives only here, not on
`manage_draft_notes`. Then either retry `publish_all` or `manage_draft_notes` action `delete` the
stragglers — do not leave a half-published review.
