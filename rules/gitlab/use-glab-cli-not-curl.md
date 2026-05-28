When fetching GitLab data (MR notes/comments, issue details, pipeline status, etc.), use the `glab` CLI rather than `curl` against the GitLab REST API directly.

**Why:** The user explicitly corrected a curl-based API call and directed use of `glab` instead.

**How to apply:** Use `glab mr note list <iid>`, `glab mr view <iid>`, `glab issue view <iid>`, etc. The MCP GitLab tools are preferred first; always us `glab api` and never `curl`.
