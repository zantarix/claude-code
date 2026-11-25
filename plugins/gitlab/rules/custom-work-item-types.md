# Custom GitLab work item types

The `mcp__gitlab__manage_work_item` tool accepts only built-in types in its enum (`ISSUE`, `TASK`, `EPIC`, …). It cannot create or convert the custom types `Bug`, `Incident`, `Ticket`, and `Tracker`. Those types need `glab api graphql`.

Use the `gitlab:custom-work-item-types` skill to create a work item of a custom type or to change the type of a work item. Invoke it with the Skill tool. The skill carries the known type GIDs and the `workItemCreate` and `workItemConvert` mutations. Do not use the MCP enum for these types. It rejects them.
