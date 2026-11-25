---
name: create-merge-request
description: |-
  Create a GitLab merge request for the current branch, describing the changes made.
  Adds a `Closes #N` line when the work implements a work item.
  If /zantarix:review was run in this session and the session folder is known, posts the review to the MR as a batched draft-note review via the `gitlab:post-mr-review` skill.
  Use proactively whenever the user asks to create an MR or merge request.
---

Create a merge request for the current branch on GitLab.

## Step 1: Determine the current branch and target branch

```bash
git branch --show-current
```

If on `main` or `master`, stop and tell the user you cannot create an MR from the default branch.

Determine the target/base branch. Check if the branch has an upstream:

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null | sed 's|origin/||'
```

Fall back to `main` if no upstream is configured.

## Step 2: Check whether an MR already exists

Get the project path from the remote. Use it as `project_id` in all MCP calls below:

```bash
git remote get-url origin | sed -E 's#^(https?://[^/]+/|ssh://([^@/]+@)?[^/]+/|[^@/]+@[^:]+:)##; s#\.git$##'
```

List the open MRs for the branch:

```
mcp__gitlab__browse_merge_requests
  action: list
  project_id: <project path>
  source_branch: <branch>
  state: opened
```

If the result is not empty, report the existing MR URL to the user and stop. Do not create a duplicate. Do not use `action: get` with `branch_name` for this check. It also returns merged MRs.

## Step 3: Summarise the changes

Collect the commit log and diff stats relative to the target branch:

```bash
git log <target>..<branch> --oneline
git diff <target>..<branch> --stat
```

Use this to draft the MR title and body:

- **Title**: Use the single commit's subject if there is only one; otherwise write a short summary that captures the overall theme.
- **Summary**: 2–4 bullet points describing what changed and why.
- **Test plan**: A brief markdown checklist of what was tested or verified (e.g. ran verify, reviewed output).
- **Closes**: If this MR implements a specific work item, include a `Closes #N` line in the body so GitLab auto-closes the work item on merge. Infer the work item number from the plan or context — the user's request, the branch name, or earlier conversation. Omit if no work item is clearly associated.

## Step 4: Check for a session review

Check whether `/zantarix:review` was run earlier in this conversation and the session folder path is already known from context (e.g. `.reviews/2026-05-29-200316/`). Do **not** scan the filesystem — `.reviews/` accumulates folders from many branches and sessions, so a filesystem search would pick up stale reviews.

If the session folder is known, the review is at `<session>/review.md`. Read its full contents — they will be handed to the `gitlab:post-mr-review` skill for posting after MR creation.

If no session folder is known from this conversation, skip the comment step entirely.

## Step 5: Create the MR

```
mcp__gitlab__manage_merge_request
  action: create
  project_id: <project path>
  source_branch: <branch>
  target_branch: <target>
  remove_source_branch: true
  title: "<title>"
  description: |
    ## Summary

    - <bullet>
    - <bullet>

    ## Test plan

    - [ ] <item>

    Closes #<number>  ← replace with actual work item number; omit this line entirely if no work item is associated

    ---
    :robot: Submitted by Claude Code on behalf of this user.
```

Record the `iid` and `web_url` from the response.

## Step 6: Post the review as a comment (if found)

If a `review.md` was found in Step 4, post it to the new MR using the `/gitlab:post-mr-review` skill.

## Step 7: Report to the user

Report the MR URL and IID. If a review comment was posted, mention it. If there were Minor/Suggestions findings in the review that were not actioned, highlight them here so the user is aware.
