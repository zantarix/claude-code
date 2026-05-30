"Ticket" is the umbrella term for any GitLab **work item** — most commonly an `Issue`, sometimes a `Task`, and potentially user-defined custom types as usage grows. It does not map directly to the legacy REST `/issues` resource.

**Why:** GitLab has moved its API surface from legacy Issues to Work Items. `Issue` is now one work-item *type* alongside `Task`, `Epic`, `Objective`, and custom types. Models trained before this shift reach for the older `/issues` REST endpoints (still available, but read-mostly and missing widget data for status, hierarchy, linked items, and custom fields).

**How to apply:** When acting on any work item — regardless of type — default to work-item APIs and MCP tools: `get_workitem_notes`, `workItemUpdate`, `workItemCreate`, `workItemAddLinkedItems`. Reach for legacy `/issues` endpoints only when the work-item API does not yet expose what you need (e.g. reading metadata that hasn't migrated).

See also: `ref-notation` for sigil meaning (`#N` = work item, `!N` = MR); `prefer-gitlab-mcp` for tool selection order.
