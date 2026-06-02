# Custom GitLab work item types

The `mcp__gitlab__manage_work_item` tool only accepts built-in work item types via its enum (`ISSUE`, `TASK`, `EPIC`, …). Custom types — `Bug`, `Incident`, `Ticket`, `Tracker` — cannot be created or converted through the MCP and require `glab api graphql`.

**How to apply:**

When creating a work item of a custom type, or changing an existing item's type, invoke the `gitlab:custom-work-item-types` skill via the Skill tool — it carries the known type GIDs for this organisation and the `workItemCreate` / `workItemConvert` incantations. Don't reach for the MCP enum for these types; it will reject them.

See also: `prefer-gitlab-mcp` (the MCP enum limitation), `child-task-work-items`.
