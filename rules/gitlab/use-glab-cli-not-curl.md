When fetching GitLab data (MR notes/comments, issue details, pipeline status, etc.), use the `glab` CLI rather than `curl` against the GitLab REST API directly.

**Why:** The user explicitly corrected a curl-based API call and directed use of `glab` instead.

**How to apply:** The MCP GitLab tools are preferred first. When CLI is needed, use `glab mr view <iid>`, `glab issue view <iid>`, `glab api "projects/:fullpath/merge_requests/<iid>/discussions"`, etc. Always use `glab api` and never `curl`. Note: `glab mr note list --type diff` only returns diff notes; to fetch all discussion threads (including general comments) use the discussions endpoint or `mcp__gitlab__browse_mr_discussions`.
