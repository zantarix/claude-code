---
name: capture-eval-case
description: Capture the current session as a raw, private eval-case bundle — transcript, repo state, edits, environment and instructions — cut at the point this skill is invoked. Use when a session is worth turning into an eval case, usually because something went wrong.
disable-model-invocation: true
---

Record everything needed to recreate an eval case from this session, cut at the user entry that invoked this skill. The bundle is raw: no task, brief, tags or grading. Perform each step in order, stopping and reporting any failure. The format is described in [FORMAT.md](FORMAT.md).

The capture is read-only on every repo and private by default. Never commit, stash or check anything out for it, and never suggest committing or publishing the bundle.

## Step 1: Check the session

Confirm `CLAUDE_CODE_SESSION_ID` is set and that the transcript exists:

```bash
ls "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/projects/*/"$CLAUDE_CODE_SESSION_ID".jsonl
```

If either is missing, stop and say so. The `<id>/` sidecar folder (subagents, tool results) only exists once a subagent has run or a large tool result has been written, so its absence is not an error.

## Step 2: Ask for a note

Ask one question with `AskUserQuestion`: why is this session interesting, and what went wrong? Offer "Skip note" as an option; the answer comes through "Other". Write the answer verbatim to a file in the scratchpad directory, with no classification or rewording. Skip the file if the user skipped the note.

## Step 3: Run the script

```bash
${CLAUDE_SKILL_DIR}/capture-eval-case.sh [--out <path>] [--note-file <note file>]
```

Pass `--out` only if the user gave an output path as an argument; otherwise the bundle goes to `~/.claude/eval-captures/<timestamp>-<session-id-prefix>/`. The script copies everything first, cuts the copies, hashes them, and writes a `.tar.xz` beside the bundle directory. If it fails, report the error and stop.

## Step 4: Report

Give the bundle path and size, the `.tar.xz` path and size, every repo captured, any subagents recorded as incomplete, and the script's warnings. Remind the user that the bundle holds full transcripts and settings and is private.
