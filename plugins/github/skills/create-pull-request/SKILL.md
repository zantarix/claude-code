---
name: create-pull-request
description: |-
  Create a GitHub pull request for the current branch, describing the changes made.
  If /review was run in this session and the session folder is known, posts the review summary as a comment.
  Use proactively whenever the user asks to create a PR or pull request.
---

Create a pull request for the current branch on GitHub.

## Step 1: Determine the current branch and target branch

```bash
git branch --show-current
```

If on `main` or `master`, stop and tell the user you cannot create a PR from the default branch.

Determine the target/base branch. Check if the branch has an upstream:

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null | sed 's|origin/||'
```

Fall back to `main` if no upstream is configured.

## Step 2: Check whether a PR already exists

```bash
gh pr list --head $(git branch --show-current) --json number,url
```

If a PR already exists, report its URL to the user and stop — do not create a duplicate.

## Step 3: Summarise the changes

Collect the commit log and diff stats relative to the target branch:

```bash
git log <target>..<branch> --oneline
git diff <target>..<branch> --stat
```

Use this to draft the PR title and body:

- **Title**: Use the single commit's subject if there is only one; otherwise write a short summary that captures the overall theme.
- **Summary**: 2–4 bullet points describing what changed and why.
- **Test plan**: A brief markdown checklist of what was tested or verified (e.g. ran verify, reviewed output).

## Step 4: Check for a session review summary

Check whether `/review` was run earlier in this conversation and the session folder path is already known from context (e.g. `.reviews/2026-05-29-200316/`). Do **not** scan the filesystem — `.reviews/` accumulates folders from many branches and sessions, so a filesystem search would pick up stale reviews.

If the session folder is known, the review summary is at `<session>/review.md`. Read its full contents — it will be posted as a comment after PR creation.

If no session folder is known from this conversation, skip the comment step entirely.

## Step 5: Create the PR

```bash
gh pr create \
  --title "<title>" \
  --base <target> \
  --body "$(cat <<'EOF'
## Summary

- <bullet>
- <bullet>

## Test plan

- [ ] <item>

---
:robot: Submitted by Claude Code on behalf of this user.
EOF
)"
```

After the command succeeds, capture the PR number from the command output or by querying:

```bash
gh pr list --head $(git branch --show-current) --json number,url | jq '.[0]'
```

## Step 6: Post the review summary as a comment (if found)

If a `review.md` was found in Step 4, post it as a comment on the PR:

```bash
gh pr comment <number> --body "$(cat <<'EOF'
## Automated Review Summary

<contents of review.md>

---
:robot: Submitted by Claude Code on behalf of this user.
EOF
)"
```

## Step 7: Report to the user

Report the PR URL and number. If a review comment was posted, mention it. If there were Minor/Suggestions findings in the review that were not actioned, highlight them here so the user is aware.
