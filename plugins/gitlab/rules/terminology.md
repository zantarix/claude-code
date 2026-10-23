"Ticket" is the umbrella term for any GitLab **work item** — most commonly an `Issue`, sometimes a `Task`, plus `Epic`, `Objective`, and custom types. `Issue` is now one work-item *type*, not the legacy REST `/issues` resource.

When acting on any work item, regardless of type, default to work-item APIs and MCP tools: `get_workitem_notes`, `workItemUpdate`, `workItemCreate`, `workItemAddLinkedItems`. Reach for legacy `/issues` endpoints only when the work-item API does not yet expose what you need — they are read-mostly and miss widget data for status, hierarchy, linked items, and custom fields.

See also: `ref-notation` (`#N` = work item, `!N` = MR); `prefer-gitlab-mcp` (tool selection order).
