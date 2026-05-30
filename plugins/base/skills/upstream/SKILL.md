---
name: upstream
description: Commit changes, push the branch, and open a pull/merge request — the full "ship this branch" flow.
---

Push the current branch upstream and open a pull or merge request. Perform each step in order, stopping and reporting any failures.

## Step 1: Ensure you are on a feature branch

```bash
git branch --show-current
```

If already on a feature branch, proceed to Step 2.

If on `main` or `master`, derive a branch name from the staged/unstaged changes (e.g. `feat/add-upstream-skill`) and create it:

```bash
git checkout -b <branch-name>
```

Tell the user the name of the branch that was created before continuing.

## Step 2: Commit

Run the `/base:commit` skill. If it fails, stop and report the failure before proceeding.

## Step 3: Push

Push the current branch to the remote:

```bash
git push --set-upstream origin $(git branch --show-current)
```

If the push fails (e.g. the branch is behind the remote), report the error and stop — do not force-push.

## Step 4: Open a pull or merge request

Determine the hosting platform:

1. **From installed plugins** — check which platform plugin is active in this project (`.claude/settings.json` or equivalent). If only `github` is present, use `/github:create-pull-request`. If only `gitlab` is present, use `/gitlab:create-merge-request`.
2. **From the remote URL** (fallback) — if both or neither plugin is present, inspect the `origin` remote:
   ```bash
   git remote get-url origin
   ```
   Use `/github:create-pull-request` for `github.com` URLs and `/gitlab:create-merge-request` for all others.
3. **Ask the user** if the platform still cannot be determined.
