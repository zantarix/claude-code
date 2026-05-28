Prefer the GitLab MCP tools (`mcp__gitlab__*`) over the `glab` CLI for GitLab operations.

**Why:** The user has pre-approved many MCP actions, so they run without permission prompts and integrate better. `glab` is a fallback only.

**How to apply:** For issues, MRs, pipelines, notes, etc., reach for `mcp__gitlab__get_issue`, `mcp__gitlab__get_workitem_notes`, `mcp__gitlab__get_merge_request`, etc. Only fall back to `glab` for things the MCP doesn't cover. When using the `glab` cli, prefer predefined commands that the cli defines over `glab api` to run arbitrary api queries.
