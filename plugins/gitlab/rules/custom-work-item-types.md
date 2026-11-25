# Custom GitLab work item types

The `workItemType` enum of `mcp__gitlab__manage_work_item` accepts only built-in types (`ISSUE`, `TASK`, `EPIC`, `INCIDENT`, …). Use the MCP for those types.

The MCP cannot create the custom types `Bug`, `Ticket`, and `Tracker`. It also cannot change the type of a work item. Both operations need `glab api graphql`.

Use the `gitlab:custom-work-item-types` skill for these operations. Invoke it with the Skill tool. The skill carries the known type GIDs and the `workItemCreate` and `workItemConvert` mutations.
