# GitLab tool selection

Use the GitLab MCP tools (`mcp__gitlab__*`) for all GitLab operations. Use the browse/manage tool pairs:

- `mcp__gitlab__browse_work_items` / `mcp__gitlab__manage_work_item`
- `mcp__gitlab__browse_merge_requests` / `mcp__gitlab__manage_merge_request`
- `mcp__gitlab__browse_mr_discussions` / `mcp__gitlab__manage_mr_discussion`

Other operations follow the same pattern. Each tool takes an `action` parameter (`list`, `get`, `create`, `update`, …). MR and discussion tools need a `project_id`. Get the project path from `git remote get-url origin`.

The MCP does not support these operations. Use `glab api graphql` for them, through the skill or rule named in each item:

- Read the status of a work item, or set a status other than `Done` (`gitlab:set-work-item-status`).
- Create a `Bug`, `Ticket`, or `Tracker` work item, or change the type of a work item (`gitlab:custom-work-item-types`).
- Comment on an Epic or another group-level work item (see `glab-api-gotchas`).

For any other operation that the MCP does not support, use a predefined `glab` subcommand (for example `glab mr view <iid>`). Use `glab api` only when no subcommand exists.

Never use `curl` against the REST API directly.
