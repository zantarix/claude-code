Prefer the GitLab MCP tools (`mcp__gitlab__*`) over the `glab` CLI for GitLab operations.

**Why:** The user has pre-approved many MCP actions, so they run without permission prompts and integrate better. `glab` is a fallback only.

**How to apply:** For work items, MRs, pipelines, notes, etc., use the browse/manage tool pairs: `mcp__gitlab__browse_work_items` / `mcp__gitlab__manage_work_item`, `mcp__gitlab__browse_merge_requests` / `mcp__gitlab__manage_merge_request`, `mcp__gitlab__browse_mr_discussions` / `mcp__gitlab__manage_mr_discussion`, etc. Each tool takes an `action` parameter (e.g. `list`, `get`, `create`, `update`). Only fall back to `glab` for things the MCP doesn't cover. When using the `glab` CLI, prefer predefined subcommands over `glab api` for arbitrary queries.
