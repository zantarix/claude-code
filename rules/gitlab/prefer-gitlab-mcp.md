# GitLab tool selection

Prefer the GitLab MCP tools (`mcp__gitlab__*`) over the `glab` CLI for all GitLab operations (work items, MRs, pipelines, notes, etc.). Use the browse/manage tool pairs: `mcp__gitlab__browse_work_items` / `mcp__gitlab__manage_work_item`, `mcp__gitlab__browse_merge_requests` / `mcp__gitlab__manage_merge_request`, `mcp__gitlab__browse_mr_discussions` / `mcp__gitlab__manage_mr_discussion`, etc. Each takes an `action` parameter (`list`, `get`, `create`, `update`, …).

Fall back to `glab` only for what the MCP doesn't cover, and there prefer predefined subcommands (`glab mr view <iid>`, `glab issue view <iid>`) over `glab api`. Never use `curl` against the REST API directly.

Caveat: `glab mr note list --type diff` returns only diff notes; to fetch all discussion threads (including general comments) use the discussions endpoint (`glab api "projects/:fullpath/merge_requests/<iid>/discussions"`) or `mcp__gitlab__browse_mr_discussions`.
