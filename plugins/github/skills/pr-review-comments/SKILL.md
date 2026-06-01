---
name: pr-review-comments
description: Fetch open PR review comments with resolution status for the current branch.
---

Fetch all review thread comments for the current branch's PR, including which threads have been resolved.

## Why not the REST API

`gh api repos/{owner}/{repo}/pulls/{number}/comments` does **not** expose resolution status. Use the GraphQL API instead, which provides `reviewThreads.isResolved`.

## Steps

1. Determine owner and repo from the remote URL:
   ```bash
   git remote get-url origin
   # e.g. git@github.com:Equiem/zero.git → owner=Equiem, repo=zero
   ```

2. Find the PR number for the current branch:
   ```bash
   gh pr list --head $(git branch --show-current) --json number,url
   ```

3. Fetch review threads with resolution status:
   ```bash
   gh api graphql -f query='
   {
     repository(owner: "OWNER", name: "REPO") {
       pullRequest(number: PR_NUMBER) {
         reviewThreads(first: 50) {
           nodes {
             id
             isResolved
             comments(first: 1) {
               nodes {
                 path
                 originalLine
                 body
                 author { login }
               }
             }
           }
         }
       }
     }
   }'
   ```

4. Parse and display, grouping by resolved/unresolved. Each `node` in `reviewThreads.nodes` has:
   - `id`: the thread ID — use this to resolve threads via `resolveReviewThread` if needed
   - `isResolved`: boolean — true if the thread was resolved in the GitHub UI
   - `comments.nodes[0]`: the first (usually only) comment in the thread, with `path`, `originalLine`, `body`, `author.login`

## Output format

Present unresolved comments first with their file/line context, then list resolved ones briefly. Example:

```
## Open review comments (3)

1. [packages/foo/bar.ts:42] copilot: <comment body>
2. ...

## Resolved (1)

- [packages/foo/baz.ts:10] copilot: <comment body> ✓
```
